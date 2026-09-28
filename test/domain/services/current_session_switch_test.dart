// S6.3 (U1; W1; S4-DEF-04 = R): what replacing the current session does with
// the one it leaves. An untouched never-saved draft is deleted; an edited one
// only when the user discards it; a saved plan never. Discard on a Saved ·
// changed plan reverts it first. A copy counts as unsaved. Real SQLite.

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

SessionSnapshot _snapshot(int frames) {
  final prefs = PlanningPreferences();
  final blocks = [_light(frames)];
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

  test('an untouched never-saved draft is deleted when replaced', () async {
    final old = await current.startNew(_plan(10));
    final next = await current.startNew(_plan(20));
    expect(next.id, isNot(old.id));
    expect(await repo.get(old.id), isNull);
  });

  test('an edited never-saved draft is kept unless discarded', () async {
    final kept = await current.startNew(_plan(10));
    await current.write(() => _plan(7));
    await current.startNew(_plan(20));
    expect(await repo.get(kept.id), isNotNull, reason: 'not discarded');

    await current.write(() => _plan(8));
    final discarded = current.session!;
    await current.startNew(_plan(30), discard: true);
    expect(await repo.get(discarded.id), isNull, reason: 'Discard');
  });

  test('Discard on a Saved · changed plan reverts it; it is never '
      'deleted', () async {
    final s = await current.startNew(_plan(20));
    await current.save(_plan(20), _snapshot(20));
    await current.write(() => _plan(7));
    expect(current.session!.status, SessionStatus.draft);

    await current.revertSavedChanges();
    await current.startNew(_plan(30), discard: true);

    final after = (await repo.get(s.id))!;
    expect(after.status, SessionStatus.planned);
    expect([for (final b in after.blocks) b.frameCount], [20]);
    expect(current.session!.id, isNot(s.id));
  });

  test('a refused revert changes nothing and keeps the current plan', () async {
    final s = await current.startNew(_plan(20));
    await current.save(
      _plan(20),
      SessionSnapshot.fromBuilder({..._snapshot(20).json, 'blocks': 'junk'}),
    );
    await current.write(() => _plan(7));

    await expectLater(
      current.revertSavedChanges(),
      throwsA(isA<SavedPlanUnavailable>()),
    );
    expect(current.session!.id, s.id);
    expect(current.hasUnsavedChanges, isTrue);
    final after = (await repo.get(s.id))!;
    expect(after.status, SessionStatus.draft);
    expect([for (final b in after.blocks) b.frameCount], [7]);
  });

  test('a copy counts as unsaved at once (W1)', () async {
    await current.startNew(_plan(10));
    await current.startNew(_plan(10), unsaved: true);
    expect(current.hasUnsavedChanges, isTrue);
  });
}
