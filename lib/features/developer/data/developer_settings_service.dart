import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeveloperSettings {
  final String? lastError;

  const DeveloperSettings({
    this.lastError,
  });

  DeveloperSettings copyWith({
    String? lastError,
    bool clearLastError = false,
  }) {
    return DeveloperSettings(
      lastError: clearLastError ? null : lastError ?? this.lastError,
    );
  }
}

class DeveloperSettingsService {
  DeveloperSettingsService._();

  static final instance = DeveloperSettingsService._();

  static const _secureStorage = FlutterSecureStorage();
  static const _githubTokenKey = 'developer.github_token';
  static const _lastErrorKey = 'developer.last_error';

  Future<DeveloperSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return DeveloperSettings(
      lastError: prefs.getString(_lastErrorKey),
    );
  }

  Future<String?> loadGithubToken() async {
    final token = await _secureStorage.read(key: _githubTokenKey);
    if (token == null || token.trim().isEmpty) return null;
    return token.trim();
  }

  Future<void> saveGithubToken(String token) async {
    await _secureStorage.write(key: _githubTokenKey, value: token.trim());
  }

  Future<void> clearGithubToken() async {
    await _secureStorage.delete(key: _githubTokenKey);
  }

  Future<void> clearAllDeveloperSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastErrorKey);
    await clearGithubToken();
  }
}
