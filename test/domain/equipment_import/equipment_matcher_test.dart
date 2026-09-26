// S3.3 (ADR-018 §6): matching a candidate against saved rigs, on synthetic
// readings and rigs only. Outcomes come from stated rules, never a score.

import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/equipment_import/equipment_candidate.dart';
import 'package:astroplan/domain/equipment_import/equipment_matcher.dart';
import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:flutter_test/flutter_test.dart';

KnownValue<T> _k<T>(T v, String field) => KnownValue(
  v,
  raw: '$v',
  origin: MetadataOrigin(format: MetadataFormat.jpeg, field: field),
);

/// A file from a phone's main camera (neutral strings): JPEG-style model by
/// default, portrait pixel dimensions, f₃₅ 23.
EquipmentCandidate _file({
  String? make = 'TestMake',
  String? model = 'TestMake TestPhone',
  double? f = 6.57,
  double? n = 1.6,
  double? f35 = 23,
  ImageDimensions? dims = const ImageDimensions(3072, 4096),
  MetadataFormat format = MetadataFormat.jpeg,
}) => EquipmentCandidate.fromReading(
  MetadataRead(
    format,
    CaptureMetadata(
      cameraMake: make == null ? const AbsentValue() : _k(make, 'Make'),
      cameraModel: model == null ? const AbsentValue() : _k(model, 'Model'),
      focalLengthMm: f == null ? const AbsentValue() : _k(f, 'FocalLength'),
      fNumber: n == null ? const AbsentValue() : _k(n, 'FNumber'),
      focalLength35mmEquivalentMm: f35 == null
          ? const AbsentValue()
          : _k(f35, 'FocalLengthIn35mmFilm'),
      imageDimensions: dims == null ? const AbsentValue() : _k(dims, 'dims'),
    ),
  ),
);

/// A saved rig for that main camera, imported earlier (metadata identity
/// stored), with sensor values close to the CALC-40 estimate.
EquipmentProfile _rig({
  int id = 1,
  String name = 'Phone main',
  String? manufacturer = 'TestMake',
  String? cameraModel = 'TestMake TestPhone',
  String? metadataMake = 'TestMake',
  String? metadataModel = 'TestMake TestPhone',
  double f = 6.57,
  double n = 1.6,
  int w = 4096,
  int h = 3072,
  double sensorW = 9.89,
  double sensorH = 7.42,
  double pitch = 2.41,
  String? cameraSource = 'user',
  SpecConfidence? cameraConfidence = SpecConfidence.reported,
}) => EquipmentProfile(
  id: id,
  name: name,
  manufacturer: manufacturer,
  cameraModel: cameraModel,
  sensorWidthMm: sensorW,
  sensorHeightMm: sensorH,
  pixelPitchUm: pitch,
  resolutionWidthPx: w,
  resolutionHeightPx: h,
  focalLengthMm: f,
  focalRatio: n,
  cameraSource: cameraSource,
  cameraConfidence: cameraConfidence,
  metadataMake: metadataMake,
  metadataModel: metadataModel,
);

void main() {
  test('no saved rigs, or no rig with this camera: none', () {
    expect(EquipmentMatcher.match(_file(), []).outcome, MatchKind.none);
    final other = _rig(metadataModel: 'Other Phone', cameraModel: 'Other');
    final m = EquipmentMatcher.match(_file(), [other]);
    expect(m.outcome, MatchKind.none);
    expect(m.rigs, isEmpty);
  });

  test('same rig: same identity, optics and mode; portrait pixels compare '
      'by their long and short sides', () {
    final m = EquipmentMatcher.match(_file(), [_rig()]);
    expect(m.outcome, MatchKind.sameRig);
    final r = m.rigs.single;
    expect(r.reasons, [
      MatchReason.identityFromImport,
      MatchReason.sameMake,
      MatchReason.sameModel,
      MatchReason.sameFocalLength,
      MatchReason.sameFocalRatio,
    ]);
    // The saved sensor size equals the estimate at its stored precision
    // (S3.9, TD-068); the saved 2.41 µm differs from the estimate's
    // 2.414 µm: listed, never applied.
    expect(r.conflicts.map((c) => c.spec), [EquipmentSpec.pixelPitch]);
    final pitch = r.conflicts.single;
    expect(pitch.saved, 2.41);
    expect(pitch.imported, 2.414);
    expect(pitch.importedProvenance.confidence, SpecConfidence.estimated);
    expect(pitch.savedIsVerified, isFalse);
  });

  test('likely the same rig: a DNG model with a code suffix against a rig '
      'imported from the JPEG (the owner phone case)', () {
    final dng = _file(
      model: 'TestMake TestPhone/TEST0001',
      format: MetadataFormat.dng,
      dims: const ImageDimensions(4096, 3072),
    );
    final m = EquipmentMatcher.match(dng, [_rig()]);
    expect(m.outcome, MatchKind.likelySameRig);
    expect(m.rigs.single.reasons, contains(MatchReason.modelByPrefix));
  });

  test('the prefix rule needs a separator and a suffix', () {
    expect(
      EquipmentMatcher.modelByPrefix('x 14t pro/2407', 'x 14t pro'),
      isTrue,
    );
    expect(
      EquipmentMatcher.modelByPrefix('x 14t pro', 'x 14t pro-2407'),
      isTrue,
    );
    expect(EquipmentMatcher.modelByPrefix('x 14t pro', 'x 14t pros'), isFalse);
    expect(EquipmentMatcher.modelByPrefix('x 14t pro', 'x 14t pro/'), isFalse);
    expect(EquipmentMatcher.modelByPrefix('x 14t pro', 'x 14t pro'), isFalse);
    // A known limit of ADR-018's rule: "Pro Max" against "Pro" is only
    // "likely", so the user sees both strings and decides.
    expect(EquipmentMatcher.modelByPrefix('x 15 pro', 'x 15 pro max'), isTrue);
  });

  test('labels are used when no import identity is stored, normalised', () {
    final byHand = _rig(
      manufacturer: '  testmake ',
      cameraModel: 'TestMake   TESTPHONE',
      metadataMake: null,
      metadataModel: null,
    );
    final m = EquipmentMatcher.match(_file(), [byHand]);
    expect(m.outcome, MatchKind.sameRig);
    expect(m.rigs.single.reasons.first, MatchReason.identityFromLabels);
  });

  test('the stored import identity wins over renamed labels', () {
    final renamed = _rig(manufacturer: 'Me', cameraModel: 'My phone');
    expect(
      EquipmentMatcher.match(_file(), [renamed]).outcome,
      MatchKind.sameRig,
    );
  });

  test('different makes never match; a missing make leaves the model to '
      'decide', () {
    expect(
      EquipmentMatcher.match(_file(make: 'OtherMake'), [_rig()]).outcome,
      MatchKind.none,
    );
    expect(
      EquipmentMatcher.match(_file(make: null), [_rig()]).outcome,
      MatchKind.sameRig,
    );
    expect(
      EquipmentMatcher.match(_file(model: null), [_rig()]).outcome,
      MatchKind.none,
      reason: 'no model, no camera identity',
    );
  });

  test('two identical saved bodies: ambiguous, the user chooses', () {
    final m = EquipmentMatcher.match(_file(), [
      _rig(id: 1, name: 'Phone A'),
      _rig(id: 2, name: 'Phone B'),
    ]);
    expect(m.outcome, MatchKind.ambiguous);
    expect(m.rigs.map((r) => r.rig.id), [1, 2]);
  });

  test('a phone\'s other module: same camera, other optics', () {
    final tele = _file(f: 8.8, n: 2.0, f35: 60);
    final m = EquipmentMatcher.match(tele, [_rig()]);
    expect(m.outcome, MatchKind.sameCameraOtherOptics);
    expect(
      m.rigs.single.reasons,
      containsAll([
        MatchReason.focalLengthDiffers,
        MatchReason.focalRatioDiffers,
      ]),
    );
    expect(m.rigs.single.conflicts, isEmpty);
  });

  test('a body on a telescope (no f or N in the file): same camera, optics '
      'unknown', () {
    final m = EquipmentMatcher.match(_file(f: null, n: null, f35: null), [
      _rig(),
    ]);
    expect(m.outcome, MatchKind.sameCameraOtherOptics);
    expect(m.rigs.single.reasons.last, MatchReason.opticsUnknown);
  });

  test('digital zoom (same f and N, twice the 35 mm equivalent): another '
      'mode, never "same"', () {
    final zoom = _file(f35: 46);
    final m = EquipmentMatcher.match(zoom, [_rig()]);
    expect(m.outcome, MatchKind.croppedOrBinnedMode);
    expect(m.rigs.single.reasons, contains(MatchReason.fieldOfViewDiffers));
  });

  test('a full-resolution mode (other pixel count): another mode', () {
    final full = _file(dims: const ImageDimensions(8192, 6144));
    final m = EquipmentMatcher.match(full, [_rig()]);
    expect(m.outcome, MatchKind.croppedOrBinnedMode);
    expect(m.rigs.single.reasons, contains(MatchReason.pixelCountDiffers));
  });

  test('the 1 % optics tolerance: a rounded 6.6 matches, 6.7 does not', () {
    expect(
      EquipmentMatcher.match(_file(), [_rig(f: 6.6)]).outcome,
      MatchKind.sameRig,
    );
    final m = EquipmentMatcher.match(_file(), [_rig(f: 6.7)]);
    expect(m.outcome, MatchKind.sameCameraOtherOptics);
  });

  test('a verified saved value is flagged; a legacy one is not', () {
    final verified = _rig(
      sensorW: 9.8,
      sensorH: 7.35,
      cameraSource: 'seed:test',
      cameraConfidence: SpecConfidence.verified,
    );
    final conflict = EquipmentMatcher.match(_file(), [verified])
        .rigs
        .single
        .conflicts
        .firstWhere((c) => c.spec == EquipmentSpec.sensorSize);
    expect(conflict.saved, [9.8, 7.35]);
    expect(conflict.savedIsVerified, isTrue);
    expect(
      conflict.savedProvenance,
      const SpecProvenance('seed:test', SpecConfidence.verified),
    );

    final legacy = _rig(
      sensorW: 9.8,
      cameraSource: null,
      cameraConfidence: null,
    );
    final legacyConflict = EquipmentMatcher.match(_file(), [legacy])
        .rigs
        .single
        .conflicts
        .firstWhere((c) => c.spec == EquipmentSpec.sensorSize);
    expect(legacyConflict.savedProvenance, isNull);
    expect(legacyConflict.savedIsVerified, isFalse);
  });

  test('the seeded camera matches by its labels; a rounded f/5.6 is the '
      'same optic, with the difference listed', () {
    final seed = EquipmentSeeder.defaults.single;
    final astro = _file(
      make: 'ZWO',
      model: 'ASI2600MC',
      f: 400,
      n: 5.6,
      f35: null,
      dims: const ImageDimensions(6248, 4176),
    );
    final m = EquipmentMatcher.match(astro, [seed]);
    expect(m.outcome, MatchKind.sameRig);
    final ratio = m.rigs.single.conflicts.single;
    expect(ratio.spec, EquipmentSpec.focalRatio);
    expect(ratio.imported, 5.6);
    expect(ratio.savedProvenance?.confidence, SpecConfidence.estimated);
    expect(m.rigs.single.fillable, isEmpty, reason: 'no RAW size proposed');
  });

  group('S3.8: the RAW size of a DNG', () {
    EquipmentCandidate dng() => EquipmentCandidate.fromReading(
      MetadataRead(
        MetadataFormat.dng,
        CaptureMetadata(
          cameraMake: _k('TestMake', 'Make'),
          cameraModel: _k('TestMake TestPhone', 'Model'),
          focalLengthMm: _k(6.57, 'FocalLength'),
          fNumber: _k(1.6, 'FNumber'),
          focalLength35mmEquivalentMm: _k(23.0, 'FocalLengthIn35mmFilm'),
          imageDimensions: _k(const ImageDimensions(4096, 3072), 'dims'),
        ),
      ),
      fileLengthBytes: 25074220,
    );

    test('a rig without a RAW size can be filled from the file', () {
      final r = EquipmentMatcher.match(dng(), [_rig()]).rigs.single;
      expect(r.fillable, [EquipmentSpec.rawFileSize]);
      expect(
        r.conflicts.map((c) => c.spec),
        isNot(contains(EquipmentSpec.rawFileSize)),
      );
    });

    test('a saved RAW size is never filled over; a difference is a conflict, '
        'kept by default', () {
      final saved = EquipmentProfile(
        id: 1,
        name: 'Phone main',
        sensorWidthMm: 9.89,
        sensorHeightMm: 7.42,
        pixelPitchUm: 2.41,
        resolutionWidthPx: 4096,
        resolutionHeightPx: 3072,
        focalLengthMm: 6.57,
        focalRatio: 1.6,
        averageRawFileSizeMB: 30,
        metadataMake: 'TestMake',
        metadataModel: 'TestMake TestPhone',
      );
      final r = EquipmentMatcher.match(dng(), [saved]).rigs.single;
      expect(r.fillable, isEmpty);
      final raw = r.conflicts.singleWhere(
        (c) => c.spec == EquipmentSpec.rawFileSize,
      );
      expect(raw.saved, 30);
      expect(raw.importedProvenance.source, 'metadata:dng:file-size');
    });
  });
}
