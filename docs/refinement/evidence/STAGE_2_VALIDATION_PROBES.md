# Stage 2 validation probe evidence

Run on 2026-09-26 at `79f392c`. Synthetic data only. No application or existing
test file was modified. These probes call the production dispatcher and use
the existing synthetic fixture builders.

## Reproduction

From the repository root in PowerShell, save the Dart block below to a
temporary file after replacing `__REPO__` with the repository's file URI:

```powershell
$repoUri = ([uri]((Get-Location).Path + '\')).AbsoluteUri
# Put the Dart block in $probe using a single-quoted here-string.
$probePath = Join-Path $env:TEMP 'astro-stage2-validation-probe.dart'
$probe.Replace('__REPO__', $repoUri) | Set-Content -LiteralPath $probePath -Encoding utf8
dart --packages=.dart_tool/package_config.json $probePath
```

```dart
import 'dart:convert';
import 'dart:io';
import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/capture_metadata_reader.dart';
import 'package:astroplan/domain/metadata/metadata_source.dart';
import '__REPO__test/support/tiff_fixture.dart';
import '__REPO__test/support/jpeg_fixture.dart';
import '__REPO__test/support/memory_metadata_source.dart';

Future<void> main() async {
  var failed = 0;
  final badIso = FixtureEntry.short(34855, 100)
    ..countOverride = 3
    ..offsetOverride = 60000;
  final tiff = (TiffFixture()..ifd0.addAll([
    FixtureEntry.bytes(50706, [1, 4, 0, 0]), badIso,
  ])).build();
  final iso = await CaptureMetadataReader.read(MemoryMetadataSource(tiff.bytes));
  print(jsonEncode({
    'probe': 'out-of-range ISO array', 'fileLength': tiff.bytes.length,
    'reading': iso.runtimeType.toString(),
    'actual': (iso as MetadataRead).metadata.sensitivity.toString(),
    'expected': 'UnparseableValue, never a known number from the pointer',
  }));
  if (iso.metadata.sensitivity.valueOrNull != null) failed++;

  final shortExif = jpegFile([
    jpegSegment(0xE1, [...'Exif'.codeUnits, 0, 0, 0x49, 0x49, 42, 0]),
  ]);
  final jpeg = await CaptureMetadataReader.read(MemoryMetadataSource(shortExif));
  print(jsonEncode({
    'probe': 'APP1 Exif with only 4 TIFF-header bytes',
    'actual': jpeg.runtimeType.toString(),
    'nothingFound': jpeg is MetadataRead ? jpeg.nothingFound : null,
    'expected': 'MetadataUnreadable (truncated/corrupt)',
  }));
  if (jpeg is! MetadataUnreadable) failed++;

  final entries = phoneStyleDngIfd0();
  for (final e in entries) {
    if ([271, 272, 50708, 33434, 33437, 37386, 36867].contains(e.tag)) {
      e.offsetOverride = 900000;
    }
  }
  final fixture = (TiffFixture()..ifd0.addAll(entries)).build();
  final source = BudgetedMetadataSource(
    MemoryMetadataSource(fixture.bytes, length: 25 << 20),
  );
  final reading = await CaptureMetadataReader.read(source);
  final traversal = source.reads.fold<int>(0, (n, r) => n + r.offset + r.count);
  print(jsonEncode({
    'probe': 'native non-seekable restart cost for real parser requests',
    'reading': reading.runtimeType.toString(), 'ranges': source.reads.length,
    'dartChargedBytes': source.bytesRead,
    'nativeBytesTraversedIfEachReadRestarts': traversal,
    'allRangesUnderNativeLimit': source.reads.every(
      (r) => r.offset + r.count <= 1 << 20,
    ),
    'budget': 1 << 20,
  }));
  print('Acceptance assertions failed: $failed/2');
  exitCode = failed == 0 ? 0 : 1;
}
```

## Observed results

| Probe | Actual at HEAD | Required outcome |
| --- | --- | --- |
| S2V-01, 38-byte DNG, SHORT count 3 pointing to byte 60000 | `MetadataRead`, `Known(isoUnspecified 60000.0 ... raw "60000")` | Malformed/out-of-range field stays unknown/unparseable. |
| S2V-02, APP1 Exif plus four TIFF bytes | `MetadataRead`, `nothingFound: true` | Typed truncated/corrupt reading. |
| S2V-03, real parser requests with seven values at offset 900000 | 11 ranges; Dart charges 365 bytes; all native range ends below 1 MiB; sum of restarted traversals is 6,300,383 bytes | Per-file resource accounting must cover consumed/skipped prefixes. |

The two semantic assertions failed; process exit was **1**. The third probe
computes the consequence of the inspected native restart algorithm for a
non-seekable stream that consumes skips. It does **not** run Kotlin, measure
a provider, or claim device verification.

The main repository gate passed separately, as did all three external real
samples. The malformed probes do not include or derive from owner file bytes.
