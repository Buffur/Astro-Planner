// S3.5: the rig editor opened on a draft pre-filled from a metadata
// candidate. Each pre-filled value says where it came from until it is
// edited; nothing is written before Save (ADR-018 §2, §4–§5).

import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/domain/repositories/equipment_repository.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_editor.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../support/metadata_candidates.dart';

class _Repository implements EquipmentRepository {
  final inserted = <EquipmentProfile>[];

  @override
  Future<int> insertEquipment(EquipmentProfile profile) async {
    inserted.add(profile);
    return inserted.length;
  }

  @override
  Future<List<EquipmentProfile>> getAllEquipment() async => inserted;

  @override
  Future<EquipmentProfile?> getEquipmentById(int id) async => null;

  @override
  Future<void> updateEquipment(EquipmentProfile profile) async {}

  @override
  Future<void> deleteEquipment(int id) async {}
}

Future<_Repository> _open(WidgetTester tester, EquipmentDraft draft) async {
  final repo = _Repository();
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => GearViewModel(repo),
      child: MaterialApp(
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
  return repo;
}

String? _note(WidgetTester tester, EquipmentSpec spec) {
  final f = find.byKey(Key('editor.prefill.${spec.name}'));
  return f.evaluate().isEmpty ? null : tester.widget<Text>(f).data;
}

void main() {
  testWidgets('pre-filled values show their origin; the diameter, tracking '
      'and limits are left to the user', (tester) async {
    await _open(tester, EquipmentDraft.fromCandidate(phoneCandidate()));
    expect(find.text('Add Equipment Profile'), findsOneWidget);
    expect(_note(tester, EquipmentSpec.focalLength), 'From the file (JPEG)');
    expect(_note(tester, EquipmentSpec.resolution), 'From the file (JPEG)');
    expect(
      _note(tester, EquipmentSpec.pixelPitch),
      'Estimated from the 35 mm equivalent — check it',
    );
    expect(
      _note(tester, EquipmentSpec.sensorSize),
      'Estimated from the 35 mm equivalent — check it',
    );
    expect(_note(tester, EquipmentSpec.rawFileSize), isNull);
    expect(find.widgetWithText(TextFormField, '6.57'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(
            find.widgetWithText(TextFormField, 'Aperture diameter (mm)'),
          )
          .controller!
          .text,
      '',
    );
  });

  testWidgets('saved untouched: each value keeps its origin, and the file '
      'identity is stored', (tester) async {
    final repo = await _open(
      tester,
      EquipmentDraft.fromCandidate(phoneCandidate()),
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final p = repo.inserted.single;
    expect(
      p.provenanceOf(EquipmentSpec.focalLength),
      const SpecProvenance('metadata:jpeg', SpecConfidence.reported),
    );
    expect(
      p.provenanceOf(EquipmentSpec.pixelPitch)?.confidence,
      SpecConfidence.estimated,
    );
    expect(p.metadataModel, 'TestMake TestPhone');
    expect(p.apertureDiameterMm, isNull);
    expect(find.text('Add Equipment Profile'), findsNothing);
  });

  testWidgets('editing the pixel size makes it (and the sensor size derived '
      'from it) the user\'s own', (tester) async {
    final repo = await _open(
      tester,
      EquipmentDraft.fromCandidate(phoneCandidate()),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, '2.414').first,
      '2.5',
    );
    await tester.pump();
    expect(_note(tester, EquipmentSpec.pixelPitch), isNull);
    expect(_note(tester, EquipmentSpec.sensorSize), isNull);
    expect(_note(tester, EquipmentSpec.focalLength), 'From the file (JPEG)');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final p = repo.inserted.single;
    expect(p.pixelPitchUm, 2.5);
    expect(p.sensorWidthMm, 10.24);
    expect(p.provenanceOf(EquipmentSpec.pixelPitch), SpecProvenance.user);
    expect(p.provenanceOf(EquipmentSpec.sensorSize), SpecProvenance.user);
    expect(p.provenanceOf(EquipmentSpec.focalLength)?.source, 'metadata:jpeg');
  });

  testWidgets('Cancel writes nothing', (tester) async {
    final repo = await _open(
      tester,
      EquipmentDraft.fromCandidate(phoneCandidate()),
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repo.inserted, isEmpty);
  });

  testWidgets('what the file lacks is required: Save is refused until the '
      'user fills it', (tester) async {
    final repo = await _open(
      tester,
      EquipmentDraft.fromCandidate(phoneCandidate(withDims: false)),
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsWidgets);
    expect(repo.inserted, isEmpty);
  });
}
