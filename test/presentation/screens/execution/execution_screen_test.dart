// TASK 13.3 (ADR-016): Start and the tracking screen. Start takes the
// execution-start snapshot and the planner goes on with a copy (owner; TD-055);
// only one session in progress; the screen's states and actions; every
// action within one thumb's reach, labelled for screen readers; no overflow
// at 200 % text; keep-screen-on only when opted in and visible.

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
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';

import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/in_memory_display_preferences.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

class _Clock extends Clock {
  DateTime now = DateTime.utc(2026, 12, 15, 19);
  @override
  DateTime nowUtc() => now;
  void minutes(int m) => now = now.add(Duration(minutes: m));
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

void main() {
  late AppDatabase database;
  late DriftSessionRepository sessions;
  late PlannerHarness vm;
  late _Clock clock;
  late FakeScreenWake wake;
  late InMemoryDisplayPreferences display;

  Future<PlannerHarness> harness() async {
    final h = PlannerHarness(
      DriftTargetRepository(database),
      DriftEquipmentRepository(database),
      _NoForecast(),
      DriftLocationRepository(database),
      locationService: FakeLocationService(),
      reverseGeocoder: FakeReverseGeocoder(),
      sessionRepository: sessions,
      clock: clock,
      displayPreferences: display,
      screenWake: wake,
    );
    await h.ready;
    return h;
  }

  /// A planner with a site, M42 and a rig; one light block of 100 × 60 s.
  Future<void> setUp_() async {
    SharedPreferences.setMockInitialValues({});
    clock = _Clock();
    wake = FakeScreenWake();
    display = InMemoryDisplayPreferences();
    database = AppDatabase(NativeDatabase.memory());
    sessions = DriftSessionRepository(database, clock: clock);
    await DriftTargetRepository(database).insertTarget(_m42);
    await DriftEquipmentRepository(database).insertEquipment(_rig);
    vm = await harness();
    await vm.site.setLocation(46.05, 14.5);
    while (vm.plan.captureBlocks.isNotEmpty) {
      await vm.plan.removeCaptureBlock(0);
    }
    await vm.plan.addCaptureBlock(
      CaptureBlock(
        frameType: FrameType.light,
        filterName: 'L',
        exposureTimeSeconds: 60,
        frameCount: 100,
      ),
    );
    await vm.plan.addCaptureBlock(
      CaptureBlock(
        frameType: FrameType.dark,
        exposureTimeSeconds: 60,
        frameCount: 20,
        calibrationPolicy: CalibrationPolicy.inWindow,
      ),
    );
    await vm.plan.idle;
    await vm.conditions.idle;
  }

  group('Start (owner decisions)', () {
    setUp(setUp_);
    tearDown(() => database.close());

    test(
      'Start runs the plan and the planner goes on with a draft copy',
      () async {
        final started = await vm.analysis.startSession();
        expect(started.status, SessionStatus.inProgress);
        expect(started.executionStartSnapshot, isNotNull);
        final planning = vm.plan.activeSession!;
        expect(planning.id, isNot(started.id));
        expect(planning.status, SessionStatus.draft);
        expect(planning.blocks, hasLength(2));
        expect((await sessions.inProgress())!.id, started.id);
      },
    );

    test('a second Start is refused while one is in progress', () async {
      await vm.analysis.startSession();
      await expectLater(
        vm.analysis.startSession(),
        throwsA(isA<SessionStateError>()),
      );
    });

    test('TD-055: after a restart the planner does not edit the run', () async {
      final started = await vm.analysis.startSession();
      // Without the draft copy, the run is the most recent open session.
      await sessions.delete(vm.plan.activeSession!.id);
      await sessions.record(started.id, ExecutionEventKind.paused);
      final restarted = await harness();
      final planning = restarted.plan.activeSession!;
      expect(planning.planEditable, isTrue);
      expect(planning.id, isNot(started.id));
      await restarted.plan.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          exposureTimeSeconds: 30,
          frameCount: 5,
        ),
      );
      await restarted.plan.idle;
      final run = await sessions.get(started.id);
      expect(run!.blocks, hasLength(2), reason: 'the run is never edited');
    });
  });

  group('tracking screen', () {
    late int runId;

    Future<void> open(WidgetTester tester) async {
      await tester.runAsync(() async {
        await setUp_();
        final started = await vm.analysis.startSession();
        runId = started.id;
        await vm.execution!.open(runId);
      });
      addTearDown(() => tester.runAsync(database.close));
      AppRouter.router.go(AppRouter.run(runId));
      await tester.pumpWidget(
        MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
      );
      await settle(tester);
    }

    Future<void> tap(WidgetTester tester, String key) async {
      await tester.tap(find.byKey(Key(key)));
      await settle(tester);
    }

    testWidgets('running: block, confirmed count and the outlook', (
      tester,
    ) async {
      await open(tester);
      expect(find.text('Orion Nebula'), findsOneWidget); // the app bar
      expect(find.byKey(const Key('run.phase')), findsOneWidget);
      expect(find.textContaining('Running ·'), findsOneWidget);
      expect(find.text('0 of 100'), findsOneWidget);
      expect(find.byKey(const Key('run.outlook')), findsOneWidget);
      expect(find.textContaining('Astronomical dawn:'), findsOneWidget);
      expect(find.textContaining('Window left:'), findsOneWidget);
      expect(find.textContaining('Plan left:'), findsOneWidget);
    });

    testWidgets('+1, −1 and Reject change the stored counts', (tester) async {
      await open(tester);
      await tap(tester, 'run.plus');
      await tap(tester, 'run.plus');
      expect(find.text('2 of 100'), findsOneWidget);
      await tap(tester, 'run.minus');
      expect(find.text('1 of 100'), findsOneWidget);
      await tap(tester, 'run.reject');
      expect(find.text('1 rejected'), findsOneWidget);
      final state = await tester.runAsync(() => sessions.execution(runId));
      expect(state!.completed.values.single, 1);
      expect(state.rejected.values.single, 1);
    });

    testWidgets('Accept stores the estimate after time passes', (tester) async {
      await open(tester);
      clock.minutes(65); // 65 min / (60 s + 5 s) = 60 frames
      await tester.pump(const Duration(seconds: 31)); // the display tick
      expect(find.text('Accept 60'), findsOneWidget);
      await tap(tester, 'run.accept');
      expect(find.text('60 of 100'), findsOneWidget);
    });

    testWidgets('Pause with a reason, then Resume', (tester) async {
      await open(tester);
      await tap(tester, 'run.pauseResume');
      await tap(tester, 'run.pause.clouds');
      expect(find.text('Paused · Clouds'), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);
      await tap(tester, 'run.pauseResume');
      expect(find.textContaining('Running ·'), findsOneWidget);
    });

    testWidgets('the block sheet switches the current block', (tester) async {
      await open(tester);
      await tap(tester, 'run.block');
      await tester.tap(find.textContaining('Darks').last);
      await settle(tester);
      expect(find.text('0 of 20'), findsOneWidget);
    });

    // TASK 13.4 (owner): Finish opens reconciliation and completes nothing
    // by itself (in 13.3 it asked, then completed).
    testWidgets('Finish opens the results page; the run is not completed '
        'until Complete', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await open(tester);
      await tap(tester, 'run.more');
      await tap(tester, 'run.finish');
      expect(find.byKey(const Key('results.summary')), findsOneWidget);
      var s = await tester.runAsync(() => sessions.get(runId));
      expect(s!.status, SessionStatus.inProgress);
      await tap(tester, 'results.save');
      s = await tester.runAsync(() => sessions.get(runId));
      expect(s!.status, SessionStatus.completed);
    });

    testWidgets('keep-screen-on: off by default, opt-in, only while shown', (
      tester,
    ) async {
      await open(tester);
      expect(wake.on, isFalse);
      await tap(tester, 'run.more');
      await tap(tester, 'run.keepScreenOn');
      expect(wake.on, isTrue);
      expect(display.keepScreenOn, isTrue);
      // Leaving the screen releases it.
      await tester.tapAt(const Offset(10, 10)); // close the sheet
      await settle(tester);
      AppRouter.router.go(AppRouter.tonight);
      await settle(tester);
      expect(wake.on, isFalse);
    });

    testWidgets('acceptance: every action is in the lower half, at least '
        '48 dp tall and labelled', (tester) async {
      await open(tester);
      final screen = tester.getSize(find.byType(Scaffold).last);
      for (final (key, label) in [
        ('run.plus', 'Confirm one frame'),
        ('run.minus', 'Remove one confirmed frame'),
        ('run.reject', 'Reject one frame'),
        ('run.accept', 'Accept the estimate of 0 frames'),
        ('run.pauseResume', 'Pause the run'),
        ('run.block', 'Choose the block you are capturing'),
        ('run.more', 'Finish, abandon or keep the screen on'),
      ]) {
        final rect = tester.getRect(find.byKey(Key(key)));
        expect(rect.center.dy, greaterThan(screen.height / 2), reason: key);
        expect(rect.height, greaterThanOrEqualTo(48), reason: key);
        expect(find.bySemanticsLabel(label), findsOneWidget, reason: key);
      }
    });

    // S1.11 (UX-28): a screen reader can press every control. On Android a
    // node is clickable only when it has a tap action (TalkBack itself is a
    // Stage 11 device check).
    testWidgets('every control exposes a tap action while it can be pressed', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await open(tester);
      for (final (key, label) in [
        ('run.plus', 'Confirm one frame'),
        ('run.minus', 'Remove one confirmed frame'),
        ('run.reject', 'Reject one frame'),
        ('run.accept', 'Accept the estimate of 0 frames'),
        ('run.pauseResume', 'Pause the run'),
        ('run.block', 'Choose the block you are capturing'),
        ('run.more', 'Finish, abandon or keep the screen on'),
      ]) {
        final enabled =
            tester.widget<ButtonStyleButton>(find.byKey(Key(key))).onPressed !=
            null;
        final data = tester
            .getSemantics(find.bySemanticsLabel(label))
            .getSemanticsData();
        expect(data.hasAction(SemanticsAction.tap), enabled, reason: key);
        final flags = data.flagsCollection;
        expect(flags.isButton, isTrue, reason: key);
        expect(
          flags.isEnabled,
          enabled ? Tristate.isTrue : Tristate.isFalse,
          reason: key,
        );
      }
      // The action does what the button does.
      tester.semantics.tap(find.semantics.byLabel('Confirm one frame'));
      await settle(tester);
      expect(find.text('1 of 100'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('no overflow at 200 % text on a 360 × 640 dp phone', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await open(tester);
      await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
      await settle(tester);
      expect(tester.takeException(), isNull);
    });
  });

  group('Tonight', () {
    testWidgets('Start opens the tracker; Tonight then shows the run', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.runAsync(setUp_);
      addTearDown(() => tester.runAsync(database.close));
      AppRouter.router.go(AppRouter.tonight);
      await tester.pumpWidget(
        MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
      );
      await settle(tester);
      await tester.scrollUntilVisible(
        find.byKey(const Key('tonight.start')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('tonight.start')));
      await settle(tester);
      expect(find.byKey(const Key('run.plus')), findsOneWidget);

      await tester.pageBack();
      await settle(tester);
      await tester.scrollUntilVisible(
        find.byKey(const Key('tonight.run')),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('In progress: Orion Nebula'), findsOneWidget);
    });
  });
}

/// Pumps fixed frames with real-time gaps (database writes; TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
