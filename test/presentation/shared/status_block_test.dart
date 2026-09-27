// S5.4 (ADR-019 §6): the status block leads with the verdict in the
// glossary's words and its status colour; a missing input is neutral; a
// duration that is not known is not invented; the reason, key numbers and
// action follow.

import 'package:astroplan/core/theme/app_palette.dart';
import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/domain/services/fit_analyzer.dart';
import 'package:astroplan/presentation/shared/app_words.dart';
import 'package:astroplan/presentation/shared/status_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _needed = Duration(hours: 2, minutes: 5);
const _usable = Duration(hours: 4, minutes: 20);

void main() {
  group('the headline', () {
    test('a verdict names the time needed and the usable time', () {
      expect(
        StatusBlock.headline(FitState.fits, needed: _needed, usable: _usable),
        'Fits: 2 h 5 min needed of 4 h 20 min usable',
      );
      expect(
        StatusBlock.headline(FitState.tight, needed: _needed, usable: _usable),
        startsWith('Tight: '),
      );
      expect(
        StatusBlock.headline(
          FitState.doesNotFit,
          needed: _needed,
          usable: _usable,
        ),
        startsWith("Doesn't fit: "),
      );
    });

    test('without both durations it is the word alone (unknown stays '
        'unknown)', () {
      expect(StatusBlock.headline(FitState.fits), AppWords.fits);
      expect(
        StatusBlock.headline(FitState.fits, needed: _needed),
        AppWords.fits,
      );
    });

    test('no window, a missing target and a missing block', () {
      expect(StatusBlock.headline(FitState.noWindow), AppWords.noWindow);
      expect(StatusBlock.headline(FitState.needsInput), AppWords.needsTarget);
      expect(
        StatusBlock.headline(FitState.needsInput, missing: AppWords.needsBlock),
        AppWords.needsBlock,
      );
      expect(StatusBlock.headline(FitState.nothingToFit), AppWords.needsBlock);
    });
  });

  group('the tokens', () {
    for (final (name, t) in [
      ('light', AppTheme.light),
      ('dark', AppTheme.dark),
      ('field', AppTheme.fieldTheme),
    ]) {
      testWidgets('$name: each state draws its status token', (tester) async {
        final p = t.extension<AppPalette>()!;
        final expected = {
          FitState.fits: p.statusFits,
          FitState.tight: p.statusTight,
          FitState.doesNotFit: p.statusDoesNotFit,
          FitState.noWindow: p.statusNoWindow,
          FitState.needsInput: p.statusNeutral,
          FitState.nothingToFit: p.statusNeutral,
        };
        for (final e in expected.entries) {
          await tester.pumpWidget(
            MaterialApp(
              theme: t,
              home: Scaffold(body: StatusBlock(state: e.key)),
            ),
          );
          final headline = tester.widget<Text>(
            find.byKey(const Key('status.headline')),
          );
          expect(headline.style!.color, e.value, reason: e.key.name);
        }
      });
    }

    test('a missing input is neutral, never the error colour', () {
      for (final p in [AppPalette.light, AppPalette.dark]) {
        expect(p.statusNeutral, isNot(p.statusNoWindow));
        expect(p.statusTight, isNot(p.statusNeutral));
      }
    });
  });

  testWidgets('the reason, the key numbers and the action follow', (
    tester,
  ) async {
    var filled = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: StatusBlock(
            state: FitState.fits,
            needed: _needed,
            usable: _usable,
            reason: 'Everything fits with 2 h 15 min of window time to spare.',
            keyNumbers: const [
              ('Capture ends', '01:40'),
              ('Integration', '1 h 40 min'),
            ],
            action: TextButton(
              onPressed: () => filled = true,
              child: const Text("Fill tonight's window"),
            ),
          ),
        ),
      ),
    );
    expect(find.textContaining('window time to spare'), findsOneWidget);
    expect(find.textContaining('Capture ends'), findsOneWidget);
    expect(find.textContaining('1 h 40 min'), findsOneWidget);
    await tester.tap(find.text("Fill tonight's window"));
    expect(filled, isTrue);
    expect(
      tester.getSemantics(find.byKey(const Key('status.headline'))),
      matchesSemantics(
        label: 'Fits: 2 h 5 min needed of 4 h 20 min usable',
        isHeader: true,
      ),
    );
  });
}
