// TASK 14.3: the export manifest v2. Acceptance: an exported file
// re-parses identically (encode → JSON text → decode → encode is equal).
// Also: UTC instants with the zone and night key, snapshots and events
// kept, v1 still readable, unknown versions refused, and the app version
// in step with pubspec.

import 'dart:convert';
import 'dart:io';

import 'package:astroplan/core/config/app_identity.dart';
import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/export/session_manifest_codec.dart';
import 'package:astroplan/data/export/share_session_exporter.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/execution.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_log.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/session_exporter.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

final _blocks = [
  CaptureBlock(
    frameType: FrameType.light,
    filterName: 'Ha',
    exposureTimeSeconds: 300,
    frameCount: 24,
  ),
  CaptureBlock(
    frameType: FrameType.dark,
    exposureTimeSeconds: 300,
    frameCount: 10,
    calibrationPolicy: CalibrationPolicy.inWindow,
  ),
];

void main() {
  late AppDatabase db;
  late DriftSessionRepository repo;
  final exportedAt = DateTime.utc(2026, 12, 16, 8);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftSessionRepository(
      db,
      clock: FixedClock(DateTime.utc(2026, 12, 15, 19)),
    );
  });
  tearDown(() => db.close());

  /// A completed run with events and snapshots, a planned session, a
  /// legacy log.
  Future<List<ExportedSession>> sessions() async {
    final prefs = PlanningPreferences();
    final snapshot = SessionSnapshotBuilder.build(
      takenAtUtc: DateTime.utc(2026, 12, 15, 18),
      night: SessionNight(
        eveningDate: CalendarDate(2026, 12, 15),
        startUtc: DateTime.utc(2026, 12, 15, 11),
        endUtc: DateTime.utc(2026, 12, 16, 11),
        latitude: 46.05,
        longitude: 14.51,
        timeContextId: 'Europe/Ljubljana',
      ),
      timeZoneId: 'Europe/Ljubljana',
      preferences: prefs,
      budget: CaptureBudgetCalculator.calculate(
        blocks: _blocks,
        overheads: CaptureOverheads.fromPreferences(prefs),
        targetTransitsInWindow: false,
      ),
      blocks: _blocks,
    );
    SessionPlan plan(String target) => SessionPlan(
      eveningDate: CalendarDate(2026, 12, 15),
      timeZoneId: 'Europe/Ljubljana',
      siteId: null,
      targetId: null,
      rigId: null,
      blocks: _blocks,
      targetLabel: target,
      rigLabel: 'Refractor 400',
      siteLabel: 'Home',
    );
    final run = await repo.start((await repo.create(plan('M42'))).id, snapshot);
    final light = run.blocks.first.id;
    await repo.record(
      run.id,
      ExecutionEventKind.framesConfirmed,
      blockId: light,
      delta: 12,
    );
    await repo.record(
      run.id,
      ExecutionEventKind.interrupted,
      reason: InterruptionReason.clouds,
    );
    await repo.record(
      run.id,
      ExecutionEventKind.framesRejected,
      blockId: light,
      delta: 2,
    );
    await repo.complete(run.id);
    await repo.updateResults(
      run.id,
      const SessionResults(
        actualLightFrames: 12,
        rejectedFrames: 2,
        environmentalNotes: 'Clouds at 23:00',
        temperatureC: -3.5,
      ),
    );
    final planned = await repo.savePlan(
      (await repo.create(plan('M31'))).id,
      plan('M31'),
      snapshot,
    );
    await db.customStatement(
      "INSERT INTO session_logs (id, target_name, equipment_name, "
      "session_date, planned_light_frames, actual_light_frames, status, "
      "legacy) VALUES (900, 'M45', 'Old rig', 1767225600, 40, 35, "
      "'completed', 1);",
    );
    return [
      for (final id in [run.id, planned.id, 900])
        ExportedSession((await repo.get(id))!, await repo.events(id)),
    ];
  }

  Map<String, Object?> roundTripJson(Map<String, Object?> m) =>
      jsonDecode(jsonEncode(m)) as Map<String, Object?>;

  test('acceptance: an exported file re-parses identically', () async {
    final first = SessionManifestCodec.encode(
      await sessions(),
      exportedAtUtc: exportedAt,
      appVersion: AppIdentity.version,
    );
    final read = SessionManifestCodec.decode(roundTripJson(first));
    final again = SessionManifestCodec.encode(
      read.sessions,
      exportedAtUtc: read.exportedAtUtc!,
      appVersion: read.appVersion!,
    );
    expect(roundTripJson(again), roundTripJson(first));
    expect(read.version, 2);
    expect(read.sessions, hasLength(3));
  });

  test('v2 carries UTC instants, the zone, the night key, snapshots, '
      'counts and events', () async {
    final m = roundTripJson(
      SessionManifestCodec.encode(
        await sessions(),
        exportedAtUtc: exportedAt,
        appVersion: AppIdentity.version,
      ),
    );
    expect(m['manifest_version'], 2);
    expect(m['app_version'], AppIdentity.version);
    expect(m['exported_at_utc_ms'], exportedAt.millisecondsSinceEpoch);
    final run = (m['sessions']! as List).first as Map;
    expect(run['status'], 'completed');
    expect(run['evening_date'], '2026-12-15');
    expect(run['time_zone_id'], 'Europe/Ljubljana');
    expect(run['started_at_utc_ms'], isA<int>());
    expect((run['execution_start_snapshot'] as Map)['v'], 1);
    final block = (run['blocks'] as List).first as Map;
    expect(block['confirmed_frames'], 12);
    expect(block['rejected_frames'], 2);
    expect(block['exposure_s'], 300);
    final kinds = [for (final e in run['events'] as List) (e as Map)['kind']];
    expect(kinds, [
      'started',
      'framesConfirmed',
      'interrupted',
      'framesRejected',
      'finished',
    ]);
    expect((run['results'] as Map)['temperature_c'], -3.5);
    expect((run['results'] as Map)['humidity_pct'], isNull);
    final legacy = (m['sessions']! as List).last as Map;
    expect(legacy['legacy'], isTrue);
    expect(legacy['events'], isEmpty);
  });

  test('v1 is still read, as a legacy log at the same UTC instant', () {
    final log = SessionLog(
      id: 5,
      targetName: 'M42',
      equipmentName: 'Rig',
      sessionDate: DateTime.utc(2025, 3, 1, 21),
      plannedLightFrames: 30,
      actualLightFrames: 28,
    );
    final read = SessionManifestCodec.decode(roundTripJson(log.toJson()));
    expect(read.version, 1);
    final s = read.sessions.single.session;
    expect(s.legacy, isTrue);
    expect(s.status, SessionStatus.completed);
    expect(s.record.sessionDate.toUtc(), DateTime.utc(2025, 3, 1, 21));
    expect(s.record.actualLightFrames, 28);
  });

  test('an unknown version or a malformed file is refused', () {
    expect(
      () => SessionManifestCodec.decode({'manifest_version': 3}),
      throwsFormatException,
    );
    expect(
      () => SessionManifestCodec.decode({'manifest_version': 2}),
      throwsFormatException,
    );
    expect(
      () => SessionManifestCodec.decode({
        'manifest_version': 2,
        'sessions': [
          {'id': 1, 'status': 'teleported'},
        ],
      }),
      throwsFormatException,
    );
  });

  test('the share summary names the targets', () async {
    expect(
      ShareSessionExporter.summary(await sessions()),
      'AstroPlan export: 3 sessions (M42, M31, M45). Manifest v2.',
    );
  });

  test('the app version matches pubspec.yaml', () {
    final line = File('pubspec.yaml')
        .readAsLinesSync()
        .firstWhere((l) => l.startsWith('version:'));
    expect(line.split(':')[1].trim().split('+').first, AppIdentity.version);
  });
}
