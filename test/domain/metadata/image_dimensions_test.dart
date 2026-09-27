// S3.1 (ADR-018 §3, amending ADR-017 §2): image dimensions in the metadata
// contract, on synthetic fixtures only. The owner's real files are checked
// by the local-only test in test/data/metadata/real_samples_test.dart.

import 'dart:typed_data';

import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/capture_metadata_reader.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/metadata/metadata_source.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/heif_fixture.dart';
import '../../support/jpeg_fixture.dart';
import '../../support/memory_metadata_source.dart';
import '../../support/tiff_fixture.dart';

Future<(MetadataValue<ImageDimensions>, BudgetedMetadataSource)> _read(
  Uint8List bytes,
) async {
  final source = BudgetedMetadataSource(MemoryMetadataSource(bytes));
  final reading = await CaptureMetadataReader.read(source);
  expect(reading, isA<MetadataRead>());
  return ((reading as MetadataRead).metadata.imageDimensions, source);
}

/// A phone-style DNG's IFD0 with its dimension tags replaced by [dims].
Uint8List _dng(List<FixtureEntry> dims, {List<FixtureEntry>? exif}) {
  const dimensionTags = {254, 256, 257, 50720};
  final fixture = TiffFixture()
    ..ifd0.addAll([
      for (final e in phoneStyleDngIfd0())
        if (!dimensionTags.contains(e.tag)) e,
      ...dims,
    ])
    ..exif = exif;
  return fixture.build().bytes;
}

/// A phone-style JPEG whose EXIF carries [ifd0] and [exif] dimension tags.
TiffFixture _jpegExif({
  List<FixtureEntry> ifd0 = const [],
  List<FixtureEntry> exif = const [],
}) {
  final fixture = phoneStyleJpegExif();
  fixture.ifd0.addAll(ifd0);
  fixture.exif!.addAll(exif);
  return fixture;
}

FixtureEntry _pair(int tag, int type, List<int> values) {
  final bytes = ByteData(values.length * (type == 3 ? 2 : 4));
  for (var i = 0; i < values.length; i++) {
    if (type == 3) {
      bytes.setUint16(2 * i, values[i], Endian.little);
    } else {
      bytes.setUint32(4 * i, values[i], Endian.little);
    }
  }
  return FixtureEntry.bytes(tag, bytes.buffer.asUint8List(), type: type)
    ..countOverride = type == 5 ? values.length ~/ 2 : values.length;
}

void main() {
  group('DNG: IFD0 of the main image only', () {
    test('ImageWidth/ImageLength of the phone-style DNG', () async {
      final (value, _) = await _read(
        (TiffFixture()..ifd0.addAll(phoneStyleDngIfd0())).build().bytes,
      );
      expect(value.valueOrNull, const ImageDimensions(4000, 3000));
      final known = value as KnownValue<ImageDimensions>;
      expect(known.raw, '4000 x 3000');
      expect(
        known.origin,
        const MetadataOrigin(
          format: MetadataFormat.dng,
          field: 'ImageWidth/ImageLength (256/257)',
          location: 'IFD0',
        ),
      );
    });

    test(
      'DefaultCropSize is preferred, as SHORT, LONG or whole RATIONAL',
      () async {
        for (final crop in [
          _pair(50720, 3, [3968, 2976]),
          _pair(50720, 4, [3968, 2976]),
          _pair(50720, 5, [7936, 2, 2976, 1]),
        ]) {
          final (value, _) = await _read(
            _dng([
              FixtureEntry.long(254, 0),
              FixtureEntry.long(256, 4000),
              FixtureEntry.long(257, 3000),
              crop,
            ]),
          );
          expect(value.valueOrNull, const ImageDimensions(3968, 2976));
          expect((value as KnownValue).origin.field, 'DefaultCropSize (50720)');
        }
      },
    );

    test('a fractional crop falls back to ImageWidth/ImageLength', () async {
      final (value, _) = await _read(
        _dng([
          FixtureEntry.long(256, 4000),
          FixtureEntry.long(257, 3000),
          _pair(50720, 5, [7937, 2, 2976, 1]),
        ]),
      );
      expect(value.valueOrNull, const ImageDimensions(4000, 3000));
    });

    test('a malformed crop is unparseable, never guessed', () async {
      for (final crop in [
        _pair(50720, 5, [3968, 0, 2976, 1]), // zero denominator
        _pair(50720, 4, [3968]), // one value
        _pair(50720, 3, [0, 2976]), // a zero side
      ]) {
        final (value, _) = await _read(
          _dng([
            FixtureEntry.long(256, 4000),
            FixtureEntry.long(257, 3000),
            crop,
          ]),
        );
        expect(value, isA<UnparseableValue<ImageDimensions>>());
      }
    });

    test('an IFD0 that is not the main image gives no dimensions', () async {
      final (preview, _) = await _read(
        _dng([
          FixtureEntry.long(254, 1), // a reduced-resolution preview
          FixtureEntry.long(256, 256),
          FixtureEntry.long(257, 192),
        ]),
      );
      expect(preview, isA<AbsentValue<ImageDimensions>>());

      final (malformed, _) = await _read(
        _dng([
          FixtureEntry.ascii(254, 'x'),
          FixtureEntry.long(256, 4000),
          FixtureEntry.long(257, 3000),
        ]),
      );
      expect(malformed, isA<UnparseableValue<ImageDimensions>>());
    });

    test('one side missing, a zero side or text is unparseable; none is '
        'absent', () async {
      final cases = {
        'missing height': [FixtureEntry.long(256, 4000)],
        'zero width': [FixtureEntry.long(256, 0), FixtureEntry.long(257, 3000)],
        'text': [FixtureEntry.ascii(256, '4000'), FixtureEntry.long(257, 3000)],
      };
      for (final MapEntry(:key, :value) in cases.entries) {
        final (dims, _) = await _read(_dng(value));
        expect(dims, isA<UnparseableValue<ImageDimensions>>(), reason: key);
      }
      final (none, _) = await _read(_dng(const []));
      expect(none, isA<AbsentValue<ImageDimensions>>());
    });

    test('the EXIF IFD is not used for a DNG', () async {
      final (value, _) = await _read(
        _dng(
          const [],
          exif: [
            FixtureEntry.long(40962, 4000),
            FixtureEntry.long(40963, 3000),
          ],
        ),
      );
      expect(value, isA<AbsentValue<ImageDimensions>>());
    });
  });

  group('JPEG and HEIC: PixelX/YDimension and IFD0, combined', () {
    test('a portrait phone JPEG: both places agree, width and height as '
        'stored; the GPS IFD is still never read', () async {
      final fixture = _jpegExif(
        ifd0: [FixtureEntry.long(256, 3000), FixtureEntry.long(257, 4000)],
        exif: [FixtureEntry.long(40962, 3000), FixtureEntry.long(40963, 4000)],
      );
      final tiff = fixture.build();
      final jpeg = jpegFile([exifApp1(tiff.bytes)]);
      final (value, source) = await _read(jpeg);

      final dims = value.valueOrNull!;
      expect(dims, const ImageDimensions(3000, 4000));
      expect(dims.longSidePx, 4000);
      expect(dims.shortSidePx, 3000);
      expect((value as KnownValue).origin.format, MetadataFormat.jpeg);
      // The GPS IFD sits right after the EXIF IFD in the fixture; the APP1
      // payload starts 12 bytes into the file (SOI, marker, length, "Exif").
      final gpsAt = 12 + tiff.ifdOffsets['GPS IFD']!;
      expect(
        source.reads.any(
          (r) => r.offset <= gpsAt && gpsAt < r.offset + r.count,
        ),
        isFalse,
        reason: 'the GPS IFD is never followed',
      );
    });

    test('only the EXIF IFD, as SHORT values', () async {
      final fixture = _jpegExif(
        exif: [
          FixtureEntry.short(40962, 4000),
          FixtureEntry.short(40963, 3000),
        ],
      );
      final (value, _) = await _read(
        jpegFile([exifApp1(fixture.build().bytes)]),
      );
      expect(value.valueOrNull, const ImageDimensions(4000, 3000));
      expect(
        (value as KnownValue).origin,
        const MetadataOrigin(
          format: MetadataFormat.jpeg,
          field: 'PixelXDimension/PixelYDimension (40962/40963)',
          location: 'APP1 EXIF IFD',
        ),
      );
    });

    test('disagreeing places are ambiguous, and stay unknown', () async {
      final fixture = _jpegExif(
        ifd0: [FixtureEntry.long(256, 4000), FixtureEntry.long(257, 3000)],
        exif: [FixtureEntry.long(40962, 2000), FixtureEntry.long(40963, 1500)],
      );
      final (value, _) = await _read(
        jpegFile([exifApp1(fixture.build().bytes)]),
      );
      expect(value, isA<AmbiguousValue<ImageDimensions>>());
      expect(value.valueOrNull, isNull);
    });

    test('tags in the wrong IFD are ignored', () async {
      final fixture = _jpegExif(
        ifd0: [FixtureEntry.long(40962, 4000), FixtureEntry.long(40963, 3000)],
        exif: [FixtureEntry.long(256, 4000), FixtureEntry.long(257, 3000)],
      );
      final (value, _) = await _read(
        jpegFile([exifApp1(fixture.build().bytes)]),
      );
      expect(value, isA<AbsentValue<ImageDimensions>>());
    });

    test('a HEIC reads them from its Exif item', () async {
      final fixture = _jpegExif(
        exif: [FixtureEntry.long(40962, 3000), FixtureEntry.long(40963, 4000)],
      );
      final heif = (HeifFixture()..addExif(2, fixture.build().bytes)).build();
      final (value, _) = await _read(heif);
      expect(value.valueOrNull, const ImageDimensions(3000, 4000));
      expect((value as KnownValue).origin.format, MetadataFormat.heif);
    });
  });

  test('ImageDimensions: long and short sides for either orientation', () {
    const landscape = ImageDimensions(4080, 3072);
    const portrait = ImageDimensions(3072, 4080);
    for (final d in [landscape, portrait]) {
      expect(d.longSidePx, 4080);
      expect(d.shortSidePx, 3072);
    }
    expect(landscape == portrait, isFalse, reason: 'stored order is kept');
  });

  // S3.V4 (S3V-05): S3.1's acceptance asks for zero or absurd dimensions to
  // be unparseable. The bound is 65,535 px per side (ExifValues), JPEG's own
  // format limit and far beyond any camera sensor; it is not the equipment
  // limit (EquipmentLimits.resolutionPx), which the candidate applies later.
  group('absurd dimensions are unparseable in every container', () {
    test(
      'JPEG EXIF 4,294,967,295 x 4,294,967,295 (the validation\'s P7)',
      () async {
        final fixture = _jpegExif(
          exif: [
            FixtureEntry.long(40962, 4294967295),
            FixtureEntry.long(40963, 4294967295),
          ],
        );
        final (value, _) = await _read(
          jpegFile([exifApp1(fixture.build().bytes)]),
        );
        expect(value, isA<UnparseableValue<ImageDimensions>>());
        expect(value.valueOrNull, isNull);
      },
    );

    test('a DNG ImageWidth and a DefaultCropSize beyond the bound', () async {
      final (width, _) = await _read(
        _dng([FixtureEntry.long(256, 70000), FixtureEntry.long(257, 3000)]),
      );
      expect(width, isA<UnparseableValue<ImageDimensions>>());
      final (crop, _) = await _read(
        _dng([
          FixtureEntry.long(256, 4000),
          FixtureEntry.long(257, 3000),
          _pair(50720, 4, [4000, 100000]),
        ]),
      );
      expect(crop, isA<UnparseableValue<ImageDimensions>>());
    });

    test('a HEIC Exif item with one absurd side', () async {
      final fixture = _jpegExif(
        exif: [FixtureEntry.long(40962, 3000), FixtureEntry.long(40963, 70000)],
      );
      final (value, _) = await _read(
        (HeifFixture()..addExif(2, fixture.build().bytes)).build(),
      );
      expect(value, isA<UnparseableValue<ImageDimensions>>());
    });

    test('the bound itself: 65,535 is known, 65,536 is not', () async {
      Future<MetadataValue<ImageDimensions>> sides(int w) async {
        final fixture = _jpegExif(
          exif: [FixtureEntry.long(40962, w), FixtureEntry.long(40963, 1000)],
        );
        return (await _read(jpegFile([exifApp1(fixture.build().bytes)]))).$1;
      }

      expect(
        (await sides(65535)).valueOrNull,
        const ImageDimensions(65535, 1000),
      );
      expect(await sides(65536), isA<UnparseableValue<ImageDimensions>>());
    });
  });
}
