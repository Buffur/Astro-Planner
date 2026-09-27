// S5.2: the controls' tokens and component themes. Control borders are
// 3:1 and the error colour AA in light and dark; every component theme is
// red or black in field mode; buttons are 48 dp tall; the destructive role
// is the error colour; motion honours reduced motion.

import 'package:astroplan/core/theme/app_button_styles.dart';
import 'package:astroplan/core/theme/app_motion.dart';
import 'package:astroplan/core/theme/app_palette.dart';
import 'package:astroplan/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}

bool _redOnly(Color c) => (c.g * 255).round() == 0 && (c.b * 255).round() == 0;

const _states = <Set<WidgetState>>[
  {},
  {WidgetState.pressed},
  {WidgetState.focused},
  {WidgetState.hovered},
  {WidgetState.disabled},
  {WidgetState.error},
  {WidgetState.focused, WidgetState.error},
];

/// Every colour a button style can resolve to.
Iterable<Color> _buttonColours(ButtonStyle? s) sync* {
  if (s == null) return;
  for (final states in _states) {
    for (final p in [
      s.foregroundColor,
      s.backgroundColor,
      s.overlayColor,
      s.iconColor,
      s.surfaceTintColor,
    ]) {
      final c = p?.resolve(states);
      if (c != null && c.a > 0) yield c;
    }
    final side = s.side?.resolve(states);
    if (side != null) yield side.color;
  }
}

void main() {
  for (final (name, t) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
  ]) {
    group(name, () {
      final p = t.extension<AppPalette>()!;
      final s = t.colorScheme;
      final surfaces = [t.scaffoldBackgroundColor, s.surface, p.surfaceRaised];

      test('a control border is at least 3:1 on every surface, and it is '
          'what Material draws field underlines with (outline)', () {
        for (final bg in surfaces) {
          expect(_contrast(p.controlBorder, bg), greaterThanOrEqualTo(3));
        }
        expect(s.outline, p.controlBorder);
      });

      test('the error colour is AA as text, and on it', () {
        for (final bg in surfaces) {
          expect(_contrast(s.error, bg), greaterThanOrEqualTo(4.5));
        }
        expect(_contrast(s.onError, s.error), greaterThanOrEqualTo(4.5));
      });

      test('a message is AA', () {
        final m = t.snackBarTheme;
        expect(
          _contrast(m.contentTextStyle!.color!, m.backgroundColor!),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(m.actionTextColor!, m.backgroundColor!),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('field labels, hints and helpers are text roles', () {
        final i = t.inputDecorationTheme;
        expect(i.labelStyle!.color, p.textSecondary);
        expect(i.hintStyle!.color, p.textTertiary);
        expect(i.helperStyle!.color, p.textTertiary);
        expect(i.errorStyle!.color, s.error);
      });
    });
  }

  test('field mode: every component theme is red or black', () {
    final t = AppTheme.fieldTheme;
    final i = t.inputDecorationTheme;
    final colours = [
      ..._buttonColours(t.filledButtonTheme.style),
      ..._buttonColours(t.outlinedButtonTheme.style),
      ..._buttonColours(t.elevatedButtonTheme.style),
      ..._buttonColours(t.textButtonTheme.style),
      ..._buttonColours(t.iconButtonTheme.style),
      ..._buttonColours(AppButtonStyles.destructive(t.colorScheme)),
      ..._buttonColours(AppButtonStyles.destructiveText(t.colorScheme)),
      i.labelStyle!.color!,
      i.hintStyle!.color!,
      i.helperStyle!.color!,
      i.errorStyle!.color!,
      i.prefixIconColor!,
      i.suffixIconColor!,
      i.fillColor!,
      for (final states in _states)
        (i.floatingLabelStyle! as WidgetStateTextStyle).resolve(states).color!,
      t.dialogTheme.backgroundColor!,
      t.dialogTheme.titleTextStyle!.color!,
      t.dialogTheme.contentTextStyle!.color!,
      (t.dialogTheme.shape! as RoundedRectangleBorder).side.color,
      t.bottomSheetTheme.backgroundColor!,
      t.bottomSheetTheme.modalBackgroundColor!,
      t.popupMenuTheme.color!,
      t.popupMenuTheme.labelTextStyle!.resolve({})!.color!,
      t.menuTheme.style!.backgroundColor!.resolve({})!,
      t.snackBarTheme.backgroundColor!,
      t.snackBarTheme.contentTextStyle!.color!,
    ];
    expect(colours.where((c) => !_redOnly(c)), isEmpty);
  });

  test('field mode: a control border is brighter than a card border '
      '(UX-39)', () {
    const p = AppPalette.field;
    expect(
      p.controlBorder.computeLuminance(),
      greaterThan(p.border.computeLuminance()),
    );
  });

  test('primary and secondary buttons are at least 48 dp tall; the '
      'pressed overlay is stronger than Material\'s 10 %', () {
    for (final t in [AppTheme.light, AppTheme.dark, AppTheme.fieldTheme]) {
      for (final style in [
        t.filledButtonTheme.style!,
        t.outlinedButtonTheme.style!,
        t.elevatedButtonTheme.style!,
      ]) {
        expect(style.minimumSize!.resolve({})!.height, 48);
        final pressed = style.overlayColor!.resolve({WidgetState.pressed})!;
        expect(pressed.a, closeTo(AppTheme.pressedOverlay, 0.01));
      }
      expect(t.elevatedButtonTheme.style!.elevation!.resolve({}), 0);
    }
  });

  test('the destructive role is the error colour', () {
    final s = AppTheme.light.colorScheme;
    expect(
      AppButtonStyles.destructive(s).backgroundColor!.resolve({}),
      s.error,
    );
    expect(
      AppButtonStyles.destructiveText(s).foregroundColor!.resolve({}),
      s.error,
    );
  });

  testWidgets('motion is off when the platform asks for less', (tester) async {
    late Duration normal, reduced;
    await tester.pumpWidget(
      Builder(
        builder: (c) {
          normal = AppMotion.duration(c, AppMotion.medium);
          return MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (c) {
                reduced = AppMotion.duration(c, AppMotion.medium);
                return const SizedBox();
              },
            ),
          );
        },
      ),
    );
    expect(normal, AppMotion.medium);
    expect(reduced, Duration.zero);
  });
}
