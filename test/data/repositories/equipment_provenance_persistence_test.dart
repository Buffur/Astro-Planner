// S3.V2 (S3V-02): untouched values whose provenance is unknown stay unknown
// after a save. Editing one field, or copying a legacy rig's camera specs,
// must never attribute the other values to the user. Through the real
// Drift repository, reread after every save.

import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/metadata_candidates.dart';

/// A legacy rig: saved before provenance existed, so every group is NULL.
const _legacy = EquipmentProfile(
  id: 0,
  name: 'Old phone',
  manufacturer: 'TestMake',
  cameraModel: 'TestMake TestPhone',
  sensorWidthMm: 9.83,
  sensorHeightMm: 7.37,
  pixelPitchUm: 2.4,
  resolutionWidthPx: 4096,
  resolutionHeightPx: 3072,
  focalLengthMm: 6.57,
  focalRatio: 1.6,
  averageRawFileSizeMB: 30,
);

EquipmentFormTexts _with(EquipmentFormTexts t, {String? pixelPitch}) =>
    EquipmentFormTexts(
      name: t.name,
      manufacturer: t.manufacturer,
      cameraModel: t.cameraModel,
      resolutionWidth: t.resolutionWidth,
      resolutionHeight: t.resolutionHeight,
      pixelPitch: pixelPitch ?? t.pixelPitch,
      sensorWidth: t.sensorWidth,
      sensorHeight: t.sensorHeight,
      focalLength: t.focalLength,
      focalRatio: t.focalRatio,
      diameter: t.diameter,
      rawFileSize: t.rawFileSize,
      rotation: t.rotation,
      maxExposure: t.maxExposure,
    );

void main() {
  late AppDatabase db;
  late DriftEquipmentRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftEquipmentRepository(db);
  });
  tearDown(() => db.close());

  test('editing one field of a legacy rig leaves the untouched values '
      'unknown (the validation\'s P2)', () async {
    final id = await repo.insertEquipment(_legacy);
    final saved = (await repo.getEquipmentById(id))!;
    for (final spec in EquipmentSpec.values) {
      expect(saved.provenanceOf(spec), isNull, reason: 'legacy: ${spec.name}');
    }

    final draft = EquipmentDraft.fromProfile(saved);
    final edited = draft
        .build(_with(draft.initial, pixelPitch: '2.5'), TrackingType.unknown)
        .profile!;
    await repo.updateEquipment(edited);
    final after = (await repo.getEquipmentById(id))!;

    expect(after.pixelPitchUm, 2.5);
    expect(after.provenanceOf(EquipmentSpec.pixelPitch), SpecProvenance.user);
    for (final untouched in [
      EquipmentSpec.resolution,
      EquipmentSpec.sensorSize,
      EquipmentSpec.rawFileSize,
      EquipmentSpec.focalLength,
      EquipmentSpec.focalRatio,
    ]) {
      expect(
        after.provenanceOf(untouched),
        isNull,
        reason: '${untouched.name} was not edited and its origin is unknown',
      );
    }
    // Values themselves are unchanged.
    expect(after.resolutionWidthPx, 4096);
    expect(after.sensorWidthMm, 9.83);
  });

  test('a new rig that copies a legacy rig\'s camera specs keeps their '
      'origin unknown (the validation\'s P1)', () async {
    final legacyId = await repo.insertEquipment(_legacy);
    final legacy = (await repo.getEquipmentById(legacyId))!;
    // A file with optics but no geometry: the camera specs come from the
    // saved rig, the optics from the file.
    final draft = EquipmentDraft.fromCandidate(
      phoneCandidate(withDims: false, with35: false),
      cameraFrom: legacy,
    );
    final profile = draft.build(draft.initial, TrackingType.unknown).profile!;
    final id = await repo.insertEquipment(profile);
    final back = (await repo.getEquipmentById(id))!;

    for (final copied in [
      EquipmentSpec.resolution,
      EquipmentSpec.sensorSize,
      EquipmentSpec.pixelPitch,
      EquipmentSpec.rawFileSize,
    ]) {
      expect(
        back.provenanceOf(copied),
        isNull,
        reason: '${copied.name} was copied from a rig of unknown origin',
      );
    }
    expect(
      back.provenanceOf(EquipmentSpec.focalLength),
      const SpecProvenance('metadata:jpeg', SpecConfidence.reported),
    );
  });

  test('a copied value the user then edits becomes the user\'s; the rest '
      'stay unknown', () async {
    final legacyId = await repo.insertEquipment(_legacy);
    final legacy = (await repo.getEquipmentById(legacyId))!;
    final draft = EquipmentDraft.fromCandidate(
      phoneCandidate(withDims: false, with35: false),
      cameraFrom: legacy,
    );
    final profile = draft
        .build(_with(draft.initial, pixelPitch: '2.45'), TrackingType.unknown)
        .profile!;
    final back = (await repo.getEquipmentById(
      await repo.insertEquipment(profile),
    ))!;
    expect(back.provenanceOf(EquipmentSpec.pixelPitch), SpecProvenance.user);
    expect(back.provenanceOf(EquipmentSpec.resolution), isNull);
  });

  test('a rig typed entirely by hand is still the user\'s own', () async {
    final draft = EquipmentDraft.fromProfile(null);
    final texts = EquipmentFormTexts(
      name: 'Typed rig',
      resolutionWidth: '6248',
      resolutionHeight: '4176',
      pixelPitch: '3.76',
      sensorWidth: '23.49',
      sensorHeight: '15.70',
      focalLength: '400',
      focalRatio: '5.6',
    );
    final id = await repo.insertEquipment(
      draft.build(texts, TrackingType.unknown).profile!,
    );
    final back = (await repo.getEquipmentById(id))!;
    for (final spec in EquipmentSpec.values) {
      expect(back.provenanceOf(spec), SpecProvenance.user, reason: spec.name);
    }
  });
}
