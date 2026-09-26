import 'package:flutter/services.dart';

import '../../domain/metadata/capture_file_access.dart';
import '../../domain/metadata/metadata_source.dart';

/// [CaptureFileAccess] on Android (ADR-017 §6, S2.4): the system document
/// picker through the app's own channel (`MetadataDocumentChannel.kt`), and
/// range reads straight from the document's content URI. No copy is made,
/// so the app's cache holds nothing to clean up, and no persistable grant
/// is taken.
class AndroidCaptureFileAccess implements CaptureFileAccess {
  AndroidCaptureFileAccess({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  static const channelName =
      'io.github.chacha12.astroplanner/metadata_document';

  final MethodChannel _channel;

  @override
  Future<CaptureFile?> pick() async {
    final Map<String, Object?>? picked;
    try {
      picked = await _channel.invokeMapMethod<String, Object?>('pick');
    } on PlatformException catch (e) {
      throw MetadataReadException(MetadataReadError.io, e);
    }
    if (picked == null) return null;
    return _AndroidCaptureFile(
      _channel,
      picked['uri']! as String,
      picked['name'] as String?,
      picked['size'] as int?,
    );
  }
}

class _AndroidCaptureFile implements CaptureFile {
  _AndroidCaptureFile(this._channel, this._uri, this.name, this._size);

  final MethodChannel _channel;
  final String _uri;
  final int? _size;

  @override
  final String? name;

  @override
  Future<MetadataSource> open() async {
    final size = _size;
    if (size == null) {
      // Without a length no range can be checked; never guess one.
      throw const MetadataReadException(
        MetadataReadError.io,
        'the provider does not report the file size',
      );
    }
    return ContentUriMetadataSource(_channel, _uri, size);
  }
}

/// A [MetadataSource] over an Android content URI, read one range at a time
/// through the platform channel.
class ContentUriMetadataSource implements MetadataSource {
  ContentUriMetadataSource(this._channel, this._uri, this.length);

  final MethodChannel _channel;
  final String _uri;
  bool _closed = false;

  @override
  final int length;

  @override
  Future<Uint8List> read(int offset, int count) async {
    if (_closed) {
      throw const MetadataReadException(MetadataReadError.io, 'closed');
    }
    if (offset < 0 || count < 0 || offset + count > length) {
      throw const MetadataReadException(MetadataReadError.outOfRange);
    }
    if (count == 0) return Uint8List(0);
    final Uint8List? bytes;
    try {
      bytes = await _channel.invokeMethod<Uint8List>('read', {
        'uri': _uri,
        'offset': offset,
        'count': count,
        // A provider that cannot seek is read from the start, never past
        // the byte budget (ADR-017 §6).
        'sequentialLimit': BudgetedMetadataSource.defaultBudgetBytes,
      });
    } on PlatformException catch (e) {
      throw MetadataReadException(MetadataReadError.io, e);
    }
    if (bytes == null || bytes.length != count) {
      throw MetadataReadException(
        MetadataReadError.io,
        'short read: ${bytes?.length ?? 0} of $count bytes at $offset',
      );
    }
    return bytes;
  }

  /// The grant is transient and nothing was copied: closing only stops
  /// further reads.
  @override
  Future<void> close() async => _closed = true;
}
