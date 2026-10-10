import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color surfaceStrong;
  final Color itemSurface;
  final Color itemSurfaceMuted;
  final Color fieldSurface;
  final Color primary;
  final Color lessonIcon;
  final Color primarySoft;
  final Color border;
  final Color onSurface;
  final Color onPrimary;
  final Color icon;
  final Color mutedText;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceStrong,
    required this.itemSurface,
    required this.itemSurfaceMuted,
    required this.fieldSurface,
    required this.primary,
    required this.lessonIcon,
    required this.primarySoft,
    required this.border,
    required this.onSurface,
    required this.onPrimary,
    required this.icon,
    required this.mutedText,
  });

  static const pink = AppColors(
    background: Color(0xFFF0E3F1),
    surface: Color(0xFFFFF5F7),
    surfaceStrong: Color(0xFFFFFBF5),
    itemSurface: Color(0xFFFFFFFF),
    itemSurfaceMuted: Color(0xFFF0EDF2),
    fieldSurface: Color(0xFFF8F1FA),
    primary: Color(0xFF6B5B8C),
    lessonIcon: Color(0xFF6B5B8C),
    primarySoft: Color(0xFFE8D4F0),
    border: Color(0xFFB8A8D8),
    onSurface: Color(0xFF2D2638),
    onPrimary: Color(0xFFFFFFFF),
    icon: Color(0xFF55466F),
    mutedText: Color(0xFF6E6875),
  );

  static const blue = AppColors(
    background: Color(0xFFE5F0F8),
    surface: Color(0xFFF0F7FC),
    surfaceStrong: Color(0xFFF9FCFF),
    itemSurface: Color(0xFFFFFFFF),
    itemSurfaceMuted: Color(0xFFE7F0F5),
    fieldSurface: Color(0xFFF0F7FC),
    primary: Color(0xFF285A7A),
    lessonIcon: Color(0xFF1677B8),
    primarySoft: Color(0xFFD2E7F4),
    border: Color(0xFF8BB9D3),
    onSurface: Color(0xFF1D3342),
    onPrimary: Color(0xFFFFFFFF),
    icon: Color(0xFF24536F),
    mutedText: Color(0xFF5E7482),
  );

  static const dark = AppColors(
    background: Color(0xFF17141C),
    surface: Color(0xFF211C2A),
    surfaceStrong: Color(0xFF282231),
    itemSurface: Color(0xFF2E273A),
    itemSurfaceMuted: Color(0xFF393044),
    fieldSurface: Color(0xFF33283F),
    primary: Color(0xFFB58CFF),
    lessonIcon: Color(0xFFC39BFF),
    primarySoft: Color(0xFF3A2D52),
    border: Color(0xFF654D86),
    onSurface: Color(0xFFF2EDF8),
    onPrimary: Color(0xFF1C1428),
    icon: Color(0xFFD3B9FF),
    mutedText: Color(0xFFB8ADBF),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceStrong,
    Color? itemSurface,
    Color? itemSurfaceMuted,
    Color? fieldSurface,
    Color? primary,
    Color? lessonIcon,
    Color? primarySoft,
    Color? border,
    Color? onSurface,
    Color? onPrimary,
    Color? icon,
    Color? mutedText,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      itemSurface: itemSurface ?? this.itemSurface,
      itemSurfaceMuted: itemSurfaceMuted ?? this.itemSurfaceMuted,
      fieldSurface: fieldSurface ?? this.fieldSurface,
      primary: primary ?? this.primary,
      lessonIcon: lessonIcon ?? this.lessonIcon,
      primarySoft: primarySoft ?? this.primarySoft,
      border: border ?? this.border,
      onSurface: onSurface ?? this.onSurface,
      onPrimary: onPrimary ?? this.onPrimary,
      icon: icon ?? this.icon,
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
      itemSurface: Color.lerp(itemSurface, other.itemSurface, t)!,
      itemSurfaceMuted: Color.lerp(itemSurfaceMuted, other.itemSurfaceMuted, t)!,
      fieldSurface: Color.lerp(fieldSurface, other.fieldSurface, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      lessonIcon: Color.lerp(lessonIcon, other.lessonIcon, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      border: Color.lerp(border, other.border, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
    );
  }
}

class AppTheme {
  const AppTheme._();

  static ThemeData forColors(
    AppColors colors, {
    Brightness brightness = Brightness.light,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: colors.primary,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        foregroundColor: colors.onSurface,
        iconTheme: IconThemeData(color: colors.icon),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.fieldSurface,
      ),
      extensions: <ThemeExtension<dynamic>>[colors],
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}