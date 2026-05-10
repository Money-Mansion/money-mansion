import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/logging/developer_log_service.dart';
import '../../developer/data/developer_settings_service.dart';
import '../../developer/developer_config.dart';
import '../data/android_apk_installer.dart';
import '../data/apk_downloader.dart';
import '../data/github_release_service.dart';
import '../models/update_check_result.dart';
import '../models/update_manifest.dart';
import '../presentation/download_progress_dialog.dart';
import '../presentation/update_dialog.dart';
import 'version_checker.dart';

class UpdateService {
  UpdateService._({
    GitHubReleaseService? github,
    ApkDownloader? downloader,
    AndroidApkInstaller? installer,
    VersionChecker? versionChecker,
    DeveloperSettingsService? settings,
  })  : _github = github ?? GitHubReleaseService(),
        _downloader = downloader ?? ApkDownloader(),
        _installer = installer ?? AndroidApkInstaller(),
        _versionChecker = versionChecker ?? VersionChecker(),
        _settings = settings ?? DeveloperSettingsService.instance;

  static final instance = UpdateService._();

  final GitHubReleaseService _github;
  final ApkDownloader _downloader;
  final AndroidApkInstaller _installer;
  final VersionChecker _versionChecker;
  final DeveloperSettingsService _settings;

  bool _startupCheckRunning = false;

  Future<UpdateCheckResult> checkForUpdates({bool manual = false}) async {
    final current = await _versionChecker.getInstalledVersion();

    if (!DeveloperConfig.dashboardEnabled) {
      return UpdateCheckResult(
        status: UpdateCheckStatus.disabled,
        currentVersion: current.version,
        currentBuild: current.build,
        message: 'Developer features are disabled in this build.',
      );
    }

    final token = await _settings.loadGithubToken();
    if (token == null) {
      return UpdateCheckResult(
        status: UpdateCheckStatus.missingToken,
        currentVersion: current.version,
        currentBuild: current.build,
        message: 'Add a GitHub token in Developer Dashboard first.',
      );
    }

    try {
      final manifest = await _github.fetchLatestManifest(token: token);
      final hasUpdate = _versionChecker.isNewer(manifest, current);
      await _settings.markCheckSucceeded();
      return UpdateCheckResult(
        status: hasUpdate
            ? UpdateCheckStatus.updateAvailable
            : UpdateCheckStatus.upToDate,
        manifest: manifest,
        currentVersion: current.version,
        currentBuild: current.build,
        message: hasUpdate ? null : 'Already on the latest developer release.',
      );
    } catch (error, stackTrace) {
      DeveloperLogService.error(
        'Update check failed',
        error: error,
        stackTrace: stackTrace,
      );
      await _settings.markCheckFailed(error.toString());
      return UpdateCheckResult(
        status: UpdateCheckStatus.error,
        currentVersion: current.version,
        currentBuild: current.build,
        message: error.toString(),
      );
    }
  }

  Future<void> maybeCheckOnStartup(BuildContext context) async {
    if (!DeveloperConfig.dashboardEnabled) return;
    if (_startupCheckRunning) return;
    final settings = await _settings.loadSettings();
    if (!settings.autoCheckOnStartup) return;
    if (!_shouldRunBackgroundCheck(settings.lastCheckAt)) return;

    _startupCheckRunning = true;
    try {
      final result = await checkForUpdates();
      if (!context.mounted || !result.hasUpdate || result.manifest == null) {
        return;
      }
      final currentSettings = await _settings.loadSettings();
      if (currentSettings.autoDownload) {
        await showDownloadProgressDialog(
          context: context,
          manifest: result.manifest!,
          updateService: this,
        );
      } else {
        await showUpdateDialog(
          context: context,
          result: result,
          settings: currentSettings,
          updateService: this,
        );
      }
    } finally {
      _startupCheckRunning = false;
    }
  }

  Future<File> downloadUpdate({
    required UpdateManifest manifest,
    DownloadProgress? onProgress,
  }) async {
    if (!manifest.supportsInternalUpdater) {
      throw Exception(
        'This build does not include the internal updater and cannot be installed from Developer Dashboard.',
      );
    }

    final token = await _settings.loadGithubToken();
    if (token == null) {
      throw Exception('GitHub token is missing');
    }
    return _downloader.download(
      manifest: manifest,
      token: token,
      onProgress: onProgress,
    );
  }

  Future<List<UpdateManifest>> listSwitchableBuilds() async {
    final token = await _settings.loadGithubToken();
    if (token == null) {
      throw Exception('GitHub token is missing');
    }
    return _github.fetchAvailableManifests(token: token);
  }

  Future<void> installApk(File apkFile) async {
    await _installer.install(apkFile);
  }

  Future<void> clearUpdateCache() async {
    await _downloader.clearCache();
  }

  bool _shouldRunBackgroundCheck(DateTime? lastCheckAt) {
    if (lastCheckAt == null) return true;
    return DateTime.now().difference(lastCheckAt) > const Duration(hours: 6);
  }
}
