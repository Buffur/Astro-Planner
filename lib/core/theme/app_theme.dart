import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightTextPrimary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightTextPrimary,
      secondary: AppColors.lightTextSecondary,
      surface: AppColors.lightSurface,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 1,
      space: 1,
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      margin: EdgeInsets.zero,
    ),
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkTextPrimary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkTextPrimary,
      secondary: AppColors.darkTextSecondary,
      surface: AppColors.darkSurface,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
      space: 1,
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      margin: EdgeInsets.zero,
    ),
  );

  static final ThemeData fieldTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.fieldTextPrimary,
    scaffoldBackgroundColor: AppColors.fieldBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.fieldBackground,
      foregroundColor: AppColors.fieldTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.fieldTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.fieldTextPrimary,
      secondary: AppColors.fieldTextSecondary,
      surface: AppColors.fieldSurface,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.fieldBorder,
      thickness: 1,
      space: 1,
    ),
    cardTheme: CardThemeData(
      color: AppColors.fieldSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: AppColors.fieldBorder),
      ),
      margin: EdgeInsets.zero,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.fieldTextPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.fieldBackground,
        backgroundColor: AppColors.fieldTextPrimary,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.fieldBackground,
      selectedItemColor: AppColors.fieldTextPrimary,
      unselectedItemColor: AppColors.fieldTextSecondary,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.fieldTextPrimary),
      bodyMedium: TextStyle(color: AppColors.fieldTextPrimary),
      bodySmall: TextStyle(color: AppColors.fieldTextSecondary),
      titleLarge: TextStyle(color: AppColors.fieldTextPrimary),
      titleMedium: TextStyle(color: AppColors.fieldTextPrimary),
      titleSmall: TextStyle(color: AppColors.fieldTextPrimary),
    ),
  );
}

