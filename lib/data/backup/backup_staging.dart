import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

/// A restore staged for the next start (TASK 14.4, owner decision): the
/// checked database waits next to the live one and replaces it before the
/// app opens the database. The live file is kept as a safety copy, never
/// deleted.
abstract final class BackupStaging {
  static const database = 'astroplan.sqlite';
  static const staged = 'astroplan.restore.sqlite';

  static File _staged(Directory dir) => File(p.join(dir.path, staged));

  static Future<void> stage(Directory dir, Uint8List databaseBytes) async {
    final tmp = File('${_staged(dir).path}.part');
    await tmp.writeAsBytes(databaseBytes, flush: true);
    await tmp.rename(_staged(dir).path); // appears only when complete
  }

  static Future<bool> isStaged(Directory dir) => _staged(dir).exists();

  static Future<void> cancel(Directory dir) async {
    if (await isStaged(dir)) await _staged(dir).delete();
  }

  /// Applies a staged restore, if any; call before opening the database.
  /// Returns the safety copy of the replaced database (null when there was
  /// none, or nothing was staged).
  static Future<File?> apply(Directory dir, {required DateTime nowUtc}) async {
    final next = _staged(dir);
    if (!await next.exists()) return null;
    final live = File(p.join(dir.path, database));
    final stamp = nowUtc.toIso8601String().replaceAll(RegExp('[:.]'), '-');
    File? safety;
    if (await live.exists()) {
      safety = await live.rename('${live.path}.before-restore-$stamp.bak');
    }
    // A write-ahead log of the old database must not be applied to the new.
    for (final suffix in ['-wal', '-shm', '-journal']) {
      final side = File('${live.path}$suffix');
      if (await side.exists()) {
        await side.rename('${side.path}.before-restore-$stamp.bak');
      }
    }
    await next.rename(live.path);
    return safety;
  }
}
