// TASK 8.5 (ADR-008 §6): what an explicit user edit records as the
// provenance of an equipment profile's camera and optics specs.

import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:flutter_test/flutter_test.dart';

EquipmentProfile _copy(
  EquipmentProfile p, {
  String? name,
  double? pixelPitchUm,
  double? focalLengthMm,
  TrackingType? trackingType,
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
  trackingType: trackingType ?? p.trackingType,
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

  test('confidence storage: known names, anything else unknown', () {
    for (final c in SpecConfidence.values) {
      expect(SpecConfidence.fromStorage(c.name), c);
    }
    expect(SpecConfidence.fromStorage(null), isNull);
    expect(SpecConfidence.fromStorage('guessed'), isNull);
  });
}
