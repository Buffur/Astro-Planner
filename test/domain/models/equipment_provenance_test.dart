// TASK 8.5 (ADR-008 §6): what an explicit user edit records as the
// provenance of an equipment profile's camera and optics specs.

import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:flutter_test/flutter_test.dart';

EquipmentProfile _copy(
  EquipmentProfile p, {
  String? name,
  double? pixelPitchUm,
  double? focalLengthMm,
  double? averageRawFileSizeMB,
  TrackingType? trackingType,
  Map<EquipmentSpec, SpecProvenance> specProvenance = const {},
  String? metadataMake,
}) => EquipmentProfile(
  id: p.id,
  name: name ?? p.name,
  manufacturer: p.manufacturer,
  cameraModel: p.cameraModel,
  sensorWidthMm: p.sensorWidthMm,
  sensorHeightMm: p.sensorHeightMm,
  pixelPitchUm: pixelPitchUm ?? p.pixelPitchUm,
  resolutionWidthPx: p.resolutionWidthPx,
  resolutionHeightPx: p.resolutionHeightPx,
  focalLengthMm: focalLengthMm ?? p.focalLengthMm,
  focalRatio: p.focalRatio,
  apertureDiameterMm: p.apertureDiameterMm,
  averageRawFileSizeMB: averageRawFileSizeMB ?? p.averageRawFileSizeMB,
  trackingType: trackingType ?? p.trackingType,
  cameraSource: p.cameraSource,
  cameraConfidence: p.cameraConfidence,
  opticsSource: p.opticsSource,
  opticsConfidence: p.opticsConfidence,
  specProvenance: specProvenance,
  metadataMake: metadataMake,
);

void main() {
  final seed = EquipmentSeeder.defaults.single;

  test('a new profile is the user\'s own, reported', () {
    final p = _copy(seed).withEditProvenance(null);
    expect(p.cameraSource, 'user');
    expect(p.cameraConfidence, SpecConfidence.reported);
    expect(p.opticsSource, 'user');
    expect(p.opticsConfidence, SpecConfidence.reported);
  });

  test('renaming or setting tracking keeps both provenances', () {
    final p = _copy(
      seed,
      name: 'My rig',
      trackingType: TrackingType.guided,
    ).withEditProvenance(seed);
    expect(p.cameraConfidence, SpecConfidence.verified);
    expect(p.cameraSource, 'seed:equipment@2');
    expect(p.opticsConfidence, SpecConfidence.estimated);
  });

  test('changing a camera spec makes only the camera the user\'s', () {
    final p = _copy(seed, pixelPitchUm: 3.8).withEditProvenance(seed);
    expect(p.cameraSource, 'user');
    expect(p.cameraConfidence, SpecConfidence.reported);
    expect(p.opticsConfidence, SpecConfidence.estimated);
  });

  test('changing the optics makes only the optics the user\'s', () {
    final p = _copy(seed, focalLengthMm: 420).withEditProvenance(seed);
    expect(p.cameraConfidence, SpecConfidence.verified);
    expect(p.opticsSource, 'user');
    expect(p.opticsConfidence, SpecConfidence.reported);
  });

  group('per field (S3.4, ADR-018 §5)', () {
    const verified = SpecProvenance(
      'seed:equipment@2',
      SpecConfidence.verified,
    );
    const estimated = SpecProvenance(
      'seed:equipment@2',
      SpecConfidence.estimated,
    );
    const imported = SpecProvenance('metadata:jpeg', SpecConfidence.reported);

    test('a field without its own pair falls back to its group', () {
      expect(seed.provenanceOf(EquipmentSpec.pixelPitch), verified);
      expect(seed.provenanceOf(EquipmentSpec.focalLength), estimated);
      final withOwn = _copy(
        seed,
        specProvenance: {EquipmentSpec.resolution: imported},
      );
      expect(withOwn.provenanceOf(EquipmentSpec.resolution), imported);
      expect(withOwn.provenanceOf(EquipmentSpec.sensorSize), verified);
    });

    test('changing one camera spec marks only that field as the user own; the '
        'untouched camera specs stay verified', () {
      final p = _copy(seed, pixelPitchUm: 3.8).withEditProvenance(seed);
      expect(p.provenanceOf(EquipmentSpec.pixelPitch), SpecProvenance.user);
      expect(p.provenanceOf(EquipmentSpec.resolution), verified);
      expect(p.provenanceOf(EquipmentSpec.sensorSize), verified);
      expect(p.provenanceOf(EquipmentSpec.focalLength), estimated);
      // The group summary keeps its TASK 8.5 meaning.
      expect(p.cameraSource, 'user');
    });

    test('an edit that changes nothing keeps every pair', () {
      final withOwn = _copy(
        seed,
        specProvenance: {EquipmentSpec.resolution: imported},
      );
      final p = _copy(withOwn, name: 'Renamed').withEditProvenance(withOwn);
      expect(p.specProvenance, {EquipmentSpec.resolution: imported});
    });

    test('an own pair survives an edit of another field in its group', () {
      final withOwn = _copy(
        seed,
        specProvenance: {EquipmentSpec.resolution: imported},
      );
      final p = _copy(
        withOwn,
        averageRawFileSizeMB: 30,
      ).withEditProvenance(withOwn);
      expect(p.provenanceOf(EquipmentSpec.resolution), imported);
      expect(p.provenanceOf(EquipmentSpec.rawFileSize), SpecProvenance.user);
    });

    test('a pair given with the edit (an accepted import value) is kept', () {
      final p = _copy(
        seed,
        focalLengthMm: 420,
        specProvenance: {EquipmentSpec.focalLength: imported},
      ).withEditProvenance(seed);
      expect(p.provenanceOf(EquipmentSpec.focalLength), imported);
      expect(p.provenanceOf(EquipmentSpec.focalRatio), estimated);
    });

    test('a new profile keeps the pairs it was given; the rest is the '
        'user group', () {
      final p = _copy(
        seed,
        specProvenance: {EquipmentSpec.focalLength: imported},
        metadataMake: 'TestMake',
      ).withEditProvenance(null);
      expect(p.provenanceOf(EquipmentSpec.focalLength), imported);
      expect(p.provenanceOf(EquipmentSpec.pixelPitch), SpecProvenance.user);
      expect(p.metadataMake, 'TestMake');
    });

    test('legacy rows (no provenance) are never given one by pinning', () {
      final legacy = _copy(seed, name: 'Legacy');
      final bare = EquipmentProfile(
        id: 1,
        name: legacy.name,
        sensorWidthMm: legacy.sensorWidthMm,
        sensorHeightMm: legacy.sensorHeightMm,
        pixelPitchUm: legacy.pixelPitchUm,
        resolutionWidthPx: legacy.resolutionWidthPx,
        resolutionHeightPx: legacy.resolutionHeightPx,
        focalLengthMm: legacy.focalLengthMm,
        focalRatio: legacy.focalRatio,
      );
      final p = _copy(bare, pixelPitchUm: 3.8).withEditProvenance(bare);
      expect(p.provenanceOf(EquipmentSpec.pixelPitch), SpecProvenance.user);
      expect(p.specProvenance.containsKey(EquipmentSpec.sensorSize), isFalse);
      // The group is now the user's (TASK 8.5), so the fallback says so.
      expect(p.provenanceOf(EquipmentSpec.sensorSize), SpecProvenance.user);
    });

    test('the metadata identity is kept across a manual edit', () {
      final imported = _copy(seed, metadataMake: 'TestMake');
      final p = _copy(imported, name: 'Renamed').withEditProvenance(imported);
      expect(p.metadataMake, 'TestMake');
    });
  });

  test('confidence storage: known names, anything else unknown', () {
    for (final c in SpecConfidence.values) {
      expect(SpecConfidence.fromStorage(c.name), c);
    }
    expect(SpecConfidence.fromStorage(null), isNull);
    expect(SpecConfidence.fromStorage('guessed'), isNull);
  });
}
