import 'dart:math' as math;
import 'dart:typed_data';

import 'metadata_source.dart';

/// A capture file's container format, recognised from its first bytes and
/// never from its name or a picker filter (ADR-017 §4). Recognising a format
/// does not mean it is supported: that is decided per reader (ADR-017 §8).
enum MetadataFormat {
  /// TIFF, little- or big-endian (`II*\0` / `MM\0*`): DNG and TIFF-based
  /// RAW files. Whether it is a DNG is read from its tags (S2.3).
  tiff,

  /// A TIFF whose IFD0 carries DNGVersion (50706). Only a reader decides
  /// this; recognition from the first bytes gives [tiff].
  dng,

  /// FITS: the first card is `SIMPLE  = ` (FITS 4.0 §4.4.1.1).
  fits,

  /// XISF 1.0 monolithic: the signature `XISF0100`.
  xisf,

  /// JPEG: `FF D8 FF`.
  jpeg,

  /// None of the above.
  unknown,
}

/// Recognises a [MetadataFormat] from at most [headerBytes] bytes.
abstract final class MetadataFormatRecognizer {
  /// The longest signature checked (FITS's `SIMPLE  = `) fits in this.
  static const headerBytes = 16;

  static Future<MetadataFormat> recognize(MetadataSource source) async {
    final n = math.min(source.length, headerBytes);
    return fromHeader(await source.read(0, n));
  }

  /// The format of a file starting with [header].
  static MetadataFormat fromHeader(Uint8List header) {
    bool startsWith(List<int> signature) {
      if (header.length < signature.length) return false;
      for (var i = 0; i < signature.length; i++) {
        if (header[i] != signature[i]) return false;
      }
      return true;
    }

    if (startsWith(const [0x49, 0x49, 0x2A, 0x00]) ||
        startsWith(const [0x4D, 0x4D, 0x00, 0x2A])) {
      return MetadataFormat.tiff;
    }
    if (startsWith('SIMPLE  = '.codeUnits)) return MetadataFormat.fits;
    if (startsWith('XISF0100'.codeUnits)) return MetadataFormat.xisf;
    if (startsWith(const [0xFF, 0xD8, 0xFF])) return MetadataFormat.jpeg;
    return MetadataFormat.unknown;
  }
}
