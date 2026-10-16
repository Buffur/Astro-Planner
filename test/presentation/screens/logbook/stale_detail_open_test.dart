// TD-063 (S8.4): opening a session from a detail page loaded before the
// session changed must decide on its stored state. Here the detail is
// loaded while the plan is Saved; the plan then gets a result elsewhere
// (another tab, or Tonight's line); "Open in planner" on the stale page must
// open a copy — never make the completed entry the planner's plan, whose
// autosave the repository would then refuse. Driven through the UI with the
// real database. (Before S8.4 the trigger was Start; it left with the
// tracker. S8.3's rule already opens an ended saved plan as a copy, so the
// case the re-read alone guards is an entry deleted meanwhile.)

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
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
  testWidgets('a stale detail page opens a copy of an entry that got a '
      'result meanwhile; later edits are kept', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    late AppDatabase db;
    late DriftSessionRepository sessions;
    late PlannerHarness vm;
    late _Clock clock;
    late int saved;
    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({});
      clock = _Clock();
      db = AppDatabase(NativeDatabase.memory());
      sessions = DriftSessionRepository(db, clock: clock);
      await DriftTargetRepository(db).insertTarget(_m42);
      await DriftEquipmentRepository(db).insertEquipment(_rig);
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoForecast(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        sessionRepository: sessions,
        clock: clock,
      );
      await vm.ready;
      await vm.choosePlan();
      await vm.site.setLocation(46.05, 14.5);
      saved = (await vm.analysis.saveSession()).id;
      await vm.lifecycle.newSession(); // the planner moves on
      await vm.plan.idle;
    });
    addTearDown(() => tester.runAsync(db.close));
    AppRouter.router.go(AppRouter.sessionDetail(saved));
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
    expect(find.text('Open in planner'), findsOneWidget, reason: 'Saved');

    // Elsewhere, after the night: the entry gets its result.
    await tester.runAsync(() async {
      clock.now = DateTime.utc(2026, 12, 16, 7);
      await sessions.recordResult(saved, const CompletedAsPlanned());
    });

    final open = find.byKey(const Key('detail.openInPlanner'));
    await tester.ensureVisible(open);
    await tester.tap(open);
    await settle(tester);

    expect(vm.plan.activeSessionId, isNot(saved));
    final entry = await tester.runAsync(() => sessions.get(saved));
    expect(entry!.status, SessionStatus.completed);
    await tester.runAsync(() async {
      await vm.plan.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          filterName: 'Ha',
          exposureTimeSeconds: 600,
          frameCount: 3,
        ),
      );
      await vm.plan.idle;
    });
    expect(vm.plan.autosaveFailure, isNull, reason: 'the edit was stored');
    final copy = await tester.runAsync(
      () => sessions.get(vm.plan.activeSessionId!),
    );
    expect(copy!.blocks.last.filterName, 'Ha');
    expect(
      (await tester.runAsync(() => sessions.get(saved)))!.blocks.length,
      entry.blocks.length,
      reason: 'the completed entry is unchanged',
    );
  });

  testWidgets('a stale detail page of an entry deleted meanwhile opens a '
      'copy; later edits are kept (the old code adopted the deleted row)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    late AppDatabase db;
    late DriftSessionRepository sessions;
    late PlannerHarness vm;
    late _Clock clock;
    late int saved;
    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({});
      clock = _Clock();
      db = AppDatabase(NativeDatabase.memory());
      sessions = DriftSessionRepository(db, clock: clock);
      await DriftTargetRepository(db).insertTarget(_m42);
      await DriftEquipmentRepository(db).insertEquipment(_rig);
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoForecast(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        sessionRepository: sessions,
        clock: clock,
      );
      await vm.ready;
      await vm.choosePlan();
      await vm.site.setLocation(46.05, 14.5);
      saved = (await vm.analysis.saveSession()).id;
      await vm.lifecycle.newSession(); // the planner moves on
      await vm.plan.idle;
    });
    addTearDown(() => tester.runAsync(db.close));
    AppRouter.router.go(AppRouter.sessionDetail(saved));
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
    expect(find.text('Open in planner'), findsOneWidget, reason: 'Saved');

    // Elsewhere, before the night ends: the entry is deleted.
    await tester.runAsync(() => sessions.delete(saved));

    final open = find.byKey(const Key('detail.openInPlanner'));
    await tester.ensureVisible(open);
    await tester.tap(open);
    await settle(tester);

    expect(vm.plan.activeSessionId, isNot(saved));
    await tester.runAsync(() async {
      await vm.plan.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          filterName: 'Ha',
          exposureTimeSeconds: 600,
          frameCount: 3,
        ),
      );
      await vm.plan.idle;
    });
    expect(vm.plan.autosaveFailure, isNull, reason: 'the edit was stored');
    final copy = await tester.runAsync(
      () => sessions.get(vm.plan.activeSessionId!),
    );
    expect(copy!.blocks.last.filterName, 'Ha');
  });
}

/// Pumps fixed frames with real-time gaps (database writes; TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
