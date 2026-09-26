import 'capture_metadata.dart';
import 'metadata_format.dart';
import 'metadata_source.dart';
import 'tiff_metadata_reader.dart';

/// Reads the metadata contract from one capture file (ADR-017): recognise
/// the format from its first bytes, then hand it to that format's reader.
/// Every read goes through a byte budget; nothing reads the whole file.
abstract final class CaptureMetadataReader {
  static Future<MetadataReading> read(MetadataSource source) async {
    final budgeted = source is BudgetedMetadataSource
        ? source
        : BudgetedMetadataSource(source);
    try {
      return switch (await MetadataFormatRecognizer.recognize(budgeted)) {
        MetadataFormat.tiff => await TiffMetadataReader.read(budgeted),
        // FITS waits for a real sample (ADR-017 §8, S2.6).
        final other => MetadataUnsupported(other),
      };
    } on MetadataReadException catch (e) {
      return MetadataUnreadable.fromReadFailure(e);
    }
  }
}
