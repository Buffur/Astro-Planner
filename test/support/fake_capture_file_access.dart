import 'package:astroplan/domain/metadata/capture_file_access.dart';
import 'package:astroplan/domain/metadata/metadata_source.dart';

import 'memory_metadata_source.dart';

/// A [CaptureFileAccess] that "picks" the next queued answer: a file of the
/// given bytes, a cancel (null), or an error.
class FakeCaptureFileAccess implements CaptureFileAccess {
  final List<Object?> answers = [];
  int picks = 0;

  /// Queues a file named [name] holding [bytes] (and zeros up to [length]).
  void file(String? name, List<int> bytes, {int? length, Object? openError}) =>
      answers.add(_FakeFile(name, bytes, length, openError));

  void cancel() => answers.add(null);

  void error(Object e) => answers.add(_Error(e));

  @override
  Future<CaptureFile?> pick() async {
    picks++;
    final answer = answers.removeAt(0);
    if (answer is _Error) throw answer.error;
    return answer as CaptureFile?;
  }
}

class _Error {
  _Error(this.error);
  final Object error;
}

class _FakeFile implements CaptureFile {
  _FakeFile(this.name, this._bytes, this._length, this._openError);

  @override
  final String? name;
  final List<int> _bytes;
  final int? _length;
  final Object? _openError;

  @override
  Future<MetadataSource> open() async {
    if (_openError case final e?) throw e;
    return MemoryMetadataSource(_bytes, length: _length);
  }
}
