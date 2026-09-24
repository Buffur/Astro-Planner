import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../../core/time/clock.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/capture_block.dart' as domain;
import '../../domain/models/execution.dart';
import '../../domain/models/session.dart';
import '../../domain/models/session_log.dart' as domain;
import '../../domain/models/session_snapshot.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/services/execution_machine.dart';
import '../database/app_database.dart';

/// [SessionRepository] on the v16 `session_logs` table (ADR-014; TASK 11.3).
///
/// Every write runs in one transaction. A session row is only ever changed
/// with a partial `write` of the columns concerned, never a full-row
/// replace (TASK 11.2).
class DriftSessionRepository implements SessionRepository {
  DriftSessionRepository(this._db, {Clock? clock})
    : _clock = clock ?? const SystemClock();

  final AppDatabase _db;
  final Clock _clock;

  int get _nowMs => _clock.nowUtc().millisecondsSinceEpoch;

  // Writes --------------------------------------------------------------------

  @override
  Future<Session> create(SessionPlan plan) async {
    final id = await _db.transaction(() async {
      final now = _nowMs;
      final id = await _db
          .into(_db.sessionLogs)
          .insert(
            SessionLogsCompanion.insert(
              targetName: plan.targetLabel,
              equipmentName: plan.rigLabel,
              sessionDate: _labelDate(plan.eveningDate),
              plannedLightFrames: plan.lightFrameCount,
              locationName: Value(plan.siteLabel),
              status: const Value('draft'),
              eveningDate: Value(plan.eveningDate.toIso8601String()),
              timeZoneId: Value(plan.timeZoneId),
              siteId: Value(plan.siteId),
              targetId: Value(plan.targetId),
              rigId: Value(plan.rigId),
              createdAtUtcMs: Value(now),
              updatedAtUtcMs: Value(now),
            ),
          );
      await _insertBlocks(id, plan.blocks);
      return id;
    });
    return (await get(id))!;
  }

  @override
  Future<Session> updatePlan(int id, SessionPlan plan) => _change(id, (s) {
    _requirePlanEditable(s);
    return _writePlan(
      id,
      plan,
      const SessionLogsCompanion(status: Value('draft')),
    );
  });

  @override
  Future<Session> savePlan(
    int id,
    SessionPlan plan,
    SessionSnapshot snapshot,
  ) => _change(id, (s) {
    _requirePlanEditable(s);
    return _writePlan(
      id,
      plan,
      SessionLogsCompanion(
        status: const Value('planned'),
        plannedAtUtcMs: Value(_nowMs),
        planSnapshot: Value(snapshot.json),
      ),
    );
  });

  @override
  Future<Session> start(int id, SessionSnapshot snapshot, {int? blockId}) =>
      _change(id, (s) async {
        _requireTransition(s, SessionStatus.inProgress);
        final running = await inProgress();
        if (running != null) {
          throw SessionStateError(
            'Session ${running.id} is already in progress; finish or '
            'abandon it first.',
          );
        }
        final block = blockId ?? _firstBlockToCapture(s.blocks);
        if (block == null) throw SessionStateError('The plan has no block.');
        await _appendEvent(s, ExecutionEventKind.started, blockId: block);
        await _writeRow(
          id,
          SessionLogsCompanion(
            status: const Value('inProgress'),
            startedAtUtcMs: Value(_nowMs),
            executionStartSnapshot: Value(snapshot.json),
          ),
        );
      });

  /// The first light block with frames, else the first block.
  static int? _firstBlockToCapture(List<domain.CaptureBlock> blocks) {
    for (final b in blocks) {
      if (b.frameType == domain.FrameType.light && b.frameCount > 0) {
        return b.id;
      }
    }
    return blocks.isEmpty ? null : blocks.first.id;
  }

  @override
  Future<Session> complete(int id) => _change(id, (s) async {
    _requireTransition(s, SessionStatus.completed);
    await _appendEvent(s, ExecutionEventKind.finished);
    await _writeRow(
      id,
      SessionLogsCompanion(
        status: const Value('completed'),
        completedAtUtcMs: Value(_nowMs),
      ),
    );
  });

  @override
  Future<Session> abandon(int id) => _change(id, (s) async {
    _requireTransition(s, SessionStatus.abandoned);
    if (s.status == SessionStatus.inProgress) {
      await _appendEvent(s, ExecutionEventKind.abandoned);
    }
    await _writeRow(id, const SessionLogsCompanion(status: Value('abandoned')));
  });

  @override
  Future<ExecutionState> record(
    int id,
    ExecutionEventKind kind, {
    int? blockId,
    int? delta,
    InterruptionReason? reason,
  }) async {
    if (kind == ExecutionEventKind.started ||
        kind == ExecutionEventKind.finished ||
        kind == ExecutionEventKind.abandoned) {
      throw ArgumentError.value(kind, 'kind', 'use start/complete/abandon');
    }
    await _change(id, (s) async {
      if (s.legacy || s.status != SessionStatus.inProgress) {
        throw SessionStateError('Session $id is not in progress.');
      }
      await _appendEvent(
        s,
        kind,
        blockId: blockId,
        delta: delta,
        reason: reason,
      );
    });
    return execution(id);
  }

  /// Validates [kind] against the run's state and stores the event with
  /// its effect on the block counters — the projection (ADR-016 §4). Runs
  /// inside the caller's transaction.
  Future<void> _appendEvent(
    Session s,
    ExecutionEventKind kind, {
    int? blockId,
    int? delta,
    InterruptionReason? reason,
  }) async {
    final state = await _fold(s);
    final event = ExecutionMachine.next(
      state,
      kind,
      _clock.nowUtc(),
      blockId: blockId,
      delta: delta,
      reason: reason,
    );
    final after = ExecutionMachine.apply(state, event);
    await _db
        .into(_db.sessionEvents)
        .insert(
          SessionEventsCompanion.insert(
            sessionLogId: s.id,
            seq: event.seq,
            atUtcMs: event.atUtc.millisecondsSinceEpoch,
            kind: event.kind.name,
            blockId: Value(event.blockId),
            delta: Value(event.delta),
            reason: Value(event.reason?.name),
            clockAdjusted: Value(event.clockAdjusted),
          ),
        );
    final block = event.blockId;
    if (block != null &&
        (kind == ExecutionEventKind.framesConfirmed ||
            kind == ExecutionEventKind.framesRejected)) {
      await (_db.update(
        _db.captureBlocks,
      )..where((t) => t.id.equals(block))).write(
        CaptureBlocksCompanion(
          completedFrames: Value(after.completedFor(block)),
          rejectedFrames: Value(after.rejectedFor(block)),
        ),
      );
    }
  }

  Future<ExecutionState> _fold(Session s) async => ExecutionMachine.fold({
    for (final b in s.blocks) b.id,
  }, await events(s.id));

  @override
  Future<List<ExecutionEvent>> events(int id) async {
    final rows =
        await (_db.select(_db.sessionEvents)
              ..where((t) => t.sessionLogId.equals(id))
              ..orderBy([(t) => OrderingTerm.asc(t.seq)]))
            .get();
    return [
      for (final r in rows)
        ExecutionEvent(
          seq: r.seq,
          atUtc: DateTime.fromMillisecondsSinceEpoch(r.atUtcMs, isUtc: true),
          kind: ExecutionEventKind.tryParse(r.kind)!,
          blockId: r.blockId,
          delta: r.delta,
          reason: InterruptionReason.tryParse(r.reason),
          clockAdjusted: r.clockAdjusted,
        ),
    ];
  }

  @override
  Future<ExecutionState> execution(int id) async {
    final s = await get(id);
    if (s == null) throw SessionStateError('No session $id.');
    return _fold(s);
  }

  @override
  Future<Session?> inProgress() async {
    final running = await list(
      statuses: {SessionStatus.inProgress},
      includeLegacy: false,
    );
    return running.isEmpty ? null : running.first;
  }

  @override
  Future<Session> updateResults(int id, SessionResults results) =>
      _change(id, (s) {
        if (s.legacy) {
          throw SessionStateError('A legacy session is read-only.');
        }
        return _writeRow(
          id,
          SessionLogsCompanion(
            actualLightFrames: Value(results.actualLightFrames),
            rejectedFrames: Value(results.rejectedFrames),
            environmentalNotes: Value(results.environmentalNotes),
            processingNotes: Value(results.processingNotes),
          ),
        );
      });

  @override
  Future<void> delete(int id) async {
    // capture_blocks and session_events cascade (ADR-008 §4, ADR-016 §4).
    await (_db.delete(_db.sessionLogs)..where((t) => t.id.equals(id))).go();
  }

  /// Loads the session, applies [write] in one transaction and returns the
  /// result. [write] throws [SessionStateError] to refuse.
  Future<Session> _change(
    int id,
    Future<void> Function(Session current) write,
  ) async {
    await _db.transaction(() async {
      final current = await get(id);
      if (current == null) throw SessionStateError('No session $id.');
      await write(current);
    });
    return (await get(id))!;
  }

  static void _requirePlanEditable(Session s) {
    if (!s.planEditable) {
      throw SessionStateError(
        s.legacy
            ? 'A legacy session is read-only.'
            : 'The plan of a ${s.status.name} session is frozen.',
      );
    }
  }

  static void _requireTransition(Session s, SessionStatus to) {
    if (s.legacy || !SessionLifecycle.canTransition(s.status, to)) {
      throw SessionStateError(
        'A ${s.legacy ? 'legacy' : s.status.name} session cannot become '
        '${to.name}.',
      );
    }
  }

  /// Blocks first, then the row — so a failing row write (for example a
  /// reference to a deleted rig) rolls the blocks back too.
  Future<void> _writePlan(
    int id,
    SessionPlan plan,
    SessionLogsCompanion extra,
  ) async {
    await (_db.delete(
      _db.captureBlocks,
    )..where((t) => t.sessionLogId.equals(id))).go();
    await _insertBlocks(id, plan.blocks);
    await _writeRow(
      id,
      extra.copyWith(
        targetName: Value(plan.targetLabel),
        equipmentName: Value(plan.rigLabel),
        sessionDate: Value(_labelDate(plan.eveningDate)),
        locationName: Value(plan.siteLabel),
        plannedLightFrames: Value(plan.lightFrameCount),
        eveningDate: Value(plan.eveningDate.toIso8601String()),
        timeZoneId: Value(plan.timeZoneId),
        siteId: Value(plan.siteId),
        targetId: Value(plan.targetId),
        rigId: Value(plan.rigId),
      ),
    );
  }

  Future<void> _writeRow(int id, SessionLogsCompanion values) async {
    await (_db.update(_db.sessionLogs)..where((t) => t.id.equals(id))).write(
      values.copyWith(updatedAtUtcMs: Value(_nowMs)),
    );
  }

  /// The pre-v16 `session_date` label: UTC midnight of the evening date. New
  /// code never reads it; the night key is `evening_date` (ADR-014 §10).
  static DateTime _labelDate(CalendarDate d) =>
      DateTime.utc(d.year, d.month, d.day);

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

  // Reads ---------------------------------------------------------------------

  @override
  Future<Session?> get(int id) async {
    final row = await (_db.select(
      _db.sessionLogs,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final blocks = await _blocksFor([id]);
    return _toSession(row, blocks[id] ?? const []);
  }

  @override
  Future<List<Session>> list({
    Set<SessionStatus>? statuses,
    CalendarDate? eveningDate,
    int? targetId,
    bool includeLegacy = true,
  }) async {
    final query = _db.select(_db.sessionLogs);
    query.where((t) {
      Expression<bool> e = const Constant(true);
      if (statuses != null) {
        e = e & t.status.isIn([for (final s in statuses) s.name]);
      }
      if (eveningDate != null) {
        e = e & t.eveningDate.equals(eveningDate.toIso8601String());
      }
      if (targetId != null) e = e & t.targetId.equals(targetId);
      if (!includeLegacy) {
        e = e & t.legacy.equals(false) & t.eveningDate.isNotNull();
      }
      return e;
    });
    query.orderBy([
      (t) => OrderingTerm(
        expression: t.updatedAtUtcMs,
        mode: OrderingMode.desc,
        nulls: NullsOrder.last,
      ),
      (t) => OrderingTerm.desc(t.id),
    ]);
    final rows = await query.get();
    final blocks = await _blocksFor([for (final r in rows) r.id]);
    return [for (final r in rows) _toSession(r, blocks[r.id] ?? const [])];
  }

  @override
  Future<Session?> mostRecentOpen() async {
    final open = await list(
      statuses: {
        SessionStatus.draft,
        SessionStatus.planned,
        SessionStatus.inProgress,
      },
      includeLegacy: false,
    );
    return open.isEmpty ? null : open.first;
  }

  Future<Map<int, List<domain.CaptureBlock>>> _blocksFor(List<int> ids) async {
    if (ids.isEmpty) return const {};
    final rows =
        await (_db.select(_db.captureBlocks)
              ..where((t) => t.sessionLogId.isIn(ids))
              ..orderBy([
                (t) => OrderingTerm.asc(t.position),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    final out = <int, List<domain.CaptureBlock>>{};
    for (final b in rows) {
      final block = _toDomainBlock(b);
      if (block == null) continue;
      out.putIfAbsent(b.sessionLogId, () => []).add(block);
    }
    return out;
  }

  static DateTime? _instant(int? ms) =>
      ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

  static Session _toSession(SessionLog row, List<domain.CaptureBlock> blocks) {
    final plan = SessionSnapshot.tryRead(row.planSnapshot);
    final start = SessionSnapshot.tryRead(row.executionStartSnapshot);
    return Session(
      record: domain.SessionLog(
        id: row.id,
        targetName: row.targetName,
        equipmentName: row.equipmentName,
        sessionDate: row.sessionDate,
        captureBlocks: blocks,
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
      status: SessionStatus.parse(row.status),
      // A row without a night key (saved between v16 and TASK 11.3, TD-052)
      // is read like a legacy row: read-only, shown from its labels.
      legacy: row.legacy || row.eveningDate == null,
      eveningDate: row.eveningDate == null
          ? null
          : CalendarDate.parse(row.eveningDate!),
      timeZoneId: row.timeZoneId,
      siteId: row.siteId,
      targetId: row.targetId,
      rigId: row.rigId,
      createdAtUtc: _instant(row.createdAtUtcMs),
      updatedAtUtc: _instant(row.updatedAtUtcMs),
      plannedAtUtc: _instant(row.plannedAtUtcMs),
      startedAtUtc: _instant(row.startedAtUtcMs),
      completedAtUtc: _instant(row.completedAtUtcMs),
      planSnapshot: plan,
      executionStartSnapshot: start,
      hasUnreadableSnapshot:
          (row.planSnapshot != null && plan == null) ||
          (row.executionStartSnapshot != null && start == null),
    );
  }

  /// A stored block as a domain block, or null (logged) when it holds values
  /// the domain rejects — never silently read as a light frame (TASK 5.3).
  static domain.CaptureBlock? _toDomainBlock(CaptureBlock b) {
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
