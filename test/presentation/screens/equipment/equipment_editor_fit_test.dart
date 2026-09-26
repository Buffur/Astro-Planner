// S3.10 (TD-069): on the owner's phone (375 dp wide, font scale 1.0) the
// editor's read-only sensor-size fields showed "9.8" for 9.89. A clipped
// text field raises no layout error, so the accessibility sweep cannot see
// it; this test compares each W × H field's text width with its box. It
// loads Roboto (the Android default font) from the Flutter SDK, because the
// test font draws every character a full em wide and would exaggerate.

import 'dart:io';

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_editor.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../support/in_memory_equipment_repository.dart';
import '../../../support/metadata_candidates.dart';

/// Loads Roboto from the SDK that runs the test (`bin/cache/artifacts`).
Future<void> _loadRoboto() async {
  final root =
      Platform.environment['FLUTTER_ROOT'] ??
      Platform.resolvedExecutable.substring(
        0,
        Platform.resolvedExecutable.indexOf(
          '${Platform.pathSeparator}bin${Platform.pathSeparator}cache',
        ),
      );
  final dir = [
    root,
    'bin',
    'cache',
    'artifacts',
    'material_fonts',
  ].join(Platform.pathSeparator);
  final loader = FontLoader('Roboto');
  for (final f in ['roboto-regular.ttf', 'roboto-medium.ttf']) {
    final file = File('$dir${Platform.pathSeparator}$f');
    expect(file.existsSync(), isTrue, reason: 'Roboto not found at $dir');
    loader.addFont(file.readAsBytes().then((b) => ByteData.sublistView(b)));
  }
  await loader.load();
}

/// Every W × H field (resolution, pixel size, sensor size) whose text is
/// wider than its box.
List<String> _clipped(WidgetTester tester) => [
  for (final e in tester.widgetList<EditableText>(
    find.descendant(
      of: find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_StellariumRow',
      ),
      matching: find.byType(EditableText),
    ),
  ))
    if (RegExp(r'^[0-9.]+$').hasMatch(e.controller.text))
      if (tester.renderObject<RenderEditable>(
            find.descendant(
              of: find.byWidget(e),
              matching: find.byWidgetPredicate(
                (w) => w.runtimeType.toString() == '_Editable',
              ),
            ),
          )
          case final r
          when r.getMaxIntrinsicWidth(double.infinity) > r.size.width + 0.5)
        '"${e.controller.text}" needs '
            '${r.getMaxIntrinsicWidth(double.infinity).toStringAsFixed(1)} '
            'in ${r.size.width.toStringAsFixed(1)}',
];

Future<void> _open(
  WidgetTester tester,
  EquipmentDraft draft, {
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => GearViewModel(InMemoryEquipmentRepository()),
      child: MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showEquipmentEditor(context, draft: draft),
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

void main() {
  setUpAll(_loadRoboto);

  final drafts = {
    'the M4 phone draft': EquipmentDraft.fromCandidate(phoneCandidate()),
    'the seeded rig': EquipmentDraft.fromProfile(
      EquipmentSeeder.defaults.single,
    ),
  };
  for (final scale in [1.0, 1.3]) {
    for (final MapEntry(key: name, value: draft) in drafts.entries) {
      testWidgets('numeric fields show their whole value on a 375 dp phone: '
          '$name, text ${(scale * 100).round()} %', (tester) async {
        await _open(tester, draft, textScale: scale);
        // Scroll the dialog through, checking every part.
        final problems = <String>{..._clipped(tester)};
        final list = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(Scrollable),
        );
        for (var i = 0; i < 6; i++) {
          await tester.drag(list.first, const Offset(0, -250));
          await tester.pumpAndSettle();
          problems.addAll(_clipped(tester));
        }
        expect(problems, isEmpty);
      });
    }
  }
}
