// lib/ui/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Dark theme
  static const darkBackground = Color(0xFF0B1326);
  static const darkSurface = Color(0xFF0B1326);
  static const darkSurfaceContainerLowest = Color(0xFF060E20);
  static const darkSurfaceContainerLow = Color(0xFF131B2E);
  static const darkSurfaceContainer = Color(0xFF171F33);
  static const darkSurfaceContainerHigh = Color(0xFF222A3D);
  static const darkSurfaceContainerHighest = Color(0xFF2D3449);
  static const darkSurfaceBright = Color(0xFF31394D);
  static const darkPrimary = Color(0xFFA4C9FF);
  static const darkPrimaryContainer = Color(0xFF60A5FA);
  static const darkOnPrimary = Color(0xFF00315D);
  static const darkOnPrimaryContainer = Color(0xFF003A6B);
  static const darkSecondary = Color(0xFFBCC7DE);
  static const darkSecondaryContainer = Color(0xFF3E495D);
  static const darkTertiary = Color(0xFFFABD34);
  static const darkTertiaryContainer = Color(0xFFD19900);
  static const darkOnTertiary = Color(0xFF412D00);
  static const darkOnSurface = Color(0xFFDAE2FD);
  static const darkOnSurfaceVariant = Color(0xFFC1C7D3);
  static const darkOutline = Color(0xFF8B919D);
  static const darkOutlineVariant = Color(0xFF414751);
  static const darkError = Color(0xFFFFB4AB);

  // Light theme
  static const lightBackground = Color(0xFFF7F9FF);
  static const lightSurface = Color(0xFFFAFCFF);
  static const lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const lightSurfaceContainerLow = Color(0xFFF0F4FF);
  static const lightSurfaceContainer = Color(0xFFE8EFFC);
  static const lightSurfaceContainerHigh = Color(0xFFDDE5F5);
  static const lightSurfaceContainerHighest = Color(0xFFD2DAEE);
  static const lightPrimary = Color(0xFF0060AC);
  static const lightPrimaryContainer = Color(0xFFD4E3FF);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightOnPrimaryContainer = Color(0xFF001C39);
  static const lightSecondary = Color(0xFF535F73);
  static const lightSecondaryContainer = Color(0xFFD8E3FB);
  static const lightTertiary = Color(0xFF6F5B00);
  static const lightTertiaryContainer = Color(0xFFFFDEA4);
  static const lightOnTertiary = Color(0xFFFFFFFF);
  static const lightOnSurface = Color(0xFF171F33);
  static const lightOnSurfaceVariant = Color(0xFF44495A);
  static const lightOutline = Color(0xFF74798A);
  static const lightOutlineVariant = Color(0xFFC4C8D7);
  static const lightError = Color(0xFFBA1A1A);
}

class AppTheme {
  static TextTheme _buildTextTheme(Color textColor) {
    final font = GoogleFonts.plusJakartaSans;
    return TextTheme(
      displayLarge: font(fontSize: 57, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.02 * 57),
      displayMedium: font(fontSize: 45, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.02 * 45),
      displaySmall: font(fontSize: 36, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.02 * 36),
      headlineLarge: font(fontSize: 32, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.02 * 32),
      headlineMedium: font(fontSize: 28, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.02 * 28),
      headlineSmall: font(fontSize: 24, fontWeight: FontWeight.w700, color: textColor, letterSpacing: -0.02 * 24),
      titleLarge: font(fontSize: 22, fontWeight: FontWeight.w600, color: textColor),
      titleMedium: font(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
      titleSmall: font(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
      bodyLarge: font(fontSize: 16, fontWeight: FontWeight.w400, color: textColor),
      bodyMedium: font(fontSize: 14, fontWeight: FontWeight.w400, color: textColor),
      bodySmall: font(fontSize: 12, fontWeight: FontWeight.w400, color: textColor),
      labelLarge: font(fontSize: 14, fontWeight: FontWeight.w700, color: textColor),
      labelMedium: font(fontSize: 12, fontWeight: FontWeight.w700, color: textColor),
      labelSmall: font(fontSize: 10, fontWeight: FontWeight.w700, color: textColor, letterSpacing: 0.1),
    );
  }

  static ThemeData get dark {
    const bg = AppColors.darkBackground;
    const text = AppColors.darkOnSurface;

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        background: bg,
        surface: AppColors.darkSurface,
        primary: AppColors.darkPrimary,
        primaryContainer: AppColors.darkPrimaryContainer,
        onPrimary: AppColors.darkOnPrimary,
        onPrimaryContainer: AppColors.darkOnPrimaryContainer,
        secondary: AppColors.darkSecondary,
        secondaryContainer: AppColors.darkSecondaryContainer,
        tertiary: AppColors.darkTertiary,
        tertiaryContainer: AppColors.darkTertiaryContainer,
        onTertiary: AppColors.darkOnTertiary,
        onSurface: text,
        onSurfaceVariant: AppColors.darkOnSurfaceVariant,
        outline: AppColors.darkOutline,
        outlineVariant: AppColors.darkOutlineVariant,
        error: AppColors.darkError,
      ),
      textTheme: _buildTextTheme(text),
      useMaterial3: true,
    );
  }

  static ThemeData get light {
    const bg = AppColors.lightBackground;
    const text = AppColors.lightOnSurface;

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(
        background: bg,
        surface: AppColors.lightSurface,
        primary: AppColors.lightPrimary,
        primaryContainer: AppColors.lightPrimaryContainer,
        onPrimary: AppColors.lightOnPrimary,
        onPrimaryContainer: AppColors.lightOnPrimaryContainer,
        secondary: AppColors.lightSecondary,
        secondaryContainer: AppColors.lightSecondaryContainer,
        tertiary: AppColors.lightTertiary,
        tertiaryContainer: AppColors.lightTertiaryContainer,
        onTertiary: AppColors.lightOnTertiary,
        onSurface: text,
        onSurfaceVariant: AppColors.lightOnSurfaceVariant,
        outline: AppColors.lightOutline,
        outlineVariant: AppColors.lightOutlineVariant,
        error: AppColors.lightError,
      ),
      textTheme: _buildTextTheme(text),
      useMaterial3: true,
    );
  }
}

// Extension for easy access to custom surface colors in dark/light mode
extension ThemeExtension on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get surfaceContainerLowest => isDark
      ? AppColors.darkSurfaceContainerLowest
      : AppColors.lightSurfaceContainerLowest;

  Color get surfaceContainerLow => isDark
      ? AppColors.darkSurfaceContainerLow
      : AppColors.lightSurfaceContainerLow;

  Color get surfaceContainer => isDark
      ? AppColors.darkSurfaceContainer
      : AppColors.lightSurfaceContainer;

  Color get surfaceContainerHigh => isDark
      ? AppColors.darkSurfaceContainerHigh
      : AppColors.lightSurfaceContainerHigh;

  Color get surfaceContainerHighest => isDark
      ? AppColors.darkSurfaceContainerHighest
      : AppColors.lightSurfaceContainerHighest;

  Color get tertiary => isDark
      ? AppColors.darkTertiary
      : AppColors.lightTertiary;

  Color get onTertiary => isDark
      ? AppColors.darkOnTertiary
      : AppColors.lightOnTertiary;

  Color get tertiaryContainer => isDark
      ? AppColors.darkTertiaryContainer
      : AppColors.lightTertiaryContainer;

  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get primaryContainer => Theme.of(this).colorScheme.primaryContainer;
  Color get onPrimaryContainer => Theme.of(this).colorScheme.onPrimaryContainer;
  Color get onSurface => Theme.of(this).colorScheme.onSurface;
  Color get onSurfaceVariant => Theme.of(this).colorScheme.onSurfaceVariant;
  Color get outlineVariant => Theme.of(this).colorScheme.outlineVariant;
  Color get errorColor => Theme.of(this).colorScheme.error;
}
