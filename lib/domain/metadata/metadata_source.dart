import 'dart:typed_data';

/// The bytes of one capture file, read in bounded ranges (ADR-017 §4). The
/// data layer implements it over a local file or an Android content URI;
/// readers in the domain see only this interface, never a file or a path.
abstract interface class MetadataSource {
  /// The file's length in bytes.
  int get length;

  /// Exactly [count] bytes starting at [offset], or a [MetadataReadException].
  Future<Uint8List> read(int offset, int count);

  /// Releases the underlying file. Reads after this fail.
  Future<void> close();
}

/// Why a read was refused or failed.
enum MetadataReadError {
  /// The range starts before 0 or ends past the end of the file.
  outOfRange,

  /// One read asked for more than the per-read limit.
  readTooLarge,

  /// The file's byte budget is spent (ADR-017 §4: 1 MiB by default).
  overBudget,

  /// The file could not be opened or read (I/O, a revoked grant, a short
  /// read, a closed source).
  io,
}

/// A typed read failure; never a crash (ADR-017 §4).
class MetadataReadException implements Exception {
  const MetadataReadException(this.error, [this.cause]);

  final MetadataReadError error;

  /// The underlying error, for the log.
  final Object? cause;

  @override
  String toString() =>
      'MetadataReadException: ${error.name}${cause == null ? '' : ' ($cause)'}';
}

/// One read made through a [BudgetedMetadataSource].
typedef MetadataRead = ({int offset, int count});

/// Wraps a [MetadataSource] so that no reader can take more than
/// [budgetBytes] from one file, or more than [maxReadBytes] in one read
/// (ADR-017 §4). Every read is logged, so tests can assert what was read.
/// A refused read costs nothing and reaches the file not at all.
class BudgetedMetadataSource implements MetadataSource {
  BudgetedMetadataSource(
    this._inner, {
    this.budgetBytes = defaultBudgetBytes,
    this.maxReadBytes = defaultMaxReadBytes,
  }) : assert(budgetBytes >= 0 && maxReadBytes >= 0);

  /// ADR-017 §4: far above a DNG's metadata (6.7 KB in the owner's samples)
  /// and a typical FITS header, far below a capture file.
  static const defaultBudgetBytes = 1 << 20;
  static const defaultMaxReadBytes = 64 << 10;

  final MetadataSource _inner;
  final int budgetBytes;
  final int maxReadBytes;
  int _bytesRead = 0;
  final List<MetadataRead> _reads = [];

  /// Bytes read so far, across all reads.
  int get bytesRead => _bytesRead;

  /// The reads made so far, in order.
  List<MetadataRead> get reads => List.unmodifiable(_reads);

  @override
  int get length => _inner.length;

  @override
  Future<Uint8List> read(int offset, int count) async {
    if (offset < 0 || count < 0 || offset + count > length) {
      throw const MetadataReadException(MetadataReadError.outOfRange);
    }
    if (count > maxReadBytes) {
      throw const MetadataReadException(MetadataReadError.readTooLarge);
    }
    if (_bytesRead + count > budgetBytes) {
      throw const MetadataReadException(MetadataReadError.overBudget);
    }
    if (count == 0) return Uint8List(0);
    _bytesRead += count;
    _reads.add((offset: offset, count: count));
    final Uint8List bytes;
    try {
      bytes = await _inner.read(offset, count);
    } on MetadataReadException {
      rethrow;
    } catch (e) {
      throw MetadataReadException(MetadataReadError.io, e);
    }
    if (bytes.length != count) {
      throw MetadataReadException(
        MetadataReadError.io,
        'short read: ${bytes.length} of $count bytes at $offset',
      );
    }
    return bytes;
  }

  @override
  Future<void> close() => _inner.close();
}
