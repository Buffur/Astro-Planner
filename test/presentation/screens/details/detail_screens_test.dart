// S6.5 (P6.5; UX-06, UX-10; TD-051; ADR-012; ADR-019 §5, §9): the planner
// keeps one factual row each for the night and the forecast; the Night &
// Moon and Weather details hold everything the planner used to show, with
// nothing lost; Tonight's rows open them. Through the real app, with the
// real database and a full forecast.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/shared/app_words.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_device_time_zone.dart';
import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/planner_harness.dart';

/// A whole-night forecast on whole UTC hours, as the provider serves it; or,
/// with [fail], no forecast at all.
class _Weather implements WeatherRepository {
  _Weather(this.clock, {this.fail = false});

  final Clock clock;
  final bool fail;

  @override
  Future<WeatherFetch> fetchSnapshot({
    required double latitude,
    required double longitude,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    if (fail) return const WeatherFetchFailed(WeatherFailure.unavailable);
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
              cloudCoverPct: 40,
              cloudCoverLowPct: 10,
              cloudCoverMidPct: 20,
              cloudCoverHighPct: 40,
              precipitationProbabilityPct: 5,
              windSpeedKmh: 8,
              windGustsKmh: 15,
              temperatureC: 2,
              dewPointC: -3,
              relativeHumidityPct: 70,
              visibilityM: 24000,
            ),
        ],
      ),
    );
  }
}

void main() {
  late AppDatabase db;
  late PlannerHarness vm;

  Future<void> start(
    WidgetTester tester,
    String location, {
    bool fail = false,
  }) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      await CatalogSeeder(DriftTargetRepository(db)).seedIfNeeded();
      await EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded();
      final siteId = await DriftLocationRepository(db).insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Ljubljana',
          latitude: 46.05,
          longitude: 14.51,
          elevation: 300,
          timeZoneId: 'Europe/Ljubljana',
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': siteId});
      final clock = FixedClock(DateTime.utc(2026, 11, 10, 16));
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _Weather(clock, fail: fail),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: clock,
        sessionRepository: DriftSessionRepository(db, clock: clock),
      );
      await vm.ready;
    });
    addTearDown(() => tester.runAsync(db.close));
    AppRouter.router.go(location);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
    await tester.runAsync(() => vm.conditions.idle);
    await settle(tester);
  }

  Future<void> open(WidgetTester tester, Finder row) async {
    await tester.ensureVisible(row);
    await settle(tester);
    await tester.tap(row);
    await settle(tester);
  }

  final nightRow = find.byKey(const Key('planner.night'));
  final weatherRow = find.byKey(const Key('planner.weather'));

  testWidgets('the planner keeps one factual row for the night and one for '
      'the forecast', (tester) async {
    await start(tester, AppRouter.session());
    expect(
      find.descendant(
        of: nightRow,
        matching: find.textContaining('Dark (Sun below −18°): '),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: nightRow,
        matching: find.byKey(const Key('nightSummary.moon')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: weatherRow,
        matching: find.textContaining('Cloud 40 % · Updated'),
      ),
      findsOneWidget,
    );
    // The full forecast and the night's timeline are no longer on the
    // planner; the sky darkness stays.
    expect(find.byKey(const Key('weather.hours')), findsNothing);
    expect(find.text(AppWords.astronomicalDusk), findsNothing);
    expect(find.text('Sky darkness'), findsOneWidget);
  });

  testWidgets('Night & Moon holds the dark span at the user\'s limit, the '
      'twilight names, the Moon, and the zone rule once', (tester) async {
    await start(tester, AppRouter.session());
    await open(tester, nightRow);
    expect(find.text('Night & Moon'), findsOneWidget);
    expect(find.textContaining('Night of '), findsWidgets);
    expect(find.textContaining('Times in'), findsOneWidget);
    // TD-078 (S6.16): the dark span and the Moon's up-times are the
    // summary's, once; the sections below do not repeat them.
    expect(find.byKey(const Key('nightSummary.dark')), findsOneWidget);
    expect(find.textContaining('Dark (Sun below −18°): '), findsOneWidget);
    expect(find.byKey(const Key('nightSummary.moon')), findsOneWidget);
    expect(find.textContaining('Moon up'), findsOneWidget);
    expect(find.byKey(const Key('night.dark')), findsNothing);
    expect(find.byKey(const Key('sky.moonUp')), findsNothing);
    expect(find.text('Sun and twilight'), findsOneWidget);
    expect(find.text('Moon'), findsOneWidget);
    for (final name in [
      'Sunset',
      AppWords.civilDusk,
      AppWords.nauticalDusk,
      AppWords.astronomicalDusk,
      AppWords.astronomicalDawn,
      AppWords.nauticalDawn,
      AppWords.civilDawn,
      'Sunrise',
    ]) {
      expect(find.text(name), findsOneWidget, reason: name);
    }
    expect(find.textContaining('Illumination at midnight'), findsOneWidget);

    // TD-051: the span follows the user's darkness limit.
    await tester.runAsync(
      () => vm.setPlanningPreferences(
        vm.planningPreferences.copyWith(darknessLimit: DarknessLimit.nautical),
      ),
    );
    await settle(tester);
    expect(
      find.textContaining('Dark (Sun below −12°): '),
      findsOneWidget,
      reason: 'the summary, once (TD-078)',
    );
  });

  testWidgets('Weather holds the whole forecast: hours, ranges, model, age, '
      'attribution and refresh', (tester) async {
    await start(tester, AppRouter.session());
    await open(tester, weatherRow);
    expect(find.text('Weather'), findsWidgets);
    expect(find.byKey(const Key('weatherDetail.summary')), findsOneWidget);
    expect(find.byKey(const Key('weather.span')), findsOneWidget);
    expect(find.byKey(const Key('weather.hours')), findsOneWidget);
    expect(find.byKey(const Key('weather.ranges')), findsOneWidget);
    expect(find.byKey(const Key('weather.attribution')), findsOneWidget);
    expect(find.byKey(const Key('weather.refresh')), findsOneWidget);
    expect(find.text('Model: open-meteo / best_match'), findsOneWidget);
    expect(find.textContaining('Updated'), findsWidgets);
  });

  testWidgets('without a forecast the row says why, and the detail offers '
      'Retry', (tester) async {
    await start(tester, AppRouter.session(), fail: true);
    expect(
      find.descendant(
        of: weatherRow,
        matching: find.text(
          'No forecast. Offline or the service did not answer.',
        ),
      ),
      findsOneWidget,
    );
    await open(tester, weatherRow);
    expect(find.text("Couldn't load weather."), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets("Tonight's Night, Moon and Weather rows open the details", (
    tester,
  ) async {
    await start(tester, AppRouter.tonight);
    await open(tester, find.byKey(const Key('tonight.night')));
    expect(find.text('Night & Moon'), findsOneWidget);
    AppRouter.router.go(AppRouter.tonight);
    await settle(tester);
    await open(tester, find.byKey(const Key('tonight.moon')));
    expect(find.text('Night & Moon'), findsOneWidget);
    AppRouter.router.go(AppRouter.tonight);
    await settle(tester);
    await open(tester, find.byKey(const Key('tonight.weather')));
    expect(find.byKey(const Key('weatherDetail.summary')), findsOneWidget);
  });
}

/// Pumps fixed frames with real-time gaps (database work; TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
