import 'dart:math' as math;
import 'dart:typed_data';

import 'metadata_source.dart';

/// A capture file's container format, recognised from its first bytes and
/// never from its name or a picker filter (ADR-017 §4). Recognition is level
/// 1 of ADR-017 §13: naming a format says nothing about whether it has a
/// reader (level 2) or whether its metadata can identify equipment (level 3,
/// Stage 3). Several formats below are recognised only, with no reader.
enum MetadataFormat {
  /// TIFF, little- or big-endian (`II*\0` / `MM\0*`): DNG and TIFF-based
  /// RAW files (NEF and ARW among them). Whether it is a DNG is read from its
  /// tags.
  tiff,

  /// A TIFF whose IFD0 carries DNGVersion (50706). Only a reader decides
  /// this; recognition from the first bytes gives [tiff].
  dng,

  /// JPEG: `FF D8 FF`.
  jpeg,

  /// A HEIF still image: ISO-BMFF with `ftyp` and a HEVC still-image major
  /// brand, or the generic image brand `mif1` (S2.9 reads it).
  heif,

  /// AVIF, a HEIF image coded with AV1 (major brand `avif` or `avis`).
  /// Recognised only: no AVIF sample exists (S2.V4, S2R-02).
  avif,

  /// A HEIF image sequence (major brand `msf1`, `hevc`, `hevx`, `hevm` or
  /// `hevs`), which may carry no top-level `meta`. Recognised only (S2.V4,
  /// S2R-02).
  heifSequence,

  /// PNG: the 8-byte PNG signature. Recognised only (S2.10).
  png,

  /// FITS: the first card is `SIMPLE  = ` (FITS 4.0 §4.4.1.1).
  fits,

  /// XISF 1.0 monolithic: the signature `XISF0100`.
  xisf,

  /// Canon CR2: a TIFF with `CR` and version 2 at byte 8. Recognised only
  /// (proprietary RAW, RG-14).
  cr2,

  /// Canon CR3: ISO-BMFF with the major brand `crx `. Recognised only
  /// (RG-14).
  cr3,

  /// Fujifilm RAF: `FUJIFILMCCD-RAW`. Recognised only (RG-14).
  raf,

  /// Panasonic RW2: `IIU\0`. Recognised only (RG-14).
  rw2,

  /// Olympus ORF: `IIRO`, `IIRS` or `MMOR`. Recognised only (RG-14).
  orf,

  /// None of the above.
  unknown,
}

/// Recognises a [MetadataFormat] from at most [headerBytes] bytes.
abstract final class MetadataFormatRecognizer {
  /// The longest signature checked (RAF's `FUJIFILMCCD-RAW`) fits in this.
  static const headerBytes = 16;

  /// Major brands of HEIF still images (ISO/IEC 23008-12): the HEVC image
  /// brands and the generic image brand `mif1`.
  static const heifBrands = {'heic', 'heix', 'heim', 'heis', 'mif1'};

  /// Major brands of AVIF images and sequences (AV1 in HEIF).
  static const avifBrands = {'avif', 'avis'};

  /// Major brands of HEIF image sequences (ISO/IEC 23008-12).
  static const heifSequenceBrands = {'msf1', 'hevc', 'hevx', 'hevm', 'hevs'};

  static Future<MetadataFormat> recognize(MetadataSource source) async {
    final n = math.min(source.length, headerBytes);
    return fromHeader(await source.read(0, n));
  }

  /// The format of a file starting with [header].
  static MetadataFormat fromHeader(Uint8List header) {
    bool startsWith(List<int> signature, [int at = 0]) {
      if (header.length < at + signature.length) return false;
      for (var i = 0; i < signature.length; i++) {
        if (header[at + i] != signature[i]) return false;
      }
      return true;
    }

    if (startsWith(const [0x49, 0x49, 0x2A, 0x00])) {
      // CR2: the TIFF header is followed by "CR" and major version 2.
      if (startsWith(const [0x43, 0x52, 0x02], 8)) return MetadataFormat.cr2;
      return MetadataFormat.tiff;
    }
    if (startsWith(const [0x4D, 0x4D, 0x00, 0x2A])) return MetadataFormat.tiff;
    if (startsWith(const [0xFF, 0xD8, 0xFF])) return MetadataFormat.jpeg;
    if (startsWith('ftyp'.codeUnits, 4) && header.length >= 12) {
      final brand = String.fromCharCodes(header.sublist(8, 12));
      if (brand == 'crx ') return MetadataFormat.cr3;
      if (heifBrands.contains(brand)) return MetadataFormat.heif;
      if (avifBrands.contains(brand)) return MetadataFormat.avif;
      if (heifSequenceBrands.contains(brand)) {
        return MetadataFormat.heifSequence;
      }
      return MetadataFormat.unknown;
    }
    if (startsWith(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
      return MetadataFormat.png;
    }
    if (startsWith('SIMPLE  = '.codeUnits)) return MetadataFormat.fits;
    if (startsWith('XISF0100'.codeUnits)) return MetadataFormat.xisf;
    if (startsWith('FUJIFILMCCD-RAW'.codeUnits)) return MetadataFormat.raf;
    if (startsWith(const [0x49, 0x49, 0x55, 0x00])) return MetadataFormat.rw2;
    if (startsWith('IIRO'.codeUnits) ||
        startsWith('IIRS'.codeUnits) ||
        startsWith('MMOR'.codeUnits)) {
      return MetadataFormat.orf;
    }
    return MetadataFormat.unknown;
  }
}
