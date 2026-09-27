// S5.4 (ADR-019 §3): the plan state a user sees, from today's stored
// fields, for every combination; its word is the glossary's and its tone a
// palette token, AA in light and dark and red in field mode.

import 'package:astroplan/core/theme/app_palette.dart';
import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/presentation/shared/app_words.dart';
import 'package:astroplan/presentation/shared/plan_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}

void main() {
  group('the mapping from stored fields', () {
    const expected = {
      SessionStatus.draft: (PlanState.notSaved, PlanState.savedChanged),
      SessionStatus.planned: (PlanState.saved, PlanState.saved),
      SessionStatus.inProgress: (PlanState.tracking, PlanState.tracking),
      SessionStatus.completed: (PlanState.completed, PlanState.completed),
      SessionStatus.abandoned: (PlanState.notDone, PlanState.notDone),
    };

    for (final status in SessionStatus.values) {
      for (final savedBefore in [false, true]) {
        test('${status.name}, ${savedBefore ? '' : 'never '}saved', () {
          final (never, once) = expected[status]!;
          expect(
            PlanState.from(
              status: status,
              savedBefore: savedBefore,
              legacy: false,
            ),
            savedBefore ? once : never,
          );
          // A legacy row is an old log whatever its status.
          expect(
            PlanState.from(
              status: status,
              savedBefore: savedBefore,
              legacy: true,
            ),
            PlanState.oldLog,
          );
        });
      }
    }

    test('no stored combination is "Partly" yet (Stage 8 stores it)', () {
      final reachable = {
        for (final status in SessionStatus.values)
          for (final savedBefore in [false, true])
            for (final legacy in [false, true])
              PlanState.from(
                status: status,
                savedBefore: savedBefore,
                legacy: legacy,
              ),
      };
      expect(reachable, isNot(contains(PlanState.partly)));
      expect(reachable, hasLength(PlanState.values.length - 1));
    });
  });

  test('each state says the glossary\'s word; "Draft" is never shown', () {
    expect(PlanState.values.map((s) => s.word).toList(), [
      AppWords.notSaved,
      AppWords.saved,
      AppWords.savedChanged,
      AppWords.tracking,
      AppWords.completed,
      AppWords.partly,
      AppWords.notDone,
      AppWords.oldLog,
    ]);
    for (final s in PlanState.values) {
      expect(s.word.toLowerCase(), isNot(contains('draft')));
    }
  });

  for (final (name, t) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
  ]) {
    test('$name: every tone is AA on every surface', () {
      final p = t.extension<AppPalette>()!;
      for (final s in PlanState.values) {
        for (final bg in [
          t.scaffoldBackgroundColor,
          t.colorScheme.surface,
          p.surfaceRaised,
        ]) {
          expect(_contrast(s.tone(p), bg), greaterThanOrEqualTo(4.5));
        }
      }
    });
  }

  test('unsaved work draws attention, settled plans read as primary text', () {
    const p = AppPalette.light;
    expect(PlanState.notSaved.tone(p), p.stateUnsaved);
    expect(PlanState.savedChanged.tone(p), p.stateUnsaved);
    expect(PlanState.saved.tone(p), p.stateSettled);
    expect(PlanState.notDone.tone(p), p.stateQuiet);
    expect(p.stateUnsaved, isNot(p.stateSettled));
  });

  testWidgets('the label shows the word in its tone', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: PlanStateLabel(PlanState.savedChanged)),
      ),
    );
    final text = tester.widget<Text>(find.text('Saved · changed'));
    expect(text.style!.color, AppPalette.light.stateUnsaved);
  });
}
