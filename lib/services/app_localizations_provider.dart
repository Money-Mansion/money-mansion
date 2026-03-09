import 'package:flutter/foundation.dart';
import 'app_localizations.dart';

class AppLocalizationsProvider extends ChangeNotifier {
  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  AppLocalizationsProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    _currentLanguage = await AppLocalizations.getLanguage();
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (!AppLocalizations.getSupportedLanguages().contains(languageCode)) {
      return;
    }
    _currentLanguage = languageCode;
    await AppLocalizations.setLanguage(languageCode);
    notifyListeners();
  }

  String translate(String key) {
    return AppLocalizations.translate(key, language: _currentLanguage);
  }

  String getLanguageName(String languageCode) {
    return AppLocalizations.getLanguageName(languageCode);
  }

  List<String> getSupportedLanguages() {
    return AppLocalizations.getSupportedLanguages();
  }
}
