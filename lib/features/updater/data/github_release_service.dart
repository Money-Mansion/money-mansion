import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/logging/developer_log_service.dart';
import '../../developer/developer_config.dart';
import '../domain/update_exception.dart';
import '../models/update_manifest.dart';

class GitHubReleaseService {
  GitHubReleaseService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _apiVersion = '2022-11-28';
  static const _versionAssetName = 'version.json';

  Future<void> verifyRepositoryAccess({required String token}) async {
    await _withRetry(
      () => _dio.get<Map<String, dynamic>>(
        'https://api.github.com/repos/${DeveloperConfig.githubOwner}/${DeveloperConfig.githubRepo}',
        options: Options(headers: _jsonHeaders(token)),
      ),
      'GitHub repository access check',
      notFoundMessage:
          'GitHub repo was not found or this token cannot access it.',
    );
  }

  Future<UpdateManifest> fetchLatestManifest({required String token}) async {
    final releaseData = await _fetchLatestReleaseData(token: token);
    return _manifestFromReleaseData(releaseData: releaseData, token: token);
  }

  Future<List<UpdateManifest>> fetchAvailableManifests({
    required String token,
  }) async {
    final releases = await _fetchReleaseList(token: token, perPage: 50);
    final manifests = <UpdateManifest>[];
    for (final releaseData in releases) {
      if (releaseData['draft'] == true) continue;
      final assets = (releaseData['assets'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
      if (_findAsset(assets, _versionAssetName) == null) continue;
      try {
        manifests.add(
          await _manifestFromReleaseData(
            releaseData: releaseData,
            token: token,
          ),
        );
      } on UpdateException catch (error) {
        DeveloperLogService.warning(
          'Skipping unusable release ${releaseData['tag_name']}: $error',
        );
      }
    }
    if (manifests.isEmpty) {
      throw const UpdateException(
        'No switchable builds were found. Run the internal release workflow on each branch or commit you want to install.',
      );
    }
    return manifests;
  }

  Future<UpdateManifest> _manifestFromReleaseData({
    required Map<String, dynamic> releaseData,
    required String token,
  }) async {
    final assets = (releaseData['assets'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final versionAsset = _findAsset(assets, _versionAssetName);
    if (versionAsset == null) {
      throw const UpdateException(
        'Latest GitHub Release has no version.json asset.',
      );
    }

    final manifestBytes = await downloadReleaseAssetBytes(
      assetApiUrl: versionAsset['url'] as String,
      token: token,
    );
    final manifestJson = jsonDecode(utf8.decode(manifestBytes));
    if (manifestJson is! Map<String, dynamic>) {
      throw const UpdateException('version.json is not a JSON object.');
    }

    final manifest = UpdateManifest.fromJson(manifestJson);
    if (!manifest.supportsInternalUpdater) {
      throw const UpdateException(
        'This release does not declare internal updater support. Build it from the internal updater branch before installing.',
      );
    }

    final apkAssetName =
        manifest.apkAssetName ?? _assetNameFromUrl(manifest.apkUrl);
    final apkAsset = apkAssetName == null
        ? _findFirstApkAsset(assets)
        : _findAsset(assets, apkAssetName);

    if (apkAsset == null && manifest.apkUrl == null) {
      throw const UpdateException(
        'version.json must contain apk_url or apk_asset_name.',
      );
    }

    return manifest.copyWith(
      releaseTag: releaseData['tag_name'] as String?,
      releaseHtmlUrl: releaseData['html_url'] as String?,
      versionAssetApiUrl: versionAsset['url'] as String?,
      apkAssetApiUrl: apkAsset?['url'] as String?,
      apkUrl: manifest.apkUrl ?? apkAsset?['browser_download_url'] as String?,
      apkAssetName: manifest.apkAssetName ?? apkAsset?['name'] as String?,
      releaseCreatedAt: _parseGitHubDate(
        releaseData['published_at'] as String? ??
            releaseData['created_at'] as String?,
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchLatestReleaseData({
    required String token,
  }) async {
    try {
      final latest = await _withRetry(
        () => _dio.get<Map<String, dynamic>>(
          'https://api.github.com/repos/${DeveloperConfig.githubOwner}/${DeveloperConfig.githubRepo}/releases/latest',
          options: Options(headers: _jsonHeaders(token)),
        ),
        'GitHub latest release',
        notFoundMessage:
            'No published GitHub Release was found. Run the internal release workflow once, or create a non-draft release with version.json and app-release.apk.',
      );
      final latestData = latest.data;
      if (latestData == null) {
        throw const UpdateException(
            'GitHub returned an empty release response.');
      }
      return latestData;
    } on UpdateException catch (error) {
      if (!error.message.startsWith('No published GitHub Release')) rethrow;
      return _fetchNewestReleaseFromList(token: token);
    }
  }

  Future<Map<String, dynamic>> _fetchNewestReleaseFromList({
    required String token,
  }) async {
    final releaseList = await _fetchReleaseList(token: token, perPage: 20);
    for (final release in releaseList) {
      if (release['draft'] == true) continue;
      final assets = (release['assets'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList();
      if (_findAsset(assets, _versionAssetName) != null) return release;
    }

    throw const UpdateException(
      'No usable GitHub Release was found. Run the internal release workflow and make sure the release contains version.json and app-release.apk.',
    );
  }

  Future<List<Map<String, dynamic>>> _fetchReleaseList({
    required String token,
    required int perPage,
  }) async {
    final releases = await _withRetry(
      () => _dio.get<List<dynamic>>(
        'https://api.github.com/repos/${DeveloperConfig.githubOwner}/${DeveloperConfig.githubRepo}/releases?per_page=$perPage',
        options: Options(headers: _jsonHeaders(token)),
      ),
      'GitHub releases list',
      notFoundMessage:
          'GitHub releases could not be found for this repository.',
    );

    return (releases.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Future<List<int>> downloadReleaseAssetBytes({
    required String assetApiUrl,
    required String token,
  }) async {
    final response = await _withRetry(
      () => _dio.get<List<int>>(
        assetApiUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: _assetHeaders(token),
          followRedirects: true,
        ),
      ),
      'GitHub release asset',
    );
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw const UpdateException('GitHub release asset download was empty');
    }
    return bytes;
  }

  Map<String, String> _jsonHeaders(String token) {
    return {
      'Accept': 'application/vnd.github+json',
      'Authorization': 'Bearer $token',
      'X-GitHub-Api-Version': _apiVersion,
    };
  }

  Map<String, String> _assetHeaders(String token) {
    return {
      'Accept': 'application/octet-stream',
      'Authorization': 'Bearer $token',
      'X-GitHub-Api-Version': _apiVersion,
    };
  }

  Map<String, dynamic>? _findAsset(
    List<Map<String, dynamic>> assets,
    String name,
  ) {
    for (final asset in assets) {
      if (asset['name'] == name) return asset;
    }
    return null;
  }

  Map<String, dynamic>? _findFirstApkAsset(List<Map<String, dynamic>> assets) {
    for (final asset in assets) {
      final name = asset['name'] as String?;
      if (name != null && name.toLowerCase().endsWith('.apk')) return asset;
    }
    return null;
  }

  String? _assetNameFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      return Uri.parse(url).pathSegments.last;
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseGitHubDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  Future<Response<T>> _withRetry<T>(
    Future<Response<T>> Function() request,
    String label, {
    String? notFoundMessage,
  }) async {
    Object? lastError;
    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        return await request();
      } on DioException catch (error) {
        lastError = error;
        final statusCode = error.response?.statusCode;
        if (statusCode != null && statusCode < 500) {
          throw UpdateException(
            _messageForDioError(
              label: label,
              error: error,
              notFoundMessage: notFoundMessage,
            ),
            cause: error,
          );
        }
        DeveloperLogService.warning(
          '$label failed on attempt $attempt: ${error.message}',
        );
        if (attempt == 3) break;
        await Future<void>.delayed(Duration(milliseconds: 600 * attempt));
      }
    }
    throw UpdateException(
      '$label failed. Check your internet connection and try again.',
      cause: lastError,
    );
  }

  String _messageForDioError({
    required String label,
    required DioException error,
    String? notFoundMessage,
  }) {
    switch (error.response?.statusCode) {
      case 401:
        return 'GitHub token is invalid or expired. Create a new fine-grained token with read access to this repo.';
      case 403:
        return 'GitHub refused access. Check token permissions, organization access, or GitHub rate limits.';
      case 404:
        return notFoundMessage ?? '$label was not found on GitHub.';
      case 422:
        return '$label request was rejected by GitHub. Check the owner, repo, and release asset names.';
      default:
        return '$label failed with GitHub status ${error.response?.statusCode}.';
    }
  }
}
