import 'dart:typed_data';

import 'tiff_fixture.dart';

/// One marker segment: FF [marker], a 2-byte length, then [payload].
List<int> jpegSegment(int marker, List<int> payload) {
  final length = payload.length + 2;
  return [0xFF, marker, length >> 8, length & 0xFF, ...payload];
}

/// An APP1 Exif segment carrying [tiff].
List<int> exifApp1(Uint8List tiff) =>
    jpegSegment(0xE1, [...'Exif'.codeUnits, 0, 0, ...tiff]);

/// Builds a synthetic JPEG (ADR-017 §9): SOI, [segments], SOS, a little fake
/// scan data and EOI. Nothing here is an image; readers never decode it.
Uint8List jpegFile(List<List<int>> segments) => Uint8List.fromList([
  0xFF, 0xD8, //
  for (final s in segments) ...s,
  ...jpegSegment(0xDA, [3, 1, 0, 2, 0x11, 3, 0x11, 0, 0x3F, 0]),
  ...List.filled(64, 0x5A),
  0xFF, 0xD9,
]);

/// A phone-style JPEG's EXIF, sanitized: IFD0 identity, the capture tags in
/// the EXIF IFD with an offset and SensitivityType 3, like the owner's phone
/// JPEG (S2.R2 §3), and a GPS IFD that must never be read.
TiffFixture phoneStyleJpegExif() => TiffFixture()
  ..ifd0.addAll([
    FixtureEntry.ascii(271, 'TestMake'),
    FixtureEntry.ascii(272, 'TestMake TestPhone'),
    FixtureEntry.ascii(305, 'TestCamera 1.0'),
    FixtureEntry.ascii(306, '2000:01:02 21:30:05'),
  ])
  ..exif = [
    FixtureEntry.rational(33434, 9987236, 1000000000),
    FixtureEntry.rational(33437, 1600, 1000),
    FixtureEntry.short(34855, 100),
    FixtureEntry.short(34864, 3),
    FixtureEntry.ascii(36867, '2000:01:02 21:30:05'),
    FixtureEntry.ascii(36881, '+03:00'),
    FixtureEntry.rational(37386, 6570, 1000),
    FixtureEntry.short(41989, 23),
  ]
  ..gps = [
    FixtureEntry.ascii(1, 'N'),
    FixtureEntry.bytes(2, List.filled(24, 7), type: 5),
  ];
