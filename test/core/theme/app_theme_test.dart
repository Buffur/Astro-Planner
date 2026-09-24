// Theme tokens (TASK 12.4): field mode's tokens are red or black only,
// every theme carries the palette, no theme text is under 12 sp, and the
// field filter maps every colour to red without dimming pure red.

import 'package:astroplan/core/theme/app_palette.dart';
import 'package:astroplan/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

bool _redOnly(Color c) => (c.g * 255).round() == 0 && (c.b * 255).round() == 0;

List<Color> _schemeColours(ColorScheme s) => [
  s.primary, s.onPrimary, s.primaryContainer, s.onPrimaryContainer, //
  s.primaryFixed, s.primaryFixedDim, s.onPrimaryFixed, //
  s.onPrimaryFixedVariant, s.secondary, s.onSecondary, //
  s.secondaryContainer, s.onSecondaryContainer, s.secondaryFixed, //
  s.secondaryFixedDim, s.onSecondaryFixed, s.onSecondaryFixedVariant, //
  s.tertiary, s.onTertiary, s.tertiaryContainer, s.onTertiaryContainer, //
  s.tertiaryFixed, s.tertiaryFixedDim, s.onTertiaryFixed, //
  s.onTertiaryFixedVariant, s.error, s.onError, s.errorContainer, //
  s.onErrorContainer, s.surface, s.onSurface, s.surfaceDim, //
  s.surfaceBright, s.surfaceContainerLowest, s.surfaceContainerLow, //
  s.surfaceContainer, s.surfaceContainerHigh, s.surfaceContainerHighest, //
  s.onSurfaceVariant, s.outline, s.outlineVariant, s.shadow, s.scrim, //
  s.inverseSurface, s.onInverseSurface, s.inversePrimary, s.surfaceTint,
];

void main() {
  group('field mode tokens', () {
    test('every palette token is red or black', () {
      expect(AppPalette.field.all.where((c) => !_redOnly(c)), isEmpty);
    });

    test('every colour-scheme role is red or black', () {
      expect(
        _schemeColours(AppTheme.fieldColorScheme).where((c) => !_redOnly(c)),
        isEmpty,
      );
    });

    test('the theme\'s own colours and text are red or black', () {
      final t = AppTheme.fieldTheme;
      final colours = [
        t.scaffoldBackgroundColor,
        t.canvasColor,
        t.cardColor,
        t.dividerColor,
        t.hintColor,
        t.disabledColor,
        t.unselectedWidgetColor,
        t.hoverColor,
        t.focusColor,
        t.highlightColor,
        t.splashColor,
        t.shadowColor,
        t.secondaryHeaderColor,
        t.primaryColor,
        t.iconTheme.color!,
        for (final s in _styles(t.textTheme)) s.color!,
        ..._schemeColours(t.colorScheme),
      ];
      expect(colours.where((c) => !_redOnly(c)), isEmpty);
    });
  });

  test('every theme carries its palette', () {
    expect(AppTheme.light.extension<AppPalette>(), AppPalette.light);
    expect(AppTheme.dark.extension<AppPalette>(), AppPalette.dark);
    expect(AppTheme.fieldTheme.extension<AppPalette>(), AppPalette.field);
  });

  test('no theme text style is under 12 sp', () {
    for (final t in [AppTheme.light, AppTheme.dark, AppTheme.fieldTheme]) {
      // Sizes come from the typography's geometry, merged in by Theme.of.
      final shown = ThemeData.localize(t, t.typography.englishLike);
      for (final s in _styles(shown.textTheme)) {
        expect(s.fontSize, greaterThanOrEqualTo(12));
      }
    }
  });

  group('field filter', () {
    (double, double, double) apply(double r, double g, double b) {
      final m = AppTheme.fieldFilterMatrix;
      double row(int i) =>
          (m[i * 5] * r + m[i * 5 + 1] * g + m[i * 5 + 2] * b + m[i * 5 + 4])
              .clamp(0, 255);
      return (row(0), row(1), row(2));
    }

    test('green and blue are always zero', () {
      for (final c in [
        (255.0, 255.0, 255.0),
        (0.0, 200.0, 0.0),
        (0.0, 0.0, 255.0),
      ]) {
        final (_, g, b) = apply(c.$1, c.$2, c.$3);
        expect((g, b), (0, 0));
      }
    });

    test('pure red is unchanged and white becomes full red', () {
      expect(apply(255, 0, 0), (255, 0, 0));
      expect(apply(255, 255, 255).$1, 255);
    });

    test('brightness order is kept: a grey is darker than white', () {
      expect(apply(64, 64, 64).$1, lessThan(apply(255, 255, 255).$1));
    });

    test('alpha passes through', () {
      final m = AppTheme.fieldFilterMatrix;
      expect(m.sublist(15), [0, 0, 0, 1, 0]);
    });
  });
}

List<TextStyle> _styles(TextTheme t) => [
  t.displayLarge!, t.displayMedium!, t.displaySmall!, //
  t.headlineLarge!, t.headlineMedium!, t.headlineSmall!, //
  t.titleLarge!, t.titleMedium!, t.titleSmall!, //
  t.bodyLarge!, t.bodyMedium!, t.bodySmall!, //
  t.labelLarge!, t.labelMedium!, t.labelSmall!,
];
