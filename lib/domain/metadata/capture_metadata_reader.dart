import 'capture_metadata.dart';
import 'dng_metadata_reader.dart';
import 'heif_metadata_reader.dart';
import 'jpeg_metadata_reader.dart';
import 'metadata_format.dart';
import 'metadata_source.dart';

/// Reads the metadata contract from one kind of container (ADR-017 §13).
/// A new format is a new reader in [CaptureMetadataReader.readers]; the
/// contract ([CaptureMetadata]) and the dispatcher do not change.
abstract interface class MetadataFormatReader {
  /// The recognised formats this reader takes.
  Set<MetadataFormat> get formats;

  /// Reads [source], whose format is one of [formats]. Never throws: a
  /// failure is a [MetadataUnreadable].
  Future<MetadataReading> read(MetadataSource source);
}

/// Reads the metadata contract from one capture file (ADR-017): recognise
/// the format from its first bytes (level 1), then hand it to the reader
/// for that format (level 2). A recognised format with no reader is
/// [MetadataUnsupported], never a guess. Every read goes through a byte
/// budget; nothing reads the whole file.
abstract final class CaptureMetadataReader {
  /// The formats with a reader (ADR-017 §13): DNG, JPEG and HEIF still
  /// images (S2.9). FITS and PNG are out of Stage 2; AVIF and HEIF sequences
  /// wait for samples (S2.V4); proprietary RAW waits for RG-14.
  static const List<MetadataFormatReader> readers = [
    DngMetadataReader(),
    JpegMetadataReader(),
    HeifMetadataReader(),
  ];

  static Future<MetadataReading> read(
    MetadataSource source, {
    List<MetadataFormatReader> readers = CaptureMetadataReader.readers,
  }) async {
    final budgeted = source is BudgetedMetadataSource
        ? source
        : BudgetedMetadataSource(source);
    final MetadataFormat format;
    try {
      format = await MetadataFormatRecognizer.recognize(budgeted);
    } on MetadataReadException catch (e) {
      return MetadataUnreadable.fromReadFailure(e);
    }
    for (final reader in readers) {
      if (reader.formats.contains(format)) return reader.read(budgeted);
    }
    return MetadataUnsupported(format);
  }
}
