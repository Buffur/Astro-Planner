import 'package:flutter/material.dart';

/// The type scale (S5.1): size, line height and weight for every style,
/// shared by the three themes. Colours come from the theme (the text roles
/// in [AppPalette]); letter spacing stays Material's. Nothing is under
/// 12 sp. The roles each style serves are in `docs/DESIGN_SYSTEM.md`.
abstract final class AppTypography {
  static TextStyle _style(double size, double lineHeight, FontWeight weight) =>
      TextStyle(fontSize: size, height: lineHeight / size, fontWeight: weight);

  static final TextTheme scale = TextTheme(
    displayLarge: _style(57, 64, FontWeight.w400),
    displayMedium: _style(45, 52, FontWeight.w400),
    displaySmall: _style(36, 44, FontWeight.w400),
    headlineLarge: _style(32, 40, FontWeight.w400),
    headlineMedium: _style(28, 36, FontWeight.w400),
    headlineSmall: _style(24, 32, FontWeight.w400),
    // Titles carry the hierarchy: heavier than Material's defaults.
    titleLarge: _style(20, 28, FontWeight.w600),
    titleMedium: _style(16, 24, FontWeight.w600),
    titleSmall: _style(14, 20, FontWeight.w600),
    bodyLarge: _style(16, 24, FontWeight.w400),
    bodyMedium: _style(14, 20, FontWeight.w400),
    bodySmall: _style(12, 16, FontWeight.w400),
    labelLarge: _style(14, 20, FontWeight.w500),
    labelMedium: _style(12, 16, FontWeight.w500),
    labelSmall: _style(12, 16, FontWeight.w500),
  );
}
