// S5.5 (ADR-019 §7): a collapsible section opens and closes with a tap on
// its 48 dp header, announces its state, keeps its summary visible, opens
// as the user left it after a restart, still works with a broken store,
// and honours reduced motion.

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/presentation/shared/collapsible_section.dart';
import 'package:astroplan/presentation/viewmodels/disclosure_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../support/in_memory_display_preferences.dart';

const _key = 'planner.budgetDetails';
final _header = find.byKey(const Key('section.$_key'));

Future<DisclosureViewModel> _pump(
  WidgetTester tester,
  InMemoryDisplayPreferences store, {
  bool reducedMotion = false,
}) async {
  final vm = DisclosureViewModel(store);
  await vm.load(); // as main.dart does before the first frame
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: vm,
      child: MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reducedMotion),
          child: const Scaffold(
            body: CollapsibleSection(
              sectionKey: _key,
              title: 'Budget details',
              summary: '4 lines · 2 h 35 min total',
              child: Text('Calibration during the window 10 min'),
            ),
          ),
        ),
      ),
    ),
  );
  return vm;
}

final _content = find.text('Calibration during the window 10 min');

void main() {
  testWidgets('a tap opens and closes it; the summary stays; the state is '
      'announced', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, InMemoryDisplayPreferences());
    expect(_content, findsNothing);
    expect(find.text('4 lines · 2 h 35 min total'), findsOneWidget);
    expect(
      tester.getSemantics(_header),
      matchesSemantics(
        label: 'Budget details, 4 lines · 2 h 35 min total',
        hint: 'Expand',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasExpandedState: true,
        isExpanded: false,
        hasTapAction: true,
      ),
    );
    expect(tester.getSize(_header).height, greaterThanOrEqualTo(48));

    await tester.tap(_header);
    await tester.pumpAndSettle();
    expect(_content, findsOneWidget);
    expect(find.text('4 lines · 2 h 35 min total'), findsOneWidget);
    expect(
      tester.getSemantics(_header),
      matchesSemantics(
        label: 'Budget details, 4 lines · 2 h 35 min total',
        hint: 'Collapse',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasExpandedState: true,
        isExpanded: true,
        hasTapAction: true,
      ),
    );

    await tester.tap(_header);
    await tester.pumpAndSettle();
    expect(_content, findsNothing);
    handle.dispose();
  });

  testWidgets('it opens as the user left it after a restart', (tester) async {
    final store = InMemoryDisplayPreferences();
    await _pump(tester, store);
    await tester.tap(_header);
    await tester.pumpAndSettle();
    expect(store.sections, {_key: true});

    // A new app start: a new ViewModel on the same store.
    await tester.pumpWidget(const SizedBox());
    await _pump(tester, store);
    expect(_content, findsOneWidget);
  });

  testWidgets('a broken store still opens and closes it', (tester) async {
    final store = InMemoryDisplayPreferences()..failSections = true;
    await _pump(tester, store);
    await tester.tap(_header);
    await tester.pumpAndSettle();
    expect(_content, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('with reduced motion it opens without an animation', (
    tester,
  ) async {
    await _pump(tester, InMemoryDisplayPreferences(), reducedMotion: true);
    await tester.tap(_header);
    await tester.pump(); // one frame, no settling
    expect(_content, findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.byType(AnimatedSize), findsNothing);
    expect(
      tester.widget<AnimatedRotation>(find.byType(AnimatedRotation)).duration,
      Duration.zero,
    );
  });
}
