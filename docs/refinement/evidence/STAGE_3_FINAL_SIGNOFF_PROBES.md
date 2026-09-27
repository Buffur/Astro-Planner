# Stage 3 final sign-off: probe evidence

Date: 2026-09-27. Baseline: `92ebf2a` (S3.V8), clean tree on entry and on exit.

Every probe below was a temporary file under `test/`, run against unchanged application code and
then removed. Only synthetic values are used (neutral strings, the committed RG-01 phone optics),
with a real in-memory SQLite database wherever storage is involved. No owner sample bytes, file
names or values are included.

## 1. Archived probes, re-run

Restored verbatim from the earlier evidence records:

- P1–P10: `STAGE_3_VALIDATION_PROBES.md`. P5 carries the one-line API restatement recorded in
  `STAGE_3_REVALIDATION_PROBES.md` (`(await vm.rigDraft(vm.match!.rigs.single.rig.id))!`); every
  assertion is unchanged.
- R1: `STAGE_3_REVALIDATION_PROBES.md`.
- F1a, F1b, F2, F3 and the two P+ probes: `STAGE_3_SIGNOFF_PROBES.md`. F1a, F1b, F2 and F3 were
  written to **pin the defects** of that sign-off, so a pin fails once its defect is fixed.

```text
flutter test --no-pub --concurrency=1 test/zz_stage3_validation_test.dart test/zz_stage3_widget_validation_test.dart test/zz_stage3_storage_validation_test.dart test/zz_stage3_revalidation_test.dart test/zz_stage3_signoff_test.dart -r expanded
```

| Probe | Result | Reading |
| --- | --- | --- |
| P1–P10 | 10 pass | S3V-01 to S3V-05 stay fixed; the P6 round trip, P9 backup/restore and P10 rollback hold |
| R1 | pass | The no-geometry camera copy uses the latest exact saved values |
| F1a | pass | Storage is unchanged by design: the per-field pairs are the import's, the group pairs are `user`/`reported` |
| F1b | **fails, as expected** | The editor no longer says "Camera specs: reported (user)" for an imported rig: S3S-01 fixed. G1–G5 below assert the correct behaviour |
| F2 | pass | The transposed conflict of a portrait-entered rig is still there: S3S-03, deferred by the owner |
| F3 | **fails, as expected** | The pitch is no longer copied into another pixel count, so the untouched draft has no pixel size and cannot be built (in the UI, Save is blocked): S3S-02 fixed. H1 restates it |
| P+ (2) | 2 pass | A likely-same open-and-save and a one-field hand edit still keep per-field provenance |

Output (test lines and printed values):

```text
00:00 +0: zz_stage3_validation_test.dart: P1 copied legacy camera provenance remains unknown after persistence
00:00 +1: zz_stage3_validation_test.dart: P2 editing one legacy field does not invent provenance for untouched fields
00:00 +2: zz_stage3_validation_test.dart: P3 explicitly taking imported sensor size replaces the actual value
00:00 +3: zz_stage3_validation_test.dart: P4 copied verified camera specs are not rounded while retaining verified provenance
00:00 +4: zz_stage3_validation_test.dart: P5 revisiting retained review must not overwrite newer saved rig values
00:00 +5: zz_stage3_validation_test.dart: P6 normal new import persists and rematches without duplicate or conflicts
00:00 +6: zz_stage3_validation_test.dart: P7 absurd image dimensions are unparseable at the metadata boundary
00:01 +7: zz_stage3_widget_validation_test.dart: P8 real routes and SQLite: retained import must not undo a later manual edit
00:05 +8: zz_stage3_storage_validation_test.dart: P9 backup and restore preserve all v18 import fields and identity
00:05 +9: zz_stage3_storage_validation_test.dart: P10 a failed rig insertion rolls back the entire device-camera-rig chain
00:06 +10: zz_stage3_revalidation_test.dart: R1 copying a camera with no file geometry uses the latest exact saved fallback
00:07 +11: zz_stage3_signoff_test.dart: F1a an imported rig: per-field estimated, group pair user
00:08 +12 -1: zz_stage3_signoff_test.dart: F1b the editor of that rig says camera specs are the user's [E]
    Expected: exactly one matching candidate
      Actual: _TextContainingWidgetFinder:<Found 0 widgets with text containing Camera specs:: []>
00:08 +13 -1: zz_stage3_signoff_test.dart: F2 a portrait hand-entered rig gets transposed "conflicts"
00:08 +13 -2: zz_stage3_signoff_test.dart: F3 camera specs copied into another output mode [E]
    Null check operator used on a null value
    package:astroplan/presentation/shared/equipment_draft.dart 507:53  EquipmentDraft.build
00:08 +14 -2: zz_stage3_signoff_test.dart: P+ likely-same open and save keeps the DNG identity
00:08 +15 -2: zz_stage3_signoff_test.dart: P+ a hand edit of the focal length marks only that field
00:08 +15 -2: Some tests failed.

P3 stored=9.89 x 7.42; provenance=derived:calc-40/metadata:jpeg (estimated)
P4 width=9.894; pitch=2.414123; RAW=30.04; sensor provenance=seed:test (verified)
F1a group camera=user/reported optics=user/reported; sensor=derived:calc-40/metadata:jpeg (estimated) pitch=derived:calc-40/metadata:jpeg (estimated) resolution=metadata:jpeg (reported) focal=metadata:jpeg (reported)
F2 outcome=sameRig conflicts=[resolution: [3072, 4096] vs [4096, 3072], sensorSize: [7.416, 9.894] vs [9.89, 7.42]]
```

## 2. New probes (`test/zz_stage3_final_signoff_test.dart`, removed after the run)

```text
flutter test --no-pub test/zz_stage3_final_signoff_test.dart -r expanded
```

Result: **13 pass**. G1–G6 check S3.V7 (S3S-01). H1–H3 and H5–H7 check S3.V8 (S3S-02) and the
paths next to it. H4 asserts nothing; it records an observation (the report's S3F-01).

| Probe | What it checks | Result |
| --- | --- | --- |
| G1 | An imported rig reread from SQLite: the editor names each estimate and file value, and never says "user" | pass |
| G2 | The verified seed with only its pixel size edited (real seeder, real SQLite): untouched specs still read verified, the edit reads user, the optics keep the seed's estimate | pass |
| G3 | A hand-typed rig reads exactly as before S3.V7 | pass |
| G4 | A legacy rig reads "source unknown" for both groups | pass |
| G5 | The per-spec line at 375 dp and 200 % text: no overflow | pass |
| G6 | Two sessions saved through the real planner graph (`PlannerHarness` with Drift repositories), reread from SQLite: the imported rig's plan snapshot has camera `null`/`null` and optics `metadata:jpeg`/`reported`; the hand-typed rig's has `user` | pass |
| H1 | F3 restated: another pixel count leaves the pitch and both sensor sides empty, withholds exactly those two specs, keeps the file's resolution, and explains why | pass |
| H2 | Equal pixel count: the copy is unchanged, exact, with the saved provenance | pass |
| H3 | Equal pixel count in the other orientation still copies | pass |
| H4 | *(observation)* A portrait-entered saved rig copied into a landscape file of equal count | recorded |
| H5 | The file's own CALC-40 estimate with another pixel count is used (nothing withheld) and is self-consistent | pass |
| H6 | The user's pixel size in a withheld draft: pitch and sensor are the user's, resolution the file's, the geometry consistent, the saved rig untouched | pass |
| H7 | Same optics, other pixel count (cropped or binned): no conflicts are offered, and Open then Save leaves the saved rig exactly as it was | pass |

Printed values:

```text
G1 editor line: Resolution: reported (metadata:jpeg) · Pixel size: estimated (derived:calc-40/metadata:jpeg) · Sensor size: estimated (derived:calc-40/metadata:jpeg) · Optics: reported (metadata:jpeg)
G2 editor line: Resolution: verified (seed:equipment@2) · Pixel size: reported (user) · Sensor size: verified (seed:equipment@2) · Optics: estimated (seed:equipment@2)
G6 imported snapshot camera=null/null optics=metadata:jpeg/reported; hand camera=user
H1 note: Pixel size not copied from "Hand phone": this file is 2048 × 1536 px, that rig 4096 × 3072 px. Binning, a crop or another mode could explain the difference, so enter the pixel size for this one.
H4 saved new rig: 4096x3072 px, sensor 7.416 x 9.894 mm, pitch 2.414; res.w x pitch = 9.888 mm
00:02 +13: All tests passed!
```

The first two runs of this file failed on the probe, not the application: an import clash
(`AstroTarget` and `LocationProfile` from both the database and the domain), then G6 disposing the
planner graph inside a widget test while its first-frame weather load was pending. G6 became a
plain `test`; no assertion changed.

### Source

```dart
// Temporary fresh-session Stage 3 final sign-off probes. Not part of the suite.
// Synthetic values only; real in-memory SQLite where storage is involved.

import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/equipment_import/equipment_candidate.dart';
import 'package:astroplan/domain/equipment_import/equipment_matcher.dart';
import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/location_profile.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/screens/equipment/equipment_editor.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';
import 'package:astroplan/presentation/viewmodels/metadata_import_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_capture_file_access.dart';
import 'support/fake_location_service.dart';
import 'support/jpeg_fixture.dart';
import 'support/metadata_candidates.dart';
import 'support/no_snapshot_weather.dart';
import 'support/planner_harness.dart';
import 'support/tiff_fixture.dart';

class _Weather with NoSnapshotWeather implements WeatherRepository {}

KnownValue<T> _k<T>(T v, String field) => KnownValue(
  v,
  raw: '$v',
  origin: MetadataOrigin(format: MetadataFormat.jpeg, field: field),
);

EquipmentCandidate _candidate({
  double f = 6.57,
  double n = 1.6,
  double? f35 = 23,
  ImageDimensions? dims = const ImageDimensions(4096, 3072),
}) => EquipmentCandidate.fromReading(
  MetadataRead(
    MetadataFormat.jpeg,
    CaptureMetadata(
      cameraMake: _k('TestMake', 'Make'),
      cameraModel: _k('TestMake TestPhone', 'Model'),
      focalLengthMm: _k(f, 'FocalLength'),
      fNumber: _k(n, 'FNumber'),
      focalLength35mmEquivalentMm: f35 == null
          ? const AbsentValue()
          : _k(f35, 'FocalLengthIn35mmFilm'),
      imageDimensions: dims == null ? const AbsentValue() : _k(dims, 'dims'),
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

EquipmentFormTexts _with(
  EquipmentFormTexts t, {
  String? pixelPitch,
  String? sensorWidth,
  String? sensorHeight,
}) => EquipmentFormTexts(
  name: t.name,
  manufacturer: t.manufacturer,
  cameraModel: t.cameraModel,
  resolutionWidth: t.resolutionWidth,
  resolutionHeight: t.resolutionHeight,
  pixelPitch: pixelPitch ?? t.pixelPitch,
  sensorWidth: sensorWidth ?? t.sensorWidth,
  sensorHeight: sensorHeight ?? t.sensorHeight,
  focalLength: t.focalLength,
  focalRatio: t.focalRatio,
  diameter: t.diameter,
  rawFileSize: t.rawFileSize,
  rotation: t.rotation,
  maxExposure: t.maxExposure,
);

Future<String> _editorLine(
  WidgetTester t,
  AppDatabase db,
  EquipmentProfile rig, {
  double textScale = 1,
  Size size = const Size(800, 1600),
}) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => GearViewModel(DriftEquipmentRepository(db)),
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showEquipmentEditor(context, existing: rig),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await t.tap(find.text('open'));
  await t.pumpAndSettle();
  return t.widget<Text>(find.byKey(const Key('editor.provenance'))).data!;
}

void main() {
  late AppDatabase db;
  late DriftEquipmentRepository repo;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftEquipmentRepository(db);
  });
  tearDown(() async => db.close());

  // ---- S3S-01 / S3.V7: provenance display and snapshots ----

  testWidgets('G1 an imported rig reread from SQLite: the editor states the '
      'estimates and file values, never "user"', (t) async {
    final line = (await t.runAsync(() async {
      final d = EquipmentDraft.fromCandidate(phoneCandidate());
      final id = await repo.insertEquipment(
        d.build(d.initial, TrackingType.unknown).profile!,
      );
      return (await repo.getEquipmentById(id))!;
    }))!;
    final text = await _editorLine(t, db, line);
    // ignore: avoid_print
    print('G1 editor line: $text');
    expect(text, contains('estimated (derived:calc-40/metadata:jpeg)'));
    expect(text, contains('Resolution: reported (metadata:jpeg)'));
    expect(text, contains('Optics: reported (metadata:jpeg)'));
    expect(text, isNot(contains('user')));
  });

  testWidgets('G2 the verified seed with only its pixel size edited: the '
      'untouched specs still read verified, the edit reads user', (t) async {
    final r = (await t.runAsync(() async {
      await EquipmentSeeder(repo).seedIfNeeded();
      final seed = (await repo.getAllEquipment()).single;
      final d = EquipmentDraft.fromProfile(seed);
      await repo.updateEquipment(
        d
            .build(_with(d.initial, pixelPitch: '3.8'), TrackingType.unknown)
            .profile!,
      );
      return (await repo.getEquipmentById(seed.id))!;
    }))!;
    expect(r.provenanceOf(EquipmentSpec.pixelPitch), SpecProvenance.user);
    expect(
      r.provenanceOf(EquipmentSpec.resolution),
      const SpecProvenance(EquipmentSeeder.source, SpecConfidence.verified),
    );
    final text = await _editorLine(t, db, r);
    // ignore: avoid_print
    print('G2 editor line: $text');
    expect(text, contains('Resolution: verified (seed:equipment@2)'));
    expect(text, contains('Sensor size: verified (seed:equipment@2)'));
    expect(text, contains('Pixel size: reported (user)'));
    expect(text, contains('Optics: estimated (seed:equipment@2)'));
    expect(r.sharedProvenance(camera: true), isNull);
  });

  testWidgets('G3 a hand-typed rig reads exactly as before S3.V7', (t) async {
    final r = (await t.runAsync(() async {
      final id = await repo.insertEquipment(_handRig());
      return (await repo.getEquipmentById(id))!;
    }))!;
    final text = await _editorLine(t, db, r);
    expect(text, 'Camera specs: reported (user) · Optics: reported (user)');
  });

  testWidgets('G4 a legacy rig (no provenance) reads unknown', (t) async {
    final r = (await t.runAsync(() async {
      final id = await repo.insertEquipment(
        const EquipmentProfile(
          id: 0,
          name: 'Legacy',
          sensorWidthMm: 9.894,
          sensorHeightMm: 7.416,
          pixelPitchUm: 2.414,
          resolutionWidthPx: 4096,
          resolutionHeightPx: 3072,
          focalLengthMm: 6.57,
          focalRatio: 1.6,
        ),
      );
      return (await repo.getEquipmentById(id))!;
    }))!;
    final text = await _editorLine(t, db, r);
    expect(text, 'Camera specs: source unknown · Optics: source unknown');
  });

  testWidgets('G5 the provenance line of an imported rig does not overflow '
      'at 375 dp and 200 % text', (t) async {
    final r = (await t.runAsync(() async {
      final d = EquipmentDraft.fromCandidate(phoneCandidate());
      final id = await repo.insertEquipment(
        d.build(d.initial, TrackingType.unknown).profile!,
      );
      return (await repo.getEquipmentById(id))!;
    }))!;
    await _editorLine(
      t,
      db,
      r,
      textScale: 2,
      size: const Size(375, 812),
    );
    expect(t.takeException(), isNull);
  });

  test('G6 a session saved through the real planner with an imported '
      'rig: the stored plan snapshot has no invented camera `user`', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final session = DriftSessionRepository(db);
    final (json, handJson) = await (() async {
      final loc = await DriftLocationRepository(db).insertLocation(
        LocationProfile(
          id: 0,
          name: 'Test Site',
          latitude: 51.5072,
          longitude: -0.1276,
          elevation: 10,
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': loc});
      final targets = DriftTargetRepository(db);
      await targets.insertTarget(
        AstroTarget(
          id: 1,
          catalogId: 'M42',
          commonName: 'Orion Nebula',
          type: 'Nebula',
          rightAscension: 83.85,
          declination: -5.45,
        ),
      );
      final d = EquipmentDraft.fromCandidate(phoneCandidate());
      final imported = (await repo.getEquipmentById(
        await repo.insertEquipment(
          d.build(d.initial, TrackingType.unknown).profile!,
        ),
      ))!;
      final hand = (await repo.getEquipmentById(
        await repo.insertEquipment(_handRig()),
      ))!;
      final vm = PlannerHarness(
        targets,
        repo,
        _Weather(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        sessionRepository: session,
      );
      await vm.ready;
      await vm.setTarget((await targets.getAllTargets()).first);
      await vm.setEquipment(imported);
      final s1 = await vm.saveSession();
      await vm.newSession();
      await vm.setTarget((await targets.getAllTargets()).first);
      await vm.setEquipment(hand);
      final s2 = await vm.saveSession();
      final a = (await session.get(s1.id))!.planSnapshot!.json['rig']! as Map;
      final b = (await session.get(s2.id))!.planSnapshot!.json['rig']! as Map;
      await vm.plan.idle;
      await vm.conditions.idle;
      vm.dispose();
      return (a, b);
    })();
    // ignore: avoid_print
    print(
      'G6 imported snapshot camera=${json['cameraSource']}/'
      '${json['cameraConfidence']} optics=${json['opticsSource']}/'
      '${json['opticsConfidence']}; hand camera=${handJson['cameraSource']}',
    );
    expect(json['cameraSource'], isNull);
    expect(json['cameraConfidence'], isNull);
    expect(json['opticsSource'], 'metadata:jpeg');
    expect(json['opticsConfidence'], 'reported');
    expect(handJson['cameraSource'], 'user');
    expect(handJson['opticsSource'], 'user');
  });

  // ---- S3S-02 / S3.V8: camera-spec copy across pixel counts ----

  test('H1 F3 restated: another pixel count leaves pitch and sensor empty',
      () async {
    final saved = (await repo.getEquipmentById(
      await repo.insertEquipment(_handRig()),
    ))!;
    final c = _candidate(
      f: 15,
      n: 2,
      f35: null,
      dims: const ImageDimensions(2048, 1536),
    );
    expect(
      EquipmentMatcher.match(c, [saved]).outcome,
      MatchKind.sameCameraOtherOptics,
    );
    final d = EquipmentDraft.fromCandidate(c, cameraFrom: saved);
    expect(d.initial.pixelPitch, '');
    expect(d.initial.sensorWidth, '');
    expect(d.initial.sensorHeight, '');
    expect(d.initial.resolutionWidth, '2048');
    expect(d.withheldFromSavedRig!.specs, {
      EquipmentSpec.pixelPitch,
      EquipmentSpec.sensorSize,
    });
    // ignore: avoid_print
    print('H1 note: ${PrefillText.withheld(d.withheldFromSavedRig!)}');
  });

  test('H2 equal pixel count: the copy is unchanged (exact, with provenance)',
      () async {
    final saved = (await repo.getEquipmentById(
      await repo.insertEquipment(_handRig()),
    ))!;
    final c = _candidate(f: 15, n: 2, f35: null);
    final d = EquipmentDraft.fromCandidate(c, cameraFrom: saved);
    expect(d.withheldFromSavedRig, isNull);
    final id = await repo.insertEquipment(
      d.build(d.initial, TrackingType.unknown).profile!,
    );
    final r = (await repo.getEquipmentById(id))!;
    expect(r.pixelPitchUm, 2.414);
    expect(r.sensorWidthMm, 9.894);
    expect(r.provenanceOf(EquipmentSpec.pixelPitch), SpecProvenance.user);
    expect(r.provenanceOf(EquipmentSpec.focalLength)!.source, 'metadata:jpeg');
  });

  test('H3 equal pixel count in the other orientation still copies', () async {
    final saved = (await repo.getEquipmentById(
      await repo.insertEquipment(_handRig()),
    ))!;
    final c = _candidate(
      f: 15,
      n: 2,
      f35: null,
      dims: const ImageDimensions(3072, 4096),
    );
    final d = EquipmentDraft.fromCandidate(c, cameraFrom: saved);
    expect(d.withheldFromSavedRig, isNull);
    expect(d.initial.pixelPitch, '2.414');
  });

  test('H4 (observation) a portrait-entered saved rig copied into a '
      'landscape file of equal count', () async {
    final saved = (await repo.getEquipmentById(
      await repo.insertEquipment(
        _handRig(w: 3072, h: 4096, sw: 7.416, sh: 9.894),
      ),
    ))!;
    final c = _candidate(f: 15, n: 2, f35: null);
    final d = EquipmentDraft.fromCandidate(c, cameraFrom: saved);
    final p = d.build(d.initial, TrackingType.unknown).profile!;
    // ignore: avoid_print
    print(
      'H4 saved new rig: ${p.resolutionWidthPx}x${p.resolutionHeightPx} px, '
      'sensor ${p.sensorWidthMm} x ${p.sensorHeightMm} mm, pitch '
      '${p.pixelPitchUm}; res.w x pitch = '
      '${(p.resolutionWidthPx * p.pixelPitchUm / 1000).toStringAsFixed(3)} mm',
    );
  });

  test('H5 the file\'s own estimate with another pixel count is used, and is '
      'self-consistent', () async {
    final saved = (await repo.getEquipmentById(
      await repo.insertEquipment(_handRig()),
    ))!;
    final c = _candidate(f: 15, n: 2, dims: const ImageDimensions(2048, 1536));
    final d = EquipmentDraft.fromCandidate(c, cameraFrom: saved);
    expect(d.withheldFromSavedRig, isNull);
    final p = d.build(d.initial, TrackingType.unknown).profile!;
    expect(
      p.provenanceOf(EquipmentSpec.pixelPitch)!.confidence,
      SpecConfidence.estimated,
    );
    final implied = p.resolutionWidthPx * p.pixelPitchUm / 1000;
    expect((implied - p.sensorWidthMm).abs(), lessThan(0.01));
  });

  test('H6 the user\'s pixel size in a withheld draft: geometry consistent, '
      'pitch and sensor the user\'s, resolution the file\'s', () async {
    final saved = (await repo.getEquipmentById(
      await repo.insertEquipment(_handRig()),
    ))!;
    final c = _candidate(
      f: 15,
      n: 2,
      f35: null,
      dims: const ImageDimensions(2048, 1536),
    );
    final d = EquipmentDraft.fromCandidate(c, cameraFrom: saved);
    final sensor = EquipmentDraft.sensorSizeText('2048', '1536', '4.828')!;
    final id = await repo.insertEquipment(
      d
          .build(
            _with(
              d.initial,
              pixelPitch: '4.828',
              sensorWidth: sensor.width,
              sensorHeight: sensor.height,
            ),
            TrackingType.unknown,
          )
          .profile!,
    );
    final r = (await repo.getEquipmentById(id))!;
    expect(r.pixelPitchUm, 4.828);
    expect(r.sensorWidthMm, closeTo(2048 * 4.828 / 1000, 0.005));
    expect(r.provenanceOf(EquipmentSpec.pixelPitch), SpecProvenance.user);
    expect(r.provenanceOf(EquipmentSpec.sensorSize), SpecProvenance.user);
    expect(r.provenanceOf(EquipmentSpec.resolution)!.source, 'metadata:jpeg');
    final s = (await repo.getEquipmentById(saved.id))!;
    expect(s.pixelPitchUm, 2.414);
  });

  test('H7 same optics, other pixel count (cropped or binned): Open leaves '
      'the saved rig exactly as it was', () async {
    final id = await repo.insertEquipment(_handRig());
    final before = (await repo.getEquipmentById(id))!;
    final exif = phoneStyleJpegExif();
    exif.exif!.addAll([
      FixtureEntry.long(40962, 2048),
      FixtureEntry.long(40963, 1536),
    ]);
    final files = FakeCaptureFileAccess()
      ..file('binned.jpg', jpegFile([exifApp1(exif.build().bytes)]));
    final vm = MetadataImportViewModel(files, repo);
    addTearDown(vm.dispose);
    await vm.pickAndRead();
    expect(vm.match!.outcome, MatchKind.croppedOrBinnedMode);
    expect(vm.match!.rigs.single.conflicts, isEmpty);
    final draft = (await vm.rigDraft(id))!;
    await repo.updateEquipment(
      draft.build(draft.initial, TrackingType.unknown).profile!,
    );
    final after = (await repo.getEquipmentById(id))!;
    expect(after.pixelPitchUm, before.pixelPitchUm);
    expect(after.resolutionWidthPx, before.resolutionWidthPx);
    expect(after.sensorWidthMm, before.sensorWidthMm);
    expect(after.specProvenance, before.specProvenance);
    expect(after.cameraSource, before.cameraSource);
  });
}
```
