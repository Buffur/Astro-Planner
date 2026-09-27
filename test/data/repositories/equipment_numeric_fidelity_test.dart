// S3.V3 (S3V-03, S3V-04): numbers stay exact through the import flows.
// Choosing the file's value applies the file's actual value; saved and
// verified values are never rounded; only estimates are rounded (S3.9).
// Through the real Drift repository, reread after every save.

import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/domain/equipment_import/equipment_matcher.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/metadata_candidates.dart';

/// A saved rig of the phone's camera with verified camera specs whose
/// exact values do not fit the editor's display precision.
const _verified = EquipmentProfile(
  id: 0,
  name: 'My phone',
  manufacturer: 'TestMake',
  cameraModel: 'TestMake TestPhone',
  sensorWidthMm: 9.894,
  sensorHeightMm: 7.416,
  pixelPitchUm: 2.414123,
  resolutionWidthPx: 4096,
  resolutionHeightPx: 3072,
  focalLengthMm: 6.57,
  focalRatio: 1.6,
  averageRawFileSizeMB: 30.04,
  cameraSource: 'seed:test',
  cameraConfidence: SpecConfidence.verified,
  metadataMake: 'TestMake',
  metadataModel: 'TestMake TestPhone',
);

void main() {
  late AppDatabase db;
  late DriftEquipmentRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftEquipmentRepository(db);
  });
  tearDown(() => db.close());

  Future<EquipmentProfile> saved() async =>
      (await repo.getEquipmentById(await repo.insertEquipment(_verified)))!;

  test('choosing the file\'s sensor size applies the file\'s value, not the '
      'old one under a new origin (the validation\'s P3)', () async {
    final rig = await saved();
    final candidate = phoneCandidate(); // estimate 9.89 × 7.42 mm
    final match = EquipmentMatcher.match(candidate, [rig]).rigs.single;
    final sensor = match.conflicts.singleWhere(
      (c) => c.spec == EquipmentSpec.sensorSize,
    );
    expect(sensor.imported, [9.89, 7.42]);

    final draft = EquipmentDraft.forRig(rig, {
      EquipmentSpec.sensorSize: (
        value: sensor.imported,
        provenance: sensor.importedProvenance,
      ),
    });
    await repo.updateEquipment(
      draft.build(draft.initial, TrackingType.unknown).profile!,
    );
    final after = (await repo.getEquipmentById(rig.id))!;

    expect(after.sensorWidthMm, 9.89);
    expect(after.sensorHeightMm, 7.42);
    expect(
      after.provenanceOf(EquipmentSpec.sensorSize)?.confidence,
      SpecConfidence.estimated,
    );
    // Not taken: exact and verified.
    expect(after.pixelPitchUm, 2.414123);
    expect(after.averageRawFileSizeMB, 30.04);
    expect(
      after.provenanceOf(EquipmentSpec.pixelPitch)?.confidence,
      SpecConfidence.verified,
    );
    // The value now equals the file's: no difference is listed any more.
    expect(
      EquipmentMatcher.match(candidate, [
        after,
      ]).rigs.single.conflicts.map((c) => c.spec),
      isNot(contains(EquipmentSpec.sensorSize)),
    );
  });

  test('camera specs copied from a saved rig keep their exact values and '
      'provenance (the validation\'s P4)', () async {
    final rig = await saved();
    final draft = EquipmentDraft.fromCandidate(
      phoneCandidate(withDims: false, with35: false),
      cameraFrom: rig,
    );
    final id = await repo.insertEquipment(
      draft.build(draft.initial, TrackingType.unknown).profile!,
    );
    final copy = (await repo.getEquipmentById(id))!;

    expect(copy.sensorWidthMm, 9.894);
    expect(copy.sensorHeightMm, 7.416);
    expect(copy.pixelPitchUm, 2.414123);
    expect(copy.averageRawFileSizeMB, 30.04);
    for (final spec in [
      EquipmentSpec.sensorSize,
      EquipmentSpec.pixelPitch,
      EquipmentSpec.resolution,
      EquipmentSpec.rawFileSize,
    ]) {
      expect(
        copy.provenanceOf(spec),
        const SpecProvenance('seed:test', SpecConfidence.verified),
        reason: spec.name,
      );
    }
  });

  test(
    'a copied value the user retypes is stored as typed, the user\'s',
    () async {
      final rig = await saved();
      final draft = EquipmentDraft.fromCandidate(
        phoneCandidate(withDims: false, with35: false),
        cameraFrom: rig,
      );
      final t = draft.initial;
      final typed = EquipmentFormTexts(
        name: t.name,
        manufacturer: t.manufacturer,
        cameraModel: t.cameraModel,
        resolutionWidth: t.resolutionWidth,
        resolutionHeight: t.resolutionHeight,
        pixelPitch: '2.5',
        sensorWidth: t.sensorWidth,
        sensorHeight: t.sensorHeight,
        focalLength: t.focalLength,
        focalRatio: t.focalRatio,
        rawFileSize: t.rawFileSize,
      );
      final id = await repo.insertEquipment(
        draft.build(typed, TrackingType.unknown).profile!,
      );
      final copy = (await repo.getEquipmentById(id))!;
      expect(copy.pixelPitchUm, 2.5);
      expect(copy.provenanceOf(EquipmentSpec.pixelPitch), SpecProvenance.user);
      expect(copy.sensorWidthMm, 9.894);
    },
  );

  test('estimates are still proposed and stored rounded (S3.9)', () async {
    final draft = EquipmentDraft.fromCandidate(phoneCandidate());
    final id = await repo.insertEquipment(
      draft.build(draft.initial, TrackingType.unknown).profile!,
    );
    final rig = (await repo.getEquipmentById(id))!;
    expect(rig.pixelPitchUm, 2.414);
    expect(rig.sensorWidthMm, 9.89);
  });

  test(
    'opening and saving a saved rig untouched keeps every value exact',
    () async {
      final rig = await saved();
      final draft = EquipmentDraft.forRig(rig, const {});
      await repo.updateEquipment(
        draft.build(draft.initial, TrackingType.unknown).profile!,
      );
      final after = (await repo.getEquipmentById(rig.id))!;
      expect(after.sensorWidthMm, 9.894);
      expect(after.pixelPitchUm, 2.414123);
      expect(after.averageRawFileSizeMB, 30.04);
      expect(
        after.provenanceOf(EquipmentSpec.sensorSize)?.confidence,
        SpecConfidence.verified,
      );
    },
  );
}
