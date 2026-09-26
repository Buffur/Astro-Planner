import 'dart:typed_data';

import 'package:astroplan/domain/metadata/metadata_source.dart';

/// A [MetadataSource] over bytes in memory, for tests (ADR-017 §9: fixtures
/// are built in code). [length] may exceed the bytes given: the rest reads
/// as zeros, which stands in for pixel data without allocating it.
class MemoryMetadataSource implements MetadataSource {
  MemoryMetadataSource(List<int> bytes, {int? length})
    : _bytes = Uint8List.fromList(bytes),
      length = length ?? bytes.length;

  final Uint8List _bytes;
  bool closed = false;

  @override
  final int length;

  @override
  Future<Uint8List> read(int offset, int count) async {
    if (closed) {
      throw const MetadataReadException(MetadataReadError.io, 'closed');
    }
    if (offset < 0 || count < 0 || offset + count > length) {
      throw const MetadataReadException(MetadataReadError.outOfRange);
    }
    final out = Uint8List(count);
    for (var i = 0; i < count && offset + i < _bytes.length; i++) {
      out[i] = _bytes[offset + i];
    }
    return out;
  }

  @override
  Future<void> close() async => closed = true;
}
