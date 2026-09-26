import 'dart:typed_data';

import 'capture_metadata.dart';
import 'capture_metadata_reader.dart';
import 'exif_structure.dart';
import 'metadata_format.dart';
import 'metadata_source.dart';
import 'metadata_value.dart';

/// HEIF/HEIC (ADR-017 §13; S2.9, as recommended in S2.R2 §7): the container
/// structure only, never an image. The top-level boxes are walked by their
/// headers; the `meta` box (at most [maxMetaBytes]) is read once and gives
/// the primary item (`pitm`), the item types (`iinf`), their locations
/// (`iloc`) and references (`iref`). The Exif item described by `cdsc` for
/// the primary item is handed, past its declared `exif_tiff_header_offset`,
/// to the shared [ExifStructure]. Image data (`mdat` beyond the Exif extent)
/// is never read.
class HeifMetadataReader implements MetadataFormatReader {
  const HeifMetadataReader();

  /// A `meta` box larger than this is refused (the owner's HEIC: 3.2 KB).
  static const maxMetaBytes = 64 << 10;

  /// More top-level boxes than this before `meta` is treated as corruption.
  static const maxTopLevelBoxes = 64;

  /// More `iloc` extents than this, over all items, is treated as
  /// corruption (S2.V4, TD-067). An extent whose field sizes are all 0
  /// occupies no bytes, so the `meta` size alone does not bound them. The
  /// limit is what a 64 KiB `meta` holds with one 4-byte field per extent;
  /// the owner's HEIC has 50.
  static const maxExtents = 16384;

  @override
  Set<MetadataFormat> get formats => const {MetadataFormat.heif};

  @override
  Future<MetadataReading> read(MetadataSource source) async {
    try {
      return await _read(source);
    } on MetadataReadException catch (e) {
      return MetadataUnreadable.fromReadFailure(e, format: MetadataFormat.heif);
    } on ExifStructureCorrupt catch (e) {
      return MetadataUnreadable(
        MetadataUnreadableReason.corrupt,
        e.why,
        MetadataFormat.heif,
      );
    } on _HeifFailure catch (e) {
      return MetadataUnreadable(e.reason, e.why, MetadataFormat.heif);
    }
  }

  static Future<MetadataReading> _read(MetadataSource source) async {
    final meta = await _findMeta(source);
    final items = _MetaItems.parse(meta.bytes, meta.offset);
    final exifIds = items.exifItemsFor();
    if (exifIds.isEmpty) {
      return const MetadataRead(MetadataFormat.heif, CaptureMetadata());
    }
    final readings = <CaptureMetadata>[];
    for (final id in exifIds) {
      readings.add(await _readExifItem(source, items, id));
    }
    return MetadataRead(MetadataFormat.heif, _combine(readings));
  }

  /// The `meta` box's payload (after its version and flags) and where that
  /// payload starts in the file.
  static Future<({Uint8List bytes, int offset})> _findMeta(
    MetadataSource source,
  ) async {
    var at = 0;
    for (var n = 0; n < maxTopLevelBoxes; n++) {
      if (at >= source.length) break;
      final box = await _boxHeader(source, at);
      if (box.type == 'meta') {
        final payload = box.size - box.headerSize - 4; // full box
        if (payload < 0) throw const _HeifFailure.corrupt('meta box size');
        if (box.size > maxMetaBytes) {
          throw const _HeifFailure(
            MetadataUnreadableReason.overBudget,
            'meta box too large',
          );
        }
        final start = at + box.headerSize + 4;
        return (bytes: await source.read(start, payload), offset: start);
      }
      at += box.size;
    }
    throw const _HeifFailure.corrupt('no meta box');
  }

  static Future<({String type, int size, int headerSize})> _boxHeader(
    MetadataSource source,
    int at,
  ) async {
    final head = ByteData.sublistView(await source.read(at, 8));
    var size = head.getUint32(0);
    final type = String.fromCharCodes(Uint8List.sublistView(head, 4, 8));
    var headerSize = 8;
    if (size == 1) {
      size = ByteData.sublistView(await source.read(at + 8, 8)).getUint64(0);
      headerSize = 16;
    } else if (size == 0) {
      size = source.length - at; // to the end of the file
    }
    if (size < headerSize) throw _HeifFailure.corrupt('$type box size');
    return (type: type, size: size, headerSize: headerSize);
  }

  static Future<CaptureMetadata> _readExifItem(
    MetadataSource source,
    _MetaItems items,
    int id,
  ) async {
    final location = items.locations[id];
    if (location == null) {
      throw _HeifFailure.corrupt('Exif item $id has no location');
    }
    if (location.extents.length != 1) {
      throw _HeifFailure.corrupt(
        'Exif item $id in ${location.extents.length} extents is not supported',
      );
    }
    final extent = location.extents.single;
    final int start;
    int length = extent.length;
    switch (location.constructionMethod) {
      case 0: // file offset
        start = location.baseOffset + extent.offset;
        if (length == 0) length = source.length - start; // to the end
      case 1: // inside idat
        final idat = items.idat;
        if (idat == null) throw const _HeifFailure.corrupt('no idat box');
        start = idat.offset + location.baseOffset + extent.offset;
        if (length == 0) length = idat.offset + idat.length - start;
        if (start < idat.offset || start + length > idat.offset + idat.length) {
          throw const _HeifFailure.corrupt('Exif item outside idat');
        }
      default:
        throw _HeifFailure.corrupt(
          'construction method ${location.constructionMethod} is not supported',
        );
    }
    if (start < 0 || length < 0 || start + length > source.length) {
      throw const MetadataReadException(MetadataReadError.outOfRange);
    }
    if (length < 4) {
      throw const MetadataReadException(MetadataReadError.outOfRange);
    }
    final tiffOffset = ByteData.sublistView(await source.read(start, 4))
        .getUint32(0);
    final tiffStart = start + 4 + tiffOffset;
    if (tiffOffset > length - 4) {
      throw const MetadataReadException(MetadataReadError.outOfRange);
    }
    final exif = await ExifStructure.open(
      MetadataSourceWindow(source, tiffStart, start + length - tiffStart),
      format: MetadataFormat.heif,
      container: 'Exif item',
    );
    return exif.extract();
  }

  /// Several Exif items that none of `cdsc` singles out: every field agrees
  /// or stays ambiguous (S2.R2 §7.3).
  static CaptureMetadata _combine(List<CaptureMetadata> all) {
    if (all.length == 1) return all.single;
    MetadataValue<T> c<T>(MetadataValue<T> Function(CaptureMetadata) f) =>
        MetadataValue.combine<T>(all.map(f));
    return CaptureMetadata(
      exposureSeconds: c((m) => m.exposureSeconds),
      sensitivity: c((m) => m.sensitivity),
      focalLengthMm: c((m) => m.focalLengthMm),
      focalLength35mmEquivalentMm: c((m) => m.focalLength35mmEquivalentMm),
      fNumber: c((m) => m.fNumber),
      captureTime: c((m) => m.captureTime),
      cameraMake: c((m) => m.cameraMake),
      cameraModel: c((m) => m.cameraModel),
      uniqueCameraModel: c((m) => m.uniqueCameraModel),
      lensMake: c((m) => m.lensMake),
      lensModel: c((m) => m.lensModel),
    );
  }
}

class _HeifFailure implements Exception {
  const _HeifFailure(this.reason, this.why);

  const _HeifFailure.corrupt(this.why)
    : reason = MetadataUnreadableReason.corrupt;

  final MetadataUnreadableReason reason;
  final String why;

  @override
  String toString() => 'HEIF: $why';
}

class _Location {
  _Location(this.constructionMethod, this.baseOffset, this.extents);

  final int constructionMethod;
  final int baseOffset;
  final List<({int offset, int length})> extents;
}

/// The item-level contents of a `meta` box, parsed from its bytes in memory.
/// Every size and count is checked against the enclosing box; anything that
/// does not fit is corrupt, never guessed.
class _MetaItems {
  int? primary;
  final types = <int, String>{};
  final locations = <int, _Location>{};

  /// `cdsc` references: item → the items it describes.
  final describes = <int, List<int>>{};
  ({int offset, int length})? idat;

  /// `iloc` extents recorded so far, over every `iloc` box.
  int _extents = 0;

  static _MetaItems parse(Uint8List meta, int metaFileOffset) {
    final items = _MetaItems();
    final data = ByteData.sublistView(meta);
    for (final box in _children(data, 0, meta.length)) {
      final body = box.start + box.headerSize;
      switch (box.type) {
        case 'pitm':
          final r = _Reader(data, body, box.end);
          final version = r.u8();
          r.skip(3);
          items.primary = version == 0 ? r.u16() : r.u32();
        case 'iinf':
          items._parseIinf(data, body, box.end);
        case 'iloc':
          items._parseIloc(data, body, box.end);
        case 'iref':
          items._parseIref(data, body, box.end);
        case 'idat':
          items.idat = (offset: metaFileOffset + body, length: box.end - body);
      }
    }
    return items;
  }

  /// The Exif items to read: those `cdsc` links to the primary item; else
  /// the only Exif item; else every Exif item (combined, conflicts
  /// ambiguous).
  List<int> exifItemsFor() {
    final exif = [
      for (final MapEntry(:key, :value) in types.entries)
        if (value == 'Exif') key,
    ];
    final primary = this.primary;
    if (primary != null) {
      final linked = [
        for (final id in exif)
          if (describes[id]?.contains(primary) ?? false) id,
      ];
      if (linked.isNotEmpty) return linked;
    }
    return exif;
  }

  void _parseIinf(ByteData data, int start, int end) {
    final r = _Reader(data, start, end);
    final version = r.u8();
    r.skip(3);
    final count = version == 0 ? r.u16() : r.u32();
    var seen = 0;
    for (final infe in _children(data, r.at, end)) {
      if (infe.type != 'infe') continue;
      seen++;
      final e = _Reader(data, infe.start + infe.headerSize, infe.end);
      final infeVersion = e.u8();
      e.skip(3);
      if (infeVersion < 2) continue; // no item type before version 2
      final id = infeVersion == 2 ? e.u16() : e.u32();
      e.skip(2); // item_protection_index
      types[id] = e.fourCc();
    }
    if (seen > count) throw const _HeifFailure.corrupt('iinf entry count');
  }

  void _parseIloc(ByteData data, int start, int end) {
    final r = _Reader(data, start, end);
    final version = r.u8();
    r.skip(3);
    if (version > 2) throw _HeifFailure.corrupt('iloc version $version');
    final sizes = r.u8();
    final offsetSize = sizes >> 4, lengthSize = sizes & 0x0F;
    final sizes2 = r.u8();
    final baseSize = sizes2 >> 4;
    final indexSize = version == 0 ? 0 : sizes2 & 0x0F;
    for (final s in [offsetSize, lengthSize, baseSize, indexSize]) {
      if (s != 0 && s != 4 && s != 8) {
        throw _HeifFailure.corrupt('iloc field size $s');
      }
    }
    final count = version < 2 ? r.u16() : r.u32();
    for (var i = 0; i < count; i++) {
      final id = version < 2 ? r.u16() : r.u32();
      final method = version == 0 ? 0 : r.u16() & 0x0F;
      final dataReference = r.u16();
      final base = r.sized(baseSize);
      final extentCount = r.u16();
      _extents += extentCount;
      if (_extents > HeifMetadataReader.maxExtents) {
        throw const _HeifFailure.corrupt('too many iloc extents');
      }
      final extents = <({int offset, int length})>[];
      for (var k = 0; k < extentCount; k++) {
        r.sized(indexSize);
        extents.add((offset: r.sized(offsetSize), length: r.sized(lengthSize)));
      }
      // Another file (data_reference_index > 0) is never followed.
      if (dataReference == 0) locations[id] = _Location(method, base, extents);
    }
  }

  void _parseIref(ByteData data, int start, int end) {
    final r = _Reader(data, start, end);
    final version = r.u8();
    r.skip(3);
    for (final ref in _children(data, r.at, end)) {
      if (ref.type != 'cdsc') continue;
      final e = _Reader(data, ref.start + ref.headerSize, ref.end);
      final from = version == 0 ? e.u16() : e.u32();
      final count = e.u16();
      final to = [
        for (var i = 0; i < count; i++) version == 0 ? e.u16() : e.u32(),
      ];
      describes.putIfAbsent(from, () => []).addAll(to);
    }
  }

  /// The child boxes in [start, end) of [data]; each must fit its parent.
  static Iterable<({String type, int start, int end, int headerSize})>
  _children(ByteData data, int start, int end) sync* {
    var at = start;
    var n = 0;
    while (at < end) {
      if (++n > 4096) throw const _HeifFailure.corrupt('too many boxes');
      if (at + 8 > end) throw const _HeifFailure.corrupt('box header');
      var size = data.getUint32(at);
      final type = String.fromCharCodes(
        Uint8List.sublistView(data, at + 4, at + 8),
      );
      var headerSize = 8;
      if (size == 1) {
        if (at + 16 > end) throw const _HeifFailure.corrupt('box header');
        size = data.getUint64(at + 8);
        headerSize = 16;
      } else if (size == 0) {
        size = end - at;
      }
      if (size < headerSize || at + size > end) {
        throw _HeifFailure.corrupt('$type box size');
      }
      yield (type: type, start: at, end: at + size, headerSize: headerSize);
      at += size;
    }
  }
}

/// Big-endian reads within [end]; reading past it is corrupt.
class _Reader {
  _Reader(this._data, this.at, this._end);

  final ByteData _data;
  final int _end;
  int at;

  void _need(int n) {
    if (at + n > _end) throw const _HeifFailure.corrupt('box ends early');
  }

  int u8() {
    _need(1);
    return _data.getUint8(at++);
  }

  int u16() {
    _need(2);
    final v = _data.getUint16(at);
    at += 2;
    return v;
  }

  int u32() {
    _need(4);
    final v = _data.getUint32(at);
    at += 4;
    return v;
  }

  int sized(int bytes) => switch (bytes) {
    0 => 0,
    4 => u32(),
    8 => () {
      _need(8);
      final v = _data.getUint64(at);
      at += 8;
      return v;
    }(),
    _ => throw _HeifFailure.corrupt('field size $bytes'),
  };

  void skip(int n) {
    _need(n);
    at += n;
  }

  String fourCc() {
    _need(4);
    final s = String.fromCharCodes(Uint8List.sublistView(_data, at, at + 4));
    at += 4;
    return s;
  }
}
