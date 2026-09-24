/// What a backup file says about itself, shown before a restore (TASK 14.4).
class BackupPreview {
  const BackupPreview({
    required this.createdAtUtc,
    required this.schemaVersion,
    required this.appVersion,
    required this.sessionCount,
  });

  final DateTime createdAtUtc;
  final int schemaVersion;
  final String appVersion;
  final int sessionCount;
}

/// Why a backup cannot be restored (TASK 14.4).
enum BackupProblem {
  /// Not an AstroPlan backup, or damaged.
  notABackup,

  /// Made by a newer app with a newer database schema: refused (roadmap).
  newerSchema,

  /// Older than the oldest schema this app can upgrade (ADR-008 floor).
  tooOld,
}

class BackupException implements Exception {
  const BackupException(this.problem);
  final BackupProblem problem;

  @override
  String toString() => 'BackupException: ${problem.name}';
}

/// Manual backup and restore (TASK 14.4; owner decisions): one
/// `.astroplan` file (database copy + manifest v2 + header) shared to a
/// place the user picks; a restore is checked, confirmed, staged and
/// applied at the next start, before the database opens.
abstract class BackupService {
  /// Creates a backup and opens the share sheet.
  Future<void> backUpAndShare();

  /// Lets the user pick a backup file and checks it; null if cancelled.
  /// Throws [BackupException] when it cannot be restored.
  Future<({BackupPreview preview, Object file})?> pick();

  /// Stages a picked, checked backup for the next start.
  Future<void> stage(Object file);

  /// Whether a restore is staged, and cancelling it.
  Future<bool> hasStagedRestore();
  Future<void> cancelStagedRestore();
}
