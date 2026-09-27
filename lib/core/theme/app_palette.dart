import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Semantic colour tokens that the Material [ColorScheme] has no role for
/// (TASK 12.4): muted text, the night's events, the altitude chart and the
/// Bortle scale. Widgets read them with [AppPalette.of]; `lib/presentation`
/// never names a colour itself (a test enforces it). Field mode's tokens
/// are red or black only.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.surfaceRaised,
    required this.border,
    required this.muted,
    required this.caution,
    required this.sunEvent,
    required this.twilightEvent,
    required this.moon,
    required this.selected,
    required this.chartDay,
    required this.chartTwilight,
    required this.chartDark,
    required this.chartWindow,
    required this.chartTarget,
    required this.chartMoon,
    required this.chartMinAltitude,
    required this.chartNow,
    required this.chartNowCentre,
    required this.chartGrid,
    required this.chartLabel,
    required this.swatchBorder,
    required this.bortle,
    required this.onBortle,
  });

  /// The text roles (S5.1; `docs/DESIGN_SYSTEM.md`): primary for the
  /// answer and values, secondary for labels and supporting text, tertiary
  /// for captions and metadata. In light and dark each is WCAG AA on the
  /// background, the surface and [surfaceRaised]; disabled is exempt (WCAG
  /// 1.4.3 excludes inactive controls).
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;

  /// Dialogs, menus and sheets: one level above the card surface.
  final Color surfaceRaised;

  /// Card, section and field outlines; dividers.
  final Color border;

  /// Secondary text and icons for empty or unknown states.
  final Color muted;

  /// A caution that is not an error, such as a "Tight" fit (S1.9): at least
  /// as prominent as body text.
  final Color caution;

  /// Sunset/sunrise and astronomical dusk/dawn icons.
  final Color sunEvent;
  final Color twilightEvent;

  /// The Moon icon.
  final Color moon;

  /// The check mark on the selected rig or target.
  final Color selected;

  /// Altitude chart: darkness bands, imaging windows, lines and labels.
  final Color chartDay;
  final Color chartTwilight;
  final Color chartDark;
  final Color chartWindow;
  final Color chartTarget;
  final Color chartMoon;
  final Color chartMinAltitude;
  final Color chartNow;
  final Color chartNowCentre;
  final Color chartGrid;
  final Color chartLabel;

  /// The outline of the chart legend's swatches and of the Bortle badge.
  final Color swatchBorder;

  /// Bortle badge background and text: index 0 is "unknown", 1–9 the class.
  final List<Color> bortle;
  final List<Color> onBortle;

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? light;

  static const light = AppPalette(
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textTertiary: AppColors.lightTextTertiary,
    textDisabled: AppColors.lightTextDisabled,
    surfaceRaised: AppColors.lightSurfaceRaised,
    border: AppColors.lightBorder,
    muted: Colors.grey,
    caution: Color(0xFF9A5B00), // dark amber: 5.4:1 on white (AA)
    sunEvent: Colors.orange,
    twilightEvent: Colors.indigo,
    moon: Colors.blueGrey,
    selected: Colors.blue,
    chartDay: Color(0xFFB3E5FC), // lightBlue.shade100
    chartTwilight: Color(0xFF7986CB), // indigo.shade300
    chartDark: Colors.black87,
    chartWindow: Color(0x6600C853),
    chartTarget: Colors.amber,
    chartMoon: Color(0xFFB0BEC5), // blueGrey.shade200
    chartMinAltitude: Colors.redAccent,
    chartNow: Colors.redAccent,
    chartNowCentre: Colors.white,
    chartGrid: Colors.white60,
    chartLabel: Colors.white,
    swatchBorder: Color(0xFFBDBDBD), // grey.shade400
    bortle: _bortleColours,
    onBortle: _onBortleColours,
  );

  static const dark = AppPalette(
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textTertiary: AppColors.darkTextTertiary,
    textDisabled: AppColors.darkTextDisabled,
    surfaceRaised: AppColors.darkSurfaceRaised,
    border: AppColors.darkBorder,
    muted: Colors.grey,
    caution: Color(0xFFFFB74D), // orange.shade300
    sunEvent: Colors.orange,
    twilightEvent: Colors.indigo,
    moon: Colors.blueGrey,
    selected: Colors.blue,
    chartDay: Color(0xFF37474F), // blueGrey.shade800
    chartTwilight: Color(0xFF1A237E), // indigo.shade900
    chartDark: Colors.black,
    chartWindow: Color(0x6600C853),
    chartTarget: Colors.amber,
    chartMoon: Color(0xFFB0BEC5),
    chartMinAltitude: Colors.redAccent,
    chartNow: Colors.redAccent,
    chartNowCentre: Colors.white,
    chartGrid: Colors.white30,
    chartLabel: Colors.white70,
    swatchBorder: Color(0xFFBDBDBD),
    bortle: _bortleColours,
    onBortle: _onBortleColours,
  );

  /// Red on black only: brightness, not hue, tells elements apart.
  static const field = AppPalette(
    textPrimary: AppColors.fieldTextPrimary,
    textSecondary: AppColors.fieldTextSecondary,
    textTertiary: AppColors.fieldTextTertiary,
    textDisabled: AppColors.fieldTextDisabled,
    surfaceRaised: AppColors.fieldSurfaceRaised,
    border: AppColors.fieldBorder,
    muted: AppColors.fieldTextSecondary,
    // As bright as "Fits": in red mode the word carries the caution.
    caution: AppColors.fieldTextPrimary,
    sunEvent: AppColors.fieldTextPrimary,
    twilightEvent: AppColors.fieldTextSecondary,
    moon: AppColors.fieldTextSecondary,
    selected: AppColors.fieldTextPrimary,
    chartDay: Color(0xFF3A0000),
    chartTwilight: Color(0xFF1C0000),
    chartDark: AppColors.fieldBackground,
    chartWindow: Color(0x55FF0000),
    chartTarget: AppColors.fieldTextPrimary,
    chartMoon: Color(0xFF990000),
    chartMinAltitude: Color(0xFFCC0000),
    chartNow: AppColors.fieldTextPrimary,
    chartNowCentre: AppColors.fieldBackground,
    chartGrid: Color(0x66FF0000),
    chartLabel: Color(0xFFCC0000),
    swatchBorder: AppColors.fieldBorder,
    bortle: [
      Color(0xFF330000),
      Color(0xFF110000),
      Color(0xFF220000),
      Color(0xFF330000),
      Color(0xFF440000),
      Color(0xFF660000),
      Color(0xFF880000),
      Color(0xFFAA0000),
      Color(0xFFCC0000),
      Color(0xFFFF0000),
    ],
    onBortle: [
      AppColors.fieldTextPrimary,
      AppColors.fieldTextPrimary,
      AppColors.fieldTextPrimary,
      AppColors.fieldTextPrimary,
      AppColors.fieldTextPrimary,
      AppColors.fieldTextPrimary,
      AppColors.fieldBackground,
      AppColors.fieldBackground,
      AppColors.fieldBackground,
      AppColors.fieldBackground,
    ],
  );

  /// The conventional Bortle map colours (unchanged from before TASK 12.4).
  static const _bortleColours = [
    Colors.grey,
    Colors.black,
    Color(0xFF263238), // blueGrey.shade900
    Color(0xFF0D47A1), // blue.shade900
    Color(0xFF388E3C), // green.shade700
    Color(0xFFFBC02D), // yellow.shade700
    Colors.orange,
    Colors.deepOrange,
    Colors.red,
    Colors.white,
  ];
  static const _onBortleColours = [
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.black,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.red,
  ];

  /// Every token, for tests.
  List<Color> get all => [
    textPrimary,
    textSecondary,
    textTertiary,
    textDisabled,
    surfaceRaised,
    border,
    muted,
    caution,
    sunEvent,
    twilightEvent,
    moon,
    selected,
    chartDay,
    chartTwilight,
    chartDark,
    chartWindow,
    chartTarget,
    chartMoon,
    chartMinAltitude,
    chartNow,
    chartNowCentre,
    chartGrid,
    chartLabel,
    swatchBorder,
    ...bortle,
    ...onBortle,
  ];

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) =>
      other == null || t < 0.5 ? this : other;
}
