import 'package:flutter/material.dart';

/// The raw colours behind the three themes. Widgets never read these
/// directly: they use `Theme.of(context).colorScheme` or [AppPalette]
/// (TASK 12.4). The text roles (S5.1) are documented in
/// `docs/DESIGN_SYSTEM.md`: in light and dark every role is WCAG AA
/// (4.5:1) on the background, the surface and the raised surface, and each
/// is at least 1.3 times the next one's contrast.
class AppColors {
  // Light Theme
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF7F7F5);
  static const Color lightSurfaceRaised = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF37352F); // 11.4:1
  static const Color lightTextSecondary = Color(0xFF5A5955); // 6.5:1
  static const Color lightTextTertiary = Color(0xFF6E6D69); // 4.8:1
  static const Color lightTextDisabled = Color(0xFFA3A29F);
  static const Color lightBorder = Color(0xFFE9E9E7);

  // Dark Theme
  static const Color darkBackground = Color(0xFF191919);
  static const Color darkSurface = Color(0xFF202020);
  static const Color darkSurfaceRaised = Color(0xFF252525);
  static const Color darkTextPrimary = Color(0xFFEBEBEA); // 12.8:1
  static const Color darkTextSecondary = Color(0xFFA5A5A3); // 6.2:1
  static const Color darkTextTertiary = Color(0xFF8F8F8D); // 4.7:1
  static const Color darkTextDisabled = Color(0xFF6B6B69);
  static const Color darkBorder = Color(0xFF2F2F2F);

  // Field Mode (Red): brightness, not hue, separates the roles.
  static const Color fieldBackground = Color(0xFF000000);
  static const Color fieldSurface = Color(0xFF110000);
  static const Color fieldSurfaceRaised = Color(0xFF1A0000);
  static const Color fieldTextPrimary = Color(0xFFFF0000);
  static const Color fieldTextSecondary = Color(0xFFAA0000);
  static const Color fieldTextTertiary = Color(0xFF880000);
  static const Color fieldTextDisabled = Color(0xFF660000);
  static const Color fieldBorder = Color(0xFF330000);
}
