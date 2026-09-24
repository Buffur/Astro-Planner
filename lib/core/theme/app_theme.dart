import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';

/// The app's three themes (TASK 12.4): light, dark and red field mode.
/// Colours come from [AppColors] and [AppPalette] tokens; text is never
/// smaller than 12 sp.
class AppTheme {
  static final ThemeData light = _withTokens(
    ThemeData(
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
    ),
    AppPalette.light,
  );

  static final ThemeData dark = _withTokens(
    ThemeData(
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
    ),
    AppPalette.dark,
  );

  /// Every colour role is red or black (TASK 12.4), so dialogs, date
  /// pickers, snackbars, menus and the navigation bar stay red too.
  static const ColorScheme fieldColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.fieldTextPrimary,
    onPrimary: AppColors.fieldBackground,
    primaryContainer: AppColors.fieldBorder,
    onPrimaryContainer: AppColors.fieldTextPrimary,
    secondary: AppColors.fieldTextSecondary,
    onSecondary: AppColors.fieldBackground,
    secondaryContainer: AppColors.fieldBorder,
    onSecondaryContainer: AppColors.fieldTextPrimary,
    tertiary: AppColors.fieldTextSecondary,
    onTertiary: AppColors.fieldBackground,
    tertiaryContainer: AppColors.fieldBorder,
    onTertiaryContainer: AppColors.fieldTextPrimary,
    error: AppColors.fieldTextPrimary,
    onError: AppColors.fieldBackground,
    errorContainer: AppColors.fieldBorder,
    onErrorContainer: AppColors.fieldTextPrimary,
    surface: AppColors.fieldBackground,
    onSurface: AppColors.fieldTextPrimary,
    onSurfaceVariant: AppColors.fieldTextSecondary,
    surfaceDim: AppColors.fieldBackground,
    surfaceBright: AppColors.fieldBorder,
    surfaceContainerLowest: AppColors.fieldBackground,
    surfaceContainerLow: AppColors.fieldSurface,
    surfaceContainer: AppColors.fieldSurface,
    surfaceContainerHigh: Color(0xFF1A0000),
    surfaceContainerHighest: Color(0xFF220000),
    outline: Color(0xFF660000),
    outlineVariant: AppColors.fieldBorder,
    shadow: AppColors.fieldBackground,
    scrim: AppColors.fieldBackground,
    inverseSurface: AppColors.fieldTextSecondary,
    onInverseSurface: AppColors.fieldBackground,
    inversePrimary: AppColors.fieldBackground,
    surfaceTint: AppColors.fieldBackground,
  );

  static final ThemeData fieldTheme = _withTokens(
    ThemeData(
      colorScheme: fieldColorScheme,
      primaryColor: AppColors.fieldTextPrimary,
      scaffoldBackgroundColor: AppColors.fieldBackground,
      canvasColor: AppColors.fieldBackground,
      cardColor: AppColors.fieldSurface,
      dividerColor: AppColors.fieldBorder,
      hintColor: AppColors.fieldTextSecondary,
      disabledColor: const Color(0xFF660000),
      unselectedWidgetColor: AppColors.fieldTextSecondary,
      hoverColor: const Color(0x1FFF0000),
      focusColor: const Color(0x1FFF0000),
      highlightColor: const Color(0x1FFF0000),
      splashColor: const Color(0x33FF0000),
      shadowColor: AppColors.fieldBackground,
      secondaryHeaderColor: AppColors.fieldSurface,
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
      iconTheme: const IconThemeData(color: AppColors.fieldTextPrimary),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.fieldBorder,
        contentTextStyle: TextStyle(color: AppColors.fieldTextPrimary),
        actionTextColor: AppColors.fieldTextPrimary,
      ),
    ),
    AppPalette.field,
    textColor: AppColors.fieldTextPrimary,
  );

  /// Red field mode's safety net (owner decision, TASK 12.4): applied over
  /// the whole app, it maps every pixel to red by brightness — R' = R +
  /// 0.7152 G + 0.0722 B (Rec. 709 luma weights for G and B), G' = B' = 0 —
  /// so map tiles and anything a token misses stay red. Pure red is
  /// unchanged.
  static const ColorFilter fieldFilter = ColorFilter.matrix(fieldFilterMatrix);

  /// The 4×5 RGBA matrix of [fieldFilter], row by row.
  static const List<double> fieldFilterMatrix = <double>[
    1, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 0, 0, //
    0, 0, 0, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  /// Adds the palette and the shared type scale (no text under 12 sp).
  static ThemeData _withTokens(
    ThemeData base,
    AppPalette palette, {
    Color? textColor,
  }) {
    TextTheme readable(TextTheme t) {
      final scaled = t.copyWith(
        labelSmall: t.labelSmall?.copyWith(fontSize: 12),
      );
      return textColor == null
          ? scaled
          : scaled.apply(bodyColor: textColor, displayColor: textColor);
    }

    return base.copyWith(
      extensions: [palette],
      textTheme: readable(base.textTheme),
      primaryTextTheme: readable(base.primaryTextTheme),
    );
  }
}
