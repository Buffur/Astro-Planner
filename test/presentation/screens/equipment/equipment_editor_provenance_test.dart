// S3.V7 (S3S-01, TD-070): the rig editor states where a saved rig's specs
// came from per spec (ADR-018 §5). A rig-wide `user` never presents an
// imported or estimated value as the user's own, and unknown stays unknown.

import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_editor.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../../support/in_memory_equipment_repository.dart';
import '../../../support/metadata_candidates.dart';

/// [p] as saved under [id].
EquipmentProfile _saved(EquipmentProfile p, {int id = 7}) => EquipmentProfile(
  id: id,
  name: p.name,
  manufacturer: p.manufacturer,
  cameraModel: p.cameraModel,
  sensorWidthMm: p.sensorWidthMm,
  sensorHeightMm: p.sensorHeightMm,
  pixelPitchUm: p.pixelPitchUm,
  resolutionWidthPx: p.resolutionWidthPx,
  resolutionHeightPx: p.resolutionHeightPx,
  focalLengthMm: p.focalLengthMm,
  focalRatio: p.focalRatio,
  apertureDiameterMm: p.apertureDiameterMm,
  averageRawFileSizeMB: p.averageRawFileSizeMB,
  cameraSource: p.cameraSource,
  cameraConfidence: p.cameraConfidence,
  opticsSource: p.opticsSource,
  opticsConfidence: p.opticsConfidence,
  specProvenance: p.specProvenance,
  metadataMake: p.metadataMake,
  metadataModel: p.metadataModel,
);

EquipmentProfile _imported() {
  final d = EquipmentDraft.fromCandidate(phoneCandidate());
  return _saved(d.build(d.initial, TrackingType.unknown).profile!);
}

/// Opens the editor on [rig] and returns the provenance text.
Future<String> _provenanceText(
  WidgetTester tester,
  EquipmentProfile rig,
) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => GearViewModel(InMemoryEquipmentRepository()),
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showEquipmentEditor(context, existing: rig),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  final line = find.byKey(const Key('editor.provenance'));
  expect(line, findsOneWidget);
  return tester.widget<Text>(line).data!;
}

void main() {
  testWidgets('an imported rig: estimates read as estimated, file values as '
      'from the file, nothing as the user\'s', (tester) async {
    final text = await _provenanceText(tester, _imported());
    expect(text, isNot(contains('user')));
    expect(text, contains('Sensor size: estimated (derived:calc-40/'));
    expect(text, contains('Pixel size: estimated (derived:calc-40/'));
    expect(text, contains('Resolution: reported (metadata:jpeg)'));
    expect(text, contains('Optics: reported (metadata:jpeg)'));
  });

  testWidgets('a rig typed by hand reads as before', (tester) async {
    final hand = _saved(
      const EquipmentProfile(
        id: 0,
        name: 'Hand rig',
        sensorWidthMm: 23.5,
        sensorHeightMm: 15.6,
        pixelPitchUm: 3.76,
        resolutionWidthPx: 6248,
        resolutionHeightPx: 4176,
        focalLengthMm: 400,
        focalRatio: 5,
      ).withEditProvenance(null),
    );
    expect(
      await _provenanceText(tester, hand),
      'Camera specs: reported (user) · Optics: reported (user)',
    );
  });

  testWidgets('the verified seed with its pixel size edited: only that spec '
      'is the user\'s', (tester) async {
    final seed = EquipmentSeeder.defaults.single;
    final edited = _saved(
      EquipmentProfile(
        id: 0,
        name: seed.name,
        sensorWidthMm: seed.sensorWidthMm,
        sensorHeightMm: seed.sensorHeightMm,
        pixelPitchUm: seed.pixelPitchUm + 0.1,
        resolutionWidthPx: seed.resolutionWidthPx,
        resolutionHeightPx: seed.resolutionHeightPx,
        focalLengthMm: seed.focalLengthMm,
        focalRatio: seed.focalRatio,
        apertureDiameterMm: seed.apertureDiameterMm,
        cameraSource: seed.cameraSource,
        cameraConfidence: seed.cameraConfidence,
        opticsSource: seed.opticsSource,
        opticsConfidence: seed.opticsConfidence,
      ).withEditProvenance(seed),
    );
    final text = await _provenanceText(tester, edited);
    expect(text, contains('Resolution: verified (${seed.cameraSource})'));
    expect(text, contains('Sensor size: verified (${seed.cameraSource})'));
    expect(text, contains('Pixel size: reported (user)'));
    expect(text, contains('Optics: estimated (${seed.opticsSource})'));
  });

  testWidgets('a legacy rig with an edited field: the untouched specs stay '
      'unknown', (tester) async {
    const legacy = EquipmentProfile(
      id: 3,
      name: 'Legacy',
      sensorWidthMm: 23.5,
      sensorHeightMm: 15.6,
      pixelPitchUm: 3.76,
      resolutionWidthPx: 6248,
      resolutionHeightPx: 4176,
      focalLengthMm: 400,
      focalRatio: 5,
    );
    final edited = _saved(
      EquipmentProfile(
        id: 3,
        name: 'Legacy',
        sensorWidthMm: 23.5,
        sensorHeightMm: 15.6,
        pixelPitchUm: 3.8,
        resolutionWidthPx: 6248,
        resolutionHeightPx: 4176,
        focalLengthMm: 400,
        focalRatio: 5,
      ).withEditProvenance(legacy),
      id: 3,
    );
    expect(
      edited.provenanceOf(EquipmentSpec.resolution),
      isNull,
      reason: 'S3.V2 keeps it unknown',
    );
    final text = await _provenanceText(tester, edited);
    expect(text, contains('Resolution: source unknown'));
    expect(text, contains('Sensor size: source unknown'));
    expect(text, contains('Pixel size: reported (user)'));
    expect(text, contains('Optics: source unknown'));
  });
}
