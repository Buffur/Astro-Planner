// S2.8 (ADR-017 §13): the JPEG reader, on synthetic files only. The owner's
// phone JPEG is checked by the local real-sample test.

import 'dart:math';
import 'dart:typed_data';

import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/capture_metadata_reader.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/metadata/metadata_source.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/jpeg_fixture.dart';
import '../../support/memory_metadata_source.dart';

Future<(MetadataReading, BudgetedMetadataSource)> _read(
  Uint8List bytes, {
  int? length,
}) async {
  final source = BudgetedMetadataSource(
    MemoryMetadataSource(bytes, length: length),
  );
  return (await CaptureMetadataReader.read(source), source);
}

MetadataUnreadableReason? _reason(MetadataReading r) =>
    r is MetadataUnreadable ? r.reason : null;

void main() {
  final app0 = jpegSegment(0xE0, [
    ...'JFIF'.codeUnits,
    0,
    1,
    1,
    0,
    0,
    1,
    0,
    1,
    0,
    0,
  ]);
  final xmp = jpegSegment(0xE1, [
    ...'http://ns.adobe.com/xap/1.0/'.codeUnits,
    0,
    ...List.filled(40, 0x20),
  ]);
  final icc = jpegSegment(0xE2, [
    ...'ICC_PROFILE'.codeUnits,
    0,
    ...List.filled(60, 1),
  ]);

  test(
    'a phone-style JPEG: values from APP1, with the recorded offset',
    () async {
      final tiff = phoneStyleJpegExif().build();
      final jpeg = jpegFile([exifApp1(tiff.bytes), xmp, icc]);
      final (reading, source) = await _read(jpeg, length: 4 << 20);

      expect(reading.format, MetadataFormat.jpeg);
      final m = (reading as MetadataRead).metadata;
      expect(m.exposureSeconds.valueOrNull, closeTo(0.009987236, 1e-12));
      expect(m.fNumber.valueOrNull, 1.6);
      expect(m.focalLengthMm.valueOrNull, 6.57);
      expect(m.focalLength35mmEquivalentMm.valueOrNull, 23.0);
      expect(
        m.sensitivity.valueOrNull,
        const Sensitivity(SensitivityKind.isoSpeed, 100),
      );
      final time = m.captureTime.valueOrNull!;
      expect(time.isZoneKnown, isTrue);
      expect(time.utc, DateTime.utc(2000, 1, 2, 18, 30, 5));
      expect(m.cameraModel.valueOrNull, 'TestMake TestPhone');
      expect(m.uniqueCameraModel, isA<AbsentValue<String>>());
      expect(m.lensModel, isA<AbsentValue<String>>());
      expect(
        (m.exposureSeconds as KnownValue).origin,
        const MetadataOrigin(
          format: MetadataFormat.jpeg,
          field: 'ExposureTime (33434)',
          location: 'APP1 EXIF IFD',
        ),
      );

      // Bounded, and nothing past the Exif segment: no XMP, ICC or scan data.
      expect(source.bytesRead, lessThan(1024));
      final exifEnd = 2 + 4 + 6 + tiff.bytes.length;
      expect(source.reads.every((r) => r.offset + r.count <= exifEnd), isTrue);
      // The GPS IFD inside the Exif segment is never followed.
      final gps = 2 + 10 + tiff.ifdOffsets['GPS IFD']!;
      expect(
        source.reads.any((r) => r.offset <= gps && gps < r.offset + r.count),
        isFalse,
      );
    },
  );

  test(
    'the Exif segment is found after other segments, with fill bytes',
    () async {
      final tiff = phoneStyleJpegExif().build();
      final jpeg = jpegFile([
        app0,
        xmp,
        [0xFF, 0xFF],
        icc,
        exifApp1(tiff.bytes),
      ]);
      final m = ((await _read(jpeg)).$1 as MetadataRead).metadata;
      expect(m.exposureSeconds.valueOrNull, closeTo(0.009987236, 1e-12));
    },
  );

  test('a JPEG without Exif is "extracted, nothing found"; the scan is not '
      'read', () async {
    final jpeg = jpegFile([app0, xmp, icc]);
    final (reading, source) = await _read(jpeg, length: 4 << 20);
    expect(reading, isA<MetadataRead>());
    expect((reading as MetadataRead).nothingFound, isTrue);
    expect(reading.format, MetadataFormat.jpeg);
    final sos = 2 + app0.length + xmp.length + icc.length;
    expect(source.reads.every((r) => r.offset + r.count <= sos + 2), isTrue);
  });

  group('broken JPEGs are typed, never a crash', () {
    test('truncated inside a segment, or a segment past the end', () async {
      final tiff = phoneStyleJpegExif().build();
      final jpeg = jpegFile([exifApp1(tiff.bytes)]);
      expect(
        _reason((await _read(Uint8List.sublistView(jpeg, 0, 3))).$1),
        MetadataUnreadableReason.truncated,
      );
      expect(
        _reason((await _read(Uint8List.sublistView(jpeg, 0, 300))).$1),
        MetadataUnreadableReason.truncated,
      );
    });

    test('a bad marker, a zero length, a second SOI', () async {
      for (final bad in [
        // APP0 (length 4) is followed by 0x00 where a marker must be.
        [0xFF, 0xD8, 0xFF, 0xE0, 0, 4, 0, 0, 0x00, 0xE1, 0, 8],
        [0xFF, 0xD8, 0xFF, 0xE0, 0, 0, 0xFF, 0xDA],
        [0xFF, 0xD8, 0xFF, 0xD8, 0xFF, 0xD9],
      ]) {
        expect(
          _reason((await _read(Uint8List.fromList(bad))).$1),
          MetadataUnreadableReason.corrupt,
          reason: '$bad',
        );
      }
    });

    test('too many segments before SOS', () async {
      final many = [
        for (var i = 0; i < 200; i++) jpegSegment(0xE5, [0]),
      ];
      expect(
        _reason((await _read(jpegFile(many))).$1),
        MetadataUnreadableReason.corrupt,
      );
    });

    test(
      'a corrupt EXIF structure inside APP1 says what was recognised',
      () async {
        final jpeg = jpegFile([
          jpegSegment(0xE1, [
            ...'Exif'.codeUnits,
            0,
            0,
            0x4A,
            0x4A,
            0,
            0,
            0,
            0,
            0,
            0,
          ]),
        ]);
        final reading = (await _read(jpeg)).$1;
        expect(_reason(reading), MetadataUnreadableReason.corrupt);
        expect(reading.format, MetadataFormat.jpeg);
      },
    );
  });

  test('robustness: every truncation and 500 random corruptions give a '
      'reading within the budget', () async {
    final jpeg = jpegFile([app0, exifApp1(phoneStyleJpegExif().build().bytes)]);
    for (var cut = 0; cut <= jpeg.length; cut += 3) {
      final (reading, source) = await _read(
        Uint8List.sublistView(jpeg, 0, cut),
      );
      expect(reading, isA<MetadataReading>());
      expect(source.bytesRead, lessThanOrEqualTo(64 * 1024));
    }
    final random = Random(20260926);
    for (var i = 0; i < 500; i++) {
      final mutated = Uint8List.fromList(jpeg);
      for (var k = 0; k < 1 + random.nextInt(8); k++) {
        mutated[random.nextInt(mutated.length)] = random.nextInt(256);
      }
      final (reading, source) = await _read(mutated);
      expect(reading, isA<MetadataReading>());
      expect(source.bytesRead, lessThanOrEqualTo(64 * 1024));
    }
  });
}
