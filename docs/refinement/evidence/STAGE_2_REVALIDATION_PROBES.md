# Stage 2 repeat validation: probe evidence

Run on 2026-09-26 at `5d8bdbb`. The data is synthetic only (the committed fixture builders in
`test/support/`). Each probe was saved under `test/zz_probe/`, run with
`flutter test --no-pub <file>`, and deleted. No application or existing test file was
modified.

## P1: HEIF `iloc` with zero-size extent fields (S2R-01, TD-067)

```dart
import 'dart:io';
import 'dart:typed_data';

import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/capture_metadata_reader.dart';
import 'package:astroplan/domain/metadata/metadata_source.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/heif_fixture.dart';
import '../support/memory_metadata_source.dart';

List<int> u16(int v) => [(v >> 8) & 0xFF, v & 0xFF];

Uint8List heifWithIloc(int items, int extentsPerItem) {
  final ftyp = HeifFixture.box(
    'ftyp', [...'heic'.codeUnits, 0, 0, 0, 0, ...'mif1'.codeUnits]);
  // iloc v1, every field size 0: an item is id, method, data ref, extent count.
  final body = <int>[0x00, 0x00, ...u16(items)];
  for (var i = 0; i < items; i++) {
    body.addAll([...u16(i + 1), 0, 0, 0, 0, ...u16(extentsPerItem)]);
  }
  final meta = HeifFixture.fullBox(
    'meta', 0, HeifFixture.fullBox('iloc', 1, body));
  return Uint8List.fromList([...ftyp, ...meta]);
}

void main() {
  test('P1', () async {
    for (final items in [300, 1000]) {
      final before = ProcessInfo.currentRss;
      final bytes = heifWithIloc(items, 65535);
      final sw = Stopwatch()..start();
      final source = BudgetedMetadataSource(MemoryMetadataSource(bytes));
      final r = await CaptureMetadataReader.read(source);
      print('items=$items metaBytes=${bytes.length} -> ${r.runtimeType} '
          'in ${sw.elapsedMilliseconds} ms, maxRss ${ProcessInfo.maxRss >> 20} MiB '
          '(start ${before >> 20}), read ${source.bytesRead} B');
    }
  }, timeout: const Timeout(Duration(minutes: 5)));
}
```

Observed across three runs (the tests share one process, so maxRss accumulates):

```text
items=10   metaBytes=128  -> MetadataRead in 94 ms,  read 128 B
items=100  metaBytes=848  -> MetadataRead in 832 ms, read 848 B
items=300  metaBytes=2448 -> MetadataRead in 3027–3442 ms, maxRss 941–948 MiB (start 123–124)
items=1000 metaBytes=8048 -> MetadataRead in 9276–16656 ms, maxRss 2605–2736 MiB (start 943–950)
```

The cost is linear in the item count. A 64 KiB `meta` (about 8,190 items) extrapolates to
about 14 GB and more than 75 s.

## P2–P5: HEIF against the shared-extractor guarantees

The same harness was used. `rd(bytes)` wraps the bytes in
`BudgetedMetadataSource(MemoryMetadataSource(bytes))` and calls
`CaptureMetadataReader.read`.

- **P2:** a `TiffFixture` whose IFD0 holds `FixtureEntry.short(34855, 100)`, with
  `countOverride = 3` and `offsetOverride = 60000`, is wrapped by
  `HeifFixture()..addExif(2, tiff)`. Result: `Read(heif)`, and ISO is
  `Unparseable("type 3, count 3" from heif:Exif item IFD0/ISOSpeedRatings (34855))`.
- **P3:** `HeifFixture()..addExif(2, List.filled(n, 0x49))` for n = 0 to 7. Result: every
  case is `Unreadable(truncated, heif)`.
- **P4:** `HeifFixture()..addExif(2, phoneStyleJpegExif().build().bytes)`. Result:
  `Read(heif)`. The GPS IFD starts at file offset 3393 (TIFF base 3205), and no logged read
  covers it. Reads: (16@0) (8@0) (8@20) (161@32) (4@3201) (8@3205) (2@3213) (72@3215)
  (2@3291) (96@3293) (8@3486) (8@3494) …
- **P5:**
  - `ftyp` with the major brand `msf1`, `hevs` or `avis`, followed by a 72-byte `moov`,
    gives `Unreadable(corrupt, heif)` ("no meta box") in every case;
  - `HeifFixture(brand: 'avif')` with a phone-style Exif item gives `Read(heif)`, and the
    model "TestMake TestPhone" is extracted.
