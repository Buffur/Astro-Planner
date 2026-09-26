import 'package:flutter/foundation.dart';

import '../../domain/metadata/capture_file_access.dart';
import '../../domain/metadata/capture_metadata.dart';
import '../../domain/metadata/capture_metadata_reader.dart';
import '../../domain/metadata/metadata_source.dart';

/// The hidden metadata screen (F-45; ADR-017 §10): the user picks one capture
/// file and sees the metadata contract read from it. Nothing is stored and
/// nothing is written to Equipment; Stage 3 decides what happens next.
class MetadataImportViewModel extends ChangeNotifier {
  MetadataImportViewModel(this._files);

  final CaptureFileAccess _files;
  bool _busy = false;
  String? _fileName;
  MetadataReading? _reading;

  bool get busy => _busy;

  /// The name of the file last read, when the provider gave one.
  String? get fileName => _fileName;

  /// The last reading, or null before the first file.
  MetadataReading? get reading => _reading;

  /// Picks a file and reads it. A cancel changes nothing. A failure to open
  /// the picker is thrown (the screen reports it); a file that cannot be
  /// opened or read becomes a [MetadataUnreadable] reading.
  Future<void> pickAndRead() async {
    _busy = true;
    notifyListeners();
    try {
      final file = await _files.pick();
      if (file == null) return;
      _fileName = file.name;
      _reading = await _readFile(file);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  static Future<MetadataReading> _readFile(CaptureFile file) async {
    final MetadataSource source;
    try {
      source = await file.open();
    } on MetadataReadException catch (e) {
      return MetadataUnreadable.fromReadFailure(e);
    }
    try {
      return await CaptureMetadataReader.read(source);
    } finally {
      await source.close();
    }
  }
}
