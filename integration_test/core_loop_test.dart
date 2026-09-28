// TASK 15.5: the end-to-end regression suite. The core loop through the
// real UI — site → target → rig → night → opportunity → plan → save →
// execute (with a restart) → complete → log → export — and time-zone
// cases. The database is real (a SQLite file, closed and reopened for the
// restart); the network, GPS, the device zone and the share sheet are
// fakes.
//
// Run on a device or emulator:  flutter test integration_test -d <device>
// Run on the host (Dart VM):    flutter test integration_test

import 'dart:convert';
import 'dart:io';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/export/session_manifest_codec.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/execution.dart';
import 'package:astroplan/domain/models/iana_time_context.dart';
import 'package:astroplan/domain/models/location_profile.dart';
import 'package:astroplan/domain/models/night_weather.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/session_exporter.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/support/fake_device_time_zone.dart';
import '../test/support/fake_location_service.dart';
import '../test/support/fake_reverse_geocoder.dart';
import '../test/support/in_memory_display_preferences.dart';
import '../test/support/in_memory_first_run.dart';
import '../test/support/planner_harness.dart';

class _Clock extends Clock {
  _Clock(this.now);
  DateTime now;
  @override
  DateTime nowUtc() => now;
}

/// The network, faked: a clear forecast on whole UTC hours, as Open-Meteo
/// serves it.
class _FakeForecast implements WeatherRepository {
  _FakeForecast(this.clock);
  final Clock clock;

  @override
  Future<WeatherFetch> fetchSnapshot({
    required double latitude,
    required double longitude,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    final first = DateTime.utc(
      startUtc.year,
      startUtc.month,
      startUtc.day,
      startUtc.hour,
    );
    return WeatherFetched(
      WeatherSnapshot(
        provider: 'open-meteo',
        model: 'best_match',
        fetchedAtUtc: clock.nowUtc(),
        latitude: latitude,
        longitude: longitude,
        hours: [
          for (
            var t = first;
            t.isBefore(endUtc);
            t = t.add(const Duration(hours: 1))
          )
            WeatherHour(
              timeUtc: t,
              cloudCoverPct: 10,
              temperatureC: 4,
              dewPointC: -2,
              relativeHumidityPct: 65,
              windSpeedKmh: 6,
            ),
        ],
      ),
    );
  }
}

/// The share sheet, faked: keeps what would have been shared.
class _FakeShare implements SessionExporter {
  final List<List<ExportedSession>> shared = [];
  @override
  Future<void> share(List<ExportedSession> sessions) async =>
      shared.add(sessions);
}

/// One installation: a database file and the preferences outlive a
/// restart; everything else is rebuilt by [boot].
class _Device {
  _Device(this.clock, {this.deviceZone = 'Europe/Ljubljana'}) {
    final dir = Directory.systemTemp.createTempSync('astroplan_e2e');
    addTearDown(() => dir.deleteSync(recursive: true));
    file = File('${dir.path}/astroplan.sqlite');
  }

  final _Clock clock;
  final String deviceZone;
  late final File file;
  final display = InMemoryDisplayPreferences();
  final firstRun = InMemoryFirstRun();
  final share = _FakeShare();
  AppDatabase? db;
  late PlannerHarness vm;

  /// main(): open the database, seed, build the ViewModels, show the app.
  Future<void> boot(WidgetTester tester) async {
    AppRouter.router.go(AppRouter.tonight);
    await tester.runAsync(() async {
      final d = db = AppDatabase(NativeDatabase(file));
      await CatalogSeeder(DriftTargetRepository(d)).seedIfNeeded();
      await EquipmentSeeder(DriftEquipmentRepository(d)).seedIfNeeded();
      vm = PlannerHarness(
        DriftTargetRepository(d),
        DriftEquipmentRepository(d),
        _FakeForecast(clock),
        DriftLocationRepository(d),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(deviceZone),
        clock: clock,
        sessionRepository: DriftSessionRepository(d, clock: clock),
        displayPreferences: display,
        firstRun: firstRun,
        exporter: share,
      );
      await vm.ready;
      await vm.theme.load();
      await vm.tonight.load();
      await vm.resumeRun?.load();
      await vm.execution?.loadActive();
    });
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  /// The process dies: the widgets and the database connection go.
  Future<void> kill(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await vm.plan.idle;
      await db?.close();
    });
    db = null;
  }

  Future<void> close(WidgetTester tester) =>
      tester.runAsync(() async => db?.close()).then((_) {});
}

Future<void> settle(WidgetTester tester, [int rounds = 12]) async {
  for (var i = 0; i < rounds; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await settle(tester);
}

/// Track live, from the plan's ⋮ menu (S6.2; interim until P8.4).
Future<void> trackLive(WidgetTester tester) async {
  await tap(tester, find.byKey(const Key('planner.menu')));
  await tap(tester, find.byKey(const Key('planner.start')));
}

/// Scrolls the page's main list from the top until [finder] is visible.
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  final list = find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .first;
  tester.state<ScrollableState>(list).position.jumpTo(0);
  await tester.pump();
  await tester.scrollUntilVisible(finder, 300, scrollable: list);
}

/// Adds a site through the Sites screen and its editor, as a user types it.
Future<void> addSite(
  WidgetTester tester, {
  required String name,
  required String latitude,
  required String longitude,
}) async {
  AppRouter.router.go(AppRouter.librarySites);
  await settle(tester);
  await tap(tester, find.text('Add site'));
  await tester.enterText(find.widgetWithText(TextFormField, 'Name'), name);
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Latitude (°)'),
    latitude,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Longitude (°)'),
    longitude,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Elevation (m)'),
    '300',
  );
  await tap(tester, find.byTooltip('Save site'));
}

/// Picks the target and the rig through the planner's pickers.
Future<void> chooseTargetAndRig(WidgetTester tester) async {
  await tap(tester, find.textContaining('Target:'));
  expect(find.text('Select Target'), findsOneWidget);
  await tester.enterText(find.byType(TextField).first, 'Andromeda');
  await settle(tester);
  await tap(tester, find.textContaining('(M31)').first);

  // S6.6: the rig's card is titled "Rig: …".
  await scrollTo(tester, find.textContaining('Rig:'));
  await tap(tester, find.textContaining('Rig:'));
  expect(find.text('Select Equipment'), findsOneWidget);
  await tap(tester, find.textContaining('ASI2600MC').first);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('the core loop: site to export, with a restart during the '
      'run', (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // 17:00 in Ljubljana on 10 November 2026: tonight is ahead.
    final device = _Device(_Clock(DateTime.utc(2026, 11, 10, 16)));
    await device.boot(tester);
    addTearDown(() => device.close(tester));

    // First run: skipped; the site is set in the Library instead.
    expect(find.text('Welcome to Astro Planner'), findsOneWidget);
    await tap(tester, find.byKey(const Key('welcome.skip')));
    expect(find.byKey(const Key('tonight.noSite')), findsOneWidget);

    // Site.
    await addSite(
      tester,
      name: 'Dark Site',
      latitude: '46.05',
      longitude: '14.51',
    );
    final vm = device.vm;
    expect(vm.site.activeSite?.name, 'Dark Site');
    expect(vm.site.displayZoneId, 'Europe/Ljubljana'); // the device zone

    // Target and rig, in the planner.
    AppRouter.router.go(AppRouter.tonight);
    await settle(tester);
    await tap(tester, find.byKey(const Key('tonight.openPlanner')));
    expect(find.text('Plan'), findsOneWidget);
    await chooseTargetAndRig(tester);
    expect(vm.plan.selectedTarget?.catalogId, 'M31');
    expect(vm.plan.selectedEquipment?.name, contains('ASI2600MC'));

    // Night, forecast and opportunity.
    expect(vm.plan.eveningDate, CalendarDate(2026, 11, 10));
    await tester.runAsync(() => vm.conditions.idle);
    await settle(tester);
    expect(vm.conditions.nightWeather, isA<NightWeatherAvailable>());
    await scrollTo(tester, find.byKey(const Key('opportunity.window.0')));
    expect(vm.conditions.imagingOpportunity!.windows, isNotEmpty);

    // Plan: the example plan, trimmed to tonight's window, then Save.
    await tap(tester, find.text('Save plan'));
    expect(find.text('Plan saved'), findsOneWidget);

    // Execute: Track live (the plan's ⋮ menu since S6.2), three frames.
    await trackLive(tester);
    expect(find.byKey(const Key('run.confirmed')), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await tap(tester, find.byKey(const Key('run.plus')));
    }
    expect(
      tester.widget<Text>(find.byKey(const Key('run.confirmed'))).data,
      startsWith('3 of '),
    );
    final runId = device.vm.execution!.session!.id;

    // The process dies mid-run; 45 minutes later the app is opened again.
    await device.kill(tester);
    device.clock.now = device.clock.now.add(const Duration(minutes: 45));
    await device.boot(tester);
    expect(find.byKey(const Key('resumeRun.keepGoing')), findsOneWidget);
    await tap(tester, find.byKey(const Key('resumeRun.keepGoing')));
    expect(
      tester.widget<Text>(find.byKey(const Key('run.confirmed'))).data,
      startsWith('3 of '),
    );
    expect(device.vm.execution!.state!.phase, ExecutionPhase.running);

    // Complete: Finish opens the results; Complete completes.
    await tap(tester, find.byKey(const Key('run.more')));
    await tap(tester, find.byKey(const Key('run.finish')));
    expect(find.textContaining('Results · '), findsOneWidget);
    await scrollTo(tester, find.byKey(const Key('results.save')));
    await tap(tester, find.byKey(const Key('results.save')));
    expect(find.text('Session completed.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6)); // the message goes
    await settle(tester);

    // Log: the Sessions list and the detail.
    expect(find.text('Sessions'), findsWidgets);
    final stored = await tester.runAsync(
      () => DriftSessionRepository(device.db!).get(runId),
    );
    expect(stored!.status, SessionStatus.completed);
    AppRouter.router.go(AppRouter.sessionDetail(runId));
    await settle(tester);
    expect(
      find.descendant(
        of: find.byKey(const Key('detail.status')),
        matching: find.text('Completed'),
      ),
      findsOneWidget,
    );

    // Export: the manifest v2 that would be shared.
    await scrollTo(tester, find.byKey(const Key('detail.export')));
    await tap(tester, find.byKey(const Key('detail.export')));
    expect(device.share.shared, hasLength(1));
    final json = jsonDecode(
      jsonEncode(
        SessionManifestCodec.encode(
          device.share.shared.single,
          exportedAtUtc: device.clock.now,
          appVersion: 'e2e',
        ),
      ),
    ) as Map<String, Object?>;
    final session = ((json['sessions'] as List).single as Map)
        .cast<String, Object?>();
    expect(session['status'], 'completed');
    expect(session['time_zone_id'], 'Europe/Ljubljana');
    expect(session['evening_date'], '2026-11-10');
    final lights = [
      for (final b in (session['blocks'] as List).cast<Map>())
        if (b['frame_type'] == 'light') b,
    ];
    expect(lights.first['confirmed_frames'], 3);
    final back = SessionManifestCodec.decode(json);
    expect(back.sessions.single.session.id, runId);
    expect(tester.takeException(), isNull);
  });

  testWidgets('time zones: a site in another zone than the device, and a '
      'run across a DST change', (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // 21:00 on 31 October 2026 in New York (EDT, UTC−4); the device says
    // Ljubljana. New York leaves DST at 02:00 on 1 November.
    final device = _Device(
      _Clock(DateTime.utc(2026, 11, 1, 1)),
      deviceZone: 'Europe/Ljubljana',
    );
    device.firstRun.done = true;
    await device.boot(tester);
    addTearDown(() => device.close(tester));

    // The site is typed in; the zone is set to the site's, not the device's.
    await tester.runAsync(() async {
      await device.vm.site.saveSite(
        LocationProfile(
          id: 0,
          name: 'Catskills',
          latitude: 42.05,
          longitude: -74.35,
          elevation: 600,
          timeZoneId: 'America/New_York',
        ),
      );
      await device.vm.plan.idle;
    });
    await settle(tester);
    final vm = device.vm;
    expect(vm.site.displayZoneId, 'America/New_York');

    // The night is the site's civil evening (31 Oct), not the device's
    // date (1 Nov in Ljubljana), and matches an independent resolution.
    final expected = SessionNightResolver.resolveDefault(
      device.clock.now,
      latitude: 42.05,
      longitude: -74.35,
      timeContext: IanaTimeContext.tryCreate('America/New_York')!,
    );
    expect(vm.plan.sessionNight, expected);
    expect(vm.plan.eveningDate, CalendarDate(2026, 10, 31));

    // A run from 01:30 EDT to 01:30 EST: two hours of running time
    // across the change, never one or three.
    AppRouter.router.go(AppRouter.session());
    await settle(tester);
    await chooseTargetAndRig(tester);
    device.clock.now = DateTime.utc(2026, 11, 1, 5, 30); // 01:30 EDT
    // Since S6.2 Track live is offered for a saved plan.
    await tap(tester, find.text('Save plan'));
    await trackLive(tester);
    final run = vm.execution!.session!;
    expect(run.executionStartSnapshot!.timeZoneId, 'America/New_York');
    device.clock.now = DateTime.utc(2026, 11, 1, 7, 30); // 01:30 EST
    await settle(tester);
    expect(vm.execution!.runningTime, const Duration(hours: 2));

    // Exported instants are UTC; the zone travels with them.
    await device.kill(tester);
    await device.boot(tester);
    final all = await tester.runAsync(
      () => DriftSessionRepository(device.db!).list(),
    );
    final started = all!.firstWhere((s) => s.id == run.id);
    expect(started.startedAtUtc!.isUtc, isTrue);
    expect(started.startedAtUtc, DateTime.utc(2026, 11, 1, 5, 30));
    expect(started.timeZoneId, 'America/New_York');
    expect(started.eveningDate, CalendarDate(2026, 10, 31));
    expect(tester.takeException(), isNull);
  });
}
