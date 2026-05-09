import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeveloperSettings {
  final bool autoCheckOnStartup;
  final DateTime? lastCheckAt;
  final String? lastError;

  const DeveloperSettings({
    required this.autoCheckOnStartup,
    this.lastCheckAt,
    this.lastError,
  });

  DeveloperSettings copyWith({
    bool? autoCheckOnStartup,
    DateTime? lastCheckAt,
    String? lastError,
    bool clearLastError = false,
  }) {
    return DeveloperSettings(
      autoCheckOnStartup: autoCheckOnStartup ?? this.autoCheckOnStartup,
      lastCheckAt: lastCheckAt ?? this.lastCheckAt,
      lastError: clearLastError ? null : lastError ?? this.lastError,
    );
  }
}

class DeveloperSettingsService {
  DeveloperSettingsService._();

  static final instance = DeveloperSettingsService._();

  static const _secureStorage = FlutterSecureStorage();
  static const _githubTokenKey = 'developer.github_token';
  static const _autoCheckKey = 'developer.auto_check_on_startup';
  static const _lastCheckAtKey = 'developer.last_check_at';
  static const _lastErrorKey = 'developer.last_error';

  Future<DeveloperSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckMs = prefs.getInt(_lastCheckAtKey);
    return DeveloperSettings(
      autoCheckOnStartup: prefs.getBool(_autoCheckKey) ?? false,
      lastCheckAt: lastCheckMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastCheckMs),
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

  Future<void> setAutoCheckOnStartup(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoCheckKey, value);
  }

  Future<void> markCheckSucceeded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastCheckAtKey, DateTime.now().millisecondsSinceEpoch);
    await prefs.remove(_lastErrorKey);
  }

  Future<void> markCheckFailed(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastCheckAtKey, DateTime.now().millisecondsSinceEpoch);
    await prefs.setString(_lastErrorKey, message);
  }

  Future<void> clearAllDeveloperSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_autoCheckKey);
    await prefs.remove(_lastCheckAtKey);
    await prefs.remove(_lastErrorKey);
    await clearGithubToken();
  }
}
