// S2.3 (ADR-017 §2, §4.3, §8, §9): the DNG reader, on synthetic fixtures
// only. The owner's real files are checked by the local-only test in
// test/data/metadata/real_samples_test.dart.

import 'dart:math';
import 'dart:typed_data';

import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/capture_metadata_reader.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/metadata/metadata_source.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/memory_metadata_source.dart';
import '../../support/tiff_fixture.dart';

/// Reads [bytes] as a file of [length] bytes (the rest reads as zeros, like
/// pixel data), returning the reading and the read log.
Future<(MetadataReading, BudgetedMetadataSource)> _read(
  Uint8List bytes, {
  int? length,
  int budget = BudgetedMetadataSource.defaultBudgetBytes,
}) async {
  final source = BudgetedMetadataSource(
    MemoryMetadataSource(bytes, length: length),
    budgetBytes: budget,
  );
  return (await CaptureMetadataReader.read(source), source);
}

CaptureMetadata _metadata(MetadataReading r) {
  expect(r, isA<MetadataRead>());
  return (r as MetadataRead).metadata;
}

bool _touches(BudgetedMetadataSource s, ({int offset, int size}) range) =>
    s.reads.any(
      (r) =>
          r.offset < range.offset + range.size &&
          range.offset < r.offset + r.count,
    );

void main() {
  test('a phone-style DNG (IFD0 only) gives every contract value', () async {
    final tiff = (TiffFixture()..ifd0.addAll(phoneStyleDngIfd0())).build();
    final (reading, source) = await _read(tiff.bytes, length: 25 << 20);

    expect((reading as MetadataRead).format, MetadataFormat.dng);
    final m = _metadata(reading);
    expect(m.exposureSeconds.valueOrNull, 30.0);
    expect((m.exposureSeconds as KnownValue).raw, '3750000000/125000000');
    expect(
      (m.exposureSeconds as KnownValue).origin,
      const MetadataOrigin(
        format: MetadataFormat.dng,
        field: 'ExposureTime (33434)',
        location: 'IFD0',
      ),
    );
    expect(m.fNumber.valueOrNull, 2.0);
    expect(m.focalLengthMm.valueOrNull, 8.8);
    expect(m.focalLength35mmEquivalentMm.valueOrNull, 60.0);
    expect(
      m.sensitivity.valueOrNull,
      const Sensitivity(SensitivityKind.isoUnspecified, 50),
    );
    final time = m.captureTime.valueOrNull!;
    expect(time.toString(), '2000-01-02T21:30:05 (zone unknown)');
    expect(time.utc, isNull, reason: 'no zone is ever inferred');
    expect(m.cameraMake.valueOrNull, 'TestMake');
    expect(m.cameraModel.valueOrNull, 'TestMake TestPhone/TEST0001');
    expect(m.uniqueCameraModel.valueOrNull, 'TEST0001-TestMake');
    expect(m.lensMake, isA<AbsentValue<String>>());
    expect(m.lensModel, isA<AbsentValue<String>>());

    // Bounded: a few small reads, nothing outside the contract.
    expect(source.bytesRead, lessThanOrEqualTo(64 * 1024));
    expect(source.bytesRead, lessThan(1024));
    expect(_touches(source, tiff.valueRanges['IFD0/51009']!), isFalse);
    expect(_touches(source, tiff.valueRanges['IFD0/305']!), isFalse);
    expect(
      source.reads.every((r) => r.offset + r.count <= 0x10000),
      isTrue,
      reason: 'pixel data is never read',
    );
  });

  test('big-endian files read the same', () async {
    final tiff = (TiffFixture(
      bigEndian: true,
    )..ifd0.addAll(phoneStyleDngIfd0())).build();
    final m = _metadata((await _read(tiff.bytes)).$1);
    expect(m.exposureSeconds.valueOrNull, 30.0);
    expect(m.focalLengthMm.valueOrNull, 8.8);
    expect(m.cameraMake.valueOrNull, 'TestMake');
  });

  test(
    'an EXIF-IFD layout: values, offset and lens from the EXIF IFD',
    () async {
      final tiff =
          (TiffFixture()
                ..ifd0.addAll([
                  FixtureEntry.ascii(271, 'TestMake'),
                  FixtureEntry.ascii(272, 'TestCamera'),
                  FixtureEntry.bytes(50706, [1, 6, 0, 0]),
                ])
                ..exif = [
                  FixtureEntry.rational(33434, 1, 250),
                  FixtureEntry.rational(33437, 56, 10),
                  FixtureEntry.short(34855, 1600),
                  FixtureEntry.short(34864, 3), // ISO speed
                  FixtureEntry.ascii(36867, '2000:01:02 21:30:05'),
                  FixtureEntry.ascii(36881, '+02:00'),
                  FixtureEntry.rational(37386, 500, 1),
                  FixtureEntry.short(41989, 0), // unknown per EXIF
                  FixtureEntry.ascii(42035, 'TestLensMaker'),
                  FixtureEntry.ascii(42036, 'TestLens 500mm'),
                ])
              .build();
      final m = _metadata((await _read(tiff.bytes)).$1);
      expect(m.exposureSeconds.valueOrNull, 0.004);
      expect((m.exposureSeconds as KnownValue).origin.location, 'EXIF IFD');
      expect(m.fNumber.valueOrNull, 5.6);
      expect(
        m.sensitivity.valueOrNull,
        const Sensitivity(SensitivityKind.isoSpeed, 1600),
      );
      expect(
        m.captureTime.valueOrNull!.utc,
        DateTime.utc(2000, 1, 2, 19, 30, 5),
      );
      expect(m.focalLengthMm.valueOrNull, 500.0);
      expect(m.focalLength35mmEquivalentMm, isA<AbsentValue<double>>());
      expect(m.lensMake.valueOrNull, 'TestLensMaker');
      expect(m.lensModel.valueOrNull, 'TestLens 500mm');
      expect(m.uniqueCameraModel, isA<AbsentValue<String>>());
    },
  );

  test(
    'the same tag in IFD0 and the EXIF IFD: agreement or ambiguity',
    () async {
      Future<MetadataValue<double>> exposure(int exifNumerator) async {
        final tiff =
            (TiffFixture()
                  ..ifd0.addAll([
                    FixtureEntry.bytes(50706, [1, 4, 0, 0]),
                    FixtureEntry.rational(33434, 30, 1),
                  ])
                  ..exif = [FixtureEntry.rational(33434, exifNumerator, 1)])
                .build();
        return _metadata((await _read(tiff.bytes)).$1).exposureSeconds;
      }

      expect((await exposure(30)).valueOrNull, 30.0);
      final conflict = await exposure(15);
      expect(conflict, isA<AmbiguousValue<double>>());
      expect(conflict.valueOrNull, isNull);
      expect(
        (conflict as AmbiguousValue<double>).candidates.map((c) => c.raw),
        ['30/1', '15/1'],
      );
    },
  );

  test('GPS and serial numbers are never read (ADR-017 §3)', () async {
    final tiff =
        (TiffFixture()
              ..ifd0.addAll([
                ...phoneStyleDngIfd0(),
                FixtureEntry.ascii(315, 'Test Artist Name'), // Artist
              ])
              ..exif = [
                FixtureEntry.rational(33434, 30, 1),
                FixtureEntry.ascii(
                  42033,
                  'SERIAL-000000001',
                ), // BodySerialNumber
                FixtureEntry.ascii(
                  42037,
                  'LENS-SERIAL-0001',
                ), // LensSerialNumber
              ]
              ..gps = [
                FixtureEntry.bytes(0, [2, 3, 0, 0]), // GPSVersionID
                FixtureEntry.ascii(1, 'N'),
                FixtureEntry.bytes(
                  2,
                  List.filled(24, 7),
                  type: 5,
                ), // GPSLatitude
              ])
            .build();
    final (reading, source) = await _read(tiff.bytes);
    expect(reading, isA<MetadataRead>());
    final gpsIfd = tiff.ifdOffsets['GPS IFD']!;
    expect(
      source.reads.any(
        (r) => r.offset <= gpsIfd && gpsIfd < r.offset + r.count,
      ),
      isFalse,
      reason: 'the GPS IFD pointer is never followed',
    );
    for (final key in [
      'GPS IFD/2',
      'EXIF IFD/42033',
      'EXIF IFD/42037',
      'IFD0/315',
    ]) {
      expect(_touches(source, tiff.valueRanges[key]!), isFalse, reason: key);
    }
  });

  test('a TIFF without DNGVersion is not supported (ADR-017 §8)', () async {
    final entries = phoneStyleDngIfd0()..removeWhere((e) => e.tag == 50706);
    final tiff = (TiffFixture()..ifd0.addAll(entries)).build();
    final reading = (await _read(tiff.bytes)).$1;
    expect(reading, isA<MetadataUnsupported>());
    expect((reading as MetadataUnsupported).format, MetadataFormat.tiff);
  });

  test('other recognised formats are not supported', () async {
    for (final (header, format) in [
      ('SIMPLE  =                    T'.codeUnits, MetadataFormat.fits),
      ('XISF0100'.codeUnits, MetadataFormat.xisf),
      // JPEG has a reader since S2.8; HEIF is recognised, without one.
      ([0, 0, 0, 24, ...'ftypheic'.codeUnits, 0, 0, 0, 0], MetadataFormat.heif),
      (<int>[], MetadataFormat.unknown),
      ('not an image'.codeUnits, MetadataFormat.unknown),
    ]) {
      final reading = (await _read(Uint8List.fromList(header))).$1;
      expect(reading, isA<MetadataUnsupported>());
      expect((reading as MetadataUnsupported).format, format);
    }
  });

  group('broken structures are typed, never a crash', () {
    MetadataUnreadableReason? reason(MetadataReading r) =>
        r is MetadataUnreadable ? r.reason : null;

    test('truncated inside IFD0, or IFD0 past the end', () async {
      final bytes = (TiffFixture()..ifd0.addAll(phoneStyleDngIfd0()))
          .build()
          .bytes;
      expect(
        reason((await _read(Uint8List.sublistView(bytes, 0, 100))).$1),
        MetadataUnreadableReason.truncated,
      );
      final pastEnd = Uint8List.fromList(bytes)
        ..buffer.asByteData().setUint32(4, bytes.length + 10, Endian.little);
      expect(
        reason((await _read(pastEnd)).$1),
        MetadataUnreadableReason.truncated,
      );
    });

    test('too many entries, a repeated tag, an EXIF loop', () async {
      final many = (TiffFixture()..ifd0.addAll(phoneStyleDngIfd0()))
          .build()
          .bytes;
      many.buffer.asByteData().setUint16(8, 5000, Endian.little);
      expect(reason((await _read(many)).$1), MetadataUnreadableReason.corrupt);

      final repeated =
          (TiffFixture()
                ..ifd0.addAll([
                  ...phoneStyleDngIfd0(),
                  FixtureEntry.rational(33434, 1, 1),
                ]))
              .build();
      expect(
        reason((await _read(repeated.bytes)).$1),
        MetadataUnreadableReason.corrupt,
      );

      final loop =
          (TiffFixture()
                ..ifd0.addAll(phoneStyleDngIfd0())
                ..exif = [FixtureEntry.rational(33434, 1, 1)]
                ..exifPointerOverride = 8)
              .build();
      expect(
        reason((await _read(loop.bytes)).$1),
        MetadataUnreadableReason.corrupt,
      );

      final outside =
          (TiffFixture()
                ..ifd0.addAll(phoneStyleDngIfd0())
                ..exif = [FixtureEntry.rational(33434, 1, 1)]
                ..exifPointerOverride = 1 << 30)
              .build();
      expect(
        reason((await _read(outside.bytes)).$1),
        MetadataUnreadableReason.truncated,
      );
    });

    test('the byte budget stops a reader early', () async {
      final bytes = (TiffFixture()..ifd0.addAll(phoneStyleDngIfd0()))
          .build()
          .bytes;
      final (reading, source) = await _read(bytes, budget: 100);
      expect(reason(reading), MetadataUnreadableReason.overBudget);
      expect(source.bytesRead, lessThanOrEqualTo(100));
    });
  });

  group('one bad value leaves the rest of the file readable', () {
    test('a value past the end, a wrong type, a wrong count', () async {
      final entries = phoneStyleDngIfd0();
      entries.firstWhere((e) => e.tag == 272).offsetOverride = 1 << 30;
      entries.removeWhere((e) => e.tag == 33434);
      entries.add(FixtureEntry.short(33434, 30)); // exposure as SHORT
      entries.firstWhere((e) => e.tag == 33437).countOverride = 2;
      final tiff = (TiffFixture()..ifd0.addAll(entries)).build();
      final m = _metadata((await _read(tiff.bytes)).$1);
      expect(m.cameraModel, isA<UnparseableValue<String>>());
      expect(m.exposureSeconds, isA<UnparseableValue<double>>());
      expect(m.fNumber, isA<UnparseableValue<double>>());
      expect(m.cameraMake.valueOrNull, 'TestMake');
      expect(m.focalLengthMm.valueOrNull, 8.8);
    });

    test('a zero denominator is unparseable, not zero', () async {
      final entries = phoneStyleDngIfd0()..removeWhere((e) => e.tag == 37386);
      entries.add(FixtureEntry.rational(37386, 880, 0));
      final m = _metadata(
        (await _read((TiffFixture()..ifd0.addAll(entries)).build().bytes)).$1,
      );
      expect(m.focalLengthMm, isA<UnparseableValue<double>>());
      expect((m.focalLengthMm as UnparseableValue).raw, '880/0');
    });
  });

  test('robustness: every truncation and 500 random corruptions give a '
      'reading, never an exception', () async {
    final bytes =
        (TiffFixture()
              ..ifd0.addAll(phoneStyleDngIfd0())
              ..exif = [
                FixtureEntry.rational(33434, 30, 1),
                FixtureEntry.ascii(36881, '+01:00'),
              ])
            .build()
            .bytes;
    for (var cut = 0; cut <= 1200; cut++) {
      final (reading, source) = await _read(
        Uint8List.sublistView(bytes, 0, cut),
      );
      expect(reading, isA<MetadataReading>());
      expect(source.bytesRead, lessThanOrEqualTo(64 * 1024));
    }
    final random = Random(20260926);
    for (var i = 0; i < 500; i++) {
      final mutated = Uint8List.fromList(bytes);
      for (var k = 0; k < 1 + random.nextInt(8); k++) {
        mutated[random.nextInt(1200)] = random.nextInt(256);
      }
      final (reading, source) = await _read(mutated);
      expect(reading, isA<MetadataReading>());
      expect(source.bytesRead, lessThanOrEqualTo(64 * 1024));
    }
  });
}
