// S7.6 (UX-22; RG-03 = Q1, so no source path): the rig form asks once for
// each value and keeps the rare ones one tap away. The pixel size is one
// field; the maximum exposure, the RAW size and the rotation sit in "More
// (optional)", collapsed, with a summary of what is set; nothing stored is
// lost or reinterpreted; the glossary title and a primary Save.

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_editor.dart';
import 'package:astroplan/presentation/shared/collapsible_section.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../support/in_memory_equipment_repository.dart';

const _rig = EquipmentProfile(
  id: 4,
  name: 'Refractor',
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.7,
  pixelPitchUm: 3.76,
  resolutionWidthPx: 6248,
  resolutionHeightPx: 4176,
  focalLengthMm: 400,
  focalRatio: 5, // = 400 / 80 (ADR-011 §4)
  apertureDiameterMm: 80,
  averageRawFileSizeMB: 50,
  rotationDeg: 90,
  trackingType: TrackingType.guided,
  maxExposureS: 300,
);

const _more = Key('section.$rigEditorMoreSection');

void main() {
  Future<InMemoryEquipmentRepository> open(
    WidgetTester tester, {
    EquipmentProfile? existing,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = const Size(412, 1600);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final repo = InMemoryEquipmentRepository();
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GearViewModel(repo),
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showEquipmentEditor(
                  context,
                  draft: EquipmentDraft.fromProfile(existing),
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
    return repo;
  }

  Future<void> tapMore(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(_more));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(_more));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    final button = find.byType(FilledButton);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('the glossary title and a primary Save', (tester) async {
    await open(tester);
    expect(find.text('Add rig'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.textContaining('Equipment'), findsNothing);
  });

  testWidgets('the pixel size is asked once and derives the sensor size', (
    tester,
  ) async {
    await open(tester);
    expect(find.widgetWithText(TextFormField, 'Pixel size (µm)'), findsOne);
    expect(find.widgetWithText(TextFormField, '3.76'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, '6248'), '6000');
    await tester.enterText(find.widgetWithText(TextFormField, '4176'), '4000');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Pixel size (µm)'),
      '4',
    );
    await tester.pump();
    expect(find.widgetWithText(TextFormField, '24.00'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '16.00'), findsOneWidget);
  });

  testWidgets('"More (optional)" is collapsed; its summary states what is '
      'set; one tap shows the fields', (tester) async {
    await open(tester, existing: _rig);
    expect(find.text('Edit rig'), findsOneWidget);
    expect(find.text('maximum 300 s · RAW 50 MB · rotation 90°'), findsOne);
    expect(
      find.widgetWithText(TextFormField, 'Maximum sub-exposure (s)'),
      findsNothing,
    );
    await tapMore(tester);
    for (final label in [
      'Maximum sub-exposure (s)',
      'Average RAW file size (MB)',
      'Rotation (°)',
    ]) {
      expect(find.widgetWithText(TextFormField, label), findsOneWidget);
    }
  });

  testWidgets('a new rig: nothing set', (tester) async {
    await open(tester);
    expect(
      find.text('Maximum exposure, RAW size, rotation: not set'),
      findsOneWidget,
    );
  });

  testWidgets('saved unchanged with the section closed: every value kept, '
      'none reinterpreted', (tester) async {
    final repo = await open(tester, existing: _rig);
    await save(tester);
    final saved = repo.updated.single;
    expect(
      (
        saved.maxExposureS,
        saved.averageRawFileSizeMB,
        saved.rotationDeg,
        saved.pixelPitchUm,
        saved.focalRatio,
        saved.apertureDiameterMm,
        saved.trackingType,
      ),
      (300.0, 50.0, 90.0, 3.76, 5.0, 80.0, TrackingType.guided),
    );
  });

  testWidgets('an invalid value in the closed section: Save opens it, shows '
      'why, and saves nothing', (tester) async {
    final repo = await open(tester, existing: _rig);
    await tapMore(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Rotation (°)'),
      '999',
    );
    await tapMore(tester); // closed again
    expect(find.widgetWithText(TextFormField, 'Rotation (°)'), findsNothing);
    await save(tester);
    expect(find.widgetWithText(TextFormField, 'Rotation (°)'), findsOneWidget);
    expect(find.textContaining('Must be'), findsOneWidget);
    expect(repo.updated, isEmpty);
  });

  testWidgets('no overflow at 200 % text, open or closed', (tester) async {
    await open(tester, existing: _rig, textScale: 2);
    expect(tester.takeException(), isNull);
    await tapMore(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CollapsibleSection, controlled: no DisclosureViewModel, the '
      'caller holds the state', (tester) async {
    var open = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => CollapsibleSection(
              sectionKey: 'test.controlled',
              title: 'Title',
              summary: 'Summary',
              open: open,
              onToggle: () => setState(() => open = !open),
              child: const Text('Body'),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Body'), findsNothing);
    await tester.tap(find.byKey(const Key('section.test.controlled')));
    await tester.pumpAndSettle();
    expect(open, isTrue);
    expect(find.text('Body'), findsOneWidget);
  });
}
