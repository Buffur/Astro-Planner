// S9.8: exported and backed-up files are named for people, in the device's
// local date and time (sortable), and say what they hold.

import 'package:astroplan/data/backup/file_backup_service.dart';
import 'package:astroplan/data/export/share_session_exporter.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_log.dart';
import 'package:astroplan/domain/services/session_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

ExportedSession _one(int id) => ExportedSession(
  Session(
    record: SessionLog(
      id: id,
      targetName: 'M42',
      equipmentName: 'Rig',
      sessionDate: DateTime.utc(2026, 9, 29),
    ),
    status: SessionStatus.completed,
    legacy: true,
  ),
  const [],
);

void main() {
  final now = DateTime.utc(2026, 9, 29, 19, 30);
  final local = now.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  final stamp =
      '${local.year}-${two(local.month)}-${two(local.day)}-'
      '${two(local.hour)}${two(local.minute)}';

  test('the stamp is the device\'s local date and time, sortable', () {
    expect(ShareSessionExporter.localFileStamp(now), stamp);
    expect(stamp, matches(RegExp(r'^\d{4}-\d{2}-\d{2}-\d{4}$')));
  });

  test('an export names what it holds: one entry or the Logbook', () {
    expect(
      ShareSessionExporter.fileName([_one(1)], now),
      'astroplan-entry-$stamp.json',
    );
    expect(
      ShareSessionExporter.fileName([_one(1), _one(2)], now),
      'astroplan-logbook-$stamp.json',
    );
  });

  test('TD-091: an export\'s share text states its local time and offset', () {
    final text = ShareSessionExporter.shareText([_one(1)], now);
    expect(text, startsWith('Astro Planner export: 1 session'));
    expect(text, contains('Exported $stamp (UTC'));
  });

  test('a backup: its name and a share text with the local time and '
      'offset', () {
    expect(
      FileBackupService.fileName(now),
      'astroplan-backup-$stamp.astroplan',
    );
    final text = FileBackupService.shareText(now);
    expect(text, contains(stamp));
    expect(text, contains('(UTC'));
    expect(text, contains('Keep this file to restore.'));
  });
}
