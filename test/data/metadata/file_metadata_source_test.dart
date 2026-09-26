// S2.1 (ADR-017 §4): a local capture file is read in bounded ranges, never
// whole. The large-file case uses a real 4 GiB file made with truncate (no
// data written; sparse or lazily allocated by the file system).

import 'dart:io';

import 'package:astroplan/data/metadata/file_metadata_source.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/metadata/metadata_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

Matcher _fails(MetadataReadError error) => throwsA(
  isA<MetadataReadException>().having((e) => e.error, 'error', error),
);

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('astroplan_meta_'));
  tearDown(() => dir.deleteSync(recursive: true));

  test(
    'a 4 GiB file is recognised from at most 64 KiB, read in ranges',
    () async {
      final file = File(p.join(dir.path, 'huge.dng'));
      final raf = await file.open(mode: FileMode.write);
      await raf.writeFrom([0x49, 0x49, 0x2A, 0x00, 8, 0, 0, 0]);
      await raf.truncate(4 << 30);
      await raf.close();

      final source = BudgetedMetadataSource(
        await FileMetadataSource.open(file),
      );
      try {
        expect(source.length, 4 << 30);
        expect(
          await MetadataFormatRecognizer.recognize(source),
          MetadataFormat.tiff,
        );
        expect(await source.read((4 << 30) - 8, 8), List.filled(8, 0));
        expect(source.bytesRead, lessThanOrEqualTo(64 * 1024));
        expect(source.reads.every((r) => r.count <= 64 * 1024), isTrue);
      } finally {
        await source.close();
      }
    },
  );

  test('reads return exactly the requested range', () async {
    final file = File(p.join(dir.path, 'small.bin'))
      ..writeAsBytesSync(List.generate(256, (i) => i));
    final source = await FileMetadataSource.open(file);
    expect(source.length, 256);
    final reads = await Future.wait([source.read(250, 6), source.read(0, 3)]);
    expect(reads, [
      [250, 251, 252, 253, 254, 255],
      [0, 1, 2],
    ]);
    await expectLater(
      source.read(250, 7),
      _fails(MetadataReadError.outOfRange),
    );
    await source.close();
    await expectLater(source.read(0, 1), _fails(MetadataReadError.io));
  });

  test('a missing file is an I/O failure', () async {
    await expectLater(
      FileMetadataSource.open(File(p.join(dir.path, 'absent.fits'))),
      _fails(MetadataReadError.io),
    );
  });

  test('a file that shrinks after opening gives a typed short read', () async {
    final file = File(p.join(dir.path, 'shrinks.bin'))
      ..writeAsBytesSync(List.filled(100, 1));
    final source = await FileMetadataSource.open(file);
    file.writeAsBytesSync(List.filled(10, 1));
    await expectLater(source.read(50, 10), _fails(MetadataReadError.io));
    await source.close();
  });
}
