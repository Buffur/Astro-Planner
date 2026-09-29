// S10.2 (Stage 10; 08 §22): the rig editor's rebuild counts, the
// deterministic half of the form-lag scenario. The keyboard is simulated as
// Android animates it: the bottom inset grows over a dozen frames. The
// counts are recorded in docs/refinement/evidence/STAGE_10_MEASUREMENTS.md.

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
  testWidgets('the keyboard opening: rebuilds of the editor per frame', (
    tester,
  ) async {
    await _open(tester);
    final counts = await _rebuilds(() => _keyboardOpens(tester));
    // ignore: avoid_print
    print('keyboard (12 frames): all ${counts.all}, dialog ${counts.dialog}');
  });

  testWidgets('typing in the pixel size: rebuilds per keystroke', (
    tester,
  ) async {
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
    // ignore: avoid_print
    print('typing (6 keys): all ${counts.all}, dialog ${counts.dialog}');
  });

  testWidgets('typing in the name: rebuilds per keystroke', (tester) async {
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
    // ignore: avoid_print
    print('name (6 keys): all ${counts.all}, dialog ${counts.dialog}');
  });
}
