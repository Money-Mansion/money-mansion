import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/logging/developer_log_service.dart';
import '../domain/update_exception.dart';
import '../models/update_manifest.dart';

typedef DownloadProgress = void Function(int received, int total);

class ApkDownloader {
  ApkDownloader({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<File> download({
    required UpdateManifest manifest,
    required String token,
    DownloadProgress? onProgress,
  }) async {
    final cacheDir = await _updatesCacheDir();
    await cacheDir.create(recursive: true);

    final safeVersion =
        manifest.version.replaceAll(RegExp(r'[^0-9A-Za-z._-]'), '_');
    final fileName = 'money_mansion_${safeVersion}_${manifest.build}.apk';
    await deleteOldApks(keepFileName: fileName);

    final target = File('${cacheDir.path}${Platform.pathSeparator}$fileName');
    final partial = File('${target.path}.part');
    final source = manifest.apkAssetApiUrl ?? manifest.apkUrl;
    if (source == null || source.isEmpty) {
      throw const UpdateException('No APK download URL was found');
    }

    if (await target.exists()) {
      try {
        await verifyApk(target, manifest.sha256);
        final size = await target.length();
        onProgress?.call(size, size);
        DeveloperLogService.info('Using cached verified APK: ${target.path}');
        return target;
      } catch (error) {
        DeveloperLogService.warning(
          'Cached APK failed verification and will be replaced: $error',
        );
        try {
          await target.delete();
        } catch (_) {}
      }
    }

    await _withRetry(
      () => _downloadToPartial(
        source,
        partial,
        token: token,
        authenticatedAsset: manifest.apkAssetApiUrl != null,
        onProgress: onProgress,
      ),
      'APK download',
    );

    if (await target.exists()) {
      await target.delete();
    }
    await partial.rename(target.path);
    await verifyApk(target, manifest.sha256);
    await deleteOldApks(keepFileName: fileName);
    DeveloperLogService.info('Downloaded and verified APK: ${target.path}');
    return target;
  }

  Future<void> verifyApk(File file, String expectedSha256) async {
    if (!await file.exists()) {
      throw const UpdateException('Downloaded APK was not found');
    }
    if (await file.length() < 4) {
      throw const UpdateException('Downloaded APK is empty or corrupted');
    }

    final handle = await file.open();
    try {
      final signature = await handle.read(2);
      if (signature.length < 2 ||
          signature[0] != 'P'.codeUnitAt(0) ||
          signature[1] != 'K'.codeUnitAt(0)) {
        throw const UpdateException(
            'Downloaded file is not a valid APK archive');
      }
    } finally {
      await handle.close();
    }

    final actual = await _sha256Of(file);
    if (actual.toLowerCase() != expectedSha256.toLowerCase()) {
      try {
        await file.delete();
      } catch (_) {}
      throw UpdateException(
        'APK SHA256 verification failed',
        cause: 'expected $expectedSha256 but got $actual',
      );
    }
  }

  Future<void> deleteOldApks({String? keepFileName}) async {
    final dir = await _updatesCacheDir();
    if (!await dir.exists()) return;
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      if (!entity.path.toLowerCase().endsWith('.apk')) continue;
      final name = entity.uri.pathSegments.last;
      if (keepFileName != null && name == keepFileName) continue;
      try {
        await entity.delete();
      } catch (_) {}
    }
  }

  Future<void> clearCache() async {
    final dir = await _updatesCacheDir();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<Directory> _updatesCacheDir() async {
    final temp = await getTemporaryDirectory();
    return Directory('${temp.path}${Platform.pathSeparator}updates');
  }

  Future<void> _downloadToPartial(
    String source,
    File partial, {
    required String token,
    required bool authenticatedAsset,
    DownloadProgress? onProgress,
  }) async {
    final resumeFrom = await partial.exists() ? await partial.length() : 0;
    final headers = <String, String>{
      if (resumeFrom > 0) 'Range': 'bytes=$resumeFrom-',
      if (authenticatedAsset) ...{
        'Accept': 'application/octet-stream',
        'Authorization': 'Bearer $token',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    };

    final response = await _dio.get<ResponseBody>(
      source,
      options: Options(
        responseType: ResponseType.stream,
        followRedirects: true,
        headers: headers,
        validateStatus: (status) => status == 200 || status == 206,
      ),
    );

    final statusCode = response.statusCode ?? 0;
    final canResume = statusCode == 206 && resumeFrom > 0;
    final writeMode = canResume ? FileMode.append : FileMode.write;
    final startingBytes = canResume ? resumeFrom : 0;
    final contentLength = response.data?.contentLength ?? -1;
    final totalBytes = contentLength > 0 ? startingBytes + contentLength : -1;

    if (!canResume && resumeFrom > 0) {
      DeveloperLogService.info(
        'APK server did not resume partial download; restarting from byte 0.',
      );
    }

    var received = startingBytes;
    final sink = partial.openWrite(mode: writeMode);
    try {
      await for (final chunk in response.data!.stream) {
        received += chunk.length;
        sink.add(chunk);
        onProgress?.call(received, totalBytes);
      }
    } finally {
      await sink.close();
    }
  }

  Future<String> _sha256Of(File file) async {
    final sink = _DigestSink();
    final input = sha256.startChunkedConversion(sink);
    await for (final chunk in file.openRead()) {
      input.add(chunk);
    }
    input.close();
    final digest = sink.digest;
    if (digest == null) {
      throw const UpdateException('Could not calculate APK SHA256');
    }
    return digest.toString();
  }

  Future<void> _withRetry(
    Future<void> Function() request,
    String label,
  ) async {
    Object? lastError;
    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        await request();
        return;
      } on DioException catch (error) {
        lastError = error;
        DeveloperLogService.warning(
          '$label failed on attempt $attempt: ${error.message}',
        );
        if (attempt == 3) break;
        await Future<void>.delayed(Duration(milliseconds: 800 * attempt));
      }
    }
    throw UpdateException('$label failed after retries', cause: lastError);
  }
}

class _DigestSink implements Sink<Digest> {
  Digest? digest;

  @override
  void add(Digest data) {
    digest = data;
  }

  @override
  void close() {}
}
