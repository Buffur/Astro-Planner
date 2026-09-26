import 'dart:typed_data';

import 'capture_metadata.dart';
import 'metadata_format.dart';
import 'metadata_source.dart';
import 'metadata_value.dart';

/// Reads the metadata contract from a DNG (ADR-017 §2, §4.3, §8).
///
/// Only IFD0 and the EXIF IFD it points to are read, and only the contract's
/// tags in them. The GPS IFD, sub-IFDs, MakerNotes and pixel data are never
/// followed; a serial number or any other tag outside the contract is never
/// decoded. Every offset and count is checked against the file before it is
/// read. A TIFF without DNGVersion is not supported: other TIFF-based RAW
/// files need a real sample first (ADR-017 §8).
abstract final class TiffMetadataReader {
  /// More entries than this in one IFD is treated as corruption (the
  /// owner's DNGs have 60).
  static const maxEntries = 1024;

  /// A text value longer than this is not read (make, model, lens and
  /// times are short).
  static const maxTextBytes = 256;

  static Future<MetadataReading> read(MetadataSource source) async {
    try {
      return await _read(source);
    } on MetadataReadException catch (e) {
      return MetadataUnreadable.fromReadFailure(e);
    } on _Corrupt catch (e) {
      return MetadataUnreadable(MetadataUnreadableReason.corrupt, e.why);
    }
  }

  static Future<MetadataReading> _read(MetadataSource source) async {
    if (source.length < 8) {
      return const MetadataUnreadable(MetadataUnreadableReason.truncated);
    }
    final header = ByteData.sublistView(await source.read(0, 8));
    final Endian endian = switch ((header.getUint8(0), header.getUint8(1))) {
      (0x49, 0x49) => Endian.little,
      (0x4D, 0x4D) => Endian.big,
      _ => throw const _Corrupt('byte order'),
    };
    if (header.getUint16(2, endian) != 42) throw const _Corrupt('magic');
    final ifd0Offset = header.getUint32(4, endian);

    final ifd0 = await _Ifd.read(source, ifd0Offset, endian, 'IFD0');
    if (!ifd0.entries.containsKey(_dngVersion)) {
      return const MetadataUnsupported(MetadataFormat.tiff);
    }

    _Ifd? exif;
    final exifPointer = ifd0.entries[_exifIfd];
    if (exifPointer != null) {
      if ((exifPointer.type != _long && exifPointer.type != _ifd) ||
          exifPointer.count != 1) {
        throw const _Corrupt('EXIF IFD pointer');
      }
      final offset = exifPointer.inlineUint32(endian);
      if (offset == ifd0Offset) throw const _Corrupt('EXIF IFD loop');
      exif = await _Ifd.read(source, offset, endian, 'EXIF IFD');
    }
    final ifds = [ifd0, ?exif];

    Future<MetadataValue<T>> field<T>(
      Future<MetadataValue<T>> Function(_Ifd ifd) readIn,
    ) async =>
        MetadataValue.combine<T>([for (final ifd in ifds) await readIn(ifd)]);

    return MetadataRead(
      MetadataFormat.dng,
      CaptureMetadata(
        exposureSeconds: await field((i) => i.rational(source, 33434)),
        fNumber: await field((i) => i.rational(source, 33437)),
        focalLengthMm: await field((i) => i.rational(source, 37386)),
        focalLength35mmEquivalentMm: await field(
          (i) async => i.short(41989, ExifValues.focalLength35mm),
        ),
        sensitivity: await field((i) async => i.sensitivity()),
        captureTime: await field((i) => i.captureTime(source)),
        cameraMake: await field((i) => i.text(source, 271, ifd0Only: true)),
        cameraModel: await field((i) => i.text(source, 272, ifd0Only: true)),
        uniqueCameraModel: await field(
          (i) => i.text(source, 50708, ifd0Only: true),
        ),
        lensMake: await field((i) => i.text(source, 42035)),
        lensModel: await field((i) => i.text(source, 42036)),
      ),
    );
  }
}

const _dngVersion = 50706;
const _exifIfd = 34665;

// TIFF field types (TIFF 6.0 §2; type 13 is the IFD type from TIFF
// Technical Note 1).
const _ascii = 2, _short = 3, _long = 4, _rational = 5, _sRational = 10;
const _ifd = 13;

int _typeSize(int type) => switch (type) {
  1 || 2 || 6 || 7 => 1,
  3 || 8 => 2,
  4 || 9 || 11 || 13 => 4,
  5 || 10 || 12 => 8,
  _ => 0, // unknown type: the entry is skipped
};

/// The contract's tags; nothing else is kept from an IFD, so nothing else can
/// be read (ADR-017 §2–§3).
const _contractTags = {
  271, 272, 50708, _dngVersion, _exifIfd, // IFD0 only (identity, structure)
  33434, 33437, 34855, 34864, 36867, 36881, 37386, 41989, 42035, 42036,
};

const _names = {
  271: 'Make',
  272: 'Model',
  33434: 'ExposureTime',
  33437: 'FNumber',
  34855: 'ISOSpeedRatings',
  36867: 'DateTimeOriginal',
  36881: 'OffsetTimeOriginal',
  37386: 'FocalLength',
  41989: 'FocalLengthIn35mmFilm',
  42035: 'LensMake',
  42036: 'LensModel',
  50708: 'UniqueCameraModel',
};

class _Corrupt implements Exception {
  const _Corrupt(this.why);

  final String why;

  @override
  String toString() => 'corrupt TIFF: $why';
}

class _Entry {
  _Entry(this.type, this.count, this.valueField);

  final int type;
  final int count;

  /// The 4-byte value/offset field as stored.
  final Uint8List valueField;

  int get size => _typeSize(type) * count;

  int inlineUint32(Endian endian) =>
      ByteData.sublistView(valueField).getUint32(0, endian);
}

class _Ifd {
  _Ifd(this.location, this.endian, this.entries);

  final String location;
  final Endian endian;

  /// Contract tags only.
  final Map<int, _Entry> entries;

  static Future<_Ifd> read(
    MetadataSource source,
    int offset,
    Endian endian,
    String location,
  ) async {
    final count = ByteData.sublistView(await source.read(offset, 2))
        .getUint16(0, endian);
    if (count > TiffMetadataReader.maxEntries) {
      throw _Corrupt('$location has $count entries');
    }
    final table = ByteData.sublistView(
      await source.read(offset + 2, 12 * count),
    );
    final entries = <int, _Entry>{};
    for (var i = 0; i < count; i++) {
      final at = 12 * i;
      final tag = table.getUint16(at, endian);
      if (!_contractTags.contains(tag)) continue;
      if (entries.containsKey(tag)) {
        throw _Corrupt('$location repeats tag $tag');
      }
      entries[tag] = _Entry(
        table.getUint16(at + 2, endian),
        table.getUint32(at + 4, endian),
        Uint8List.fromList(
          table.buffer.asUint8List(table.offsetInBytes + at + 8, 4),
        ),
      );
    }
    return _Ifd(location, endian, entries);
  }

  MetadataOrigin origin(int tag) => MetadataOrigin(
    format: MetadataFormat.dng,
    field: '${_names[tag] ?? 'Tag'} ($tag)',
    location: location,
  );

  /// The value bytes of [entry], or null when they cannot be read without
  /// leaving the file or reading more than [limit] bytes.
  Future<Uint8List?> _bytes(
    MetadataSource source,
    _Entry entry,
    int limit,
  ) async {
    final size = entry.size;
    if (size == 0 || size > limit) return null;
    if (size <= 4) return Uint8List.sublistView(entry.valueField, 0, size);
    final offset = entry.inlineUint32(endian);
    if (offset + size > source.length) return null;
    return source.read(offset, size);
  }

  UnparseableValue<T> _bad<T>(int tag, _Entry e) => UnparseableValue<T>(
    raw: 'type ${e.type}, count ${e.count}',
    origin: origin(tag),
  );

  Future<MetadataValue<double>> rational(MetadataSource source, int tag) async {
    final e = entries[tag];
    if (e == null) return const AbsentValue();
    if ((e.type != _rational && e.type != _sRational) || e.count != 1) {
      return _bad(tag, e);
    }
    final bytes = await _bytes(source, e, 8);
    if (bytes == null) return _bad(tag, e);
    final data = ByteData.sublistView(bytes);
    final r = e.type == _rational
        ? ExifRational(data.getUint32(0, endian), data.getUint32(4, endian))
        : ExifRational(data.getInt32(0, endian), data.getInt32(4, endian));
    return ExifValues.positive(r, origin(tag));
  }

  /// The first SHORT (or LONG) of [tag], or null.
  int? _firstInteger(int tag) {
    final e = entries[tag];
    if (e == null || e.count < 1) return null;
    final data = ByteData.sublistView(e.valueField);
    return switch (e.type) {
      _short => data.getUint16(0, endian),
      _long => data.getUint32(0, endian),
      _ => null,
    };
  }

  MetadataValue<double> short(
    int tag,
    MetadataValue<double> Function(int?, MetadataOrigin) convert,
  ) {
    final e = entries[tag];
    if (e == null) return const AbsentValue();
    final value = _firstInteger(tag);
    if (value == null) return _bad(tag, e);
    return convert(value, origin(tag));
  }

  MetadataValue<Sensitivity> sensitivity() {
    final e = entries[34855];
    if (e == null) return const AbsentValue();
    final value = _firstInteger(34855);
    if (value == null) return _bad(34855, e);
    return ExifValues.sensitivity(value, _firstInteger(34864), origin(34855));
  }

  Future<String?> _asciiText(MetadataSource source, _Entry? e) async {
    if (e == null || e.type != _ascii) return null;
    final bytes = await _bytes(source, e, TiffMetadataReader.maxTextBytes);
    if (bytes == null) return null;
    return String.fromCharCodes([for (final b in bytes) b < 0x80 ? b : 0x3F]);
  }

  Future<MetadataValue<CaptureTime>> captureTime(MetadataSource source) async {
    final e = entries[36867];
    if (e == null) return const AbsentValue();
    final dateTime = await _asciiText(source, e);
    if (dateTime == null) return _bad(36867, e);
    final offset = await _asciiText(source, entries[36881]);
    return ExifValues.captureTime(dateTime, offset, origin(36867));
  }

  Future<MetadataValue<String>> text(
    MetadataSource source,
    int tag, {
    bool ifd0Only = false,
  }) async {
    final e = entries[tag];
    if (e == null || (ifd0Only && location != 'IFD0')) {
      return const AbsentValue();
    }
    final value = await _asciiText(source, e);
    if (value == null) return _bad(tag, e);
    return ExifValues.text(value, origin(tag));
  }
}
