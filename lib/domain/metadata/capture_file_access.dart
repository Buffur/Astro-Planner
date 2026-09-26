import 'metadata_source.dart';

/// Lets the user choose one capture file for metadata reading (ADR-017 §6).
/// Implementations never copy the file: on Android the document is read in
/// place through its content URI. A failure to pick is a
/// [MetadataReadException] with [MetadataReadError.io].
abstract interface class CaptureFileAccess {
  /// The chosen file, or null when the user cancels.
  Future<CaptureFile?> pick();
}

/// One chosen capture file.
abstract interface class CaptureFile {
  /// The name the provider shows, when it gives one.
  String? get name;

  /// The file's bytes as a [MetadataSource]; read it through a budget
  /// ([BudgetedMetadataSource]) and close it when done.
  Future<MetadataSource> open();
}
