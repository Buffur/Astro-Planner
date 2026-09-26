import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/app_identity.dart';
import '../../core/diagnostics/app_log.dart';
import '../../core/time/clock.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/services/backup_service.dart';
import '../../domain/services/session_exporter.dart';
import '../database/app_database.dart';
import '../export/session_manifest_codec.dart';
import 'backup_archive.dart';
import 'backup_staging.dart';

/// [BackupService] on the app's database file (TASK 14.4): `VACUUM INTO`
/// gives a consistent copy while the app runs; the share sheet saves it
/// where the user chooses; file_picker opens one for a restore.
class FileBackupService implements BackupService {
  FileBackupService(
    this._db,
    this._sessions, {
    this._clock = const SystemClock(),
    Future<Directory> Function()? dataDir,
    Future<Directory> Function()? tempDir,
    Future<Uint8List?> Function()? pickBytes,
    Future<void> Function()? clearPicked,
  }) : _dataDir = dataDir ?? getApplicationDocumentsDirectory,
       _tempDir = tempDir ?? getTemporaryDirectory,
       _pickBytes = pickBytes ?? _pickWithFilePicker,
       _clearPicked = clearPicked ?? FilePicker.clearTemporaryFiles;

  final AppDatabase _db;
  final SessionRepository _sessions;
  final Clock _clock;
  final Future<Directory> Function() _dataDir;
  final Future<Directory> Function() _tempDir;

  /// The picked backup's bytes, or null when cancelled.
  final Future<Uint8List?> Function() _pickBytes;

  /// Deletes the picker's copies of picked files (TD-065).
  final Future<void> Function() _clearPicked;

  static Future<Uint8List?> _pickWithFilePicker() async {
    final picked = await FilePicker.pickFiles(
      dialogTitle: '${AppIdentity.appName} backup',
    );
    if (picked.isEmpty) return null;
    return picked.first.xFile.readAsBytes();
  }

  /// The backup file's bytes (the testable part of [backUpAndShare]).
  Future<Uint8List> createBackup() async {
    final now = _clock.nowUtc();
    final tmp = await _tempDir();
    final copy = File(
      p.join(tmp.path, 'backup-${now.millisecondsSinceEpoch}.sqlite'),
    );
    if (await copy.exists()) await copy.delete();
    // A consistent snapshot of the live database, WAL included.
    await _db.customStatement('VACUUM INTO ?', [copy.path]);
    final database = await copy.readAsBytes();
    await copy.delete();
    final all = await _sessions.list();
    final exported = [
      for (final s in all)
        ExportedSession(s, s.legacy ? const [] : await _sessions.events(s.id)),
    ];
    return BackupArchive.build(
      database: database,
      manifestJson: jsonEncode(
        SessionManifestCodec.encode(
          exported,
          exportedAtUtc: now,
          appVersion: AppIdentity.version,
        ),
      ),
      preview: BackupPreview(
        createdAtUtc: now,
        schemaVersion: _db.schemaVersion,
        appVersion: AppIdentity.version,
        sessionCount: all.length,
      ),
    );
  }

  @override
  Future<void> backUpAndShare() async {
    final bytes = await createBackup();
    final stamp = _clock
        .nowUtc()
        .toIso8601String()
        .substring(0, 16)
        .replaceAll(':', '');
    final file = File(
      p.join((await _tempDir()).path, 'astroplan-backup-$stamp.astroplan'),
    );
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/zip')],
        text:
            '${AppIdentity.appName} backup ($stamp UTC). Keep this file to restore.',
      ),
    );
  }

  /// Checks backup [bytes] against this app (the testable part of [pick]).
  ({BackupPreview preview, Uint8List database}) check(Uint8List bytes) =>
      BackupArchive.read(
        bytes,
        appSchemaVersion: _db.schemaVersion,
        minSchemaVersion: kMinSupportedSchemaVersion,
      );

  @override
  Future<({BackupPreview preview, Object file})?> pick() async {
    try {
      final bytes = await _pickBytes();
      if (bytes == null) return null;
      final checked = check(bytes);
      return (preview: checked.preview, file: checked.database);
    } finally {
      // TD-065 (ADR-017 §6): on Android the picker copies the whole file
      // into the app's cache. This flow owns that copy and deletes it once
      // the pick is consumed, cancelled or refused.
      try {
        await _clearPicked();
      } catch (e) {
        AppLog.warning('backup', 'Picked-file copies not cleared', error: e);
      }
    }
  }

  @override
  Future<void> stage(Object file) async =>
      BackupStaging.stage(await _dataDir(), file as Uint8List);

  @override
  Future<bool> hasStagedRestore() async =>
      BackupStaging.isStaged(await _dataDir());

  @override
  Future<void> cancelStagedRestore() async =>
      BackupStaging.cancel(await _dataDir());
}
