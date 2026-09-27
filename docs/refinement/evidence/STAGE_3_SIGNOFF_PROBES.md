# Stage 3 fresh-session sign-off: probe evidence

Date: 2026-09-27. Baseline: `74026ca` (application code identical to `d5e2b60`;
`git diff --stat d5e2b60 HEAD -- lib test android integration_test` is empty).

The probe file below was written in a fresh session, run once, and removed.
It uses only synthetic values (neutral strings, the committed RG-01 phone optics)
and an in-memory SQLite database. No owner sample bytes or values are included.

Run from the repository root:

```text
flutter test --no-pub test/zz_stage3_signoff_test.dart
```

Result: **6 pass**. Four of the tests pin the behaviour the findings describe (F1a, F1b, F2, F3).
Two are positive checks that found no defect (P+).

| Probe | What it shows | Finding |
| --- | --- | --- |
| F1a | A rig saved from a phone import has per-field provenance `derived:calc-40/metadata:jpeg (estimated)` for sensor size and pitch, and `metadata:jpeg (reported)` for resolution and focal length. Its group pairs are `user/reported` for both camera and optics | S3S-01 |
| F1b | The rig editor opened on that saved rig shows `Camera specs: reported (user) · Optics: reported (user)`. The word "estimated" appears nowhere | S3S-01 |
| F2 | A hand-entered portrait rig (3072 × 4096 px, 7.416 × 9.894 mm) against a landscape file of the same camera and optics gives `sameRig` with two conflicts that are the same values transposed | S3S-03 |
| F3 | Same camera, other optics, a 2048 × 1536 output with no 35 mm equivalent. "New rig with the camera specs of" the 4096 × 3072 rig saves 2048 × 1536 px with the saved 2.414 µm pitch and 9.894 mm sensor. Resolution × pitch = 4.944 mm, half the stored sensor width | S3S-02 |
| P+ (1) | Likely-same (DNG identity `…/CODE9`, JPEG `…`), opened and saved: the DNG identity and the per-field provenance are kept | none |
| P+ (2) | A hand edit of an imported rig's focal length marks only that field `user`. The focal ratio stays `metadata:jpeg`, the pitch stays estimated, and the sensor width is exact | none |

## Output

```text
00:00 +0: F1a an imported rig: per-field estimated, group pair user
F1a group camera=user/reported optics=user/reported; sensor=derived:calc-40/metadata:jpeg (estimated) pitch=derived:calc-40/metadata:jpeg (estimated) resolution=metadata:jpeg (reported) focal=metadata:jpeg (reported)
00:00 +1: F1b the editor of that rig says camera specs are the user's
F1b editor line: Camera specs: reported (user) · Optics: reported (user)
00:01 +2: F2 a portrait hand-entered rig gets transposed "conflicts"
F2 outcome=sameRig conflicts=[resolution: [3072, 4096] vs [4096, 3072], sensorSize: [7.416, 9.894] vs [9.89, 7.42]]
00:01 +3: F3 camera specs copied into another output mode
F3 saved: 2048x1536 px, pitch 2.414 um (user (reported)), sensor 9.894 mm; res x pitch = 4.944 mm
00:01 +4: P+ likely-same open and save keeps the DNG identity
00:01 +5: P+ a hand edit of the focal length marks only that field
00:01 +6: All tests passed!
```

## Probe source (`test/zz_stage3_signoff_test.dart`, removed after the run)

```dart
// Temporary fresh-session Stage 3 sign-off probes. Not part of the suite.

import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/domain/equipment_import/equipment_candidate.dart';
import 'package:astroplan/domain/equipment_import/equipment_matcher.dart';
import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_editor.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'support/metadata_candidates.dart';

KnownValue<T> _k<T>(T v, String field, [MetadataFormat f = MetadataFormat.jpeg]) =>
    KnownValue(v, raw: '$v', origin: MetadataOrigin(format: f, field: field));

EquipmentCandidate _candidate({
  String model = 'TestMake TestPhone',
  double f = 6.57,
  double n = 1.6,
  double? f35 = 23,
  ImageDimensions? dims = const ImageDimensions(4096, 3072),
  MetadataFormat format = MetadataFormat.jpeg,
}) => EquipmentCandidate.fromReading(
  MetadataRead(
    format,
    CaptureMetadata(
      cameraMake: _k('TestMake', 'Make', format),
      cameraModel: _k(model, 'Model', format),
      focalLengthMm: _k(f, 'FocalLength', format),
      fNumber: _k(n, 'FNumber', format),
      focalLength35mmEquivalentMm: f35 == null
          ? const AbsentValue()
          : _k(f35, 'FocalLengthIn35mmFilm', format),
      imageDimensions: dims == null
          ? const AbsentValue()
          : _k(dims, 'dims', format),
    ),
  ),
);

EquipmentProfile _handRig({
  int w = 4096,
  int h = 3072,
  double sw = 9.894,
  double sh = 7.416,
}) => EquipmentProfile(
  id: 0,
  name: 'Hand phone',
  manufacturer: 'TestMake',
  cameraModel: 'TestMake TestPhone',
  sensorWidthMm: sw,
  sensorHeightMm: sh,
  pixelPitchUm: 2.414,
  resolutionWidthPx: w,
  resolutionHeightPx: h,
  focalLengthMm: 6.57,
  focalRatio: 1.6,
).withEditProvenance(null);

void main() {
  late AppDatabase db;
  late DriftEquipmentRepository repo;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftEquipmentRepository(db);
  });
  tearDown(() async => db.close());

  test('F1a an imported rig: per-field estimated, group pair user', () async {
    final d = EquipmentDraft.fromCandidate(phoneCandidate());
    final id = await repo.insertEquipment(
      d.build(d.initial, TrackingType.unknown).profile!,
    );
    final r = (await repo.getEquipmentById(id))!;
    // ignore: avoid_print
    print(
      'F1a group camera=${r.cameraSource}/${r.cameraConfidence?.name} '
      'optics=${r.opticsSource}/${r.opticsConfidence?.name}; '
      'sensor=${r.provenanceOf(EquipmentSpec.sensorSize)} '
      'pitch=${r.provenanceOf(EquipmentSpec.pixelPitch)} '
      'resolution=${r.provenanceOf(EquipmentSpec.resolution)} '
      'focal=${r.provenanceOf(EquipmentSpec.focalLength)}',
    );
    expect(
      r.provenanceOf(EquipmentSpec.sensorSize)!.confidence,
      SpecConfidence.estimated,
    );
    expect(r.cameraSource, 'user');
    expect(r.cameraConfidence, SpecConfidence.reported);
  });

  testWidgets('F1b the editor of that rig says camera specs are the user\'s', (
    tester,
  ) async {
    final d = EquipmentDraft.fromCandidate(phoneCandidate());
    final built = d.build(d.initial, TrackingType.unknown).profile!;
    final rig = EquipmentProfile(
      id: 7,
      name: built.name,
      manufacturer: built.manufacturer,
      cameraModel: built.cameraModel,
      sensorWidthMm: built.sensorWidthMm,
      sensorHeightMm: built.sensorHeightMm,
      pixelPitchUm: built.pixelPitchUm,
      resolutionWidthPx: built.resolutionWidthPx,
      resolutionHeightPx: built.resolutionHeightPx,
      focalLengthMm: built.focalLengthMm,
      focalRatio: built.focalRatio,
      cameraSource: built.cameraSource,
      cameraConfidence: built.cameraConfidence,
      opticsSource: built.opticsSource,
      opticsConfidence: built.opticsConfidence,
      specProvenance: built.specProvenance,
      metadataMake: built.metadataMake,
      metadataModel: built.metadataModel,
    );
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GearViewModel(DriftEquipmentRepository(db)),
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
    final line = find.textContaining('Camera specs:');
    expect(line, findsOneWidget);
    // ignore: avoid_print
    print('F1b editor line: ${(tester.widget<Text>(line)).data}');
    expect(find.textContaining('estimated'), findsNothing);
  });

  test('F2 a portrait hand-entered rig gets transposed "conflicts"', () async {
    final rig = _handRig(w: 3072, h: 4096, sw: 7.416, sh: 9.894);
    final id = await repo.insertEquipment(rig);
    final saved = (await repo.getEquipmentById(id))!;
    final m = EquipmentMatcher.match(_candidate(), [saved]);
    // ignore: avoid_print
    print(
      'F2 outcome=${m.outcome.name} conflicts='
      '${[for (final c in m.rigs.single.conflicts) '${c.spec.name}: ${c.saved} vs ${c.imported}']}',
    );
    expect(m.outcome, MatchKind.sameRig);
    expect(
      m.rigs.single.conflicts.map((c) => c.spec),
      contains(EquipmentSpec.resolution),
    );
  });

  test('F3 camera specs copied into another output mode', () async {
    final id = await repo.insertEquipment(_handRig());
    final saved = (await repo.getEquipmentById(id))!;
    // Same camera, other optics, a 2x2-binned output, no 35 mm equivalent.
    final c = _candidate(
      f: 15,
      n: 2,
      f35: null,
      dims: const ImageDimensions(2048, 1536),
    );
    final m = EquipmentMatcher.match(c, [saved]);
    expect(m.outcome, MatchKind.sameCameraOtherOptics);
    final d = EquipmentDraft.fromCandidate(c, cameraFrom: saved);
    final p = d.build(d.initial, TrackingType.unknown).profile!;
    final impliedWidth = p.resolutionWidthPx * p.pixelPitchUm / 1000;
    // ignore: avoid_print
    print(
      'F3 saved: ${p.resolutionWidthPx}x${p.resolutionHeightPx} px, '
      'pitch ${p.pixelPitchUm} um (${p.provenanceOf(EquipmentSpec.pixelPitch)}), '
      'sensor ${p.sensorWidthMm} mm; res x pitch = '
      '${impliedWidth.toStringAsFixed(3)} mm',
    );
    expect((impliedWidth - p.sensorWidthMm).abs() / p.sensorWidthMm, greaterThan(0.4));
  });

  test('P+ likely-same open and save keeps the DNG identity', () async {
    final dng = _candidate(
      model: 'TestMake TestPhone/CODE9',
      format: MetadataFormat.dng,
    );
    final d0 = EquipmentDraft.fromCandidate(dng);
    final id = await repo.insertEquipment(
      d0.build(d0.initial, TrackingType.unknown).profile!,
    );
    final m = EquipmentMatcher.match(_candidate(), await repo.getAllEquipment());
    expect(m.outcome, MatchKind.likelySameRig);
    final d = EquipmentDraft.forRig(m.rigs.single.rig, const {});
    await repo.updateEquipment(d.build(d.initial, TrackingType.unknown).profile!);
    final r = (await repo.getEquipmentById(id))!;
    expect(r.metadataModel, 'TestMake TestPhone/CODE9');
    expect(
      r.provenanceOf(EquipmentSpec.sensorSize)!.confidence,
      SpecConfidence.estimated,
    );
    expect(r.provenanceOf(EquipmentSpec.focalLength)!.source, 'metadata:dng');
  });

  test('P+ a hand edit of the focal length marks only that field', () async {
    final d0 = EquipmentDraft.fromCandidate(phoneCandidate());
    final id = await repo.insertEquipment(
      d0.build(d0.initial, TrackingType.unknown).profile!,
    );
    final r0 = (await repo.getEquipmentById(id))!;
    final d = EquipmentDraft.fromProfile(r0);
    final t = d.initial;
    final edited = EquipmentFormTexts(
      name: t.name,
      manufacturer: t.manufacturer,
      cameraModel: t.cameraModel,
      resolutionWidth: t.resolutionWidth,
      resolutionHeight: t.resolutionHeight,
      pixelPitch: t.pixelPitch,
      sensorWidth: t.sensorWidth,
      sensorHeight: t.sensorHeight,
      focalLength: '6.6',
      focalRatio: t.focalRatio,
      diameter: t.diameter,
      rawFileSize: t.rawFileSize,
      rotation: t.rotation,
      maxExposure: t.maxExposure,
    );
    await repo.updateEquipment(d.build(edited, TrackingType.unknown).profile!);
    final r = (await repo.getEquipmentById(id))!;
    expect(r.provenanceOf(EquipmentSpec.focalLength), SpecProvenance.user);
    expect(r.provenanceOf(EquipmentSpec.focalRatio)!.source, 'metadata:jpeg');
    expect(
      r.provenanceOf(EquipmentSpec.pixelPitch)!.confidence,
      SpecConfidence.estimated,
    );
    expect(r.sensorWidthMm, r0.sensorWidthMm);
  });
}
```
