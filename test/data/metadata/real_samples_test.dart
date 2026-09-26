// S2.3 (ADR-017 §9): real-sample validation, local only. The owner's files
// and their expected values stay outside the repository: set
// ASTROPLAN_METADATA_SAMPLES to a directory holding `expected.json`:
//
//   {"samples": [{"file": "<absolute path>", "format": "dng",
//     "exposureSeconds": 30, "fNumber": 2.0, "focalLengthMm": 8.8,
//     "focalLength35mmEquivalentMm": 60, "sensitivity": "isoUnspecified 50",
//     "captureTime": "YYYY-MM-DDTHH:MM:SS (zone unknown)",
//     "cameraMake": "...", "cameraModel": "...", "uniqueCameraModel": "...",
//     "lensMake": null, "lensModel": null, "maxBytesRead": 65536}]}
//
// A key that is present is checked (null means the field must be unknown);
// a key that is left out is not checked. Without the variable the test is
// skipped, as in CI and the ordinary quality gate.

import 'dart:convert';
import 'dart:io';

import 'package:astroplan/data/metadata/file_metadata_source.dart';
import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/capture_metadata_reader.dart';
import 'package:astroplan/domain/metadata/metadata_source.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

const _variable = 'ASTROPLAN_METADATA_SAMPLES';

void main() {
  final dir = Platform.environment[_variable];
  final skip = dir == null
      ? 'real samples are local only: set $_variable to run them'
      : null;

  test(
    'the owner\'s real samples give their expected contract values',
    () async {
      final expected = jsonDecode(
        File(p.join(dir!, 'expected.json')).readAsStringSync(),
      ) as Map<String, Object?>;
      final samples = (expected['samples']! as List)
          .cast<Map<String, Object?>>();
      expect(samples, isNotEmpty);
      for (final sample in samples) {
        final path = sample['file']! as String;
        final source = BudgetedMetadataSource(
          await FileMetadataSource.open(File(path)),
        );
        final reading = await CaptureMetadataReader.read(source);
        await source.close();
        final name = p.basename(path);
        expect(reading, isA<MetadataRead>(), reason: name);
        final read = reading as MetadataRead;
        expect(read.format.name, sample['format'], reason: name);
        final m = read.metadata;
        final fields = <String, MetadataValue<Object>>{
          'exposureSeconds': m.exposureSeconds,
          'fNumber': m.fNumber,
          'focalLengthMm': m.focalLengthMm,
          'focalLength35mmEquivalentMm': m.focalLength35mmEquivalentMm,
          'sensitivity': m.sensitivity,
          'captureTime': m.captureTime,
          'cameraMake': m.cameraMake,
          'cameraModel': m.cameraModel,
          'uniqueCameraModel': m.uniqueCameraModel,
          'lensMake': m.lensMake,
          'lensModel': m.lensModel,
          'imageDimensions': m.imageDimensions,
        };
        for (final MapEntry(:key, :value) in fields.entries) {
          if (!sample.containsKey(key)) continue;
          final want = sample[key];
          final got = value.valueOrNull;
          final reason = '$name $key';
          switch (want) {
            case null:
              expect(got, isNull, reason: reason);
            case num():
              expect(got, isA<double>(), reason: reason);
              expect(got! as double, closeTo(want, 1e-9), reason: reason);
            default:
              expect(got?.toString(), want, reason: reason);
          }
        }
        expect(
          source.bytesRead,
          lessThanOrEqualTo(sample['maxBytesRead'] as int? ?? 65536),
          reason: '$name bytes read',
        );
        // ignore: avoid_print
        print(
          '$name: ${source.bytesRead} bytes read in ${source.reads.length} '
          'reads of ${source.length}',
        );
      }
    },
    skip: skip,
  );
}
