// S3.V7 (S3S-01, TD-070): the provenance a group of specs shares is read
// from each spec's own provenance (ADR-018 §5), never from the group pair
// alone, so an imported rig's estimates are never covered by a rig-wide
// `user`.

import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/metadata_candidates.dart';

EquipmentProfile _imported() {
  final d = EquipmentDraft.fromCandidate(phoneCandidate());
  return d.build(d.initial, TrackingType.unknown).profile!;
}

EquipmentProfile _hand({double? rawMB}) => EquipmentProfile(
  id: 0,
  name: 'Hand rig',
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.6,
  pixelPitchUm: 3.76,
  resolutionWidthPx: 6248,
  resolutionHeightPx: 4176,
  focalLengthMm: 400,
  focalRatio: 5,
  averageRawFileSizeMB: rawMB,
).withEditProvenance(null);

void main() {
  test('an imported rig shares no camera provenance: its estimates are not '
      'the user\'s', () {
    final p = _imported();
    // The group pair says `user`; the specs say otherwise.
    expect(p.cameraSource, 'user');
    expect(p.sharedProvenance(camera: true), isNull);
    final specs = {
      for (final (spec, provenance) in p.groupProvenance(camera: true))
        spec: provenance,
    };
    expect(
      specs[EquipmentSpec.sensorSize]!.confidence,
      SpecConfidence.estimated,
    );
    expect(
      specs[EquipmentSpec.pixelPitch]!.confidence,
      SpecConfidence.estimated,
    );
    expect(specs[EquipmentSpec.resolution]!.source, 'metadata:jpeg');
    expect(specs.values, isNot(contains(SpecProvenance.user)));
  });

  test('an imported rig\'s optics share the file\'s provenance', () {
    final p = _imported();
    expect(
      p.sharedProvenance(camera: false),
      const SpecProvenance('metadata:jpeg', SpecConfidence.reported),
    );
  });

  test('a rig typed by hand shares `user` in both groups', () {
    final p = _hand();
    expect(p.sharedProvenance(camera: true), SpecProvenance.user);
    expect(p.sharedProvenance(camera: false), SpecProvenance.user);
  });

  test('a RAW size that is not set takes no part', () {
    final p = _hand();
    expect(
      p.groupProvenance(camera: true).map((e) => e.$1),
      isNot(contains(EquipmentSpec.rawFileSize)),
    );
    expect(
      _hand(rawMB: 50).groupProvenance(camera: true).map((e) => e.$1),
      contains(EquipmentSpec.rawFileSize),
    );
  });

  test('a legacy rig has unknown provenance, never `user`', () {
    final seed = EquipmentSeeder.defaults.single;
    final legacy = EquipmentProfile(
      id: 1,
      name: 'Legacy',
      sensorWidthMm: seed.sensorWidthMm,
      sensorHeightMm: seed.sensorHeightMm,
      pixelPitchUm: seed.pixelPitchUm,
      resolutionWidthPx: seed.resolutionWidthPx,
      resolutionHeightPx: seed.resolutionHeightPx,
      focalLengthMm: seed.focalLengthMm,
      focalRatio: seed.focalRatio,
    );
    expect(legacy.sharedProvenance(camera: true), isNull);
    expect(
      legacy.groupProvenance(camera: true).map((e) => e.$2),
      everyElement(isNull),
    );
  });

  test('the verified seed with one spec edited: the rest stays verified', () {
    final seed = EquipmentSeeder.defaults.single;
    final edited = EquipmentProfile(
      id: seed.id,
      name: seed.name,
      manufacturer: seed.manufacturer,
      cameraModel: seed.cameraModel,
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
    ).withEditProvenance(seed);
    expect(edited.sharedProvenance(camera: true), isNull);
    final specs = {
      for (final (spec, provenance) in edited.groupProvenance(camera: true))
        spec: provenance,
    };
    expect(specs[EquipmentSpec.pixelPitch], SpecProvenance.user);
    expect(
      specs[EquipmentSpec.resolution]!.confidence,
      SpecConfidence.verified,
    );
    expect(
      edited.sharedProvenance(camera: false)!.confidence,
      SpecConfidence.estimated,
    );
  });
}
