// S2.9 (ADR-017 §13; S2.R2 §7): the HEIF reader, on synthetic ISO-BMFF files
// only. The owner's phone HEIC is checked by the local real-sample test.

import 'dart:math';
import 'dart:typed_data';

import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/capture_metadata_reader.dart';
import 'package:astroplan/domain/metadata/heif_metadata_reader.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/metadata/metadata_source.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/heif_fixture.dart';
import '../../support/jpeg_fixture.dart';
import '../../support/memory_metadata_source.dart';
import '../../support/tiff_fixture.dart';

/// Xiaomi writes a JPEG APP1 header before the TIFF header (S2.R2 §3).
final _app1Prefix = [0xFF, 0xE1, 0x12, 0x34, ...'Exif'.codeUnits, 0, 0];

Uint8List _tiff() => phoneStyleJpegExif().build().bytes;

Future<(MetadataReading, BudgetedMetadataSource)> _read(Uint8List bytes) async {
  final source = BudgetedMetadataSource(MemoryMetadataSource(bytes));
  return (await CaptureMetadataReader.read(source), source);
}

MetadataUnreadableReason? _reason(MetadataReading r) =>
    r is MetadataUnreadable ? r.reason : null;

void main() {
  test('a phone-style HEIC: the Exif item at the end of mdat, past an APP1 '
      'prefix, linked to the primary item', () async {
    final heif = (HeifFixture()..addExif(2, _tiff(), prefix: _app1Prefix))
        .build();
    final (reading, source) = await _read(heif);

    expect(reading.format, MetadataFormat.heif);
    final m = (reading as MetadataRead).metadata;
    expect(m.exposureSeconds.valueOrNull, closeTo(0.009987236, 1e-12));
    expect(m.fNumber.valueOrNull, 1.6);
    expect(
      m.sensitivity.valueOrNull,
      const Sensitivity(SensitivityKind.isoSpeed, 100),
    );
    expect(m.captureTime.valueOrNull!.utc, DateTime.utc(2000, 1, 2, 18, 30, 5));
    expect(m.cameraModel.valueOrNull, 'TestMake TestPhone');
    expect(
      (m.exposureSeconds as KnownValue).origin.location,
      'Exif item EXIF IFD',
    );
    // Bounded, and no tile bytes read (the tiles are 3000 bytes of 0x5A).
    expect(source.bytesRead, lessThan(4096));
    // The tiles: the first 3000 bytes of mdat's payload (the Exif payload
    // follows them in this layout).
    final mdat = _indexOf(heif, 'mdat'.codeUnits) + 4;
    expect(heif.sublist(mdat, mdat + 3000), everyElement(0x5A));
    expect(
      source.reads.any(
        (r) => r.offset < mdat + 3000 && mdat < r.offset + r.count,
      ),
      isFalse,
      reason: 'image data is never read',
    );
  });

  test('variants: Exif before the tiles, in idat, 64-bit offsets, 32-bit ids,'
      ' iloc versions 0-2, no prefix', () async {
    final variants = <String, HeifFixture>{
      'before tiles': HeifFixture()..addExif(2, _tiff(), beforeTiles: true),
      'idat': HeifFixture()..addExif(2, _tiff(), inIdat: true),
      '8-byte offsets': HeifFixture(offsetSize: 8)..addExif(2, _tiff()),
      '32-bit ids': HeifFixture(largeIds: true, primary: 70000)
        ..addExif(70001, _tiff()),
      'iloc v0': HeifFixture(ilocVersion: 0)..addExif(2, _tiff()),
      'mif1 brand': HeifFixture(brand: 'mif1')..addExif(2, _tiff()),
    };
    for (final MapEntry(:key, :value) in variants.entries) {
      final reading = (await _read(value.build())).$1;
      expect(reading, isA<MetadataRead>(), reason: key);
      expect(
        (reading as MetadataRead).metadata.fNumber.valueOrNull,
        1.6,
        reason: key,
      );
    }
  });

  group('choosing the Exif item', () {
    Uint8List exifWith(int fNumberTimesTen) =>
        (TiffFixture()
              ..ifd0.add(FixtureEntry.ascii(271, 'TestMake'))
              ..exif = [FixtureEntry.rational(33437, fNumberTimesTen, 10)])
            .build()
            .bytes;

    test('the one cdsc links to the primary item wins', () async {
      final heif =
          (HeifFixture()
                ..addExif(2, exifWith(28), linked: false)
                ..addExif(3, exifWith(40)))
              .build();
      final m = ((await _read(heif)).$1 as MetadataRead).metadata;
      expect(m.fNumber.valueOrNull, 4.0);
    });

    test(
      'several unlinked items that disagree are ambiguous, never picked',
      () async {
        final heif =
            (HeifFixture()
                  ..addExif(2, exifWith(28), linked: false)
                  ..addExif(3, exifWith(40), linked: false))
                .build();
        final m = ((await _read(heif)).$1 as MetadataRead).metadata;
        expect(m.fNumber, isA<AmbiguousValue<double>>());
        expect(m.cameraMake.valueOrNull, 'TestMake', reason: 'they agree');
      },
    );

    test('no Exif item is "extracted, nothing found"', () async {
      final reading = (await _read(HeifFixture().build())).$1;
      expect((reading as MetadataRead).nothingFound, isTrue);
      expect(reading.format, MetadataFormat.heif);
    });
  });

  group('broken files are typed, never a crash, never "nothing found"', () {
    test('an Exif extent past the end is truncated', () async {
      final heif =
          (HeifFixture()
                ..addExif(2, _tiff())
                ..exifOffsetOverride = 1 << 30)
              .build();
      expect(
        _reason((await _read(heif)).$1),
        MetadataUnreadableReason.truncated,
      );
    });

    test('a TIFF offset past the extent, or a TIFF header cut short, is '
        'truncated', () async {
      final past =
          (HeifFixture()
                ..addExif(2, _tiff())
                ..tiffHeaderOffsetOverride = 1 << 20)
              .build();
      expect(
        _reason((await _read(past)).$1),
        MetadataUnreadableReason.truncated,
      );
      final short = (HeifFixture()..addExif(2, [0x49, 0x49, 0x2A, 0x00]))
          .build();
      expect(
        _reason((await _read(short)).$1),
        MetadataUnreadableReason.truncated,
      );
    });

    test('several extents, construction method 2, no meta box', () async {
      final extents =
          (HeifFixture()
                ..addExif(2, _tiff())
                ..extentCount = 2)
              .build();
      expect(
        _reason((await _read(extents)).$1),
        MetadataUnreadableReason.corrupt,
      );
      final method2 =
          (HeifFixture()
                ..addExif(2, _tiff())
                ..constructionMethodOverride = 2)
              .build();
      expect(
        _reason((await _read(method2)).$1),
        MetadataUnreadableReason.corrupt,
      );
      final noMeta = Uint8List.fromList([
        ...HeifFixture.box('ftyp', [...'heic'.codeUnits, 0, 0, 0, 0]),
        ...HeifFixture.box('mdat', List.filled(100, 1)),
      ]);
      expect(
        _reason((await _read(noMeta)).$1),
        MetadataUnreadableReason.corrupt,
      );
    });

    test('an oversized meta box is refused before it is read', () async {
      final big = Uint8List.fromList([
        ...HeifFixture.box('ftyp', [...'heic'.codeUnits, 0, 0, 0, 0]),
        ...HeifFixture.fullBox('meta', 0, List.filled(70 << 10, 0)),
      ]);
      final (reading, source) = await _read(big);
      expect(_reason(reading), MetadataUnreadableReason.overBudget);
      expect(source.bytesRead, lessThan(1024));
    });
  });

  group('S2.V4: work bounded by the input (TD-067)', () {
    // An iloc whose field sizes are all 0: every extent occupies no bytes.
    Uint8List zeroSizeExtents(int items, int extentsPerItem) {
      List<int> u16(int v) => [(v >> 8) & 0xFF, v & 0xFF];
      final body = <int>[0, 0, ...u16(items)];
      for (var i = 0; i < items; i++) {
        body.addAll([...u16(i + 1), 0, 0, 0, 0, ...u16(extentsPerItem)]);
      }
      return Uint8List.fromList([
        ...HeifFixture.box('ftyp', [...'heic'.codeUnits, 0, 0, 0, 0]),
        ...HeifFixture.fullBox('meta', 0, HeifFixture.fullBox('iloc', 1, body)),
      ]);
    }

    test(
      'extents that occupy no bytes cannot exhaust memory or time',
      () async {
        // Before S2.V4 this 8 KB meta took 9-17 s and about 1.7 GB.
        final watch = Stopwatch()..start();
        for (final (items, each) in [(1000, 65535), (1, 65535)]) {
          final (reading, source) = await _read(zeroSizeExtents(items, each));
          expect(_reason(reading), MetadataUnreadableReason.corrupt);
          expect(source.bytesRead, lessThan(16 << 10));
        }
        expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
      },
    );

    test('up to the limit the iloc still parses', () async {
      final atLimit = zeroSizeExtents(4, HeifMetadataReader.maxExtents ~/ 4);
      final reading = (await _read(atLimit)).$1;
      expect((reading as MetadataRead).nothingFound, isTrue);
      final over = zeroSizeExtents(4, HeifMetadataReader.maxExtents ~/ 4 + 1);
      expect(_reason((await _read(over)).$1), MetadataUnreadableReason.corrupt);
    });
  });

  group("the shared extractor's guarantees hold through HEIF (S2R-04)", () {
    test('the GPS IFD in the Exif item is never read', () async {
      final tiff = phoneStyleJpegExif().build();
      final heif = (HeifFixture()..addExif(2, tiff.bytes)).build();
      final (reading, source) = await _read(heif);
      expect(reading, isA<MetadataRead>());
      final gps = _indexOf(heif, tiff.bytes) + tiff.ifdOffsets['GPS IFD']!;
      expect(
        source.reads.any((r) => r.offset <= gps && gps < r.offset + r.count),
        isFalse,
      );
    });

    test('an integer array is never read as a value (S2V-01)', () async {
      final tiff =
          (TiffFixture()
                ..ifd0.add(
                  FixtureEntry.short(34855, 100)
                    ..countOverride = 3
                    ..offsetOverride = 60000,
                ))
              .build()
              .bytes;
      final reading = (await _read((HeifFixture()..addExif(2, tiff)).build()))
          .$1;
      final iso = (reading as MetadataRead).metadata.sensitivity;
      expect(iso, isA<UnparseableValue<Sensitivity>>());
    });

    test('an Exif item with an incomplete TIFF header is truncated '
        '(S2V-02)', () async {
      for (var size = 0; size < 8; size++) {
        final heif = (HeifFixture()..addExif(2, List.filled(size, 0x49)))
            .build();
        expect(
          _reason((await _read(heif)).$1),
          MetadataUnreadableReason.truncated,
          reason: '$size header bytes',
        );
      }
    });
  });

  test('S2.V4 (S2R-02): AVIF and HEIF sequences are recognised only, and '
      'nothing past the signature is read', () async {
    for (final (brand, format) in [
      ('avif', MetadataFormat.avif),
      ('avis', MetadataFormat.avif),
      ('msf1', MetadataFormat.heifSequence),
      ('hevs', MetadataFormat.heifSequence),
    ]) {
      final file = (HeifFixture(brand: brand)..addExif(2, _tiff())).build();
      final (reading, source) = await _read(file);
      expect(reading, isA<MetadataUnsupported>(), reason: brand);
      expect(reading.format, format, reason: brand);
      expect(source.bytesRead, 16, reason: brand);
    }
  });

  test('robustness: every truncation and 500 random corruptions give a '
      'typed reading within the budget', () async {
    final heif = (HeifFixture()..addExif(2, _tiff(), prefix: _app1Prefix))
        .build();
    for (var cut = 0; cut <= heif.length; cut += 7) {
      final (reading, source) = await _read(
        Uint8List.sublistView(heif, 0, cut),
      );
      expect(reading, isA<MetadataReading>());
      expect(source.bytesRead, lessThanOrEqualTo(1 << 20));
      if (cut < heif.length) {
        expect(
          reading is MetadataRead && !reading.nothingFound,
          isFalse,
          reason: 'a cut file never reads as complete ($cut bytes)',
        );
      }
    }
    final random = Random(20260926);
    for (var i = 0; i < 500; i++) {
      final mutated = Uint8List.fromList(heif);
      for (var k = 0; k < 1 + random.nextInt(8); k++) {
        mutated[random.nextInt(mutated.length)] = random.nextInt(256);
      }
      final (reading, source) = await _read(mutated);
      expect(reading, isA<MetadataReading>());
      expect(source.bytesRead, lessThanOrEqualTo(1 << 20));
    }
  });
}

int _indexOf(List<int> haystack, List<int> needle) {
  for (var i = 0; i + needle.length <= haystack.length; i++) {
    var match = true;
    for (var k = 0; k < needle.length && match; k++) {
      match = haystack[i + k] == needle[k];
    }
    if (match) return i;
  }
  throw StateError('not found');
}
