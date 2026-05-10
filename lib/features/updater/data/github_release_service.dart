import 'package:dio/dio.dart';

import '../../../core/logging/developer_log_service.dart';
import '../../developer/developer_config.dart';
import '../domain/update_exception.dart';

class GitHubReleaseService {
  GitHubReleaseService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _apiVersion = '2022-11-28';

  Future<void> verifyRepositoryAccess({required String token}) async {
    await _withRetry(
      () => _dio.get<Map<String, dynamic>>(
        'https://api.github.com/repos/${DeveloperConfig.githubOwner}/${DeveloperConfig.githubRepo}',
        options: Options(headers: _jsonHeaders(token)),
      ),
      'GitHub repository access check',
    );
  }

  Map<String, String> _jsonHeaders(String token) {
    return {
      'Accept': 'application/vnd.github+json',
      'Authorization': 'Bearer $token',
      'X-GitHub-Api-Version': _apiVersion,
    };
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
