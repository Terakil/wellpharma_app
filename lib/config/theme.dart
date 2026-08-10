import 'package:flutter/material.dart';

class AppColors {
  // Dark Palette
  static const bgMainDark = Color(0xFF0F172A);
  static const bgSideDark = Color(0xFF1E293B);
  static const cardDark = Color(0xFF16213A);
  static const textMainDark = Color(0xFFF8FAFC);
  static const textDimDark = Color(0xFF94A3B8);

  // Light Palette
  static const bgMainLight = Color(0xFFF1F5F9);
  static const bgSideLight = Colors.white;
  static const cardLight = Colors.white;
  static const textMainLight = Color(0xFF0F172A);
  static const textDimLight = Color(0xFF64748B);

  static const primary = Color(0xFF10B981);
  static const primaryDark = Color(0xFF059669);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentRed = Color(0xFFEF4444);
}

ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final bgMain = isDark ? AppColors.bgMainDark : AppColors.bgMainLight;
  final bgSide = isDark ? AppColors.bgSideDark : AppColors.bgSideLight;
  final textMain = isDark ? AppColors.textMainDark : AppColors.textMainLight;
  final textDim = isDark ? AppColors.textDimDark : AppColors.textDimLight;
  final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Outfit',
    brightness: brightness,
    scaffoldBackgroundColor: bgMain,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      secondary: AppColors.accentBlue,
      error: AppColors.accentRed,
      surface: bgSide,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bgMain,
      foregroundColor: textMain,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      hintStyle: TextStyle(color: textDim),
      labelStyle: TextStyle(color: textDim),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: bgSide,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: textDim,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: textMain),
      bodyLarge: TextStyle(color: textMain),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: bgSide,
      contentTextStyle: TextStyle(color: textMain),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
