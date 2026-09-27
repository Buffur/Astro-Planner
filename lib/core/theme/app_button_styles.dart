import 'package:flutter/material.dart';

/// The destructive button role (S5.2). The primary (filled), secondary
/// (outlined) and tertiary (text) roles come from the theme's button
/// themes; a destructive action adds one of these styles. See
/// `docs/DESIGN_SYSTEM.md`, "Buttons".
abstract final class AppButtonStyles {
  /// A destructive action that is the screen's main action.
  static ButtonStyle destructive(ColorScheme scheme) => FilledButton.styleFrom(
    backgroundColor: scheme.error,
    foregroundColor: scheme.onError,
  );

  /// A destructive action beside Cancel in a dialog.
  static ButtonStyle destructiveText(ColorScheme scheme) =>
      TextButton.styleFrom(foregroundColor: scheme.error);
}
