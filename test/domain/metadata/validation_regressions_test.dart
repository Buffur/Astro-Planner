import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/capture_metadata_reader.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/jpeg_fixture.dart';
import '../../support/memory_metadata_source.dart';
import '../../support/tiff_fixture.dart';

void main() {
  for (final jpeg in [false, true]) {
    for (final tag in [34855, 34864, 41989]) {
      test(
        'invalid integer counts stay unknown: jpeg=$jpeg tag=$tag',
        () async {
          for (final count in [0, 2, 3, 0xffffffff]) {
            final fixture = TiffFixture()
              ..ifd0.addAll([
                FixtureEntry.bytes(50706, [1, 4, 0, 0]),
                if (tag == 34864) FixtureEntry.short(34855, 100),
                FixtureEntry.short(tag, 100)
                  ..countOverride = count
                  ..offsetOverride = 60000,
              ]);
            final tiff = fixture.build().bytes;
            final reading = await CaptureMetadataReader.read(
              MemoryMetadataSource(jpeg ? jpegFile([exifApp1(tiff)]) : tiff),
            );
            final m = (reading as MetadataRead).metadata;
            final value = tag == 41989
                ? m.focalLength35mmEquivalentMm
                : m.sensitivity;
            expect(value, isA<UnparseableValue>(), reason: 'count $count');
            expect(value.valueOrNull, isNull);
          }
        },
      );
    }
  }

  test(
    'identified EXIF with an incomplete TIFF header is unreadable',
    () async {
      for (var size = 0; size < 8; size++) {
        final reading = await CaptureMetadataReader.read(
          MemoryMetadataSource(
            jpegFile([
              jpegSegment(0xE1, [
                ...'Exif'.codeUnits,
                0,
                0,
                ...List.filled(size, 0),
              ]),
            ]),
          ),
        );
        expect(
          (reading as MetadataUnreadable).reason,
          MetadataUnreadableReason.truncated,
          reason: '$size header bytes',
        );
      }
    },
  );
}
