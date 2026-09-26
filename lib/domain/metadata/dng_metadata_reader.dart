import 'capture_metadata.dart';
import 'capture_metadata_reader.dart';
import 'exif_structure.dart';
import 'metadata_format.dart';
import 'metadata_source.dart';

/// DNG (ADR-017 §8, §13): a TIFF file whose IFD0 carries DNGVersion, read
/// through the shared [ExifStructure] at offset 0. A TIFF without
/// DNGVersion (CR2 aside, which recognition names, NEF or ARW, say) is not
/// supported: proprietary RAW goes through research RG-14, never an ad hoc
/// parser.
class DngMetadataReader implements MetadataFormatReader {
  const DngMetadataReader();

  @override
  Set<MetadataFormat> get formats => const {MetadataFormat.tiff};

  @override
  Future<MetadataReading> read(MetadataSource source) async {
    var recognized = MetadataFormat.tiff;
    try {
      final exif = await ExifStructure.open(source, format: MetadataFormat.dng);
      if (!exif.hasIfd0Tag(dngVersionTag)) {
        return const MetadataUnsupported(MetadataFormat.tiff);
      }
      recognized = MetadataFormat.dng;
      return MetadataRead(MetadataFormat.dng, await exif.extract());
    } on MetadataReadException catch (e) {
      return MetadataUnreadable.fromReadFailure(e, format: recognized);
    } on ExifStructureCorrupt catch (e) {
      return MetadataUnreadable(
        MetadataUnreadableReason.corrupt,
        e.why,
        recognized,
      );
    }
  }
}
