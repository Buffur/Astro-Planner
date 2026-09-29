import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../../domain/services/backup_service.dart';
import 'backup_preferences.dart';

/// A backup checked by [BackupArchive.read]: its preview, the database and
/// the settings it carries ([BackupPreferences.parse]; null for a version 1
/// archive, which has none).
typedef CheckedBackup = ({
  BackupPreview preview,
  Uint8List database,
  Map<String, Object?>? preferences,
});

/// The `.astroplan` backup file (TASK 14.4): a ZIP with `backup.json` (the
/// header), `astroplan.sqlite` (a consistent database copy),
/// `manifest.json` (export manifest v2, readable without the app) and,
/// since format version 2 (S8.9, TD-056), `preferences.json`
/// ([BackupPreferences]). A version 1 archive still restores.
abstract final class BackupArchive {
  static const format = 'astroplan-backup';
  static const formatVersion = 2;
  static const _header = 'backup.json';
  static const _database = 'astroplan.sqlite';
  static const _manifest = 'manifest.json';
  static const _preferences = 'preferences.json';

  static Uint8List build({
    required Uint8List database,
    required String manifestJson,
    required Map<String, Object?> preferences,
    required BackupPreview preview,
  }) {
    final header = utf8.encode(
      jsonEncode({
        'format': format,
        'format_version': formatVersion,
        'schema_version': preview.schemaVersion,
        'app_version': preview.appVersion,
        'created_at_utc_ms': preview.createdAtUtc.millisecondsSinceEpoch,
        'session_count': preview.sessionCount,
      }),
    );
    final archive = Archive()
      ..add(ArchiveFile.bytes(_header, header))
      ..add(ArchiveFile.bytes(_database, database))
      ..add(ArchiveFile.bytes(_manifest, utf8.encode(manifestJson)))
      ..add(
        ArchiveFile.bytes(_preferences, utf8.encode(jsonEncode(preferences))),
      );
    return ZipEncoder().encodeBytes(archive);
  }

  /// Reads and checks a backup for an app at [appSchemaVersion] that can
  /// upgrade from [minSchemaVersion]. Throws [BackupException].
  static CheckedBackup read(
    Uint8List bytes, {
    required int appSchemaVersion,
    required int minSchemaVersion,
  }) {
    final Archive archive;
    final Map<String, Object?> header;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
      header = Map<String, Object?>.from(
        jsonDecode(utf8.decode(archive.findFile(_header)!.content)) as Map,
      );
    } catch (_) {
      throw const BackupException(BackupProblem.notABackup);
    }
    final db = archive.findFile(_database);
    final version = header['format_version'];
    if (header['format'] != format ||
        (version != 1 && version != formatVersion) ||
        db == null) {
      throw const BackupException(BackupProblem.notABackup);
    }
    Map<String, Object?>? preferences;
    if (version == formatVersion) {
      try {
        preferences = BackupPreferences.parse(
          jsonDecode(utf8.decode(archive.findFile(_preferences)!.content)),
        );
      } catch (_) {
        throw const BackupException(BackupProblem.notABackup);
      }
    }
    final database = Uint8List.fromList(db.content);
    final stored = sqliteUserVersion(database);
    final schema = header['schema_version'];
    // The database itself must say the same version as the header.
    if (stored == null || schema is! int || stored != schema) {
      throw const BackupException(BackupProblem.notABackup);
    }
    if (schema > appSchemaVersion) {
      throw const BackupException(BackupProblem.newerSchema);
    }
    if (schema < minSchemaVersion) {
      throw const BackupException(BackupProblem.tooOld);
    }
    return (
      preview: BackupPreview(
        createdAtUtc: DateTime.fromMillisecondsSinceEpoch(
          header['created_at_utc_ms'] as int? ?? 0,
          isUtc: true,
        ),
        schemaVersion: schema,
        appVersion: header['app_version'] as String? ?? '?',
        sessionCount: header['session_count'] as int? ?? 0,
      ),
      database: database,
      preferences: preferences,
    );
  }

  /// SQLite's `user_version` (the schema version Drift stores): a
  /// big-endian int at offset 60 of the 100-byte header; null if [db] is
  /// not a SQLite database.
  static int? sqliteUserVersion(Uint8List db) {
    const magic = 'SQLite format 3\u0000';
    if (db.length < 100 || String.fromCharCodes(db.sublist(0, 16)) != magic) {
      return null;
    }
    return ByteData.sublistView(db, 60, 64).getInt32(0);
  }
}
