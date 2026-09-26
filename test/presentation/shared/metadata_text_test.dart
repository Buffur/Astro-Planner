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
    expect(MetadataText.rows(const CaptureMetadata()), hasLength(11));
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
}
