// S3.9 (TD-068): a rig saved from a file through the editor must match that
// same file with no differences. Device check M4 showed "2.425 µm vs
// 2.425 µm" because the editor stored rounded estimates and the matcher
// compared them with unrounded ones.

import 'package:astroplan/domain/equipment_import/equipment_candidate.dart';
import 'package:astroplan/domain/equipment_import/equipment_matcher.dart';
import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/presentation/shared/equipment_draft.dart';
import 'package:flutter_test/flutter_test.dart';

KnownValue<T> _k<T>(T v, String field) => KnownValue(
  v,
  raw: '$v',
  origin: MetadataOrigin(format: MetadataFormat.dng, field: field),
);

/// Saves [c] through the editor's form model untouched, as the user's Save
/// does, and gives the stored rig an id.
EquipmentProfile _saved(EquipmentCandidate c) {
  final draft = EquipmentDraft.fromCandidate(c);
  final p = draft.build(draft.initial, TrackingType.unknown).profile!;
  return EquipmentProfile(
    id: 1,
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
    averageRawFileSizeMB: p.averageRawFileSizeMB,
    cameraSource: p.cameraSource,
    cameraConfidence: p.cameraConfidence,
    opticsSource: p.opticsSource,
    opticsConfidence: p.opticsConfidence,
    specProvenance: p.specProvenance,
    metadataMake: p.metadataMake,
    metadataModel: p.metadataModel,
  );
}

void main() {
  // The device case (M4): a phone main camera's DNG, 4080 × 3056, f₃₅ 23,
  // 25,172,524 bytes; and the telephoto, plus a JPEG without a RAW size.
  final cases = {
    'main DNG (the M4 case)': (6.57, 1.6, 23.0, 4080, 3056, 25172524),
    'telephoto DNG': (8.8, 2.0, 60.0, 4064, 3056, 25074220),
    'main JPEG, portrait, no RAW size': (6.57, 1.6, 23.0, 3072, 4096, null),
  };
  for (final MapEntry(key: name, value: v) in cases.entries) {
    test('a rig saved from a file matches that file with no differences: '
        '$name', () {
      final (f, n, f35, w, h, bytes) = v;
      final c = EquipmentCandidate.fromReading(
        MetadataRead(
          bytes == null ? MetadataFormat.jpeg : MetadataFormat.dng,
          CaptureMetadata(
            cameraMake: _k('TestMake', 'Make'),
            cameraModel: _k('TestMake TestPhone/TEST0001', 'Model'),
            focalLengthMm: _k(f, 'FocalLength'),
            fNumber: _k(n, 'FNumber'),
            focalLength35mmEquivalentMm: _k(f35, 'FocalLengthIn35mmFilm'),
            imageDimensions: _k(ImageDimensions(w, h), 'dims'),
          ),
        ),
        fileLengthBytes: bytes,
      );
      final m = EquipmentMatcher.match(c, [_saved(c)]);
      expect(m.outcome, MatchKind.sameRig);
      expect(
        m.rigs.single.conflicts.map((x) => x.spec),
        isEmpty,
        reason: 'no rounding "differences"',
      );
      expect(m.rigs.single.fillable, isEmpty);
    });
  }

  test('a real difference is still listed (a user value against the file)', () {
    final c = EquipmentCandidate.fromReading(
      MetadataRead(
        MetadataFormat.dng,
        CaptureMetadata(
          cameraMake: _k('TestMake', 'Make'),
          cameraModel: _k('TestMake TestPhone', 'Model'),
          focalLengthMm: _k(6.57, 'FocalLength'),
          fNumber: _k(1.6, 'FNumber'),
          focalLength35mmEquivalentMm: _k(23.0, 'FocalLengthIn35mmFilm'),
          imageDimensions: _k(const ImageDimensions(4080, 3056), 'dims'),
        ),
      ),
    );
    final saved = _saved(c);
    final edited = EquipmentProfile(
      id: saved.id,
      name: saved.name,
      sensorWidthMm: saved.sensorWidthMm,
      sensorHeightMm: saved.sensorHeightMm,
      pixelPitchUm: 2.4, // typed by the user
      resolutionWidthPx: saved.resolutionWidthPx,
      resolutionHeightPx: saved.resolutionHeightPx,
      focalLengthMm: saved.focalLengthMm,
      focalRatio: saved.focalRatio,
      metadataMake: saved.metadataMake,
      metadataModel: saved.metadataModel,
    );
    final conflicts = EquipmentMatcher.match(c, [edited]).rigs.single.conflicts;
    expect(conflicts.map((x) => x.spec), [EquipmentSpec.pixelPitch]);
  });
}
