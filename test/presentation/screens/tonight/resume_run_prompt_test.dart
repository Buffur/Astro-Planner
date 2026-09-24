// The resume prompt at start (TASK 13.2, ADR-016 §5): a session left in
// progress is offered to keep going, pause, finish or abandon; a finished
// night is flagged; nothing changes without an answer; no prompt when
// nothing is in progress.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/execution.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

class _Clock extends Clock {
  DateTime now = DateTime.utc(2026, 12, 15, 19);
  @override
  DateTime nowUtc() => now;
}

final _light = CaptureBlock(
  frameType: FrameType.light,
  filterName: 'L',
  exposureTimeSeconds: 60,
  frameCount: 100,
);

final _night = SessionNight(
  eveningDate: CalendarDate(2026, 12, 15),
  startUtc: DateTime.utc(2026, 12, 15, 11),
  endUtc: DateTime.utc(2026, 12, 16, 11),
  latitude: 46.05,
  longitude: 14.51,
  timeContextId: 'Europe/Ljubljana',
);

void main() {
  late AppDatabase database;
  late DriftSessionRepository sessions;
  late PlannerHarness vm;
  late _Clock clock;
  late int sessionId;

  /// A session started at 19:00 UTC, the app restarted at [restartAt].
  Future<void> start(
    WidgetTester tester, {
    required DateTime restartAt,
    bool inProgress = true,
    bool paused = false,
  }) async {
    AppRouter.router.go(AppRouter.tonight);
    SharedPreferences.setMockInitialValues({});
    clock = _Clock();
    await tester.runAsync(() async {
      database = AppDatabase(NativeDatabase.memory());
      sessions = DriftSessionRepository(database, clock: clock);
      final s = await sessions.create(
        SessionPlan(
          eveningDate: CalendarDate(2026, 12, 15),
          timeZoneId: null,
          siteId: null,
          targetId: null,
          rigId: null,
          blocks: [_light],
          targetLabel: 'M42',
          rigLabel: 'Rig',
        ),
      );
      sessionId = s.id;
      if (inProgress) {
        final prefs = PlanningPreferences();
        await sessions.start(
          s.id,
          SessionSnapshotBuilder.build(
            takenAtUtc: clock.now,
            night: _night,
            preferences: prefs,
            budget: CaptureBudgetCalculator.calculate(
              blocks: [_light],
              overheads: CaptureOverheads.fromPreferences(prefs),
              targetTransitsInWindow: false,
            ),
            blocks: [_light],
          ),
        );
        if (paused) {
          clock.now = clock.now.add(const Duration(minutes: 10));
          await sessions.record(s.id, ExecutionEventKind.paused);
        }
      }
      clock.now = restartAt;
      vm = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _NoForecast(),
        DriftLocationRepository(database),
        locationService: FakeLocationService(),
        sessionRepository: sessions,
        clock: clock,
      );
      await vm.ready;
      await vm.resumeRun!.load(); // as main.dart does before runApp
    });
    addTearDown(() => tester.runAsync(database.close));
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  Future<List<ExecutionEvent>> events(WidgetTester tester) async =>
      (await tester.runAsync(() => sessions.events(sessionId)))!;

  testWidgets('a run left running is offered with its time and estimate', (
    tester,
  ) async {
    // Restarted 65 min later: 65 min / (60 s + 5 s) = 60 frames estimated.
    await start(tester, restartAt: DateTime.utc(2026, 12, 15, 20, 5));
    expect(find.byKey(const Key('resumeRun.dialog')), findsOneWidget);
    expect(find.text('M42 is in progress'), findsOneWidget);
    expect(find.textContaining('Running for 1 h 5 min'), findsOneWidget);
    expect(find.textContaining('About 60 more frames (estimated)'), findsOne);
    expect(find.byKey(const Key('resumeRun.stale')), findsNothing);
    expect(await events(tester), hasLength(1), reason: 'nothing written yet');
  });

  testWidgets('Keep going changes nothing', (tester) async {
    await start(tester, restartAt: DateTime.utc(2026, 12, 15, 20));
    await tester.tap(find.byKey(const Key('resumeRun.keepGoing')));
    await settle(tester);
    expect(find.byKey(const Key('resumeRun.dialog')), findsNothing);
    expect(await events(tester), hasLength(1));
    expect(vm.resumeRun!.offer, isNull);
  });

  testWidgets('Pause now records a pause', (tester) async {
    await start(tester, restartAt: DateTime.utc(2026, 12, 15, 20));
    await tester.tap(find.byKey(const Key('resumeRun.pause')));
    await settle(tester);
    expect((await events(tester)).last.kind, ExecutionEventKind.paused);
  });

  testWidgets('Finish completes the session', (tester) async {
    await start(tester, restartAt: DateTime.utc(2026, 12, 15, 20));
    await tester.tap(find.byKey(const Key('resumeRun.finish')));
    await settle(tester);
    final s = await tester.runAsync(() => sessions.get(sessionId));
    expect(s!.status, SessionStatus.completed);
  });

  testWidgets('Abandon asks first', (tester) async {
    await start(tester, restartAt: DateTime.utc(2026, 12, 15, 20));
    await tester.tap(find.byKey(const Key('resumeRun.abandon')));
    await settle(tester);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.byKey(const Key('resumeRun.dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('resumeRun.abandon')));
    await settle(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Abandon').last);
    await settle(tester);
    final s = await tester.runAsync(() => sessions.get(sessionId));
    expect(s!.status, SessionStatus.abandoned);
  });

  testWidgets('a run past its night is flagged, never finished on its own', (
    tester,
  ) async {
    await start(tester, restartAt: DateTime.utc(2026, 12, 16, 15));
    expect(find.byKey(const Key('resumeRun.stale')), findsOneWidget);
    final s = await tester.runAsync(() => sessions.get(sessionId));
    expect(s!.status, SessionStatus.inProgress);
  });

  testWidgets('a paused run offers to keep it paused, no estimate', (
    tester,
  ) async {
    await start(
      tester,
      restartAt: DateTime.utc(2026, 12, 15, 22),
      paused: true,
    );
    expect(find.text('Paused.'), findsOneWidget);
    expect(find.byKey(const Key('resumeRun.pause')), findsNothing);
    expect(find.text('Keep paused'), findsOneWidget);
    expect(find.byKey(const Key('resumeRun.estimate')), findsNothing);
  });

  testWidgets('a clock behind the last event is flagged', (tester) async {
    await start(tester, restartAt: DateTime.utc(2026, 12, 15, 18));
    expect(find.byKey(const Key('resumeRun.clock')), findsOneWidget);
  });

  testWidgets('no prompt when nothing is in progress', (tester) async {
    await start(
      tester,
      restartAt: DateTime.utc(2026, 12, 15, 20),
      inProgress: false,
    );
    expect(find.byKey(const Key('resumeRun.dialog')), findsNothing);
  });
}

/// Pumps fixed frames with real-time gaps (database writes; TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
