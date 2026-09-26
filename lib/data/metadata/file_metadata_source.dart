import 'dart:io';
import 'dart:typed_data';

import '../../domain/metadata/metadata_source.dart';

/// A [MetadataSource] over a local file, read with positioned reads and never
/// loaded whole (ADR-017 §4). Used on the host, in tests and on desktop; on
/// Android a content URI is read without a copy instead (ADR-017 §6).
class FileMetadataSource implements MetadataSource {
  FileMetadataSource._(this._file, this.length);

  /// Opens [file] for reading; a failure is a [MetadataReadError.io].
  static Future<FileMetadataSource> open(File file) async {
    RandomAccessFile? opened;
    try {
      opened = await file.open();
      return FileMetadataSource._(opened, await opened.length());
    } on FileSystemException catch (e) {
      await opened?.close();
      throw MetadataReadException(MetadataReadError.io, e);
    }
  }

  final RandomAccessFile _file;
  bool _closed = false;

  /// A [RandomAccessFile] takes one operation at a time: reads queue here.
  Future<void> _queue = Future.value();

  @override
  final int length;

  @override
  Future<Uint8List> read(int offset, int count) {
    if (offset < 0 || count < 0 || offset + count > length) {
      return Future.error(
        const MetadataReadException(MetadataReadError.outOfRange),
      );
    }
    final result = _queue.then((_) => _read(offset, count));
    _queue = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  Future<Uint8List> _read(int offset, int count) async {
    if (_closed) {
      throw const MetadataReadException(MetadataReadError.io, 'closed');
    }
    try {
      await _file.setPosition(offset);
      final bytes = BytesBuilder(copy: false);
      while (bytes.length < count) {
        final chunk = await _file.read(count - bytes.length);
        if (chunk.isEmpty) {
          // The file shrank after it was opened.
          throw MetadataReadException(
            MetadataReadError.io,
            'short read: ${bytes.length} of $count bytes at $offset',
          );
        }
        bytes.add(chunk);
      }
      return bytes.takeBytes();
    } on FileSystemException catch (e) {
      throw MetadataReadException(MetadataReadError.io, e);
    }
  }

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _queue;
    await _file.close();
  }
}
