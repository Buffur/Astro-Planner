import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../../domain/repositories/logbook_repository.dart';
import '../../domain/models/session_log.dart' as domain;
import '../../domain/models/capture_block.dart' as domain;
import '../database/app_database.dart';

class DriftLogbookRepository implements LogbookRepository {
  final AppDatabase _db;

  DriftLogbookRepository(this._db);

  @override
  Future<List<domain.SessionLog>> getAllLogs() async {
    // Newest-saved first (TASK 4.2, TD-039); id correlates with insertion
    // order since it's an autoincrement primary key.
    final sessionRows = await (_db.select(
      _db.sessionLogs,
    )..orderBy([(t) => OrderingTerm.desc(t.id)])).get();
    // TASK 5.3: blocks come back in their saved order.
    final blockRows =
        await (_db.select(_db.captureBlocks)..orderBy([
              (t) => OrderingTerm.asc(t.position),
              (t) => OrderingTerm.asc(t.id),
            ]))
            .get();

    final blocksBySession = <int, List<domain.CaptureBlock>>{};
    for (final b in blockRows) {
      final block = _toDomain(b);
      if (block == null) continue;
      blocksBySession.putIfAbsent(b.sessionLogId, () => []).add(block);
    }

    return sessionRows
        .map(
          (row) => domain.SessionLog(
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
          ),
        )
        .toList();
  }

  @override
  Future<int> addLog(domain.SessionLog log) async {
    return await _db.transaction(() async {
      final sessionId = await _db
          .into(_db.sessionLogs)
          .insert(
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

      await _insertBlocks(sessionId, log.captureBlocks);

      return sessionId;
    });
  }

  @override
  Future<void> updateLog(domain.SessionLog log) async {
    await _db.transaction(() async {
      // TASK 11.2: a partial update of the log columns this repository
      // owns. A full-row replace would reset the v16 columns (status,
      // references, snapshots, timestamps) that it does not know about.
      await (_db.update(
        _db.sessionLogs,
      )..where((t) => t.id.equals(log.id))).write(
        SessionLogsCompanion(
          targetName: Value(log.targetName),
          equipmentName: Value(log.equipmentName),
          sessionDate: Value(log.sessionDate),
          locationName: Value(log.locationName),
          bortleScale: Value(log.bortleScale),
          plannedLightFrames: Value(log.plannedLightFrames),
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

      // Replace all blocks
      await (_db.delete(
        _db.captureBlocks,
      )..where((t) => t.sessionLogId.equals(log.id))).go();

      await _insertBlocks(log.id, log.captureBlocks);
    });
  }

  @override
  Future<void> deleteLog(int id) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.captureBlocks,
      )..where((t) => t.sessionLogId.equals(id))).go();
      await (_db.delete(_db.sessionLogs)..where((t) => t.id.equals(id))).go();
    });
  }

  /// Writes [blocks] for [sessionId] with their list order as `position`.
  Future<void> _insertBlocks(
    int sessionId,
    List<domain.CaptureBlock> blocks,
  ) async {
    for (var i = 0; i < blocks.length; i++) {
      final block = blocks[i];
      await _db
          .into(_db.captureBlocks)
          .insert(
            CaptureBlocksCompanion.insert(
              sessionLogId: sessionId,
              frameType: block.frameType.name,
              filterName: Value(block.filterName),
              exposureTimeSeconds: block.exposureTimeSeconds,
              frameCount: block.frameCount,
              binning: Value(block.binning),
              position: Value(i),
              calibrationPolicy: Value(block.calibrationPolicy?.name),
              gainKind: Value(block.gain.kind.name),
              gainValue: Value(block.gain.value),
            ),
          );
    }
  }

  /// Maps a stored row to a domain block, or null (logged) when the row
  /// holds values the domain rejects: an unknown frame type, or a value
  /// outside the validated ranges (possible only in data written before
  /// TASK 5.3's validation). Never silently read as a light frame.
  static domain.CaptureBlock? _toDomain(CaptureBlock b) {
    final type = domain.CaptureBlock.tryParseFrameType(b.frameType);
    if (type == null) {
      debugPrint('Skipping capture block ${b.id}: frame type ${b.frameType}');
      return null;
    }
    try {
      return domain.CaptureBlock(
        id: b.id,
        sessionLogId: b.sessionLogId,
        frameType: type,
        filterName: b.filterName,
        exposureTimeSeconds: b.exposureTimeSeconds,
        frameCount: b.frameCount,
        binning: b.binning,
        gain: domain.CaptureGain.fromStored(b.gainKind, b.gainValue),
        calibrationPolicy: type == domain.FrameType.light
            ? null
            : domain.CalibrationPolicy.tryParse(b.calibrationPolicy),
      );
    } on ArgumentError catch (e) {
      debugPrint('Skipping invalid capture block ${b.id}: $e');
      return null;
    }
  }
}
