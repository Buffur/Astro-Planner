import 'dart:typed_data';

/// Builds synthetic HEIF files in memory (ADR-017 §9; S2.9): ISO-BMFF boxes
/// only, with no image data worth the name. Layout: `ftyp`, `meta` (`hdlr`,
/// `pitm`, `iinf`, `iloc`, `iref`, optional `idat`), then `mdat` with filler
/// "tiles" and the Exif payloads, before or after them.
class HeifFixture {
  HeifFixture({
    this.brand = 'heic',
    this.primary = 1,
    this.ilocVersion = 1,
    this.offsetSize = 4,
    this.largeIds = false,
  });

  final String brand;
  final int primary;
  final int ilocVersion;
  final int offsetSize;

  /// 32-bit item ids (pitm v1, infe v3, iloc v2, iref v1).
  final bool largeIds;

  /// Exif items: id, the TIFF bytes, an optional prefix skipped through
  /// `exif_tiff_header_offset`, whether `cdsc` links it to [primary],
  /// whether it sits in `idat` (construction method 1), and whether it comes
  /// before the filler tiles in `mdat`.
  final List<
    ({
      int id,
      List<int> tiff,
      List<int> prefix,
      bool linked,
      bool inIdat,
      bool beforeTiles,
    })
  >
  exif = [];

  /// Overrides for corruption cases.
  int? exifOffsetOverride;
  int? exifLengthOverride;
  int? tiffHeaderOffsetOverride;
  int extentCount = 1;
  int constructionMethodOverride = -1;

  void addExif(
    int id,
    List<int> tiff, {
    List<int> prefix = const [],
    bool linked = true,
    bool inIdat = false,
    bool beforeTiles = false,
  }) => exif.add((
    id: id,
    tiff: tiff,
    prefix: prefix,
    linked: linked,
    inIdat: inIdat,
    beforeTiles: beforeTiles,
  ));

  static List<int> box(String type, List<int> payload) {
    final size = payload.length + 8;
    return [..._u32(size), ...type.codeUnits, ...payload];
  }

  static List<int> fullBox(String type, int version, List<int> payload) =>
      box(type, [version, 0, 0, 0, ...payload]);

  static List<int> _u16(int v) => [(v >> 8) & 0xFF, v & 0xFF];

  static List<int> _u32(int v) => [
    (v >> 24) & 0xFF,
    (v >> 16) & 0xFF,
    (v >> 8) & 0xFF,
    v & 0xFF,
  ];

  static List<int> _u64(int v) => [..._u32(v >> 32), ..._u32(v & 0xFFFFFFFF)];

  List<int> _id(int v) => largeIds ? _u32(v) : _u16(v);

  List<int> _payload(int i) {
    final e = exif[i];
    return [
      ..._u32(tiffHeaderOffsetOverride ?? e.prefix.length),
      ...e.prefix,
      ...e.tiff,
    ];
  }

  Uint8List build() {
    final ftyp = box('ftyp', [
      ...brand.codeUnits,
      0,
      0,
      0,
      0,
      ...'mif1'.codeUnits,
    ]);
    final tiles = List.filled(3000, 0x5A);
    final grid = primary;

    // idat payload: the Exif items constructed from idat, in order.
    final idatPayload = <int>[];
    final idatAt = <int, int>{};
    for (var i = 0; i < exif.length; i++) {
      if (!exif[i].inIdat) continue;
      idatAt[i] = idatPayload.length;
      idatPayload.addAll(_payload(i));
    }

    List<int> meta(int mdatPayloadStart, Map<int, int> mdatAt) {
      final hdlr = fullBox('hdlr', 0, [
        0,
        0,
        0,
        0,
        ...'pict'.codeUnits,
        ...List.filled(13, 0),
      ]);
      final pitm = fullBox('pitm', largeIds ? 1 : 0, _id(grid));
      final infeVersion = largeIds ? 3 : 2;
      final infes = [
        fullBox('infe', infeVersion, [
          ..._id(grid),
          0,
          0,
          ...'grid'.codeUnits,
          0,
        ]),
        for (final e in exif)
          fullBox('infe', infeVersion, [
            ..._id(e.id),
            0,
            0,
            ...'Exif'.codeUnits,
            0,
          ]),
      ];
      final iinf = fullBox('iinf', largeIds ? 1 : 0, [
        ...(largeIds ? _u32(infes.length) : _u16(infes.length)),
        for (final i in infes) ...i,
      ]);
      final version = largeIds ? 2 : ilocVersion;
      List<int> sized(int v) => offsetSize == 8 ? _u64(v) : _u32(v);
      final entries = <int>[];
      for (var i = 0; i < exif.length; i++) {
        final e = exif[i];
        final payload = _payload(i);
        final method = constructionMethodOverride >= 0
            ? constructionMethodOverride
            : (e.inIdat ? 1 : 0);
        final offset =
            exifOffsetOverride ??
            (e.inIdat ? idatAt[i]! : mdatPayloadStart + mdatAt[i]!);
        final length = exifLengthOverride ?? payload.length;
        entries.addAll([
          ...(version < 2 ? _u16(e.id) : _u32(e.id)),
          if (version > 0) ..._u16(method),
          ..._u16(0), // data_reference_index: this file
          ..._u16(extentCount),
          for (var k = 0; k < extentCount; k++) ...[
            ...sized(offset),
            ...sized(length),
          ],
        ]);
      }
      final sizeByte = (offsetSize << 4) | offsetSize;
      final iloc = fullBox('iloc', version, [
        sizeByte,
        0, // base offset size 0, index size 0
        ...(version < 2 ? _u16(exif.length) : _u32(exif.length)),
        ...entries,
      ]);
      final linked = [
        for (final e in exif)
          if (e.linked) e,
      ];
      final iref = fullBox('iref', largeIds ? 1 : 0, [
        for (final e in linked)
          ...box('cdsc', [..._id(e.id), ..._u16(1), ..._id(grid)]),
      ]);
      return fullBox('meta', 0, [
        ...hdlr,
        ...pitm,
        ...iinf,
        ...iloc,
        if (linked.isNotEmpty) ...iref,
        if (idatPayload.isNotEmpty) ...box('idat', idatPayload),
      ]);
    }

    // mdat payload: Exif payloads before or after the tiles.
    final mdatAt = <int, int>{};
    final mdatPayload = <int>[];
    for (var i = 0; i < exif.length; i++) {
      if (exif[i].inIdat || !exif[i].beforeTiles) continue;
      mdatAt[i] = mdatPayload.length;
      mdatPayload.addAll(_payload(i));
    }
    mdatPayload.addAll(tiles);
    for (var i = 0; i < exif.length; i++) {
      if (exif[i].inIdat || exif[i].beforeTiles) continue;
      mdatAt[i] = mdatPayload.length;
      mdatPayload.addAll(_payload(i));
    }
    // The meta box's size does not depend on the offsets' values: build it
    // once to learn where mdat starts, then again with the real offsets.
    final metaSize = meta(0, mdatAt).length;
    final mdatPayloadStart = ftyp.length + metaSize + 8;
    return Uint8List.fromList([
      ...ftyp,
      ...meta(mdatPayloadStart, mdatAt),
      ...box('mdat', mdatPayload),
    ]);
  }
}
