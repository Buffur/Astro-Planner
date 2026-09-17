import 'package:drift/drift.dart';
import '../../domain/repositories/logbook_repository.dart';
import '../../domain/models/session_log.dart' as domain;
import '../database/app_database.dart';

class DriftLogbookRepository implements LogbookRepository {
  final AppDatabase _db;

  DriftLogbookRepository(this._db);

  @override
  Future<List<domain.SessionLog>> getAllLogs() async {
    final rows = await _db.select(_db.sessionLogs).get();
    return rows.map((row) => domain.SessionLog(
      id: row.id,
      targetName: row.targetName,
      equipmentName: row.equipmentName,
      sessionDate: row.sessionDate,
      plannedLightFrames: row.plannedLightFrames,
      actualLightFrames: row.actualLightFrames,
      rejectedFrames: row.rejectedFrames,
      environmentalNotes: row.environmentalNotes,
      processingNotes: row.processingNotes,
    )).toList();
  }

  @override
  Future<void> addLog(domain.SessionLog log) async {
    await _db.into(_db.sessionLogs).insert(
      SessionLogsCompanion.insert(
        targetName: log.targetName,
        equipmentName: log.equipmentName,
        sessionDate: log.sessionDate,
        plannedLightFrames: log.plannedLightFrames,
        actualLightFrames: Value(log.actualLightFrames),
        rejectedFrames: Value(log.rejectedFrames),
        environmentalNotes: Value(log.environmentalNotes),
        processingNotes: Value(log.processingNotes),
      ),
    );
  }

  @override
  Future<void> updateLog(domain.SessionLog log) async {
    await _db.update(_db.sessionLogs).replace(
      SessionLog(
        id: log.id,
        targetName: log.targetName,
        equipmentName: log.equipmentName,
        sessionDate: log.sessionDate,
        plannedLightFrames: log.plannedLightFrames,
        actualLightFrames: log.actualLightFrames,
        rejectedFrames: log.rejectedFrames,
        environmentalNotes: log.environmentalNotes,
        processingNotes: log.processingNotes,
      )
    );
  }

  @override
  Future<void> deleteLog(int id) async {
    await (_db.delete(_db.sessionLogs)..where((t) => t.id.equals(id))).go();
  }
}
