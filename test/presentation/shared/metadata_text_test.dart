// S2.5: the metadata contract's wording. Units always; a source for every
// value; unknowns said as unknown.

import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';
import 'package:astroplan/presentation/shared/metadata_text.dart';
import 'package:flutter_test/flutter_test.dart';

const _o = MetadataOrigin(
  format: MetadataFormat.dng,
  field: 'FNumber (33437)',
  location: 'EXIF IFD',
);

void main() {
  test('exposure rows use shutter fractions without changing metadata', () {
    const origin = MetadataOrigin(
      format: MetadataFormat.jpeg,
      field: 'ExposureTime (33434)',
      location: 'APP1 EXIF IFD',
    );
    for (final (seconds, raw, text) in [
      (0.04005, '4005/100000', '≈1/25 s'),
      (0.02, '1/50', '1/50 s'),
      (0.4, '2/5', '0.4 s'),
    ]) {
      final value = KnownValue(seconds, raw: raw, origin: origin);
      final row = MetadataText.rows(CaptureMetadata(exposureSeconds: value))
          .singleWhere((r) => r.label == 'Exposure');
      expect(row.value, text);
      expect(row.source, 'JPEG · APP1 EXIF IFD · ExposureTime (33434)');
      expect(value.value, seconds);
      expect(value.raw, raw);
    }
  });

  test('each value state reads differently, with its source', () {
    String valueOf(MetadataValue<double> v) =>
        MetadataText.rows(CaptureMetadata(fNumber: v))
            .firstWhere((r) => r.label == 'Aperture')
            .value;

    expect(valueOf(const KnownValue(5.6, raw: '56/10', origin: _o)), 'f/5.6');
    expect(valueOf(const AbsentValue()), 'Not in the file');
    expect(
      valueOf(const UnparseableValue(raw: '56/0', origin: _o)),
      'Unreadable value ("56/0")',
    );
    expect(
      valueOf(
        const AmbiguousValue([
          (raw: '56/10', origin: _o),
          (raw: '8/1', origin: _o),
        ]),
      ),
      'Unknown: conflicting values "56/10" and "8/1"',
    );
    expect(MetadataText.source(_o), 'DNG · EXIF IFD · FNumber (33437)');
  });

  test('every contract field has a row', () {
    // 12 since S3.1 added image dimensions (ADR-018 §3).
    expect(
      MetadataText.rows(const CaptureMetadata()),
      hasLength(const CaptureMetadata().values.length),
    );
    expect(const CaptureMetadata().values, hasLength(12));
  });

  test('image size reads as stored, in pixels', () {
    final row = MetadataText.rows(
      const CaptureMetadata(
        imageDimensions: KnownValue(
          ImageDimensions(3072, 4096),
          raw: '3072 x 4096',
          origin: _o,
        ),
      ),
    ).singleWhere((r) => r.label == 'Image size');
    expect(row.value, '3072 × 4096 px');
  });

  test('sensitivity names its standard, or says it is not stated', () {
    expect(
      MetadataText.sensitivity(
        const Sensitivity(SensitivityKind.isoUnspecified, 50),
      ),
      'ISO 50 (standard not stated)',
    );
    expect(
      MetadataText.sensitivity(
        const Sensitivity(SensitivityKind.isoSpeed, 1600),
      ),
      'ISO 1600 (ISO speed)',
    );
  });

  test('a capture time shows its zone only when recorded', () {
    const local = CaptureTime(
      year: 2000,
      month: 1,
      day: 2,
      hour: 21,
      minute: 30,
      second: 5,
    );
    expect(
      MetadataText.captureTime(local),
      '2000-01-02 21:30:05 (time zone not recorded)',
    );
    const west = CaptureTime(
      year: 2000,
      month: 1,
      day: 2,
      hour: 21,
      minute: 30,
      second: 5,
      utcOffset: Duration(hours: -5, minutes: -30),
    );
    expect(MetadataText.captureTime(west), '2000-01-02 21:30:05 (UTC−05:30)');
  });

  test('formats and failures have plain wording', () {
    expect(
      MetadataText.unsupported(MetadataFormat.tiff),
      "This file's format (TIFF (not a DNG)) is not supported yet.",
    );
    for (final r in MetadataUnreadableReason.values) {
      expect(MetadataText.unreadable(r), isNotEmpty);
    }
  });

  test('S2.7: every recognised format has a name; unrecognised is said so', () {
    for (final f in MetadataFormat.values) {
      expect(MetadataText.format(f), isNotEmpty);
    }
    expect(
      MetadataText.unsupported(MetadataFormat.cr3),
      "This file's format (Canon CR3) is not supported yet.",
    );
    expect(
      MetadataText.unsupported(MetadataFormat.unknown),
      "This file's format is not recognised.",
    );
  });
}
