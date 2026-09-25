// S1.3 (ENG-01 = SCI-01 = RT-01; ADR-012 §6): the forecast's age follows the
// clock — re-aged by NightClock's tick and before a snapshot, reloaded when
// the app resumes with an outdated forecast, and following the default
// night when it rolls over. The steps of the audit's probe 04/P1.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/night_weather.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/repositories/weather_snapshot_store.dart';
import 'package:astroplan/domain/services/night_weather_service.dart';
import 'package:astroplan/presentation/widgets/night_clock.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/planner_harness.dart';

class _Clock extends Clock {
  DateTime now = DateTime.utc(2026, 9, 24, 14);
  @override
  DateTime nowUtc() => now;
  void advance(Duration d) => now = now.add(d);
}

class _MemoryStore implements WeatherSnapshotStore {
  final Map<String, WeatherSnapshot> data = {};
  @override
  Future<WeatherSnapshot?> read(String key) async => data[key];
  @override
  Future<void> write(String key, WeatherSnapshot snapshot) async =>
      data[key] = snapshot;
}

class _Weather implements WeatherRepository {
  _Weather(this.clock);
  final _Clock clock;
  int calls = 0;

  @override
  Future<WeatherFetch> fetchSnapshot({
    required double latitude,
    required double longitude,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    calls++;
    return WeatherFetched(
      WeatherSnapshot(
        provider: 'open-meteo',
        model: 'best_match',
        fetchedAtUtc: clock.nowUtc(),
        latitude: latitude,
        longitude: longitude,
        hours: [WeatherHour(timeUtc: startUtc, cloudCoverPct: 20)],
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late _Clock clock;
  late _Weather weather;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    clock = _Clock();
    weather = _Weather(clock);
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
  });

  tearDown(() => db.close());

  /// The planner with a site and its forecast loaded at 14:00 UTC.
  Future<PlannerHarness> start() async {
    final vm = PlannerHarness(
      DriftTargetRepository(db),
      DriftEquipmentRepository(db),
      weather,
      DriftLocationRepository(db),
      locationService: FakeLocationService(),
      reverseGeocoder: FakeReverseGeocoder(),
      deviceTimeZone: FakeDeviceTimeZone(),
      clock: clock,
      sessionRepository: DriftSessionRepository(db, clock: clock),
      nightWeatherService: NightWeatherService(
        repository: weather,
        store: _MemoryStore(),
        clock: clock,
        model: 'best_match',
      ),
    );
    await vm.ready;
    await vm.conditions.refreshWeather();
    expect((vm.nightWeather as NightWeatherAvailable).age, WeatherAge.current);
    return vm;
  }

  NightWeatherAvailable available(PlannerHarness vm) =>
      vm.nightWeather as NightWeatherAvailable;

  group('the domain', () {
    final snapshot = WeatherSnapshot(
      provider: 'open-meteo',
      model: 'best_match',
      fetchedAtUtc: DateTime.utc(2026, 9, 24, 14),
      latitude: 46,
      longitude: 14,
      hours: const [],
    );
    final fresh = NightWeatherAvailable(
      snapshot: snapshot,
      age: WeatherAge.current,
      ageDuration: Duration.zero,
      fromCache: false,
    );

    test('at() re-ages through WeatherFreshness and keeps the rest', () {
      final later = fresh.at(DateTime.utc(2026, 9, 25, 3));
      expect(later.age, WeatherAge.stale);
      expect(later.ageDuration, const Duration(hours: 13));
      expect(later.snapshot, same(snapshot));
      expect(later.fromCache, isFalse);
    });

    test('isOutdated: aging, stale or unavailable, never idle or loading', () {
      expect(fresh.isOutdated, isFalse);
      expect(fresh.at(DateTime.utc(2026, 9, 24, 17)).isOutdated, isTrue);
      expect(
        const NightWeatherUnavailable(WeatherFailure.unavailable).isOutdated,
        isTrue,
      );
      expect(const NightWeatherIdle().isOutdated, isFalse);
      expect(const NightWeatherLoading().isOutdated, isFalse);
      expect(const NightWeatherOutOfRange().isOutdated, isFalse);
    });
  });

  test('5 h after loading, a tick shows the forecast as aging without '
      'fetching it again', () async {
    final vm = await start();
    var notified = 0;
    vm.conditions.addListener(() => notified++);

    clock.advance(const Duration(seconds: 20));
    vm.conditions.checkClock();
    expect(notified, 0, reason: 'the wording is still "just now"');

    clock.advance(const Duration(hours: 5));
    vm.conditions.checkClock();
    expect(available(vm).age, WeatherAge.aging);
    expect(available(vm).ageDuration, const Duration(hours: 5, seconds: 20));
    expect(notified, 1);
    expect(weather.calls, 1);
  });

  test('resuming with an outdated forecast reloads it; a current one is '
      'kept', () async {
    final vm = await start();
    clock.advance(const Duration(minutes: 30));
    vm.conditions.resumed();
    await vm.conditions.idle;
    expect(weather.calls, 1);

    clock.advance(const Duration(hours: 4));
    vm.conditions.resumed();
    await vm.conditions.idle;
    expect(weather.calls, 2);
    expect(available(vm).age, WeatherAge.current);
  });

  test('when the default night rolls over, the forecast follows it', () async {
    final vm = await start();
    final first = vm.sessionNight!;

    clock.now = DateTime.utc(2026, 9, 25, 15);
    vm.conditions.checkClock();
    await vm.conditions.idle;
    final next = vm.sessionNight!;
    expect(next, isNot(first));
    expect(available(vm).snapshot.hours.single.timeUtc, next.startUtc);
    expect(weather.calls, 2);
  });

  test(
    'a snapshot saved 5 h after loading records the age at saving',
    () async {
      final vm = await start();
      clock.advance(const Duration(hours: 5));
      final saved = await vm.saveSession();
      final w = saved.planSnapshot!.json['weather'] as Map<String, Object?>;
      expect(w['age'], WeatherAge.aging.name);
    },
  );

  testWidgets('NightClock ticks every minute and reloads on resume, and '
      'stops with the tree', (tester) async {
    late PlannerHarness vm;
    await tester.runAsync(() async => vm = await start());
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: const NightClock(child: SizedBox()),
      ),
    );

    clock.advance(const Duration(hours: 5));
    await tester.pump(const Duration(minutes: 1));
    expect(available(vm).age, WeatherAge.aging);
    expect(weather.calls, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.runAsync(() => vm.conditions.idle);
    expect(weather.calls, 2);
    expect(available(vm).age, WeatherAge.current);

    await tester.pumpWidget(const SizedBox());
  });
}
