// TASK 13.4: reconciliation. The results page adjusts counts (stored
// events), validates optional conditions, completes or abandons a run, and
// corrects a completed one; Sessions shows planned vs actual integration
// (acceptance) with "Edit results".

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
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/no_snapshot_weather.dart';
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

void main() {
  late AppDatabase database;
  late DriftSessionRepository sessions;
  late PlannerHarness vm;
  late _Clock clock;
  late int runId;
  late int lightId;

  /// A running session: 24 × 300 s lights (2 h), 10 confirmed.
  Future<void> open(WidgetTester tester, {bool complete = false}) async {
    tester.view.physicalSize = const Size(800, 2000);
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
      final started = await vm.analysis.startSession();
      runId = started.id;
      lightId = started.blocks.single.id;
      await sessions.record(
        runId,
        ExecutionEventKind.framesConfirmed,
        blockId: lightId,
        delta: 10,
      );
      if (complete) await sessions.complete(runId);
      await vm.execution!.loadActive();
    });
    addTearDown(() => tester.runAsync(database.close));
    AppRouter.router.go(
      complete ? AppRouter.sessions : AppRouter.results(runId),
    );
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  Future<void> tap(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await settle(tester);
  }

  Future<Session> stored(WidgetTester tester) async =>
      (await tester.runAsync(() => sessions.get(runId)))!;

  testWidgets('the page shows planned vs actual and the counts', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Integration: 50 min of 2 h planned'), findsOneWidget);
    expect(find.text('42 % of the plan'), findsOneWidget);
    expect(find.text('Confirmed: 10'), findsOneWidget);
    expect(find.text('Complete session'), findsOneWidget);
  });

  testWidgets('a stepper stores an event and updates the summary', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, 'results.confirmed.plus.$lightId');
    await tap(tester, 'results.rejected.plus.$lightId');
    expect(find.text('Confirmed: 11'), findsOneWidget);
    expect(find.text('Rejected: 1'), findsOneWidget);
    expect(find.text('Integration: 55 min of 2 h planned'), findsOneWidget);
    final events = await tester.runAsync(() => sessions.events(runId));
    expect(events!.last.kind, ExecutionEventKind.framesRejected);
  });

  testWidgets('conditions are optional and checked', (tester) async {
    await open(tester);
    await tester.enterText(find.byKey(const Key('results.humidity')), '140');
    await tap(tester, 'results.save');
    expect(find.text('Between 0 and 100 %.'), findsOneWidget);
    expect((await stored(tester)).status, SessionStatus.inProgress);
  });

  testWidgets('Complete stores notes and conditions and completes the run', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(
      find.byKey(const Key('results.environment')),
      'Wind after 23:00',
    );
    await tester.enterText(find.byKey(const Key('results.temperature')), '-3');
    await tap(tester, 'results.save');
    final s = await stored(tester);
    expect(s.status, SessionStatus.completed);
    expect(s.record.environmentalNotes, 'Wind after 23:00');
    expect(s.record.temperature, -3);
    expect(s.record.humidity, isNull, reason: 'left empty, not 0');
    expect(s.record.actualLightFrames, 10);
    expect(find.text('Sessions'), findsWidgets);
  });

  testWidgets('Abandon asks, then abandons', (tester) async {
    await open(tester);
    await tap(tester, 'results.abandon');
    await tap(tester, 'results.confirmAbandon');
    expect((await stored(tester)).status, SessionStatus.abandoned);
  });

  testWidgets('acceptance: a completed session shows planned vs actual in '
      'Sessions; Edit results corrects it with a timestamped event', (
    tester,
  ) async {
    await open(tester, complete: true);
    expect(find.byKey(Key('logbook.integration.$runId')), findsOneWidget);
    expect(find.text('Integration: 50 min of 2 h planned'), findsOneWidget);

    await tap(tester, 'logbook.editResults.$runId');
    expect(find.text('Save results'), findsOneWidget);
    expect(
      find.text('Corrections are stored with the time they were made.'),
      findsOneWidget,
    );
    await tap(tester, 'results.confirmed.minus.$lightId');
    final events = await tester.runAsync(() => sessions.events(runId));
    expect(events![events.length - 2].kind, ExecutionEventKind.finished);
    expect(events.last.kind, ExecutionEventKind.framesConfirmed);
    expect(events.last.delta, -1);
    expect((await stored(tester)).record.actualLightFrames, 9);
  });
}

/// Pumps fixed frames with real-time gaps (database writes; TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
