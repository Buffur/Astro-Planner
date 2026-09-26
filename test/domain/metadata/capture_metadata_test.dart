// S2.2 (ADR-017 §2, §5; CALC-39): the metadata contract as typed values.
// Unknown stays unknown, units are explicit, and every value keeps its raw
// text and its origin.

import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/exif_values.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/metadata/metadata_source.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';
import 'package:flutter_test/flutter_test.dart';

const _ifd0 = MetadataOrigin(
  format: MetadataFormat.tiff,
  field: 'ExposureTime (33434)',
  location: 'IFD0',
);
const _exif = MetadataOrigin(
  format: MetadataFormat.tiff,
  field: 'ExposureTime (33434)',
  location: 'EXIF IFD',
);

void main() {
  group('positive rationals (exposure s, f-number, focal length mm)', () {
    test('exact conversion, raw kept', () {
      // The owner's phone writes 30 s this way.
      expect(
        ExifValues.positive(const ExifRational(3750000000, 125000000), _ifd0),
        const KnownValue(30.0, raw: '3750000000/125000000', origin: _ifd0),
      );
      expect(
        ExifValues.positive(const ExifRational(1, 250), _ifd0).valueOrNull,
        0.004,
      );
      expect(
        ExifValues.positive(const ExifRational(657, 100), _ifd0).valueOrNull,
        6.57,
      );
    });

    test('missing is absent; zero, negative or /0 is unparseable', () {
      expect(ExifValues.positive(null, _ifd0), const AbsentValue<double>());
      for (final r in const [
        ExifRational(1, 0),
        ExifRational(0, 0),
        ExifRational(0, 1),
        ExifRational(-1, 1),
      ]) {
        expect(
          ExifValues.positive(r, _ifd0),
          UnparseableValue<double>(raw: '$r', origin: _ifd0),
        );
      }
    });
  });

  test('35 mm equivalent: 0 means unknown (EXIF 2.3)', () {
    expect(
      ExifValues.focalLength35mm(null, _ifd0),
      const AbsentValue<double>(),
    );
    expect(ExifValues.focalLength35mm(0, _ifd0), const AbsentValue<double>());
    expect(ExifValues.focalLength35mm(60, _ifd0).valueOrNull, 60.0);
  });

  group('sensitivity keeps its kind', () {
    test('no SensitivityType: an ISO value of unspecified kind', () {
      expect(
        ExifValues.sensitivity(50, null, _ifd0).valueOrNull,
        const Sensitivity(SensitivityKind.isoUnspecified, 50),
      );
    });

    test('types 1–3 name the standard; 0 and combinations do not', () {
      final kinds = {
        for (final type in [0, 1, 2, 3, 4, 5, 6, 7])
          type: ExifValues.sensitivity(800, type, _ifd0).valueOrNull?.kind,
      };
      expect(kinds, {
        0: SensitivityKind.isoUnspecified,
        1: SensitivityKind.standardOutputSensitivity,
        2: SensitivityKind.recommendedExposureIndex,
        3: SensitivityKind.isoSpeed,
        4: SensitivityKind.isoUnspecified,
        5: SensitivityKind.isoUnspecified,
        6: SensitivityKind.isoUnspecified,
        7: SensitivityKind.isoUnspecified,
      });
    });

    test('0 and 65535 ("65535 or more") are unparseable, never a value', () {
      expect(
        ExifValues.sensitivity(null, 3, _ifd0),
        const AbsentValue<Sensitivity>(),
      );
      expect(
        ExifValues.sensitivity(0, null, _ifd0),
        isA<UnparseableValue<Sensitivity>>(),
      );
      expect(
        ExifValues.sensitivity(65535, 3, _ifd0),
        const UnparseableValue<Sensitivity>(
          raw: '65535 (type 3)',
          origin: _ifd0,
        ),
      );
    });
  });

  group('capture time', () {
    test('without an offset the zone is unknown and there is no instant', () {
      final t = ExifValues.captureTime(
        '2000:01:02 21:30:05\u0000',
        null,
        _ifd0,
      );
      expect(t, isA<KnownValue<CaptureTime>>());
      final time = t.valueOrNull!;
      expect(time.isZoneKnown, isFalse);
      expect(time.utc, isNull);
      expect(time.toString(), '2000-01-02T21:30:05 (zone unknown)');
    });

    test('a recorded offset gives the UTC instant', () {
      final time = ExifValues.captureTime(
        '2000:01:02 21:30:05',
        '+03:00',
        _ifd0,
      ).valueOrNull!;
      expect(time.utc, DateTime.utc(2000, 1, 2, 18, 30, 5));
      expect(time.toString(), '2000-01-02T21:30:05+03:00');
      final west = ExifValues.captureTime(
        '2026:01:01 00:30:00',
        '-05:30',
        _ifd0,
      ).valueOrNull!;
      expect(west.utc, DateTime.utc(2026, 1, 1, 6));
    });

    test('an unparseable offset leaves the zone unknown, raw kept', () {
      final t = ExifValues.captureTime('2000:01:02 21:30:05', '+25:00', _ifd0);
      expect(t.valueOrNull!.isZoneKnown, isFalse);
      expect((t as KnownValue<CaptureTime>).raw, '2000:01:02 21:30:05 +25:00');
    });

    test('a time marked unknown is absent; a bad date is unparseable', () {
      for (final unknown in [
        null,
        '',
        '    :  :     :  :  ',
        '0000:00:00 00:00:00',
      ]) {
        expect(
          ExifValues.captureTime(unknown, null, _ifd0),
          const AbsentValue<CaptureTime>(),
          reason: '"$unknown"',
        );
      }
      for (final bad in [
        '2000-01-02 21:30:05',
        '2026:13:01 00:00:00',
        '2026:02:29 00:00:00', // not a leap year
        '2000:01:02 24:00:00',
        '2000:01:02 21:60:00',
      ]) {
        expect(
          ExifValues.captureTime(bad, null, _ifd0),
          isA<UnparseableValue<CaptureTime>>(),
          reason: bad,
        );
      }
      expect(
        ExifValues.captureTime('2024:02:29 00:00:00', null, _ifd0),
        isA<KnownValue<CaptureTime>>(),
      );
    });
  });

  test(
    'text: NUL-terminated and padded values are cleaned; empty is absent',
    () {
      expect(
        ExifValues.text('TestMake\u0000', _ifd0),
        const KnownValue('TestMake', raw: 'TestMake', origin: _ifd0),
      );
      expect(ExifValues.text(' \u0000', _ifd0), const AbsentValue<String>());
      expect(ExifValues.text(null, _ifd0), const AbsentValue<String>());
    },
  );

  group('combining a field found in two places', () {
    const a = KnownValue(30.0, raw: '30/1', origin: _ifd0);
    const b = KnownValue(30.0, raw: '300/10', origin: _exif);
    const c = KnownValue(15.0, raw: '15/1', origin: _exif);
    const bad = UnparseableValue<double>(raw: '1/0', origin: _exif);

    test('absent places are ignored; agreeing values stay known', () {
      expect(MetadataValue.combine<double>([]), const AbsentValue<double>());
      expect(MetadataValue.combine<double>([const AbsentValue(), a]), a);
      expect(MetadataValue.combine<double>([a, b]), a);
    });

    test('a conflict is ambiguous, with every raw value and origin', () {
      final result = MetadataValue.combine<double>([a, c]);
      expect(result, isA<AmbiguousValue<double>>());
      expect(result.valueOrNull, isNull);
      expect((result as AmbiguousValue<double>).candidates, [
        (raw: '30/1', origin: _ifd0),
        (raw: '15/1', origin: _exif),
      ]);
      expect(
        MetadataValue.combine<double>([a, bad]),
        isA<AmbiguousValue<double>>(),
      );
      expect(
        (MetadataValue.combine<double>([
          result,
          a,
        ]) as AmbiguousValue<double>).candidates,
        hasLength(3),
      );
    });
  });

  test('an empty contract is all absent: nothing is defaulted', () {
    const m = CaptureMetadata();
    for (final v in <MetadataValue<Object>>[
      m.exposureSeconds,
      m.sensitivity,
      m.focalLengthMm,
      m.focalLength35mmEquivalentMm,
      m.fNumber,
      m.captureTime,
      m.cameraMake,
      m.cameraModel,
      m.uniqueCameraModel,
      m.lensMake,
      m.lensModel,
    ]) {
      expect(v, isA<AbsentValue<Object>>());
      expect(v.valueOrNull, isNull);
    }
  });

  test('read failures map to typed unreadable reasons', () {
    final reasons = {
      for (final e in MetadataReadError.values)
        e: MetadataUnreadable.fromReadFailure(MetadataReadException(e)).reason,
    };
    expect(reasons, {
      MetadataReadError.outOfRange: MetadataUnreadableReason.truncated,
      MetadataReadError.readTooLarge: MetadataUnreadableReason.corrupt,
      MetadataReadError.overBudget: MetadataUnreadableReason.overBudget,
      MetadataReadError.io: MetadataUnreadableReason.io,
    });
  });
}
