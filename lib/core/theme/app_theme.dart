import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_palette.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// The app's three themes (TASK 12.4): light, dark and red field mode.
/// Colours come from [AppColors] and [AppPalette] tokens; text is never
/// smaller than 12 sp. Since S5.1 the text roles drive the colour scheme
/// (`onSurface` is the primary text, `onSurfaceVariant` and `secondary`
/// the secondary text), `surfaceContainerHigh` is the raised surface, and
/// [AppTypography.scale] sets every style's size and weight.
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
        // Selected segments and the navigation indicator: a light fill
        // with primary text (Material would derive them from secondary).
        secondaryContainer: AppColors.lightBorder,
        onSecondaryContainer: AppColors.lightTextPrimary,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        onSurfaceVariant: AppColors.lightTextSecondary,
        surfaceContainerHigh: AppColors.lightSurfaceRaised,
        // S5.2: Material falls back to black for both (the prominent
        // field underline of 08 §6).
        outline: AppColors.lightControlBorder,
        outlineVariant: AppColors.lightBorder,
        error: AppColors.lightError,
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
          borderRadius: BorderRadius.circular(AppRadius.small),
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
        onSurface: AppColors.darkTextPrimary,
        onSurfaceVariant: AppColors.darkTextSecondary,
        surfaceContainerHigh: AppColors.darkSurfaceRaised,
        // S5.2: Material falls back to white for both.
        outline: AppColors.darkControlBorder,
        outlineVariant: AppColors.darkBorder,
        error: AppColors.darkError,
        onError: AppColors.darkBackground,
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
          borderRadius: BorderRadius.circular(AppRadius.small),
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
    surfaceContainerHigh: AppColors.fieldSurfaceRaised,
    surfaceContainerHighest: Color(0xFF220000),
    outline: AppColors.fieldControlBorder,
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
      disabledColor: AppColors.fieldTextDisabled,
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
          borderRadius: BorderRadius.circular(AppRadius.small),
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
    field: true,
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
  /// The scale's sizes and weights override Material's geometry; the
  /// colours stay the theme's.
  static ThemeData _withTokens(
    ThemeData base,
    AppPalette palette, {
    Color? textColor,
    bool field = false,
  }) {
    TextTheme readable(TextTheme t) {
      final scaled = t.merge(AppTypography.scale);
      return textColor == null
          ? scaled
          : scaled.apply(bodyColor: textColor, displayColor: textColor);
    }

    return _withControls(
      base.copyWith(
        extensions: [palette],
        textTheme: readable(base.textTheme),
        primaryTextTheme: readable(base.primaryTextTheme),
      ),
      palette,
      field: field,
    );
  }

  /// The controls' look (S5.2; `docs/DESIGN_SYSTEM.md`): the button roles,
  /// text fields, dialogs, sheets, menus and messages, from the tokens
  /// only, so field mode stays red or black.
  static ThemeData _withControls(
    ThemeData t,
    AppPalette p, {
    required bool field,
  }) {
    final s = t.colorScheme;
    final text = t.textTheme;
    final shape = WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
    );
    final label = WidgetStatePropertyAll(text.labelLarge);
    const tall = WidgetStatePropertyAll(Size(64, 48));

    // Pressed feedback stronger than Material's 10 % (08 §5, §8).
    WidgetStateProperty<Color?> overlay(Color c) =>
        WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return c.withValues(alpha: pressedOverlay);
          }
          if (states.contains(WidgetState.focused)) {
            return c.withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.hovered)) {
            return c.withValues(alpha: 0.08);
          }
          return null;
        });
    WidgetStateProperty<Color> onOff(Color on) =>
        WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.disabled) ? p.textDisabled : on,
        );
    final secondary = ButtonStyle(
      minimumSize: tall,
      shape: shape,
      textStyle: label,
      foregroundColor: onOff(p.textPrimary),
      iconColor: onOff(p.textPrimary),
      overlayColor: overlay(p.textPrimary),
      side: WidgetStateProperty.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.disabled)
              ? p.border
              : p.controlBorder,
        ),
      ),
    );

    return t.copyWith(
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: tall,
          shape: shape,
          textStyle: label,
          overlayColor: overlay(s.onPrimary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(style: secondary),
      // The flat design has no elevation: an elevated button is the
      // secondary role, on the surface.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: secondary.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? t.scaffoldBackgroundColor
                : s.surface,
          ),
          elevation: const WidgetStatePropertyAll(0),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: shape,
          textStyle: label,
          foregroundColor: onOff(p.textPrimary),
          iconColor: onOff(p.textPrimary),
          overlayColor: overlay(p.textPrimary),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(overlayColor: overlay(p.textPrimary)),
      ),
      // A quiet underline (08 §6): the enabled line is the control border
      // (colorScheme.outline, which Material reads); focus draws it 2 px in
      // the primary colour. Labels and hints are text roles (AA).
      inputDecorationTheme: InputDecorationThemeData(
        labelStyle: TextStyle(color: p.textSecondary),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.error)
                ? s.error
                : states.contains(WidgetState.focused)
                ? s.primary
                : p.textSecondary,
          ),
        ),
        hintStyle: TextStyle(color: p.textTertiary),
        helperStyle: TextStyle(color: p.textTertiary),
        errorStyle: TextStyle(color: s.error),
        prefixIconColor: p.textSecondary,
        suffixIconColor: p.textSecondary,
        fillColor: s.surface,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          side: BorderSide(color: p.border),
        ),
        titleTextStyle: text.titleLarge?.copyWith(color: p.textPrimary),
        contentTextStyle: text.bodyMedium?.copyWith(color: p.textSecondary),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surfaceRaised,
        modalBackgroundColor: p.surfaceRaised,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.large),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          side: BorderSide(color: p.border),
        ),
        labelTextStyle: WidgetStatePropertyAll(
          text.bodyMedium?.copyWith(color: p.textPrimary),
        ),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(p.surfaceRaised),
        ),
      ),
      // Field mode keeps its dim red message; light and dark invert.
      snackBarTheme: field
          ? t.snackBarTheme
          : SnackBarThemeData(
              backgroundColor: p.textPrimary,
              contentTextStyle: text.bodyMedium?.copyWith(
                color: t.scaffoldBackgroundColor,
              ),
              actionTextColor: t.scaffoldBackgroundColor,
            ),
    );
  }

  /// The pressed overlay's opacity on every button (S5.2).
  static const double pressedOverlay = 0.16;
}
