// S8.2 (ADR-019 §3.1, §4): "How did it go?", the one result form. It reviews
// the saved plan (never the planner's state), records Completed as planned,
// Partly (typed counts, not ±1; UX-25) or Not done (an optional reason) with
// notes and conditions; Back writes nothing; a stale form writes nothing; a
// night that has not ended offers no result; a Saved · changed plan is
// settled first and the planner keeps its edits on the copy. The Logbook
// offers Record result and Edit result.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/execution.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_result.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/legacy_run.dart';
import '../../../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

class _Clock extends Clock {
  DateTime now = DateTime.utc(2026, 12, 15, 19);
  @override
  DateTime nowUtc() => now;
}

const _m42 = AstroTarget(
  id: 1,
  catalogId: 'M42',
  commonName: 'Orion Nebula',
  type: 'Nebula',
  rightAscension: 83.82,
  declination: -5.39,
);

const _rig = EquipmentProfile(
  id: 1,
  name: 'Refractor 400',
  focalRatio: 5.0,
  focalLengthMm: 400.0,
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.6,
  resolutionWidthPx: 6000,
  resolutionHeightPx: 4000,
  pixelPitchUm: 3.76,
  averageRawFileSizeMB: 50.0,
);

/// The morning after the 15 Dec night at Ljubljana (dawn about 04:50 UTC).
final _morning = DateTime.utc(2026, 12, 16, 7);

enum _Kind { run, completedRun, saved, savedChanged }

void main() {
  late AppDatabase database;
  late DriftSessionRepository sessions;
  late PlannerHarness vm;
  late _Clock clock;
  late int id;
  late int lightId;

  /// 24 × 300 s lights (2 h) of M42 at Ljubljana on 15 Dec: a run with 10
  /// confirmed, the same completed, a Saved plan, or a Saved · changed one
  /// (a Ha block added after Save). [route] opens the form, else Logbook.
  Future<void> open(
    WidgetTester tester,
    _Kind kind, {
    DateTime? at,
    bool route = true,
  }) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({});
      clock = _Clock();
      database = AppDatabase(NativeDatabase.memory());
      sessions = DriftSessionRepository(database, clock: clock);
      await DriftTargetRepository(database).insertTarget(_m42);
      await DriftEquipmentRepository(database).insertEquipment(_rig);
      vm = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _NoForecast(),
        DriftLocationRepository(database),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        sessionRepository: sessions,
        clock: clock,
      );
      await vm.ready;
      await vm.choosePlan(); // S6.8: nothing is preselected
      await vm.site.setLocation(46.05, 14.5);
      while (vm.plan.captureBlocks.isNotEmpty) {
        await vm.plan.removeCaptureBlock(0);
      }
      await vm.plan.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          filterName: 'L',
          exposureTimeSeconds: 300,
          frameCount: 24,
        ),
      );
      await vm.plan.idle;
      final Session s;
      if (kind == _Kind.run || kind == _Kind.completedRun) {
        // S8.4: a run the retired live mode left in progress.
        s = await startLegacyRun(sessions, await vm.analysis.saveSession());
        await sessions.record(
          s.id,
          ExecutionEventKind.framesConfirmed,
          blockId: s.blocks.single.id,
          delta: 10,
        );
        if (kind == _Kind.completedRun) await sessions.complete(s.id);
      } else {
        s = await vm.analysis.saveSession();
        if (kind == _Kind.savedChanged) {
          await vm.plan.addCaptureBlock(
            CaptureBlock(
              frameType: FrameType.light,
              filterName: 'Ha',
              exposureTimeSeconds: 600,
              frameCount: 6,
            ),
          );
          await vm.plan.idle;
        }
      }
      id = s.id;
      lightId = (await sessions.get(id))!.blocks.first.id;
      if (at != null) clock.now = at;
    });
    addTearDown(() => tester.runAsync(database.close));
    AppRouter.router.go(route ? AppRouter.results(id) : AppRouter.sessions);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  Future<void> tap(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.tap(find.byKey(Key(key)));
    await settle(tester);
  }

  Future<Session> stored(WidgetTester tester) async =>
      (await tester.runAsync(() => sessions.get(id)))!;

  String count(WidgetTester tester) => tester
      .widget<TextFormField>(find.byKey(Key('results.count.$lightId')))
      .controller!
      .text;

  group('a run from the live mode', () {
    testWidgets('the review, then Partly pre-filled from the confirmed '
        'counts; Save result completes it with notes and conditions', (
      tester,
    ) async {
      await open(tester, _Kind.run);
      expect(find.byKey(const Key('results.review')), findsOneWidget);
      expect(find.byKey(Key('results.planned.$lightId')), findsOneWidget);
      expect(find.text('Integration: 50 min of 2 h planned'), findsOneWidget);
      expect(count(tester), '10');
      expect(find.byKey(const Key('results.confirmed.plus.1')), findsNothing);

      await tester.enterText(
        find.byKey(const Key('results.environment')),
        'Wind after 23:00',
      );
      await tester.enterText(
        find.byKey(const Key('results.temperature')),
        '-3',
      );
      await tester.enterText(find.byKey(Key('results.count.$lightId')), '14');
      await tap(tester, 'results.save');
      final s = await stored(tester);
      expect(s.status, SessionStatus.completed);
      expect(s.resultKind, ResultKind.partly);
      expect(s.record.actualLightFrames, 14);
      expect(s.record.environmentalNotes, 'Wind after 23:00');
      expect(s.record.temperature, -3);
      expect(s.record.humidity, isNull, reason: 'left empty, not 0');
      expect(find.text('Result saved.'), findsOneWidget);
    });

    testWidgets('conditions and counts are checked; nothing is written', (
      tester,
    ) async {
      await open(tester, _Kind.run);
      await tester.enterText(find.byKey(const Key('results.humidity')), '140');
      await tap(tester, 'results.save');
      expect(find.text('Between 0 and 100 %.'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('results.humidity')), '');
      await tester.enterText(find.byKey(Key('results.count.$lightId')), '');
      await tap(tester, 'results.save');
      expect(find.text('Enter the frames you took (0 or more).'), findsWidgets);
      expect((await stored(tester)).status, SessionStatus.inProgress);
    });

    testWidgets('Not done abandons it with the chosen reason', (tester) async {
      await open(tester, _Kind.run);
      await tap(tester, 'results.outcome.notDone');
      await tap(tester, 'results.reason.clouds');
      await tap(tester, 'results.save');
      final s = await stored(tester);
      expect(s.status, SessionStatus.abandoned);
      expect(s.notDoneReason, NotDoneReason.clouds);
    });
  });

  group('a Saved plan', () {
    testWidgets('before its night ends there is no result to record', (
      tester,
    ) async {
      await open(tester, _Kind.saved, at: DateTime.utc(2026, 12, 16, 2));
      expect(find.byKey(const Key('results.review')), findsOneWidget);
      expect(find.byKey(const Key('results.notYet')), findsOneWidget);
      expect(find.byKey(const Key('results.save')), findsNothing);
    });

    testWidgets('after it: nothing is chosen for the user; Completed as '
        'planned is one choice, reported as planned', (tester) async {
      await open(tester, _Kind.saved, at: _morning);
      final save = tester.widget<FilledButton>(
        find.byKey(const Key('results.save')),
      );
      expect(save.onPressed, isNull, reason: 'no outcome chosen yet');
      await tap(tester, 'results.outcome.asPlanned');
      expect(find.byKey(const Key('results.asPlannedNote')), findsOneWidget);
      await tap(tester, 'results.save');
      final s = await stored(tester);
      expect(s.status, SessionStatus.completed);
      expect(s.resultKind, ResultKind.asPlanned);
      expect(s.record.actualLightFrames, 24);
      final kinds = (await tester.runAsync(() => sessions.events(id)))!
          .map((e) => e.kind);
      expect(kinds, [
        ExecutionEventKind.reported,
        ExecutionEventKind.framesConfirmed,
      ]);
    });

    testWidgets('Partly takes a typed number (0 allowed)', (tester) async {
      await open(tester, _Kind.saved, at: _morning);
      await tap(tester, 'results.outcome.partly');
      expect(count(tester), '24', reason: 'pre-filled from the plan');
      await tester.enterText(find.byKey(Key('results.count.$lightId')), '0');
      await tap(tester, 'results.save');
      final s = await stored(tester);
      expect(
        (s.status, s.resultKind),
        (SessionStatus.completed, ResultKind.partly),
      );
      expect(s.record.actualLightFrames, 0);
    });

    testWidgets('Back writes nothing', (tester) async {
      await open(tester, _Kind.saved, at: _morning, route: false);
      await tap(tester, 'logbook.recordResult.$id');
      await tap(tester, 'results.outcome.notDone');
      await tester.pageBack();
      await settle(tester);
      expect((await stored(tester)).status, SessionStatus.planned);
      expect(await tester.runAsync(() => sessions.events(id)), isEmpty);
    });

    testWidgets('a stale form writes nothing and says so', (tester) async {
      await open(tester, _Kind.saved, at: _morning);
      await tap(tester, 'results.outcome.asPlanned');
      await tester.runAsync(() async {
        clock.now = clock.now.add(const Duration(minutes: 1));
        await sessions.recordResult(id, const NotDone());
      });
      await tap(tester, 'results.save');
      expect(
        find.textContaining('This entry changed since you opened it.'),
        findsOneWidget,
      );
      final s = await stored(tester);
      expect((s.status, s.resultKind), (SessionStatus.abandoned, null));
    });
  });

  testWidgets('a Saved · changed plan: the form reviews what was saved; the '
      'planner keeps its edits on a copy, and nothing asks about them', (
    tester,
  ) async {
    await open(tester, _Kind.savedChanged, at: _morning);
    expect(find.byKey(const Key('results.review')), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    final entry = await stored(tester);
    expect(entry.status, SessionStatus.planned);
    expect(entry.blocks.map((b) => b.filterName), ['L']);
    expect(vm.plan.activeSessionId, isNot(id));
    expect(vm.plan.captureBlocks.map((b) => b.filterName), ['L', 'Ha']);
    expect(vm.plan.hasUnsavedChanges, isTrue);
    expect(
      find.textContaining('Ha ·'),
      findsNothing,
      reason: 'saved plan only',
    );

    await tap(tester, 'results.outcome.asPlanned');
    await tap(tester, 'results.save');
    expect((await stored(tester)).record.actualLightFrames, 24);
    final copy = await tester.runAsync(
      () => sessions.get(vm.plan.activeSessionId!),
    );
    expect(copy!.blocks.map((b) => b.filterName), ['L', 'Ha']);
  });

  group('the Logbook', () {
    testWidgets('an ended Saved plan offers Record result, on its row and '
        'on the entry, with Copy to another night and no Open', (tester) async {
      await open(tester, _Kind.saved, at: _morning, route: false);
      AppRouter.router.go(AppRouter.sessionDetail(id));
      await settle(tester);
      expect(find.byKey(const Key('detail.recordResult')), findsOneWidget);
      expect(find.byKey(const Key('detail.copy')), findsOneWidget);
      expect(find.byKey(const Key('detail.openInPlanner')), findsNothing);
      AppRouter.router.go(AppRouter.sessions);
      await settle(tester);
      await tap(tester, 'logbook.recordResult.$id');
      expect(find.byKey(const Key('results.review')), findsOneWidget);
    });

    testWidgets('acceptance: a completed session shows planned vs actual; '
        'Edit result corrects it with a timestamped event', (tester) async {
      await open(tester, _Kind.completedRun, route: false);
      expect(find.byKey(Key('logbook.integration.$id')), findsOneWidget);
      expect(find.text('Integration: 50 min of 2 h planned'), findsOneWidget);
      await tap(tester, 'logbook.editResults.$id');
      expect(count(tester), '10');
      await tester.enterText(find.byKey(Key('results.count.$lightId')), '9');
      await tap(tester, 'results.save');
      final events = (await tester.runAsync(() => sessions.events(id)))!;
      expect(events[events.length - 2].kind, ExecutionEventKind.finished);
      expect(
        (events.last.kind, events.last.delta),
        (ExecutionEventKind.framesConfirmed, -1),
      );
      expect((await stored(tester)).record.actualLightFrames, 9);
    });
  });
}

/// Pumps fixed frames with real-time gaps (database writes; TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
