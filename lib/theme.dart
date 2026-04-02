import 'package:flutter/material.dart';

/// Couleurs chaudes de l'application.
class AppColors {
  static const Color primary = Color(0xFFD45A00);       // Orange foncé
  static const Color secondary = Color(0xFFFF8C42);     // Orange clair
  static const Color surface = Color(0xFFFFF3E0);       // Crème / beige clair
  static const Color surfaceDark = Color(0xFF1E1410);   // Marron très foncé
  static const Color searchBorder = Color(0xFF003399);  // Bleu foncé (champs)
  static const Color searchFill = Colors.white;
  static const Color searchFillDark = Color(0xFF2A1F14);
  static const Color cardLight = Color(0xFFFFF8F0);
  static const Color cardDark = Color(0xFF2E1F10);
}

ThemeData buildLightTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.surface,
    ),
    fontFamily: 'Roboto',
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.surface,
    cardTheme: CardTheme(
      color: AppColors.cardLight,
      elevation: 4,
      shadowColor: AppColors.primary.withAlpha(60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shadowColor: AppColors.primary.withAlpha(100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.searchFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.searchBorder, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.searchBorder, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shadowColor: AppColors.primary.withAlpha(120),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.secondary.withAlpha(40),
      selectedColor: AppColors.primary,
      labelStyle: const TextStyle(color: AppColors.primary),
    ),
  );
}

ThemeData buildDarkTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surface: AppColors.surfaceDark,
    ),
    fontFamily: 'Roboto',
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.surfaceDark,
    cardTheme: CardTheme(
      color: AppColors.cardDark,
      elevation: 4,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.black87,
        elevation: 6,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.searchFillDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.searchBorder, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.searchBorder, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.secondary, width: 2.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.secondary,
      elevation: 4,
    ),
  );
}
