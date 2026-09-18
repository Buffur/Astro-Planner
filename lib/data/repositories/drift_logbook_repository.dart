import 'package:drift/drift.dart';
import '../../domain/repositories/logbook_repository.dart';
import '../../domain/models/session_log.dart' as domain;
import '../../domain/models/capture_block.dart' as domain;
import '../database/app_database.dart';

class DriftLogbookRepository implements LogbookRepository {
  final AppDatabase _db;

  DriftLogbookRepository(this._db);

  @override
  Future<List<domain.SessionLog>> getAllLogs() async {
    final sessionRows = await _db.select(_db.sessionLogs).get();
    final blockRows = await _db.select(_db.captureBlocks).get();
    
    final blocksBySession = <int, List<domain.CaptureBlock>>{};
    for (final b in blockRows) {
      final block = domain.CaptureBlock(
        id: b.id,
        sessionLogId: b.sessionLogId,
        frameType: domain.FrameType.values.firstWhere((e) => e.name == b.frameType, orElse: () => domain.FrameType.light),
        filterName: b.filterName,
        exposureTimeSeconds: b.exposureTimeSeconds,
        frameCount: b.frameCount,
        binning: b.binning,
        gainIso: b.gainIso,
      );
      blocksBySession.putIfAbsent(b.sessionLogId, () => []).add(block);
    }

    return sessionRows.map((row) => domain.SessionLog(
      id: row.id,
      targetName: row.targetName,
      equipmentName: row.equipmentName,
      sessionDate: row.sessionDate,
      captureBlocks: blocksBySession[row.id] ?? [],
      locationName: row.locationName,
      bortleScale: row.bortleScale,
      plannedLightFrames: row.plannedLightFrames,
      plannedDarkFrames: row.plannedDarkFrames,
      plannedFlatFrames: row.plannedFlatFrames,
      plannedBiasFrames: row.plannedBiasFrames,
      integrationTimeSeconds: row.integrationTimeSeconds,
      focalLength: row.focalLength,
      aperture: row.aperture,
      temperature: row.temperature,
      humidity: row.humidity,
      cloudCover: row.cloudCover,
      actualLightFrames: row.actualLightFrames,
      rejectedFrames: row.rejectedFrames,
      environmentalNotes: row.environmentalNotes,
      processingNotes: row.processingNotes,
    )).toList();
  }

  @override
  Future<void> addLog(domain.SessionLog log) async {
    await _db.transaction(() async {
      final sessionId = await _db.into(_db.sessionLogs).insert(
        SessionLogsCompanion.insert(
          targetName: log.targetName,
          equipmentName: log.equipmentName,
          sessionDate: log.sessionDate,
          locationName: Value(log.locationName),
          bortleScale: Value(log.bortleScale),
          plannedLightFrames: log.plannedLightFrames,
          plannedDarkFrames: Value(log.plannedDarkFrames),
          plannedFlatFrames: Value(log.plannedFlatFrames),
          plannedBiasFrames: Value(log.plannedBiasFrames),
          integrationTimeSeconds: Value(log.integrationTimeSeconds),
          focalLength: Value(log.focalLength),
          aperture: Value(log.aperture),
          temperature: Value(log.temperature),
          humidity: Value(log.humidity),
          cloudCover: Value(log.cloudCover),
          actualLightFrames: Value(log.actualLightFrames),
          rejectedFrames: Value(log.rejectedFrames),
          environmentalNotes: Value(log.environmentalNotes),
          processingNotes: Value(log.processingNotes),
        ),
      );
      
      for (final block in log.captureBlocks) {
        await _db.into(_db.captureBlocks).insert(
          CaptureBlocksCompanion.insert(
            sessionLogId: sessionId,
            frameType: block.frameType.name,
            filterName: Value(block.filterName),
            exposureTimeSeconds: block.exposureTimeSeconds,
            frameCount: block.frameCount,
            binning: Value(block.binning),
            gainIso: Value(block.gainIso),
          )
        );
      }
    });
  }

  @override
  Future<void> updateLog(domain.SessionLog log) async {
    await _db.transaction(() async {
      await _db.update(_db.sessionLogs).replace(
        SessionLog(
          id: log.id,
          targetName: log.targetName,
          equipmentName: log.equipmentName,
          sessionDate: log.sessionDate,
          locationName: log.locationName,
          bortleScale: log.bortleScale,
          plannedLightFrames: log.plannedLightFrames,
          plannedDarkFrames: log.plannedDarkFrames,
          plannedFlatFrames: log.plannedFlatFrames,
          plannedBiasFrames: log.plannedBiasFrames,
          integrationTimeSeconds: log.integrationTimeSeconds,
          focalLength: log.focalLength,
          aperture: log.aperture,
          temperature: log.temperature,
          humidity: log.humidity,
          cloudCover: log.cloudCover,
          actualLightFrames: log.actualLightFrames,
          rejectedFrames: log.rejectedFrames,
          environmentalNotes: log.environmentalNotes,
          processingNotes: log.processingNotes,
        )
      );
      
      // Replace all blocks
      await (_db.delete(_db.captureBlocks)..where((t) => t.sessionLogId.equals(log.id))).go();
      
      for (final block in log.captureBlocks) {
        await _db.into(_db.captureBlocks).insert(
          CaptureBlocksCompanion.insert(
            sessionLogId: log.id,
            frameType: block.frameType.name,
            filterName: Value(block.filterName),
            exposureTimeSeconds: block.exposureTimeSeconds,
            frameCount: block.frameCount,
            binning: Value(block.binning),
            gainIso: Value(block.gainIso),
          )
        );
      }
    });
  }

  @override
  Future<void> deleteLog(int id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.captureBlocks)..where((t) => t.sessionLogId.equals(id))).go();
      await (_db.delete(_db.sessionLogs)..where((t) => t.id.equals(id))).go();
    });
  }
}
