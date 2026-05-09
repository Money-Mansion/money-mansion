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
    );
  }

  Future<UpdateManifest> fetchLatestManifest({required String token}) async {
    final release = await _withRetry(
      () => _dio.get<Map<String, dynamic>>(
        'https://api.github.com/repos/${DeveloperConfig.githubOwner}/${DeveloperConfig.githubRepo}/releases/latest',
        options: Options(headers: _jsonHeaders(token)),
      ),
      'GitHub latest release',
    );

    final releaseData = release.data;
    if (releaseData == null) {
      throw const UpdateException('GitHub returned an empty release response');
    }

    final assets = (releaseData['assets'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final versionAsset = _findAsset(assets, _versionAssetName);
    if (versionAsset == null) {
      throw const UpdateException('Latest GitHub Release has no version.json');
    }

    final manifestBytes = await downloadReleaseAssetBytes(
      assetApiUrl: versionAsset['url'] as String,
      token: token,
    );
    final manifestJson = jsonDecode(utf8.decode(manifestBytes));
    if (manifestJson is! Map<String, dynamic>) {
      throw const UpdateException('version.json is not a JSON object');
    }

    final manifest = UpdateManifest.fromJson(manifestJson);

    return manifest.copyWith(
      releaseTag: releaseData['tag_name'] as String?,
      releaseHtmlUrl: releaseData['html_url'] as String?,
      versionAssetApiUrl: versionAsset['url'] as String?,
    );
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

  Future<Response<T>> _withRetry<T>(
    Future<Response<T>> Function() request,
    String label,
  ) async {
    Object? lastError;
    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        return await request();
      } on DioException catch (error) {
        lastError = error;
        DeveloperLogService.warning(
          '$label failed on attempt $attempt: ${error.message}',
        );
        if (attempt == 3) break;
        await Future<void>.delayed(Duration(milliseconds: 600 * attempt));
      }
    }
    throw UpdateException('$label failed after retries', cause: lastError);
  }
}
