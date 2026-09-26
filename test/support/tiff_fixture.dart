import 'dart:typed_data';

/// Builds synthetic TIFF/DNG files in memory for tests (ADR-017 §9): no bytes
/// of any real file. Layout: the 8-byte header, IFD0 at 8, then the EXIF and
/// GPS IFDs when given, then every out-of-line value. The pointers to the
/// EXIF and GPS IFDs are added automatically.
class TiffFixture {
  TiffFixture({this.bigEndian = false});

  final bool bigEndian;
  final List<FixtureEntry> ifd0 = [];
  List<FixtureEntry>? exif;
  List<FixtureEntry>? gps;

  /// Overrides the EXIF IFD pointer's value (for loop and range cases).
  int? exifPointerOverride;

  Endian get _endian => bigEndian ? Endian.big : Endian.little;

  BuiltTiff build() {
    final ifds = <String, List<FixtureEntry>>{
      'IFD0': [
        ...ifd0,
        if (exif != null) FixtureEntry.long(34665, 0),
        if (gps != null) FixtureEntry.long(34853, 0),
      ]..sort((a, b) => a.tag.compareTo(b.tag)),
      'EXIF IFD': ?exif,
      'GPS IFD': ?gps,
    };
    final ifdOffsets = <String, int>{};
    var at = 8;
    for (final MapEntry(:key, :value) in ifds.entries) {
      ifdOffsets[key] = at;
      at += 2 + 12 * value.length + 4;
    }
    final dataStart = at;
    final out = BytesBuilder();
    final data = BytesBuilder();
    final ranges = <String, ({int offset, int size})>{};

    ByteData word(int bytes) => ByteData(bytes);
    final header = word(8)
      ..setUint8(0, bigEndian ? 0x4D : 0x49)
      ..setUint8(1, bigEndian ? 0x4D : 0x49)
      ..setUint16(2, 42, _endian)
      ..setUint32(4, 8, _endian);
    out.add(header.buffer.asUint8List());

    for (final MapEntry(key: name, value: entries) in ifds.entries) {
      final table = word(2 + 12 * entries.length + 4)
        ..setUint16(0, entries.length, _endian);
      for (var i = 0; i < entries.length; i++) {
        final e = entries[i];
        final p = 2 + 12 * i;
        final value = switch (e.tag) {
          34665 when name == 'IFD0' => _u32(
            exifPointerOverride ?? ifdOffsets['EXIF IFD']!,
          ),
          34853 when name == 'IFD0' => _u32(ifdOffsets['GPS IFD']!),
          _ => e.encode(_endian),
        };
        table
          ..setUint16(p, e.tag, _endian)
          ..setUint16(p + 2, e.type, _endian)
          ..setUint32(p + 4, e.countOverride ?? e.count, _endian);
        if (value.length <= 4 && e.offsetOverride == null) {
          for (var b = 0; b < value.length; b++) {
            table.setUint8(p + 8 + b, value[b]);
          }
        } else {
          final offset = e.offsetOverride ?? dataStart + data.length;
          table.setUint32(p + 8, offset, _endian);
          if (e.offsetOverride == null) {
            ranges['$name/${e.tag}'] = (offset: offset, size: value.length);
            data.add(value);
          }
        }
      }
      out.add(table.buffer.asUint8List());
    }
    out.add(data.takeBytes());
    return BuiltTiff(out.takeBytes(), ifdOffsets, ranges);
  }

  Uint8List _u32(int v) =>
      (ByteData(4)..setUint32(0, v, _endian)).buffer.asUint8List();
}

class BuiltTiff {
  BuiltTiff(this.bytes, this.ifdOffsets, this.valueRanges);

  final Uint8List bytes;

  /// Where each IFD starts.
  final Map<String, int> ifdOffsets;

  /// Where each out-of-line value is, by `'<IFD>/<tag>'`.
  final Map<String, ({int offset, int size})> valueRanges;
}

/// One IFD entry: its tag, TIFF type, count and value.
class FixtureEntry {
  FixtureEntry._(this.tag, this.type, this.count, this._encode);

  factory FixtureEntry.ascii(int tag, String text) {
    final bytes = [...text.codeUnits, 0];
    return FixtureEntry._(
      tag,
      2,
      bytes.length,
      (_) => Uint8List.fromList(bytes),
    );
  }

  factory FixtureEntry.short(int tag, int value) => FixtureEntry._(
    tag,
    3,
    1,
    (e) => (ByteData(2)..setUint16(0, value, e)).buffer.asUint8List(),
  );

  factory FixtureEntry.long(int tag, int value) => FixtureEntry._(
    tag,
    4,
    1,
    (e) => (ByteData(4)..setUint32(0, value, e)).buffer.asUint8List(),
  );

  factory FixtureEntry.rational(int tag, int numerator, int denominator) =>
      FixtureEntry._(
        tag,
        5,
        1,
        (e) =>
            (ByteData(8)
                  ..setUint32(0, numerator, e)
                  ..setUint32(4, denominator, e))
                .buffer
                .asUint8List(),
      );

  factory FixtureEntry.bytes(int tag, List<int> bytes, {int type = 1}) =>
      FixtureEntry._(tag, type, bytes.length, (_) => Uint8List.fromList(bytes));

  final int tag;
  final int type;
  final int count;
  final Uint8List Function(Endian) _encode;

  /// Corruption hooks: a stored count or value offset that lies.
  int? countOverride;
  int? offsetOverride;

  Uint8List encode(Endian endian) => _encode(endian);
}

/// A DNG laid out like the owner's phone files (IFD0 only, TIFF/EP style:
/// the capture tags in IFD0, no EXIF IFD, no GPS, no offset, a large
/// OpcodeList and uncompressed CFA data after the metadata) with neutral,
/// sanitized values (ADR-017 §9). Returns the entries so a test can change
/// them.
List<FixtureEntry> phoneStyleDngIfd0() => [
  FixtureEntry.long(254, 0), // NewSubfileType
  FixtureEntry.long(256, 4000), // ImageWidth
  FixtureEntry.long(257, 3000), // ImageLength
  FixtureEntry.short(258, 16), // BitsPerSample
  FixtureEntry.short(259, 1), // Compression: none
  FixtureEntry.short(262, 32803), // CFA
  FixtureEntry.ascii(271, 'TestMake'),
  FixtureEntry.ascii(272, 'TestMake TestPhone/TEST0001'),
  FixtureEntry.long(273, 0x10000), // StripOffsets: past the metadata
  FixtureEntry.ascii(305, 'TestOS 1.0'), // Software (not in the contract)
  FixtureEntry.ascii(306, '2000:01:02 21:30:06'), // DateTime (not in it)
  FixtureEntry.rational(33434, 3750000000, 125000000), // 30 s
  FixtureEntry.rational(33437, 200, 100), // f/2
  FixtureEntry.short(34855, 50), // ISO, no SensitivityType
  FixtureEntry.ascii(36867, '2000:01:02 21:30:05'),
  FixtureEntry.rational(37386, 880, 100), // 8.8 mm
  FixtureEntry.short(41989, 60), // 60 mm equivalent
  FixtureEntry.bytes(50706, [1, 4, 0, 0]), // DNGVersion 1.4.0.0
  FixtureEntry.ascii(50708, 'TEST0001-TestMake'),
  FixtureEntry.bytes(51009, List.filled(4996, 0xA5), type: 7), // OpcodeList2
];
