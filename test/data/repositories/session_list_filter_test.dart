// TASK 14.1: the Sessions list's filters run in the query — status,
// target, site and a night date range; legacy rows (no night key) match
// the date range by their stored date, and never a site or target filter.

import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftSessionRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftSessionRepository(db);
    await db.customStatement('PRAGMA foreign_keys = OFF;');
    // A legacy log stored on 2026-01-10 (local), and four new sessions.
    final legacyDate = DateTime(2026, 1, 10, 22).millisecondsSinceEpoch ~/ 1000;
    await db.customStatement(
      "INSERT INTO session_logs (id, target_name, equipment_name, "
      "session_date, planned_light_frames, status, legacy, evening_date, "
      "site_id, target_id) VALUES "
      "(1, 'M31', 'Rig', $legacyDate, 10, 'completed', 1, NULL, NULL, NULL), "
      "(2, 'M42', 'Rig', 0, 10, 'planned', 0, '2026-01-05', 7, 42), "
      "(3, 'M42', 'Rig', 0, 10, 'completed', 0, '2026-01-10', 7, 42), "
      "(4, 'M45', 'Rig', 0, 10, 'completed', 0, '2026-01-12', 8, 45), "
      "(5, 'M45', 'Rig', 0, 10, 'abandoned', 0, '2026-02-01', 8, 45);",
    );
  });
  tearDown(() => db.close());

  Future<List<int>> ids({
    Set<SessionStatus>? statuses,
    int? targetId,
    int? siteId,
    CalendarDate? from,
    CalendarDate? to,
  }) async => [
    for (final s in await repo.list(
      statuses: statuses,
      targetId: targetId,
      siteId: siteId,
      from: from,
      to: to,
    ))
      s.id,
  ]..sort();

  test('no filter: everything', () async {
    expect(await ids(), [1, 2, 3, 4, 5]);
  });

  test('status', () async {
    expect(await ids(statuses: {SessionStatus.completed}), [1, 3, 4]);
    expect(
      await ids(statuses: {SessionStatus.planned, SessionStatus.abandoned}),
      [2, 5],
    );
  });

  test('target and site never match a legacy row', () async {
    expect(await ids(targetId: 42), [2, 3]);
    expect(await ids(siteId: 8), [4, 5]);
    expect(await ids(siteId: 7, targetId: 45), isEmpty);
  });

  test('night range, inclusive; legacy by its stored date', () async {
    expect(
      await ids(from: CalendarDate(2026, 1, 10), to: CalendarDate(2026, 1, 12)),
      [1, 3, 4],
    );
    expect(await ids(from: CalendarDate(2026, 1, 11)), [4, 5]);
    expect(await ids(to: CalendarDate(2026, 1, 9)), [2]);
  });

  test('filters combine', () async {
    expect(
      await ids(
        statuses: {SessionStatus.completed},
        from: CalendarDate(2026, 1, 11),
      ),
      [4],
    );
  });
}
