// TD-058 (S6.2): New, Copy and Open switch the current session inside the
// autosave chain, as Save and Start do since S1.12. An edit written while
// the switch is still in the database lands in the new session, never in the
// one it replaces. Real SQLite (in memory), no injected delays.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/models/session_snapshot.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/current_session.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

CaptureBlock _light(int frames) => CaptureBlock(
  frameType: FrameType.light,
  filterName: 'L',
  exposureTimeSeconds: 300,
  frameCount: frames,
);

SessionPlan _plan(int frames) => SessionPlan(
  eveningDate: CalendarDate(2026, 12, 15),
  timeZoneId: 'Europe/Ljubljana',
  siteId: null,
  targetId: null,
  rigId: null,
  blocks: [_light(frames)],
  targetLabel: 'M42',
  rigLabel: 'Rig',
);

SessionSnapshot _snapshot() {
  final prefs = PlanningPreferences();
  final blocks = [_light(20)];
  return SessionSnapshotBuilder.build(
    takenAtUtc: DateTime.utc(2026, 12, 15, 18),
    night: SessionNight(
      eveningDate: CalendarDate(2026, 12, 15),
      startUtc: DateTime.utc(2026, 12, 15, 11),
      endUtc: DateTime.utc(2026, 12, 16, 11),
      latitude: 46.05,
      longitude: 14.51,
      timeContextId: 'Europe/Ljubljana',
    ),
    preferences: prefs,
    budget: CaptureBudgetCalculator.calculate(
      blocks: blocks,
      overheads: CaptureOverheads.fromPreferences(prefs),
    ),
    blocks: blocks,
  );
}

void main() {
  late AppDatabase db;
  late DriftSessionRepository repo;
  late CurrentSession current;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftSessionRepository(
      db,
      clock: FixedClock(DateTime.utc(2026, 12, 15, 18)),
    );
    current = CurrentSession(repo);
  });
  tearDown(() => db.close());

  List<int> frames(Session s) => [for (final b in s.blocks) b.frameCount];

  test('an edit written while New is creating its draft lands in the new '
      'draft', () async {
    final old = await current.startNew(_plan(10));
    // Edited, so the switch keeps it (S6.3 deletes an untouched draft).
    await current.write(() => _plan(10));

    final created = current.startNew(_plan(20));
    final edit = current.write(() => _plan(7)); // before New has finished
    await created;
    await edit;

    final now = current.session!;
    expect(now.id, isNot(old.id));
    expect(frames((await repo.get(now.id))!), [7], reason: 'the edit');
    expect(frames((await repo.get(old.id))!), [10], reason: 'untouched');
    expect(current.hasUnsavedChanges, isTrue);
  });

  test('an edit written while Open copies a frozen session lands in the '
      'copy', () async {
    final old = await current.startNew(_plan(10));
    // Edited, so the switch keeps it (S6.3 deletes an untouched draft).
    await current.write(() => _plan(10));
    final run = await repo.start(
      (await repo.create(_plan(20))).id,
      _snapshot(),
    );

    final adopted = current.adopt(run, () => _plan(20));
    final edit = current.write(() => _plan(7)); // before Open has finished
    await adopted;
    await edit;

    final copy = current.session!;
    expect(copy.id, isNot(old.id));
    expect(copy.id, isNot(run.id));
    expect(frames((await repo.get(copy.id))!), [7], reason: 'the edit');
    expect(frames((await repo.get(old.id))!), [10], reason: 'untouched');
    final after = (await repo.get(run.id))!;
    expect(after.status, SessionStatus.inProgress);
    expect(frames(after), [20], reason: 'a run is never edited');
  });
}
