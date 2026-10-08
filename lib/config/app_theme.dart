import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color surfaceStrong;
  final Color primary;
  final Color lessonIcon;
  final Color primarySoft;
  final Color border;
  final Color onSurface;
  final Color mutedText;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceStrong,
    required this.primary,
    required this.lessonIcon,
    required this.primarySoft,
    required this.border,
    required this.onSurface,
    required this.mutedText,
  });

  static const pink = AppColors(
    background: Color(0xFFF0E3F1),
    surface: Color(0xFFFFF5F7),
    surfaceStrong: Color(0xFFFFFBF5),
    primary: Color(0xFF6B5B8C),
    lessonIcon: Color(0xFF6B5B8C),
    primarySoft: Color(0xFFE8D4F0),
    border: Color(0xFFB8A8D8),
    onSurface: Color(0xFF2D2638),
    mutedText: Color(0xFF6E6875),
  );

  static const blue = AppColors(
    background: Color(0xFFE5F0F8),
    surface: Color(0xFFF0F7FC),
    surfaceStrong: Color(0xFFF9FCFF),
    primary: Color(0xFF285A7A),
    lessonIcon: Color(0xFF1677B8),
    primarySoft: Color(0xFFD2E7F4),
    border: Color(0xFF8BB9D3),
    onSurface: Color(0xFF1D3342),
    mutedText: Color(0xFF5E7482),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceStrong,
    Color? primary,
    Color? lessonIcon,
    Color? primarySoft,
    Color? border,
    Color? onSurface,
    Color? mutedText,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      primary: primary ?? this.primary,
      lessonIcon: lessonIcon ?? this.lessonIcon,
      primarySoft: primarySoft ?? this.primarySoft,
      border: border ?? this.border,
      onSurface: onSurface ?? this.onSurface,
      mutedText: mutedText ?? this.mutedText,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceStrong: Color.lerp(surfaceStrong, other.surfaceStrong, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      lessonIcon: Color.lerp(lessonIcon, other.lessonIcon, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      border: Color.lerp(border, other.border, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
    );
  }
}

class AppTheme {
  const AppTheme._();

  static ThemeData forColors(AppColors colors) {
    final scheme = ColorScheme.fromSeed(
      seedColor: colors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      extensions: <ThemeExtension<dynamic>>[colors],
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}