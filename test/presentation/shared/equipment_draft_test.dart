// S3.5: the rig editor's form model. A pre-filled value keeps its origin
// only while its text is untouched; the diameter, rotation, tracking and
// maximum exposure are never pre-filled (ADR-018 §4–§5).

import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/equipment_limits.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:astroplan/domain/equipment_import/equipment_candidate.dart';
import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/metadata_candidates.dart';

EquipmentFormTexts _with(
  EquipmentFormTexts t, {
  String? pixelPitch,
  String? focalLength,
}) => EquipmentFormTexts(
  name: t.name,
  manufacturer: t.manufacturer,
  cameraModel: t.cameraModel,
  resolutionWidth: t.resolutionWidth,
  resolutionHeight: t.resolutionHeight,
  pixelPitch: pixelPitch ?? t.pixelPitch,
  sensorWidth: t.sensorWidth,
  sensorHeight: t.sensorHeight,
  focalLength: focalLength ?? t.focalLength,
  focalRatio: t.focalRatio,
  diameter: t.diameter,
  rawFileSize: t.rawFileSize,
  rotation: t.rotation,
  maxExposure: t.maxExposure,
);

void main() {
  const fromJpeg = SpecProvenance('metadata:jpeg', SpecConfidence.reported);
  const estimate = SpecProvenance(
    'derived:calc-40/metadata:jpeg',
    SpecConfidence.estimated,
  );

  test('a candidate pre-fills what the file gives; the rest stays empty', () {
    final d = EquipmentDraft.fromCandidate(phoneCandidate());
    final t = d.initial;
    expect(t.name, 'TestMake TestPhone · 6.57 mm');
    expect(t.manufacturer, 'TestMake');
    expect(t.cameraModel, 'TestMake TestPhone');
    expect((t.resolutionWidth, t.resolutionHeight), ('4096', '3072'));
    expect(t.pixelPitch, '2.414');
    expect((t.sensorWidth, t.sensorHeight), ('9.89', '7.42'));
    expect(t.focalLength, '6.57');
    expect(t.focalRatio, '1.6');
    // Never pre-filled (ADR-011 §4–§5; a frame's 30 s is not a limit).
    expect(t.diameter, '');
    expect(t.rotation, '');
    expect(t.maxExposure, '');
    expect(t.rawFileSize, '');
    expect(d.trackingType, TrackingType.unknown);
    expect(d.existing, isNull);
    expect(d.metadataMake, 'TestMake');
    expect(d.metadataModel, 'TestMake TestPhone');
  });

  test('saved untouched: every pre-filled value keeps its origin; the rest '
      'is the user\'s', () {
    final d = EquipmentDraft.fromCandidate(phoneCandidate());
    final p = d.build(d.initial, TrackingType.unknown).profile!;
    expect(p.provenanceOf(EquipmentSpec.resolution), fromJpeg);
    expect(p.provenanceOf(EquipmentSpec.focalLength), fromJpeg);
    expect(p.provenanceOf(EquipmentSpec.focalRatio), fromJpeg);
    expect(p.provenanceOf(EquipmentSpec.pixelPitch), estimate);
    expect(p.provenanceOf(EquipmentSpec.sensorSize), estimate);
    expect(p.provenanceOf(EquipmentSpec.rawFileSize), SpecProvenance.user);
    expect(p.apertureDiameterMm, isNull);
    expect(p.pixelPitchUm, 2.414);
    expect(p.sensorWidthMm, 9.89);
    expect(p.metadataMake, 'TestMake');
    expect(p.metadataModel, 'TestMake TestPhone');
  });

  test('an edited pre-filled value becomes the user\'s own', () {
    final d = EquipmentDraft.fromCandidate(phoneCandidate());
    final edited = _with(d.initial, pixelPitch: '2.4', focalLength: '6.6');
    expect(d.unchangedPrefill(EquipmentSpec.pixelPitch, edited), isNull);
    final p = d.build(edited, TrackingType.unknown).profile!;
    expect(p.provenanceOf(EquipmentSpec.pixelPitch), SpecProvenance.user);
    expect(p.provenanceOf(EquipmentSpec.focalLength), SpecProvenance.user);
    expect(p.provenanceOf(EquipmentSpec.resolution), fromJpeg);
  });

  test('no dimensions, no estimate: those fields stay empty for the user', () {
    final d = EquipmentDraft.fromCandidate(phoneCandidate(withDims: false));
    expect(d.initial.resolutionWidth, '');
    expect(d.initial.pixelPitch, '');
    expect(d.initial.sensorWidth, '');
    expect(d.prefilled.keys, {
      EquipmentSpec.focalLength,
      EquipmentSpec.focalRatio,
    });
  });

  test('a saved rig with this camera fills the camera specs the file lacks, '
      'with that rig\'s provenance', () {
    final seed = EquipmentSeeder.defaults.single;
    final d = EquipmentDraft.fromCandidate(
      phoneCandidate(withDims: false, with35: false),
      cameraFrom: seed,
    );
    expect(d.initial.pixelPitch, '3.76');
    expect(d.initial.resolutionWidth, '6248');
    final pitch = d.prefilled[EquipmentSpec.pixelPitch]!;
    expect(pitch.fromSavedRig, isTrue);
    expect(pitch.provenance.confidence, SpecConfidence.verified);
    expect(
      PrefillText.note(pitch),
      'From your saved rig with this camera (verified)',
    );
    final p = d.build(d.initial, TrackingType.unknown).profile!;
    expect(
      p.provenanceOf(EquipmentSpec.pixelPitch),
      const SpecProvenance('seed:equipment@2', SpecConfidence.verified),
    );
    // The optics still come from the file.
    expect(p.provenanceOf(EquipmentSpec.focalLength), fromJpeg);
  });

  test('the notes say where a value came from', () {
    final d = EquipmentDraft.fromCandidate(phoneCandidate());
    expect(
      PrefillText.note(d.prefilled[EquipmentSpec.focalLength]!),
      'From the file (JPEG)',
    );
    expect(
      PrefillText.note(d.prefilled[EquipmentSpec.pixelPitch]!),
      'Estimated from the 35 mm equivalent — check it',
    );
  });

  test('editing a saved rig by hand behaves as before S3.5: an untouched '
      'sensor keeps its exact stored value and provenance', () {
    const stored = EquipmentProfile(
      id: 7,
      name: 'Rig',
      sensorWidthMm: 23.4999,
      sensorHeightMm: 15.7001,
      pixelPitchUm: 3.76,
      resolutionWidthPx: 6248,
      resolutionHeightPx: 4176,
      focalLengthMm: 400,
      focalRatio: 5.6,
      trackingType: TrackingType.guided,
      cameraSource: 'seed:x',
      cameraConfidence: SpecConfidence.verified,
    );
    final d = EquipmentDraft.fromProfile(stored);
    expect(d.initial.sensorWidth, '23.50');
    expect(d.prefilled, isEmpty);
    final p = d.build(d.initial, d.trackingType).profile!;
    expect(p.id, 7);
    expect(p.sensorWidthMm, 23.4999);
    expect(p.trackingType, TrackingType.guided);
    expect(p.cameraConfidence, SpecConfidence.verified);
  });

  test('an aperture problem is returned, not a profile', () {
    final d = EquipmentDraft.fromCandidate(phoneCandidate());
    final t = d.initial;
    final bad = EquipmentFormTexts(
      name: t.name,
      resolutionWidth: t.resolutionWidth,
      resolutionHeight: t.resolutionHeight,
      pixelPitch: t.pixelPitch,
      sensorWidth: t.sensorWidth,
      sensorHeight: t.sensorHeight,
      focalLength: '400',
      focalRatio: '5.6',
      // With a diameter the ratio is derived (N = f / D, ADR-011 §4); a
      // diameter outside 1–2000 mm is refused.
      diameter: '5000',
    );
    final result = d.build(bad, TrackingType.unknown);
    expect(result.profile, isNull);
    expect(result.apertureProblem, ApertureProblem.diameterOutOfRange);
  });

  test('S3.8: a DNG pre-fills the RAW size, noted as one file', () {
    final c = EquipmentCandidate.fromReading(
      MetadataRead(MetadataFormat.dng, const CaptureMetadata()),
      fileLengthBytes: 25074220,
    );
    final d = EquipmentDraft.fromCandidate(c);
    expect(d.initial.rawFileSize, '25.1');
    expect(
      PrefillText.note(d.prefilled[EquipmentSpec.rawFileSize]!),
      'Estimated from this one file'
      "'"
      's size (DNG)',
    );
  });
}
