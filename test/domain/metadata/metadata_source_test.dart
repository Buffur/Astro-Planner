// S2.1 (ADR-017 §4): every read of a capture file goes through a byte budget
// and a per-read limit, and every failure is typed.

import 'dart:typed_data';

import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/metadata/metadata_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/memory_metadata_source.dart';

Matcher _fails(MetadataReadError error) => throwsA(
  isA<MetadataReadException>().having((e) => e.error, 'error', error),
);

/// A source whose reads misbehave in the ways a real file can.
class _Broken implements MetadataSource {
  _Broken(this.length, this.onRead);

  @override
  final int length;
  final Future<Uint8List> Function(int offset, int count) onRead;

  @override
  Future<Uint8List> read(int offset, int count) => onRead(offset, count);

  @override
  Future<void> close() async {}
}

void main() {
  group('BudgetedMetadataSource', () {
    test('reads within the limits and logs each read', () async {
      final source = BudgetedMetadataSource(
        MemoryMetadataSource(List.generate(100, (i) => i)),
      );
      expect(await source.read(10, 3), [10, 11, 12]);
      expect(await source.read(0, 0), isEmpty);
      expect(source.bytesRead, 3);
      expect(source.reads, [(offset: 10, count: 3)]);
    });

    test('the defaults are ADR-017 §4: 1 MiB per file, 64 KiB per read', () {
      final source = BudgetedMetadataSource(MemoryMetadataSource(const []));
      expect(source.budgetBytes, 1024 * 1024);
      expect(source.maxReadBytes, 64 * 1024);
    });

    test(
      'the budget holds across reads; a refused read costs nothing',
      () async {
        final source = BudgetedMetadataSource(
          MemoryMetadataSource(const [], length: 1000),
          budgetBytes: 100,
          maxReadBytes: 60,
        );
        await source.read(0, 60);
        await expectLater(
          source.read(60, 41),
          _fails(MetadataReadError.overBudget),
        );
        expect(source.bytesRead, 60);
        await source.read(60, 40); // exactly the rest of the budget
        await expectLater(
          source.read(0, 1),
          _fails(MetadataReadError.overBudget),
        );
        expect(source.bytesRead, 100);
        expect(source.reads, hasLength(2));
      },
    );

    test('one read above the per-read limit is refused', () async {
      final source = BudgetedMetadataSource(
        MemoryMetadataSource(const [], length: 1000),
        maxReadBytes: 16,
      );
      await expectLater(
        source.read(0, 17),
        _fails(MetadataReadError.readTooLarge),
      );
      expect(source.bytesRead, 0);
    });

    test('ranges outside the file are refused before reaching it', () async {
      var reached = false;
      final source = BudgetedMetadataSource(
        _Broken(10, (_, _) async {
          reached = true;
          return Uint8List(0);
        }),
      );
      await expectLater(
        source.read(8, 3),
        _fails(MetadataReadError.outOfRange),
      );
      await expectLater(
        source.read(-1, 1),
        _fails(MetadataReadError.outOfRange),
      );
      await expectLater(
        source.read(0, -1),
        _fails(MetadataReadError.outOfRange),
      );
      await expectLater(
        source.read(11, 0),
        _fails(MetadataReadError.outOfRange),
      );
      expect(reached, isFalse);
    });

    test('a short read or an untyped failure becomes an I/O failure', () async {
      final short = BudgetedMetadataSource(
        _Broken(10, (_, count) async => Uint8List(count - 1)),
      );
      await expectLater(short.read(0, 4), _fails(MetadataReadError.io));

      final cause = StateError('disk went away');
      final failing = BudgetedMetadataSource(
        _Broken(10, (_, _) => Future.error(cause)),
      );
      await expectLater(
        failing.read(0, 4),
        throwsA(
          isA<MetadataReadException>()
              .having((e) => e.error, 'error', MetadataReadError.io)
              .having((e) => e.cause, 'cause', cause),
        ),
      );
    });

    test('a typed failure from the file passes through unchanged', () async {
      final source = BudgetedMetadataSource(
        _Broken(
          10,
          (_, _) => Future.error(
            const MetadataReadException(MetadataReadError.io, 'revoked'),
          ),
        ),
      );
      await expectLater(
        source.read(0, 4),
        throwsA(
          isA<MetadataReadException>().having(
            (e) => e.cause,
            'cause',
            'revoked',
          ),
        ),
      );
    });
  });

  group('MetadataFormatRecognizer', () {
    Future<(MetadataFormat, BudgetedMetadataSource)> recognize(
      List<int> header, {
      int? length,
    }) async {
      final source = BudgetedMetadataSource(
        MemoryMetadataSource(header, length: length),
      );
      return (await MetadataFormatRecognizer.recognize(source), source);
    }

    test('each signature is recognised from its first bytes', () async {
      expect(
        (await recognize([0x49, 0x49, 0x2A, 0x00, 8, 0, 0, 0])).$1,
        MetadataFormat.tiff,
      );
      expect(
        (await recognize([0x4D, 0x4D, 0x00, 0x2A, 0, 0, 0, 8])).$1,
        MetadataFormat.tiff,
      );
      expect(
        (await recognize('SIMPLE  =                    T'.codeUnits)).$1,
        MetadataFormat.fits,
      );
      expect((await recognize('XISF0100'.codeUnits)).$1, MetadataFormat.xisf);
      expect(
        (await recognize([0xFF, 0xD8, 0xFF, 0xE1])).$1,
        MetadataFormat.jpeg,
      );
    });

    test('near misses, short and empty files are unknown', () async {
      for (final header in [
        <int>[],
        [0x49, 0x49, 0x2A],
        [0x49, 0x49, 0x2B, 0x00], // BigTIFF: not supported, not TIFF here
        [0x49, 0x49, 0x00, 0x2A], // mixed byte order
        'SIMPLE =                     T'.codeUnits, // `=` not in byte 9
        'simple  =                    T'.codeUnits,
        'XISF0200'.codeUnits,
        [0xFF, 0xD8],
      ]) {
        expect(
          (await recognize(header)).$1,
          MetadataFormat.unknown,
          reason: '$header',
        );
      }
    });

    test(
      'recognition reads 16 bytes at most, whatever the file size',
      () async {
        final (format, source) = await recognize([
          0x49,
          0x49,
          0x2A,
          0x00,
          8,
          0,
          0,
          0,
        ], length: 4 << 30);
        expect(format, MetadataFormat.tiff);
        expect(source.bytesRead, lessThanOrEqualTo(16));
      },
    );
  });
}
