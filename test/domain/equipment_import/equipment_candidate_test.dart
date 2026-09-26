// S3.2 (ADR-018 §4): a metadata reading → an equipment candidate, and the
// CALC-40 estimate, on synthetic readings only. Expected estimate values were
// computed by hand (independently, outside the app) from the formula.

import 'package:astroplan/domain/equipment_import/equipment_candidate.dart';
import 'package:astroplan/domain/equipment_import/sensor_geometry_estimate.dart';
import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:flutter_test/flutter_test.dart';

MetadataOrigin _o(String field, [MetadataFormat f = MetadataFormat.dng]) =>
    MetadataOrigin(format: f, field: field, location: 'IFD0');

KnownValue<T> _k<T>(
  T v,
  String field, [
  MetadataFormat f = MetadataFormat.dng,
]) => KnownValue(v, raw: '$v', origin: _o(field, f));

EquipmentCandidate _candidate(
  CaptureMetadata m, [
  MetadataFormat f = MetadataFormat.dng,
]) => EquipmentCandidate.fromReading(MetadataRead(f, m));

/// A phone module like the owner's main camera (committed RG-01 values:
/// f = 6.57 mm, f₃₅ = 23 mm, 4096 × 3072), with neutral identity strings.
CaptureMetadata _phone({
  MetadataFormat f = MetadataFormat.dng,
  ImageDimensions dims = const ImageDimensions(4096, 3072),
}) => CaptureMetadata(
  exposureSeconds: _k(30.0, 'ExposureTime', f),
  sensitivity: _k(
    const Sensitivity(SensitivityKind.isoUnspecified, 50),
    'ISO',
    f,
  ),
  captureTime: _k(
    const CaptureTime(
      year: 2000,
      month: 1,
      day: 2,
      hour: 21,
      minute: 30,
      second: 5,
    ),
    'DateTimeOriginal',
    f,
  ),
  cameraMake: _k('TestMake', 'Make', f),
  cameraModel: _k('TestMake TestPhone/TEST0001', 'Model', f),
  uniqueCameraModel: _k('TEST0001-TestMake', 'UniqueCameraModel', f),
  focalLengthMm: _k(6.57, 'FocalLength', f),
  focalLength35mmEquivalentMm: _k(23.0, 'FocalLengthIn35mmFilm', f),
  fNumber: _k(1.6, 'FNumber', f),
  imageDimensions: _k(dims, 'ImageWidth/ImageLength', f),
);

List<CandidateField<Object>> _allFields(EquipmentCandidate c) => [
  c.manufacturer,
  c.cameraModel,
  c.resolutionWidthPx,
  c.resolutionHeightPx,
  c.focalLengthMm,
  c.focalRatio,
  c.sensorWidthMm,
  c.sensorHeightMm,
  c.pixelPitchUm,
  c.averageRawFileSizeMB,
  c.apertureDiameterMm,
  c.rotationDeg,
  c.maxExposureS,
];

void main() {
  group('CALC-40: sensor geometry from the 35 mm equivalent', () {
    test('the owner phone main camera (f 6.57, f35 23, 4096 x 3072)', () {
      final e = SensorGeometryEstimate.of(
        focalLengthMm: 6.57,
        focalLength35mmEquivalentMm: 23,
        longSidePx: 4096,
        shortSidePx: 3072,
      )!;
      expect(e.cropFactor, closeTo(3.50076, 1e-5));
      expect(e.widthMm, closeTo(9.88736, 1e-5));
      expect(e.heightMm, closeTo(7.41552, 1e-5));
      expect(e.pixelPitchUm, closeTo(2.41391, 1e-5));
    });

    test('the telephoto (f 8.8, f35 60, 4064 x 3056) and a round case', () {
      final tele = SensorGeometryEstimate.of(
        focalLengthMm: 8.8,
        focalLength35mmEquivalentMm: 60,
        longSidePx: 4064,
        shortSidePx: 3056,
      )!;
      expect(tele.widthMm, closeTo(5.07182, 1e-5));
      expect(tele.heightMm, closeTo(3.81385, 1e-5));
      expect(tele.pixelPitchUm, closeTo(1.24799, 1e-5));

      final round = SensorGeometryEstimate.of(
        focalLengthMm: 4,
        focalLength35mmEquivalentMm: 24,
        longSidePx: 4000,
        shortSidePx: 3000,
      )!;
      expect(round.cropFactor, 6);
      expect(round.widthMm, closeTo(5.76888, 1e-5));
      expect(round.heightMm, closeTo(4.32666, 1e-5));
    });

    test('no estimate without a crop, with bad inputs, or out of range', () {
      SensorGeometryEstimate? of(double f, double f35, int l, int s) =>
          SensorGeometryEstimate.of(
            focalLengthMm: f,
            focalLength35mmEquivalentMm: f35,
            longSidePx: l,
            shortSidePx: s,
          );
      expect(of(50, 50, 6000, 4000), isNull, reason: 'f35 = f: no crop');
      expect(of(50, 35, 6000, 4000), isNull, reason: 'f35 < f');
      expect(of(0, 23, 4096, 3072), isNull);
      expect(of(6.57, 23, 3072, 4096), isNull, reason: 'long < short');
      expect(of(6.57, 23, 4096, 0), isNull);
      // A 0.4 mm sensor: below EquipmentLimits.sensorSideMm.
      expect(of(1, 100, 4000, 3000), isNull);
      // A 0.34 µm pitch (9.9 mm over 29,000 px): below
      // EquipmentLimits.pixelPitchUm.
      expect(of(6.57, 23, 29000, 21750), isNull);
      // The same sensor at a plausible pixel count is estimated.
      expect(of(6.57, 23, 8192, 6144), isNotNull);
    });
  });

  group('the candidate', () {
    test('a phone module: file values reported, the estimate offered as '
        'estimated, frame settings ignored', () {
      final c = _candidate(_phone());
      expect(c.format, MetadataFormat.dng);
      expect(c.hasEnoughEvidence, isTrue);
      expect(c.suggestedName, 'TestMake TestPhone/TEST0001 · 6.57 mm');

      final focal = c.focalLengthMm as ProposedField<double>;
      expect(focal.value, 6.57);
      expect(focal.source, 'metadata:dng');
      expect(focal.confidence, SpecConfidence.reported);
      expect(focal.origins.single.field, 'FocalLength');
      expect(c.focalRatio.valueOrNull, 1.6);
      expect(c.manufacturer.valueOrNull, 'TestMake');
      expect(c.cameraModel.valueOrNull, 'TestMake TestPhone/TEST0001');
      expect(c.resolutionWidthPx.valueOrNull, 4096);
      expect(c.resolutionHeightPx.valueOrNull, 3072);
      expect(
        (c.resolutionWidthPx as ProposedField).confidence,
        SpecConfidence.reported,
      );

      final pitch = c.pixelPitchUm as ProposedField<double>;
      expect(pitch.value, closeTo(2.41391, 1e-5));
      expect(pitch.source, 'derived:calc-40/metadata:dng');
      expect(pitch.confidence, SpecConfidence.estimated);
      expect(pitch.origins.map((o) => o.field), [
        'FocalLength',
        'FocalLengthIn35mmFilm',
        'ImageWidth/ImageLength',
      ]);
      expect(c.sensorWidthMm.valueOrNull, closeTo(9.88736, 1e-5));
      expect(c.sensorHeightMm.valueOrNull, closeTo(7.41552, 1e-5));

      // Never from metadata (ADR-011 §4, §5).
      for (final f in [c.apertureDiameterMm, c.rotationDeg, c.maxExposureS]) {
        expect((f as UnknownField).gap, CandidateGap.neverFromMetadata);
      }
      // The RAW size waits for S3.8.
      expect(c.averageRawFileSizeMB, isA<UnknownField<double>>());
      // The frame's 30 s exposure is not the rig's maximum exposure.
      expect(c.maxExposureS.valueOrNull, isNull);

      expect(c.evidence.uniqueCameraModel, 'TEST0001-TestMake');
      expect(c.evidence.focalLength35mmEquivalentMm, 23);
      expect(c.evidence.imageDimensions, const ImageDimensions(4096, 3072));
    });

    test('no proposed field is ever verified', () {
      for (final c in [
        _candidate(_phone()),
        _candidate(_phone(f: MetadataFormat.jpeg), MetadataFormat.jpeg),
      ]) {
        for (final f in _allFields(c)) {
          if (f is ProposedField<Object>) {
            expect(f.confidence, isNot(SpecConfidence.verified));
          }
        }
      }
    });

    test('a portrait JPEG: the long side becomes the width; the source '
        'names the format', () {
      final c = _candidate(
        _phone(f: MetadataFormat.jpeg, dims: const ImageDimensions(3072, 4096)),
        MetadataFormat.jpeg,
      );
      expect(c.resolutionWidthPx.valueOrNull, 4096);
      expect(c.resolutionHeightPx.valueOrNull, 3072);
      expect(c.sensorWidthMm.valueOrNull, closeTo(9.88736, 1e-5));
      expect((c.focalLengthMm as ProposedField).source, 'metadata:jpeg');
      expect(
        (c.pixelPitchUm as ProposedField).source,
        'derived:calc-40/metadata:jpeg',
      );
    });

    test('a body with an electronic lens and no 35 mm equivalent: optics '
        'proposed, sensor not estimable', () {
      final c = _candidate(
        CaptureMetadata(
          cameraMake: _k('TestCam', 'Make'),
          cameraModel: _k('Body X', 'Model'),
          lensModel: _k('Lens 24-70', 'LensModel'),
          focalLengthMm: _k(50.0, 'FocalLength'),
          fNumber: _k(4.0, 'FNumber'),
          imageDimensions: _k(const ImageDimensions(6000, 4000), 'dims'),
        ),
      );
      expect(c.suggestedName, 'TestCam Body X · Lens 24-70');
      expect(c.focalLengthMm.valueOrNull, 50);
      expect(c.focalRatio.valueOrNull, 4);
      expect(c.resolutionWidthPx.valueOrNull, 6000);
      for (final f in [c.sensorWidthMm, c.sensorHeightMm, c.pixelPitchUm]) {
        expect((f as UnknownField).gap, CandidateGap.notEstimable);
      }
      expect(c.evidence.lensModel, 'Lens 24-70');
    });

    test('a body on a telescope: no focal length, an unreadable f-number; '
        'nothing invented', () {
      final c = _candidate(
        CaptureMetadata(
          cameraMake: _k('TestCam', 'Make'),
          cameraModel: _k('TestCam Body Y', 'Model'),
          fNumber: UnparseableValue(raw: '0/1', origin: _o('FNumber')),
          focalLength35mmEquivalentMm: _k(35.0, 'FocalLengthIn35mmFilm'),
          imageDimensions: _k(const ImageDimensions(6000, 4000), 'dims'),
        ),
      );
      expect(c.hasEnoughEvidence, isTrue);
      expect(c.suggestedName, 'TestCam Body Y');
      expect((c.focalLengthMm as UnknownField).gap, CandidateGap.notInFile);
      expect((c.focalRatio as UnknownField).gap, CandidateGap.unreadable);
      expect((c.sensorWidthMm as UnknownField).gap, CandidateGap.notEstimable);
    });

    test('conflicting and implausible values stay unknown with a reason', () {
      final c = _candidate(
        CaptureMetadata(
          cameraMake: _k('TestMake', 'Make'),
          focalLengthMm: AmbiguousValue([
            (raw: '657/100', origin: _o('FocalLength')),
            (raw: '880/100', origin: _o('FocalLength')),
          ]),
          fNumber: _k(64.0, 'FNumber'), // above EquipmentLimits.focalRatio
          focalLength35mmEquivalentMm: _k(23.0, 'FocalLengthIn35mmFilm'),
          imageDimensions: _k(const ImageDimensions(64, 48), 'dims'),
        ),
      );
      expect((c.focalLengthMm as UnknownField).gap, CandidateGap.conflicting);
      expect((c.focalRatio as UnknownField).gap, CandidateGap.outOfRange);
      expect(
        (c.resolutionWidthPx as UnknownField).gap,
        CandidateGap.outOfRange,
      );
      expect(
        (c.resolutionHeightPx as UnknownField).gap,
        CandidateGap.outOfRange,
      );
      expect((c.pixelPitchUm as UnknownField).gap, CandidateGap.notEstimable);
    });

    test('a file with no camera and no optics gives not enough evidence', () {
      final c = _candidate(
        CaptureMetadata(
          exposureSeconds: _k(30.0, 'ExposureTime'),
          imageDimensions: _k(const ImageDimensions(4000, 3000), 'dims'),
        ),
      );
      expect(c.hasEnoughEvidence, isFalse);
      expect(c.suggestedName, isNull);
      expect(_candidate(const CaptureMetadata()).hasEnoughEvidence, isFalse);
    });

    test('the name does not repeat the make, and uses what is known', () {
      String? name(CaptureMetadata m) => _candidate(m).suggestedName;
      expect(
        name(
          CaptureMetadata(
            cameraMake: _k('TestCam', 'Make'),
            cameraModel: _k('EOS Test', 'Model'),
          ),
        ),
        'TestCam EOS Test',
      );
      expect(
        name(CaptureMetadata(cameraModel: _k('Body Z', 'Model'))),
        'Body Z',
      );
      expect(
        name(CaptureMetadata(focalLengthMm: _k(8.8, 'FocalLength'))),
        '8.8 mm',
      );
    });
  });
}
