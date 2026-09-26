import 'dart:typed_data';

import 'capture_metadata.dart';
import 'capture_metadata_reader.dart';
import 'exif_structure.dart';
import 'metadata_format.dart';
import 'metadata_source.dart';

/// JPEG (ADR-017 §13, S2.8): a bounded walk over the marker segments from SOI
/// to the first SOS, looking for the APP1 `Exif\0\0` segment, whose TIFF
/// structure goes to the shared [ExifStructure]. Nothing is decoded: the scan
/// data after SOS is never read, and every other segment (XMP, ICC, maker
/// segments, tables) is skipped by its length. A JPEG without an Exif segment
/// reads as "extracted, nothing found".
class JpegMetadataReader implements MetadataFormatReader {
  const JpegMetadataReader();

  /// More segments than this before SOS is treated as corruption (the
  /// owner's phone JPEG has 13).
  static const maxSegments = 128;

  static const _exifId = [0x45, 0x78, 0x69, 0x66, 0x00, 0x00]; // Exif\0\0

  @override
  Set<MetadataFormat> get formats => const {MetadataFormat.jpeg};

  @override
  Future<MetadataReading> read(MetadataSource source) async {
    try {
      return await _read(source);
    } on MetadataReadException catch (e) {
      return MetadataUnreadable.fromReadFailure(e, format: MetadataFormat.jpeg);
    } on ExifStructureCorrupt catch (e) {
      return MetadataUnreadable(
        MetadataUnreadableReason.corrupt,
        e.why,
        MetadataFormat.jpeg,
      );
    }
  }

  static Future<MetadataReading> _read(MetadataSource source) async {
    const nothing = MetadataRead(MetadataFormat.jpeg, CaptureMetadata());
    var at = 2; // after SOI
    for (var segments = 0; segments < maxSegments; segments++) {
      final head = await source.read(at, 2);
      if (head[0] != 0xFF) throw const ExifStructureCorrupt('JPEG marker');
      final marker = head[1];
      if (marker == 0xFF) {
        at += 1; // a fill byte before the marker
        continue;
      }
      if (marker == 0xDA || marker == 0xD9) return nothing; // SOS, EOI
      if (marker == 0xD8 ||
          marker == 0x01 ||
          (marker >= 0xD0 && marker <= 0xD7)) {
        throw const ExifStructureCorrupt('JPEG marker without a segment');
      }
      final lengthBytes = await source.read(at + 2, 2);
      final length = ByteData.sublistView(lengthBytes).getUint16(0);
      if (length < 2) throw const ExifStructureCorrupt('JPEG segment length');
      if (marker == 0xE1 && length >= 8) {
        final id = await source.read(at + 4, 6);
        if (_same(id, _exifId)) {
          final exif = await ExifStructure.open(
            MetadataSourceWindow(source, at + 10, length - 8),
            format: MetadataFormat.jpeg,
            container: 'APP1',
          );
          return MetadataRead(MetadataFormat.jpeg, await exif.extract());
        }
      }
      at += 2 + length;
    }
    throw const ExifStructureCorrupt('too many JPEG segments');
  }

  static bool _same(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
