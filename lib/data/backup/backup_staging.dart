import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../../core/diagnostics/app_log.dart';
import 'backup_preferences.dart';

/// A restore staged for the next start (TASK 14.4, owner decision): the
/// checked database waits next to the live one and replaces it before the
/// app opens the database. The live file is kept as a safety copy, never
/// deleted. Since S8.9 the backup's settings wait beside it and are
/// applied with it (TD-056, ENG-14).
abstract final class BackupStaging {
  static const database = 'astroplan.sqlite';
  static const staged = 'astroplan.restore.sqlite';
  static const stagedPreferences = 'astroplan.restore.preferences.json';

  static File _staged(Directory dir) => File(p.join(dir.path, staged));
  static File _stagedPreferences(Directory dir) =>
      File(p.join(dir.path, stagedPreferences));

  /// Stages [databaseBytes] and the settings the backup carries
  /// ([BackupPreferences.parse]d; null for a version 1 archive).
  static Future<void> stage(
    Directory dir,
    Uint8List databaseBytes, {
    Map<String, Object?>? preferences,
  }) async {
    final settings = _stagedPreferences(dir);
    if (preferences == null) {
      if (await settings.exists()) await settings.delete();
    } else {
      await settings.writeAsString(jsonEncode(preferences), flush: true);
    }
    final tmp = File('${_staged(dir).path}.part');
    await tmp.writeAsBytes(databaseBytes, flush: true);
    await tmp.rename(_staged(dir).path); // appears only when complete
  }

  static Future<bool> isStaged(Directory dir) => _staged(dir).exists();

  static Future<void> cancel(Directory dir) async {
    if (await isStaged(dir)) await _staged(dir).delete();
    final settings = _stagedPreferences(dir);
    if (await settings.exists()) await settings.delete();
  }

  /// Applies a staged restore, if any; call before opening the database.
  /// The settings go first ([restorePreferences], by default into this
  /// device's preferences): applying them again is harmless, so a restore
  /// interrupted before the database is swapped is simply redone at the
  /// next start. Returns the safety copy of the replaced database (null
  /// when there was none, or nothing was staged).
  static Future<File?> apply(
    Directory dir, {
    required DateTime nowUtc,
    Future<void> Function(Map<String, Object?>? preferences)
        restorePreferences =
        BackupPreferences.restore,
  }) async {
    final next = _staged(dir);
    if (!await next.exists()) return null;
    final settings = _stagedPreferences(dir);
    await restorePreferences(await _readStaged(settings));
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
    if (await settings.exists()) await settings.delete();
    return safety;
  }

  /// The staged settings; null when none were staged, or (logged) when
  /// they cannot be read: the restore then keeps the device's settings
  /// and still clears its stale ids, as for a version 1 archive.
  static Future<Map<String, Object?>?> _readStaged(File settings) async {
    if (!await settings.exists()) return null;
    try {
      return BackupPreferences.parse(jsonDecode(await settings.readAsString()));
    } on FormatException catch (e) {
      AppLog.warning('backup', 'Staged settings unreadable', error: e);
      return null;
    }
  }
}
