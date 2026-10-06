import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_theme.dart';

enum AppColorMode { pink, blue }

class AppThemeProvider extends ChangeNotifier {
  static const _preferenceKey = 'app_color_mode';

  AppColorMode _mode = AppColorMode.pink;

  AppThemeProvider() {
    _loadMode();
  }

  AppColorMode get mode => _mode;

  AppColors get colors {
    switch (_mode) {
      case AppColorMode.pink:
        return AppColors.pink;
      case AppColorMode.blue:
        return AppColors.blue;
    }
  }

  Future<void> setMode(AppColorMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferenceKey, mode.name);
  }

  Future<void> _loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_preferenceKey);
    final mode = AppColorMode.values.where((value) => value.name == savedMode);
    if (mode.isEmpty || mode.first == _mode) return;
    _mode = mode.first;
    notifyListeners();
  }
}