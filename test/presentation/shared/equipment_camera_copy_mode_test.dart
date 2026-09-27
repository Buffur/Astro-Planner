// S3.V8 (S3S-02, TD-071, SI-014): "a new rig with the camera specs of" a
// saved rig never copies its pixel size or sensor size into a file with
// another pixel count. Binning, a crop, resampling or another sensor mode
// could explain the difference, and metadata cannot tell which, so those
// values stay unknown until the user provides them (owner, option (a)).

import 'package:astroplan/domain/equipment_import/equipment_matcher.dart';
import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/metadata_candidates.dart';

/// A saved rig of the candidate's camera, other optics: 4096 × 3072 px,
/// 2.414 µm, verified.
const _saved = EquipmentProfile(
  id: 4,
  name: 'Phone main',
  manufacturer: 'TestMake',
  cameraModel: 'TestMake TestPhone',
  sensorWidthMm: 9.894,
  sensorHeightMm: 7.416,
  pixelPitchUm: 2.414,
  resolutionWidthPx: 4096,
  resolutionHeightPx: 3072,
  focalLengthMm: 15,
  focalRatio: 2,
  cameraSource: 'seed:test',
  cameraConfidence: SpecConfidence.verified,
);

EquipmentFormTexts _withPitch(EquipmentFormTexts t, String pitch) {
  final size = EquipmentDraft.sensorSizeText(
    t.resolutionWidth,
    t.resolutionHeight,
    pitch,
  )!;
  return EquipmentFormTexts(
    name: t.name,
    manufacturer: t.manufacturer,
    cameraModel: t.cameraModel,
    resolutionWidth: t.resolutionWidth,
    resolutionHeight: t.resolutionHeight,
    pixelPitch: pitch,
    sensorWidth: size.width,
    sensorHeight: size.height,
    focalLength: t.focalLength,
    focalRatio: t.focalRatio,
    diameter: t.diameter,
    rawFileSize: t.rawFileSize,
    rotation: t.rotation,
    maxExposure: t.maxExposure,
  );
}

void main() {
  test('another pixel count (a 2×2-binned output): pixel size and sensor '
      'size stay unknown, with the reason', () {
    final c = phoneCandidate(
      with35: false,
      dims: const ImageDimensions(2048, 1536),
    );
    expect(
      EquipmentMatcher.match(c, const [_saved]).outcome,
      MatchKind.sameCameraOtherOptics,
    );
    final d = EquipmentDraft.fromCandidate(c, cameraFrom: _saved);
    expect(d.initial.resolutionWidth, '2048');
    expect(d.initial.pixelPitch, '');
    expect(d.initial.sensorWidth, '');
    expect(d.initial.sensorHeight, '');
    expect(d.prefilled.keys, isNot(contains(EquipmentSpec.pixelPitch)));
    expect(d.prefilled.keys, isNot(contains(EquipmentSpec.sensorSize)));

    final w = d.withheldFromSavedRig!;
    expect(w.rigName, 'Phone main');
    expect(w.specs, {EquipmentSpec.pixelPitch, EquipmentSpec.sensorSize});
    expect(
      PrefillText.withheld(w),
      'Pixel size not copied from "Phone main": this file is 2048 × 1536 px, '
      'that rig 4096 × 3072 px. Binning, a crop or another mode could explain '
      'the difference, so enter the pixel size for this one.',
    );
  });

  test('the user\'s pixel size is saved as theirs; the sensor size follows '
      'from it', () {
    final c = phoneCandidate(
      with35: false,
      dims: const ImageDimensions(2048, 1536),
    );
    final d = EquipmentDraft.fromCandidate(c, cameraFrom: _saved);
    final p = d
        .build(_withPitch(d.initial, '4.8'), TrackingType.unknown)
        .profile!;
    expect(p.pixelPitchUm, 4.8);
    expect(p.sensorWidthMm, closeTo(2048 * 4.8 / 1000, 0.005));
    expect(p.provenanceOf(EquipmentSpec.pixelPitch), SpecProvenance.user);
    expect(p.provenanceOf(EquipmentSpec.sensorSize), SpecProvenance.user);
    // The file's own values keep the file's provenance.
    expect(p.provenanceOf(EquipmentSpec.resolution)!.source, 'metadata:jpeg');
  });

  test('the same pixel count, in either orientation: copied as before', () {
    final c = phoneCandidate(
      with35: false,
      dims: const ImageDimensions(3072, 4096),
    );
    final d = EquipmentDraft.fromCandidate(c, cameraFrom: _saved);
    expect(d.withheldFromSavedRig, isNull);
    expect(d.initial.pixelPitch, '2.414');
    final p = d.build(d.initial, TrackingType.unknown).profile!;
    expect(p.pixelPitchUm, 2.414);
    expect(p.sensorWidthMm, 9.894);
    expect(
      p.provenanceOf(EquipmentSpec.pixelPitch)!.confidence,
      SpecConfidence.verified,
    );
  });

  test('no pixel count in the file: the saved camera is copied whole, as '
      'before', () {
    final c = phoneCandidate(withDims: false, with35: false);
    final d = EquipmentDraft.fromCandidate(c, cameraFrom: _saved);
    expect(d.withheldFromSavedRig, isNull);
    expect(d.initial.resolutionWidth, '4096');
    expect(d.initial.pixelPitch, '2.414');
  });

  test('the file\'s own estimate is used; nothing is withheld', () {
    final c = phoneCandidate(dims: const ImageDimensions(2048, 1536));
    final d = EquipmentDraft.fromCandidate(c, cameraFrom: _saved);
    expect(d.withheldFromSavedRig, isNull);
    expect(
      d.prefilled[EquipmentSpec.pixelPitch]!.provenance.confidence,
      SpecConfidence.estimated,
    );
  });
}
