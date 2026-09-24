// TASK 15.4: the lifecycle, process-death and offline matrix — the rows
// that can run on the host. Row ids (L1–L8) match docs/TEST_PLAN.md, which
// also lists the rows covered elsewhere and the steps only a device can run.
//
// A "kill" here is what Android does under "Don't keep activities" or a
// process death: the process loses everything but the database file and
// the preferences, and main() runs again. The tests close the database and
// build a new ViewModel graph on the same file and preferences.

import 'dart:io';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/execution.dart';
import 'package:astroplan/domain/models/location_profile.dart';
import 'package:astroplan/domain/models/night_weather.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/location_service.dart';
import 'package:astroplan/domain/services/reverse_geocoder.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/drift.dart'
    show ApplyInterceptor, QueryExecutor, QueryInterceptor;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_device_time_zone.dart';
import '../support/fake_location_service.dart';
import '../support/fake_reverse_geocoder.dart';
import '../support/in_memory_display_preferences.dart';
import '../support/in_memory_first_run.dart';
import '../support/no_snapshot_weather.dart';
import '../support/planner_harness.dart';

/// No network: every forecast request fails as it does offline.
class _Offline with NoSnapshotWeather implements WeatherRepository {}

class _Clock extends Clock {
  _Clock(this.now);
  DateTime now;
  @override
  DateTime nowUtc() => now;
}

/// A disk that can fill up: while [full], every write fails as SQLite
/// does on a full disk (SQLITE_FULL).
class _Disk extends QueryInterceptor {
  bool full = false;

  Never _full() => throw SqliteException(
    extendedResultCode: 13,
    message: 'database or disk is full',
  );

  @override
  Future<int> runInsert(QueryExecutor e, String s, List<Object?> a) =>
      full ? _full() : e.runInsert(s, a);

  @override
  Future<int> runUpdate(QueryExecutor e, String s, List<Object?> a) =>
      full ? _full() : e.runUpdate(s, a);

  @override
  Future<int> runDelete(QueryExecutor e, String s, List<Object?> a) =>
      full ? _full() : e.runDelete(s, a);
}

final _ljubljana = LocationProfile(
  id: 0,
  name: 'Ljubljana',
  latitude: 46.05,
  longitude: 14.51,
  elevation: 300,
  timeZoneId: 'Europe/Ljubljana',
);

final _newYork = LocationProfile(
  id: 0,
  name: 'New York',
  latitude: 40.71,
  longitude: -74.0,
  elevation: 10,
  timeZoneId: 'America/New_York',
);

/// One app start on [db]: seeding as main() does, then the ViewModels.
Future<PlannerHarness> _boot(
  AppDatabase db, {
  required Clock clock,
  InMemoryDisplayPreferences? display,
  InMemoryFirstRun? firstRun,
  LocationService? location,
  ReverseGeocoder? geocoder,
}) async {
  await CatalogSeeder(DriftTargetRepository(db)).seedIfNeeded();
  await EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded();
  final vm = PlannerHarness(
    DriftTargetRepository(db),
    DriftEquipmentRepository(db),
    _Offline(),
    DriftLocationRepository(db),
    locationService: location ?? FakeLocationService(),
    reverseGeocoder: geocoder ?? FakeReverseGeocoder(),
    deviceTimeZone: FakeDeviceTimeZone('Europe/Ljubljana'),
    clock: clock,
    sessionRepository: DriftSessionRepository(db, clock: clock),
    displayPreferences: display,
    firstRun: firstRun ?? InMemoryFirstRun(done: true),
  );
  await vm.ready;
  await vm.theme.load();
  await vm.tonight.load();
  await vm.resumeRun?.load();
  await vm.execution?.loadActive();
  return vm;
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _pumpApp(WidgetTester tester, PlannerHarness vm) async {
  await tester.pumpWidget(
    MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
  );
  await _settle(tester);
}

void _phone(WidgetTester tester, {bool landscape = false}) {
  tester.view.physicalSize = landscape
      ? const Size(915, 412)
      : const Size(412, 915);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
}

/// Every visible text, for "nothing on screen changed".
List<String> _texts(WidgetTester tester) => [
  for (final t in tester.widgetList<Text>(find.byType(Text)))
    t.data ?? t.textSpan?.toPlainText() ?? '',
];

File _dbFile() {
  final dir = Directory.systemTemp.createTempSync('astroplan_lifecycle');
  addTearDown(() => dir.deleteSync(recursive: true));
  return File('${dir.path}/app.sqlite');
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // L1 — a fresh install while offline, with location permission denied.
  testWidgets('L1: a fresh offline install starts, sets a site by typing, '
      'and plans without a network', (tester) async {
    _phone(tester);
    AppRouter.router.go(AppRouter.tonight);
    final firstRun = InMemoryFirstRun();
    late AppDatabase db;
    late PlannerHarness vm;
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      vm = await _boot(
        db,
        clock: FixedClock(DateTime.utc(2026, 11, 10, 18)),
        firstRun: firstRun,
        geocoder: FakeReverseGeocoder(
          result: const ReverseGeocodeFailed('offline'),
        ),
      );
    });
    addTearDown(() => tester.runAsync(db.close));
    await _pumpApp(tester, vm);
    expect(find.text('Welcome to AstroPlan'), findsOneWidget);

    // Location permission denied: nothing changes, the app says why.
    await tester.runAsync(() async {
      final result = await vm.site.useCurrentLocation();
      expect(result, isA<LocationUnavailable>());
    });
    expect(vm.site.isDefaultLocation, isTrue);

    await tester.tap(find.byKey(const Key('welcome.skip')));
    await _settle(tester);
    expect(find.byKey(const Key('tonight.noSite')), findsOneWidget);

    // A site typed in, offline: the night, the opportunity and the plan
    // work; the forecast says it is unavailable (never a number).
    await tester.runAsync(() async {
      await vm.site.saveSite(_ljubljana);
      await vm.plan.idle;
      await vm.conditions.idle;
    });
    await _settle(tester);
    expect(vm.plan.sessionNight, isNotNull);
    expect(vm.conditions.imagingOpportunity, isNotNull);
    expect(vm.conditions.nightWeather, isA<NightWeatherUnavailable>());
    expect(find.byKey(const Key('tonight.noSite')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  // L3 — "Don't keep activities" / a kill while planning.
  test('L3: a kill while planning restores the plan, night, target, site '
      'and field mode', () async {
    final file = _dbFile();
    final clock = FixedClock(DateTime.utc(2026, 11, 10, 18));
    final display = InMemoryDisplayPreferences();

    var db = AppDatabase(NativeDatabase(file));
    var vm = await _boot(db, clock: clock, display: display);
    await vm.site.saveSite(_ljubljana);
    await vm.plan.setTarget((await vm.vms.targetList.search('M31')).first);
    await vm.plan.setEveningDate(CalendarDate(2026, 11, 20));
    await vm.plan.addCaptureBlock(
      CaptureBlock(
        id: 0,
        frameType: FrameType.light,
        filterName: 'Ha',
        exposureTimeSeconds: 180,
        frameCount: 42,
      ),
    );
    await vm.theme.toggleFieldMode();
    await vm.plan.idle;
    String plan(PlannerHarness v) => [
      for (final b in v.plan.captureBlocks)
        '${b.frameType.name}/${b.filterName}/${b.exposureTimeSeconds}/'
            '${b.frameCount}',
    ].join(', ');
    final before = plan(vm);
    await db.close(); // the process dies

    db = AppDatabase(NativeDatabase(file));
    vm = await _boot(db, clock: clock, display: display);
    expect(vm.site.activeSite?.name, 'Ljubljana');
    expect(vm.plan.selectedTarget?.catalogId, 'M31');
    expect(vm.plan.eveningDate, CalendarDate(2026, 11, 20));
    expect(plan(vm), before);
    expect(vm.theme.isFieldMode, isTrue);
    await db.close();
  });

  // L4 — a kill during a run, running and then paused.
  test('L4: a kill during a run keeps the counts; running time follows the '
      'clock while running and stops while paused', () async {
    final file = _dbFile();
    final clock = _Clock(DateTime.utc(2026, 11, 10, 18));

    var db = AppDatabase(NativeDatabase(file));
    var vm = await _boot(db, clock: clock);
    await vm.site.saveSite(_ljubljana);
    await vm.plan.idle;
    final started = await vm.analysis.startSession();
    await vm.execution!.open(started.id);
    final block = vm.execution!.block!.id;
    await vm.execution!.confirm(5);
    final running = vm.execution!.runningTime;
    await db.close(); // killed while running

    clock.now = clock.now.add(const Duration(minutes: 30));
    db = AppDatabase(NativeDatabase(file));
    vm = await _boot(db, clock: clock);
    expect(vm.resumeRun!.offer, isNotNull); // the resume prompt is due
    expect(vm.execution!.session?.id, started.id);
    expect(vm.execution!.state!.phase, ExecutionPhase.running);
    expect(vm.execution!.state!.completedFor(block), 5);
    expect(vm.execution!.runningTime, running + const Duration(minutes: 30));
    await vm.execution!.pause();
    final paused = vm.execution!.runningTime;
    await db.close(); // killed while paused

    clock.now = clock.now.add(const Duration(hours: 1));
    db = AppDatabase(NativeDatabase(file));
    vm = await _boot(db, clock: clock);
    expect(vm.execution!.state!.phase, ExecutionPhase.paused);
    expect(vm.execution!.state!.completedFor(block), 5);
    expect(vm.execution!.runningTime, paused);
    await db.close();
  });

  group('L5: rotation and theme changes keep the state', () {
    testWidgets('typed input survives rotation, dark mode and field mode', (
      tester,
    ) async {
      _phone(tester);
      AppRouter.router.go(AppRouter.tonight);
      late AppDatabase db;
      late PlannerHarness vm;
      await tester.runAsync(() async {
        db = AppDatabase(NativeDatabase.memory());
        vm = await _boot(db, clock: FixedClock(DateTime.utc(2026, 11, 10, 18)));
        await vm.site.saveSite(_ljubljana);
      });
      addTearDown(() => tester.runAsync(db.close));
      await _pumpApp(tester, vm);
      AppRouter.router.push(AppRouter.siteEdit);
      await _settle(tester);
      final name = find.widgetWithText(TextFormField, 'Name');
      await tester.enterText(name, 'Dark field');
      await tester.pump();

      tester.view.physicalSize = const Size(915, 412); // rotate
      await _settle(tester);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await _settle(tester);
      await tester.runAsync(vm.theme.toggleFieldMode);
      await _settle(tester);
      tester.view.physicalSize = const Size(412, 915); // and back
      await _settle(tester);

      expect(find.widgetWithText(TextFormField, 'Dark field'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('every screen lays out in landscape', (tester) async {
      _phone(tester, landscape: true);
      AppRouter.router.go(AppRouter.tonight);
      late AppDatabase db;
      late PlannerHarness vm;
      late int run;
      await tester.runAsync(() async {
        db = AppDatabase(NativeDatabase.memory());
        vm = await _boot(db, clock: FixedClock(DateTime.utc(2026, 11, 10, 18)));
        await vm.site.saveSite(_ljubljana);
        await vm.plan.idle;
        run = (await vm.analysis.startSession()).id;
        await vm.execution!.open(run);
      });
      addTearDown(() => tester.runAsync(db.close));
      await _pumpApp(tester, vm);
      final problems = <String>[];
      for (final route in [
        AppRouter.tonight,
        AppRouter.candidates,
        AppRouter.sessions,
        AppRouter.library,
        AppRouter.libraryRigs,
        AppRouter.libraryTargets,
        AppRouter.librarySites,
        AppRouter.libraryProgress,
        AppRouter.settings,
        AppRouter.about,
        AppRouter.session(),
        AppRouter.siteEdit,
        AppRouter.run(run),
        AppRouter.results(run),
        AppRouter.welcome,
      ]) {
        AppRouter.router.go(route);
        await _settle(tester);
        for (var page = 0; page < 80; page++) {
          final error = tester.takeException();
          if (error != null) problems.add('$route: $error');
          final lists = find.byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          );
          if (lists.evaluate().isEmpty) break;
          final p = tester.state<ScrollableState>(lists.first).position;
          if (p.pixels >= p.maxScrollExtent) break;
          p.jumpTo((p.pixels + 300).clamp(0.0, p.maxScrollExtent));
          await tester.pump();
        }
      }
      expect(problems, isEmpty);
    });
  });

  // L6 — a time-zone change during a run. The process zone cannot change
  // inside a test, so this covers what the app controls: the tracker uses
  // the run's start snapshot (its zone and night) and UTC events, never
  // the active site or the device zone.
  testWidgets('L6: moving to another site and zone during a run changes '
      'nothing on the tracker', (tester) async {
    _phone(tester);
    AppRouter.router.go(AppRouter.tonight);
    late AppDatabase db;
    late PlannerHarness vm;
    late int run;
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      vm = await _boot(db, clock: FixedClock(DateTime.utc(2026, 11, 10, 20)));
      await vm.site.saveSite(_ljubljana);
      await vm.plan.idle;
      run = (await vm.analysis.startSession()).id;
      await vm.execution!.open(run);
      await vm.execution!.confirm(3);
    });
    addTearDown(() => tester.runAsync(db.close));
    await _pumpApp(tester, vm);
    AppRouter.router.go(AppRouter.run(run));
    await _settle(tester);
    final before = _texts(tester);
    final night = vm.execution!.session!.executionStartSnapshot!.night;

    await tester.runAsync(() async {
      await vm.site.saveSite(_newYork); // becomes the active site
      await vm.plan.idle;
    });
    await _settle(tester);
    expect(vm.site.displayZoneId, 'America/New_York');
    expect(
      vm.execution!.session!.executionStartSnapshot!.timeZoneId,
      'Europe/Ljubljana',
    );
    expect(vm.execution!.session!.executionStartSnapshot!.night, night);
    expect(_texts(tester), before);
    expect(tester.takeException(), isNull);
  });

  // L8 — low storage: the disk fills up while planning and while tracking.
  testWidgets('L8: a full disk is reported, loses nothing already stored, '
      'and the app recovers when space is freed', (tester) async {
    _phone(tester);
    AppRouter.router.go(AppRouter.tonight);
    final disk = _Disk();
    late AppDatabase db;
    late PlannerHarness vm;
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory().interceptWith(disk));
      vm = await _boot(db, clock: FixedClock(DateTime.utc(2026, 11, 10, 20)));
      await vm.site.saveSite(_ljubljana);
      await vm.plan.idle;
    });
    addTearDown(() => tester.runAsync(db.close));
    await _pumpApp(tester, vm);
    AppRouter.router.go(AppRouter.session());
    await _settle(tester);
    final light = CaptureBlock(
      id: 0,
      frameType: FrameType.light,
      exposureTimeSeconds: 60,
      frameCount: 10,
    );

    // Planning: the autosave fails and says so; Save fails and says so.
    disk.full = true;
    await tester.runAsync(() async {
      await vm.plan.addCaptureBlock(light);
      await vm.plan.idle;
    });
    await _settle(tester);
    expect(find.byKey(const Key('planner.autosaveFailure')), findsOneWidget);
    await tester.tap(find.text('Save Session'));
    await _settle(tester);
    expect(find.textContaining("Couldn't save the session"), findsOneWidget);
    await tester.pump(const Duration(seconds: 10)); // the message times out
    await _settle(tester);

    // Space freed: the next edit saves the whole plan and the banner goes.
    disk.full = false;
    await tester.runAsync(() async {
      await vm.plan.addCaptureBlock(light);
      await vm.plan.idle;
    });
    await _settle(tester);
    expect(find.byKey(const Key('planner.autosaveFailure')), findsNothing);
    final stored = await tester.runAsync(
      () => DriftSessionRepository(db).get(vm.plan.activeSessionId!),
    );
    expect(stored!.blocks.length, vm.plan.captureBlocks.length);

    // Tracking: a frame that cannot be stored is reported, not counted.
    late int run;
    await tester.runAsync(() async {
      run = (await vm.analysis.startSession()).id;
      await vm.execution!.open(run);
    });
    AppRouter.router.go(AppRouter.run(run));
    await _settle(tester);
    final counted = tester.widget<Text>(find.byKey(const Key('run.confirmed')));
    disk.full = true;
    await tester.tap(find.byKey(const Key('run.plus')));
    await _settle(tester);
    expect(find.textContaining("Couldn't record that"), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('run.confirmed'))).data,
      counted.data,
    );
    disk.full = false;
    await tester.tap(find.byKey(const Key('run.plus')));
    await _settle(tester);
    expect(vm.execution!.state!.completedFor(vm.execution!.block!.id), 1);
    expect(tester.takeException(), isNull);
  });
}
