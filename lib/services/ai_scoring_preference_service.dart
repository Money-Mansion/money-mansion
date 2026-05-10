import 'package:shared_preferences/shared_preferences.dart';

class AiScoringPreferenceService {
  AiScoringPreferenceService._();

  static const _externalAiScoringKey = 'external_ai_scoring_enabled';

  static const hasConfiguredExternalAi =
      String.fromEnvironment('GROQ_API_KEY') != '';

  static Future<bool> isExternalAiScoringEnabled() async {
    if (!hasConfiguredExternalAi) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_externalAiScoringKey) ?? false;
  }

  static Future<void> setExternalAiScoringEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    if (!hasConfiguredExternalAi || !enabled) {
      await prefs.setBool(_externalAiScoringKey, false);
      return;
    }
    await prefs.setBool(_externalAiScoringKey, true);
  }
}
