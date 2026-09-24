// TASK 9.3: the ViewModel exposes the chosen night's forecast state from
// NightWeatherService — idle without a site, available (fresh or cached
// with its age) with one, and a failed refresh keeps the cache.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/night_weather.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/repositories/weather_snapshot_store.dart';
import 'package:astroplan/domain/services/night_weather_service.dart';

import '../../support/planner_harness.dart';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';

class _Clock extends Clock {
  DateTime now = DateTime.utc(2026, 9, 24, 12);
  @override
  DateTime nowUtc() => now;
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
  bool offline = false;
  int calls = 0;

  @override
  Future<WeatherFetch> fetchSnapshot({
    required double latitude,
    required double longitude,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    calls++;
    if (offline) return const WeatherFetchFailed(WeatherFailure.unavailable);
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

  late AppDatabase database;
  late DriftLocationRepository locations;
  late _Clock clock;
  late _Weather weather;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase(NativeDatabase.memory());
    locations = DriftLocationRepository(database);
    clock = _Clock();
    weather = _Weather(clock);
  });

  tearDown(() => database.close());

  Future<PlannerHarness> build() async {
    final vm = PlannerHarness(
      DriftTargetRepository(database),
      DriftEquipmentRepository(database),
      weather,
      locations,
      locationService: FakeLocationService(),
      reverseGeocoder: FakeReverseGeocoder(),
      deviceTimeZone: FakeDeviceTimeZone(),
      clock: clock,
      nightWeatherService: NightWeatherService(
        repository: weather,
        store: _MemoryStore(),
        clock: clock,
        model: 'best_match',
      ),
    );
    await vm.ready;
    return vm;
  }

  test('without a site there is no night, so no forecast', () async {
    final vm = await build();
    await vm.refreshWeather();
    expect(vm.nightWeather, isA<NightWeatherIdle>());
    expect(weather.calls, 0);
  });

  test('with a site the night forecast loads, then comes from the cache '
      'with its age when offline', () async {
    final id = await locations.insertLocation(
      domain.LocationProfile(
        id: 0,
        name: 'Home',
        latitude: 46.05,
        longitude: 14.51,
        elevation: 300,
      ),
    );
    final vm = await build();
    await vm.selectSite(id);

    final fresh = vm.nightWeather as NightWeatherAvailable;
    expect(fresh.fromCache, isFalse);
    expect(fresh.snapshot.hours.single.timeUtc, vm.sessionNight!.startUtc);

    weather.offline = true;
    clock.now = clock.now.add(const Duration(hours: 6));
    await vm.refreshWeather();
    final cached = vm.nightWeather as NightWeatherAvailable;
    expect(cached.fromCache, isTrue);
    expect(cached.age, WeatherAge.aging);
    expect(cached.ageDuration, const Duration(hours: 6));
    expect(cached.refreshFailed, WeatherFailure.unavailable);
  });
}
