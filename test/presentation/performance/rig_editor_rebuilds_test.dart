// S10.2 and S10.3 (Stage 10; 08 §22): the rig editor's rebuild counts, the
// deterministic half of the form-lag scenario. The keyboard is simulated as
// Android animates it: the bottom inset grows over a dozen frames. Before
// S10.3 the whole form rebuilt on every one of those frames (its
// `MediaQuery.of`); the counts are in
// docs/refinement/evidence/STAGE_10_MEASUREMENTS.md.

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_editor.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../support/in_memory_equipment_repository.dart';

/// Counts the elements rebuilt while [action] runs: all of them, and the
/// editor's dialog content (the [StatefulBuilder] under the [AlertDialog]).
Future<({int all, int dialog})> _rebuilds(
  Future<void> Function() action,
) async {
  var all = 0, dialog = 0;
  final previous = debugOnRebuildDirtyWidget;
  debugOnRebuildDirtyWidget = (element, builtOnce) {
    all++;
    if (element.widget is StatefulBuilder) dialog++;
  };
  try {
    await action();
  } finally {
    debugOnRebuildDirtyWidget = previous;
  }
  return (all: all, dialog: dialog);
}

Future<void> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(412, 915);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => GearViewModel(InMemoryEquipmentRepository()),
      child: MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showEquipmentEditor(
                context,
                draft: EquipmentDraft.fromProfile(
                  EquipmentSeeder.defaults.single,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

/// The keyboard opening: the bottom inset grows to [height] over [frames].
Future<void> _keyboardOpens(
  WidgetTester tester, {
  double height = 300,
  int frames = 12,
}) async {
  for (var i = 1; i <= frames; i++) {
    tester.view.viewInsets = FakeViewPadding(bottom: height * i / frames);
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('the keyboard opening does not rebuild the form (S10.3)', (
    tester,
  ) async {
    await _open(tester);
    final counts = await _rebuilds(() => _keyboardOpens(tester));
    expect(counts.dialog, 0, reason: 'the form rebuilt on a keyboard frame');
    expect(tester.takeException(), isNull);
  });

  testWidgets('a keystroke in the pixel size rebuilds the form once, for '
      'the derived sensor size', (tester) async {
    await _open(tester);
    final field = find.byKey(const Key('equipmentEditor.pixelSize'));
    await tester.tap(field);
    await tester.pump();
    final counts = await _rebuilds(() async {
      for (final text in ['3', '3.', '3.7', '3.76', '3.761', '3.7612']) {
        await tester.enterText(field, text);
        await tester.pump();
      }
    });
    expect(counts.dialog, 6);
  });

  testWidgets('a keystroke in the name does not rebuild the form', (
    tester,
  ) async {
    await _open(tester);
    final field = find.widgetWithText(TextFormField, 'Rig name');
    await tester.tap(field);
    await tester.pump();
    final counts = await _rebuilds(() async {
      for (final text in ['R', 'Re', 'Ref', 'Refr', 'Refra', 'Refrac']) {
        await tester.enterText(field, text);
        await tester.pump();
      }
    });
    expect(counts.dialog, 0);
  });
}
