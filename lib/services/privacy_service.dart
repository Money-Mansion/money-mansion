import 'package:flutter/services.dart';

class PrivacyService {
  static Future<String> getPrivacyPolicyHtml() => _loadFromAssets();

  static Future<String> _loadFromAssets() async {
    try {
      return await rootBundle.loadString('assets/privacy_policy_fallback.html');
    } catch (_) {
      return '<p>Privacy Policy not available</p>';
    }
  }

  static Future<void> clearCache() async {
    // Privacy policy content is bundled with the app for offline access.
  }
}
