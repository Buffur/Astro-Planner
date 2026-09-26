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
  int _remaining = BudgetedMetadataSource.defaultBudgetBytes;
  Future<void> _queue = Future.value();

  @override
  final int length;

  @override
  Future<Uint8List> read(int offset, int count) {
    final result = _queue.then((_) => _read(offset, count));
    _queue = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  Future<Uint8List> _read(int offset, int count) async {
    if (_closed) {
      throw const MetadataReadException(MetadataReadError.io, 'closed');
    }
    if (offset < 0 || count < 0 || offset + count > length) {
      throw const MetadataReadException(MetadataReadError.outOfRange);
    }
    if (count == 0) return Uint8List(0);
    if (count > BudgetedMetadataSource.defaultMaxReadBytes) {
      throw const MetadataReadException(MetadataReadError.readTooLarge);
    }
    if (count > _remaining) {
      throw const MetadataReadException(MetadataReadError.overBudget);
    }
    final Map<Object?, Object?>? answer;
    try {
      answer = await _channel.invokeMapMethod<Object?, Object?>('read', {
        'uri': _uri,
        'offset': offset,
        'count': count,
        // Native code charges skipped prefixes as well as returned bytes.
        'remainingBudget': _remaining,
      });
    } on PlatformException catch (e) {
      // On I/O failure the amount consumed is unknown. Refuse further reads
      // from this source rather than resetting or guessing its budget.
      if (e.code != 'overBudget') _remaining = 0;
      throw MetadataReadException(
        e.code == 'overBudget'
            ? MetadataReadError.overBudget
            : MetadataReadError.io,
        e,
      );
    }
    final bytes = answer?['bytes'];
    final consumed = answer?['consumed'];
    if (bytes is! Uint8List ||
        bytes.length != count ||
        consumed is! int ||
        consumed < count ||
        consumed > _remaining) {
      _remaining = 0;
      throw MetadataReadException(
        MetadataReadError.io,
        'invalid range response at $offset',
      );
    }
    _remaining -= consumed;
    return bytes;
  }

  /// The grant is transient and nothing was copied: closing only stops
  /// further reads.
  @override
  Future<void> close() async => _closed = true;
}
