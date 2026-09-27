// S5.1: the foundation tokens. The text roles are WCAG AA on every surface
// in light and dark, a documented step apart; field mode's roles step down
// in brightness; the colour scheme is wired to the roles; every theme
// carries the one type scale and radius.

import 'package:astroplan/core/theme/app_palette.dart';
import 'package:astroplan/core/theme/app_radius.dart';
import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG contrast ratio of [a] on [b].
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}

/// The documented step between neighbouring text roles (DESIGN_SYSTEM.md).
const _step = 1.3;

List<Color> _surfaces(ThemeData t) => [
  t.scaffoldBackgroundColor,
  t.colorScheme.surface,
  t.extension<AppPalette>()!.surfaceRaised,
];

double _worst(Color text, ThemeData t) =>
    _surfaces(t).map((s) => _contrast(text, s)).reduce((a, b) => a < b ? a : b);

List<TextStyle?> _styles(TextTheme t) => [
  t.displayLarge, t.displayMedium, t.displaySmall, //
  t.headlineLarge, t.headlineMedium, t.headlineSmall, //
  t.titleLarge, t.titleMedium, t.titleSmall, //
  t.bodyLarge, t.bodyMedium, t.bodySmall, //
  t.labelLarge, t.labelMedium, t.labelSmall,
];

void main() {
  const themes = [
    ('light', AppPalette.light),
    ('dark', AppPalette.dark),
    ('field', AppPalette.field),
  ];
  ThemeData theme(String name) => switch (name) {
    'light' => AppTheme.light,
    'dark' => AppTheme.dark,
    _ => AppTheme.fieldTheme,
  };

  for (final name in ['light', 'dark']) {
    group('$name text roles', () {
      final t = theme(name);
      final p = t.extension<AppPalette>()!;

      test('primary, secondary and tertiary are AA (4.5:1) on the '
          'background, the surface and the raised surface', () {
        for (final role in [p.textPrimary, p.textSecondary, p.textTertiary]) {
          expect(_worst(role, t), greaterThanOrEqualTo(4.5));
        }
      });

      test('text on a selected container (segments, the navigation '
          'indicator) is AA', () {
        final s = t.colorScheme;
        expect(
          _contrast(s.onSecondaryContainer, s.secondaryContainer),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('each role is at least $_step times the next one\'s contrast, '
          'and disabled is below tertiary', () {
        expect(
          _worst(p.textPrimary, t),
          greaterThanOrEqualTo(_step * _worst(p.textSecondary, t)),
        );
        expect(
          _worst(p.textSecondary, t),
          greaterThanOrEqualTo(_step * _worst(p.textTertiary, t)),
        );
        expect(_worst(p.textDisabled, t), lessThan(_worst(p.textTertiary, t)));
      });
    });
  }

  test('field mode: the roles step down in brightness', () {
    const p = AppPalette.field;
    final l = [
      p.textPrimary,
      p.textSecondary,
      p.textTertiary,
      p.textDisabled,
    ].map((c) => c.computeLuminance()).toList();
    for (var i = 1; i < l.length; i++) {
      expect(l[i], lessThan(l[i - 1]));
    }
  });

  for (final (name, palette) in themes) {
    group('$name wiring', () {
      final t = theme(name);

      test('the colour scheme follows the text roles and the raised '
          'surface', () {
        final s = t.colorScheme;
        expect(s.onSurface, palette.textPrimary);
        expect(s.onSurfaceVariant, palette.textSecondary);
        expect(s.surfaceContainerHigh, palette.surfaceRaised);
        if (name != 'field') expect(s.secondary, palette.textSecondary);
      });

      test('every style has the scale\'s size, line height and weight', () {
        final shown = ThemeData.localize(t, t.typography.englishLike);
        final actual = _styles(shown.textTheme);
        final expected = _styles(AppTypography.scale);
        for (var i = 0; i < actual.length; i++) {
          expect(actual[i]!.fontSize, expected[i]!.fontSize);
          expect(actual[i]!.height, expected[i]!.height);
          expect(actual[i]!.fontWeight, expected[i]!.fontWeight);
          expect(actual[i]!.fontSize, greaterThanOrEqualTo(12));
        }
      });

      test('cards use the small radius', () {
        final shape = t.cardTheme.shape! as RoundedRectangleBorder;
        expect(shape.borderRadius, BorderRadius.circular(AppRadius.small));
      });
    });
  }
}
