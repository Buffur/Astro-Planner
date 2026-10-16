// TD-086 (S8V-02; I-4, SI-008): a Saved · changed entry whose saved plan
// cannot be read holds only the working edits in its row, so the result
// form shows no planned blocks, night or target from it; only Not done can
// be recorded, once the night has ended.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart' as domain;
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:astroplan/presentation/viewmodels/results_viewmodel.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

final _blocks = [
  domain.CaptureBlock(
    frameType: domain.FrameType.light,
    filterName: 'L',
    exposureTimeSeconds: 300,
    frameCount: 20,
  ),
];

SessionPlan _plan(CalendarDate night) => SessionPlan(
  eveningDate: night,
  timeZoneId: 'Europe/Ljubljana',
  siteId: null,
  targetId: null,
  rigId: null,
  blocks: _blocks,
  targetLabel: 'M42',
  rigLabel: 'Rig',
);

void main() {
  test('the form reviews nothing from the working row; Not done only, once '
      'the night has ended', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final clock = FixedClock(DateTime.utc(2026, 12, 15, 18));
    final repo = DriftSessionRepository(db, clock: clock);
    final prefs = PlanningPreferences();
    final night = CalendarDate(2026, 12, 15);
    final s = await repo.create(_plan(night));
    await repo.savePlan(
      s.id,
      _plan(night),
      SessionSnapshotBuilder.build(
        takenAtUtc: DateTime.utc(2026, 12, 15, 18),
        night: SessionNight(
          eveningDate: night,
          startUtc: DateTime.utc(2026, 12, 15, 11),
          endUtc: DateTime.utc(2026, 12, 16, 11),
          latitude: 46.05,
          longitude: 14.51,
          timeContextId: 'Europe/Ljubljana',
        ),
        preferences: prefs,
        budget: CaptureBudgetCalculator.calculate(
          blocks: _blocks,
          overheads: CaptureOverheads.fromPreferences(prefs),
          targetTransitsInWindow: false,
        ),
        blocks: _blocks,
      ),
    );
    await repo.updatePlan(s.id, _plan(night)); // an edit: Saved · changed
    await (db.update(db.sessionLogs)..where((t) => t.id.equals(s.id))).write(
      const SessionLogsCompanion(planSnapshot: Value({'v': 99})),
    );

    final vm = ResultsViewModel(repo, FixedClock(DateTime.utc(2026, 12, 18)));
    await vm.load(s.id);
    expect(vm.session!.isSavedChanged, isTrue);
    expect(vm.savedPlanUnreadable, isTrue);
    expect(vm.review, isNull);
    expect(vm.lightBlocks, isEmpty, reason: 'the working edits, not planned');
    expect(vm.onlyNotDone, isTrue);
    expect(vm.canRecord, isTrue);

    final early = ResultsViewModel(repo, clock);
    await early.load(s.id);
    expect(early.lightBlocks, isEmpty);
    expect(early.onlyNotDone, isFalse, reason: 'the night has not ended');
    expect(early.canRecord, isFalse);
  });
}
