// S2.7 (ADR-017 §13): one EXIF extractor for every container, recognition
// kept apart from extraction, and recognition-only formats that are named
// but never parsed.

import 'dart:typed_data';

import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/capture_metadata_reader.dart';
import 'package:astroplan/domain/metadata/exif_structure.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/metadata/metadata_source.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/memory_metadata_source.dart';
import '../../support/tiff_fixture.dart';

Uint8List _phoneTiff() =>
    (TiffFixture()..ifd0.addAll(phoneStyleDngIfd0())).build().bytes;

List<int> _ftyp(String brand) => [
  0,
  0,
  0,
  24,
  ...'ftyp'.codeUnits,
  ...brand.codeUnits,
  0,
  0,
  0,
  0,
];

void main() {
  group('the EXIF structure at a non-zero base offset', () {
    test('an embedded structure reads the same values, labelled by its '
        'container, and never reads before its start', () async {
      const base = 1000;
      final file = [...List.filled(base, 0xEE), ..._phoneTiff()];
      final source = BudgetedMetadataSource(MemoryMetadataSource(file));
      final exif = await ExifStructure.open(
        MetadataSourceWindow(source, base),
        format: MetadataFormat.jpeg,
        container: 'APP1',
      );
      final m = await exif.extract();

      expect(m.exposureSeconds.valueOrNull, 30.0);
      expect(m.focalLengthMm.valueOrNull, 8.8);
      expect(m.cameraMake.valueOrNull, 'TestMake');
      expect(
        (m.exposureSeconds as KnownValue).origin,
        const MetadataOrigin(
          format: MetadataFormat.jpeg,
          field: 'ExposureTime (33434)',
          location: 'APP1 IFD0',
        ),
      );
      expect(source.reads.every((r) => r.offset >= base), isTrue);
    });

    test('the EXIF IFD of an embedded structure is labelled too', () async {
      final tiff =
          (TiffFixture()
                ..ifd0.add(FixtureEntry.ascii(271, 'TestMake'))
                ..exif = [FixtureEntry.rational(33437, 28, 10)])
              .build();
      final source = MemoryMetadataSource([1, 2, 3, ...tiff.bytes]);
      final m = await (await ExifStructure.open(
        MetadataSourceWindow(source, 3),
        format: MetadataFormat.jpeg,
        container: 'APP1',
      )).extract();
      expect(m.fNumber.valueOrNull, 2.8);
      expect((m.fNumber as KnownValue).origin.location, 'APP1 EXIF IFD');
    });

    test('a window refuses ranges outside itself', () async {
      final source = MemoryMetadataSource(List.filled(100, 1));
      final window = MetadataSourceWindow(source, 90);
      expect(window.length, 10);
      await expectLater(
        window.read(8, 4),
        throwsA(isA<MetadataReadException>()),
      );
      expect(await window.read(0, 10), List.filled(10, 1));
      expect(
        () => MetadataSourceWindow(source, 90, 11),
        throwsA(isA<MetadataReadException>()),
      );
      expect(
        () => MetadataSourceWindow(source, -1),
        throwsA(isA<MetadataReadException>()),
      );
    });
  });

  group('recognition-only formats are named, never parsed', () {
    final signatures = <MetadataFormat, List<int>>{
      MetadataFormat.heif: _ftyp('heic'),
      MetadataFormat.avif: _ftyp('avif'),
      MetadataFormat.heifSequence: _ftyp('msf1'),
      MetadataFormat.png: [
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0,
        0,
      ],
      MetadataFormat.cr2: [
        0x49,
        0x49,
        0x2A,
        0x00,
        16,
        0,
        0,
        0,
        0x43,
        0x52,
        2,
        0,
      ],
      MetadataFormat.cr3: _ftyp('crx '),
      MetadataFormat.raf: 'FUJIFILMCCD-RAW 0201'.codeUnits,
      MetadataFormat.rw2: [0x49, 0x49, 0x55, 0x00, 24, 0, 0, 0],
      MetadataFormat.orf: 'IIRO\u0008\u0000\u0000\u0000'.codeUnits,
    };

    test('each signature is recognised', () {
      for (final MapEntry(:key, :value) in signatures.entries) {
        expect(
          MetadataFormatRecognizer.fromHeader(Uint8List.fromList(value)),
          key,
          reason: key.name,
        );
      }
      // S2.V4 (S2R-02): AVIF and sequences are no longer HEIF still images.
      for (final (brand, format) in [
        ('mif1', MetadataFormat.heif),
        ('heix', MetadataFormat.heif),
        ('avis', MetadataFormat.avif),
        ('hevc', MetadataFormat.heifSequence),
      ]) {
        expect(
          MetadataFormatRecognizer.fromHeader(Uint8List.fromList(_ftyp(brand))),
          format,
          reason: brand,
        );
      }
      for (final orf in ['IIRS', 'MMOR']) {
        expect(
          MetadataFormatRecognizer.fromHeader(
            Uint8List.fromList([...orf.codeUnits, 0, 0, 0, 8]),
          ),
          MetadataFormat.orf,
        );
      }
    });

    test('near misses are not recognised as those formats', () {
      MetadataFormat of(List<int> h) =>
          MetadataFormatRecognizer.fromHeader(Uint8List.fromList(h));
      // A TIFF with "CR" but another major version is a plain TIFF.
      expect(
        of([0x49, 0x49, 0x2A, 0x00, 16, 0, 0, 0, 0x43, 0x52, 3, 0]),
        MetadataFormat.tiff,
      );
      expect(of(_ftyp('mp41')), MetadataFormat.unknown); // an MP4 video
      expect(of(_ftyp('heic').sublist(0, 10)), MetadataFormat.unknown);
      expect(of([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A]), MetadataFormat.unknown);
      expect(of('FUJIFILMCCD-RA'.codeUnits), MetadataFormat.unknown);
      expect(of('IIRX'.codeUnits), MetadataFormat.unknown);
      expect(of([0x49, 0x49, 0x55, 0x01]), MetadataFormat.unknown);
    });

    test('a recognised format without a reader is "no reader", not '
        '"unrecognised"', () async {
      // HEIF has a reader since S2.9 (heif_metadata_reader_test.dart).
      for (final MapEntry(:key, :value) in signatures.entries.where(
        (e) => e.key != MetadataFormat.heif,
      )) {
        final reading = await CaptureMetadataReader.read(
          MemoryMetadataSource(value, length: 4096),
        );
        expect(reading, isA<MetadataUnsupported>(), reason: key.name);
        expect(reading.format, key);
        expect((reading as MetadataUnsupported).recognized, isTrue);
      }
      final unknown = await CaptureMetadataReader.read(
        MemoryMetadataSource('plain text'.codeUnits),
      );
      expect((unknown as MetadataUnsupported).recognized, isFalse);
      expect(unknown.format, MetadataFormat.unknown);
    });
  });

  group('levels 1 and 2 are distinct', () {
    test('"extracted, nothing found" is explicit', () async {
      final empty =
          (TiffFixture()..ifd0.add(FixtureEntry.bytes(50706, [1, 4, 0, 0])))
              .build();
      final reading = await CaptureMetadataReader.read(
        MemoryMetadataSource(empty.bytes),
      );
      expect(reading, isA<MetadataRead>());
      expect((reading as MetadataRead).nothingFound, isTrue);
      expect(reading.format, MetadataFormat.dng);

      final phone = await CaptureMetadataReader.read(
        MemoryMetadataSource(_phoneTiff()),
      );
      expect((phone as MetadataRead).nothingFound, isFalse);
    });

    test('an unreadable file still says what was recognised', () async {
      final cutInIfd0 = await CaptureMetadataReader.read(
        MemoryMetadataSource(Uint8List.sublistView(_phoneTiff(), 0, 100)),
      );
      expect(cutInIfd0, isA<MetadataUnreadable>());
      expect(cutInIfd0.format, MetadataFormat.tiff);

      final loop =
          (TiffFixture()
                ..ifd0.addAll(phoneStyleDngIfd0())
                ..exif = [FixtureEntry.rational(33434, 1, 1)]
                ..exifPointerOverride = 8)
              .build();
      final afterGate = await CaptureMetadataReader.read(
        MemoryMetadataSource(loop.bytes),
      );
      expect(
        (afterGate as MetadataUnreadable).reason,
        MetadataUnreadableReason.corrupt,
      );
      expect(afterGate.format, MetadataFormat.dng);
    });

    test(
      'a new format is a new reader: the contract and dispatcher stay',
      () async {
        final png = await CaptureMetadataReader.read(
          MemoryMetadataSource([
            0x89,
            0x50,
            0x4E,
            0x47,
            0x0D,
            0x0A,
            0x1A,
            0x0A,
          ]),
          readers: [...CaptureMetadataReader.readers, const _PngStandIn()],
        );
        expect(png, isA<MetadataRead>());
        expect((png as MetadataRead).nothingFound, isTrue);
        expect(png.format, MetadataFormat.png);
      },
    );
  });
}

/// A stand-in reader, proving dispatch by registration only.
class _PngStandIn implements MetadataFormatReader {
  const _PngStandIn();

  @override
  Set<MetadataFormat> get formats => const {MetadataFormat.png};

  @override
  Future<MetadataReading> read(MetadataSource source) async =>
      const MetadataRead(MetadataFormat.png, CaptureMetadata());
}
