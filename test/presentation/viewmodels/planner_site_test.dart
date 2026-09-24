// TASK 7.1 acceptance: no code path writes into a saved site without an
// explicit user action; the active site's IANA zone drives the night and the
// display; the transient position never becomes a site.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/location_service.dart';

import '../../support/planner_harness.dart';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_location_service.dart';
import '../../support/no_snapshot_weather.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

/// Counts every write while delegating to the real Drift repository.
class _SpyLocations extends DriftLocationRepository {
  _SpyLocations(super.db);
  int inserts = 0;
  int updates = 0;
  final updated = <domain.LocationProfile>[];

  @override
  Future<int> insertLocation(domain.LocationProfile location) {
    inserts++;
    return super.insertLocation(location);
  }

  @override
  Future<void> updateLocation(domain.LocationProfile location) {
    updates++;
    updated.add(location);
    return super.updateLocation(location);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late _SpyLocations locations;
  late int siteId;

  Future<PlannerHarness> build({LocationService? gps}) async {
    final vm = PlannerHarness(
      DriftTargetRepository(database),
      DriftEquipmentRepository(database),
      _NoWeather(),
      locations,
      locationService: gps ?? FakeLocationService(),
      clock: FixedClock(DateTime.utc(2026, 9, 22, 6)), // 20:00 Sep 22 (+14)
    );
    await vm.ready;
    return vm;
  }

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    locations = _SpyLocations(database);
    siteId = await locations.insertLocation(
      domain.LocationProfile(
        id: 0,
        name: 'Kiritimati',
        latitude: 1.8721,
        longitude: -157.4278,
        elevation: 3,
        timeZoneId: 'Pacific/Kiritimati',
      ),
    );
    locations.inserts = 0;
    SharedPreferences.setMockInitialValues({'activeLocationId': siteId});
  });

  tearDown(() async => database.close());

  test(
    'the active site\'s IANA zone drives the night and the display',
    () async {
      final vm = await build();
      expect(vm.activeSite?.name, 'Kiritimati');
      expect(vm.displayZoneId, 'Pacific/Kiritimati');
      // ADR-007 L1 fixed: the civil evening date, not the mean-solar Sep 21.
      expect(vm.eveningDate, CalendarDate(2026, 9, 22));
      expect(vm.sessionNight!.timeContextId, 'Pacific/Kiritimati');
    },
  );

  test(
    'a map pick is transient: no site write, site deselected, zone gone',
    () async {
      final vm = await build();
      await vm.setLocation(48.8566, 2.3522);
      await Future<void>.delayed(Duration.zero);

      expect(locations.inserts, 0);
      expect(locations.updates, 0);
      expect(vm.activeSite, isNull);
      expect(vm.displayZoneId, isNull);
      expect(vm.sessionNight!.timeContextId, 'solar');
      // TASK 7.4 removed the online Bortle scraper (PD-05). Before 7.4 this
      // test's fake scraper answered 5 and the test asserted that the value
      // was held in memory only; now nothing is fetched, so a new position
      // has an unknown Bortle class.
      expect(vm.bortleClass, isNull);
      final site = await locations.getLocationById(siteId);
      expect(site!.latitude, 1.8721);
      expect(site.bortleClass, isNull);
    },
  );

  test('GPS on first launch creates no site', () async {
    SharedPreferences.setMockInitialValues({});
    final vm = await build(
      gps: FakeLocationService(
        location: const DeviceLocation(latitude: 45, longitude: 7),
      ),
    );
    await vm.useCurrentLocation();
    expect(locations.inserts, 0);
    expect(locations.updates, 0);
    expect(vm.latitude, 45);
    expect(vm.activeSite, isNull);
  });

  test(
    'an explicit Bortle edit is the one write, with source and date',
    () async {
      final vm = await build();
      await vm.setBortleClass(3);
      expect(locations.updates, 1);
      final written = locations.updated.single;
      expect(written.bortleClass, 3);
      expect(written.bortleSource, 'user');
      expect(written.bortleDate, CalendarDate(2026, 9, 22));
      expect((await locations.getLocationById(siteId))!.bortleClass, 3);

      await vm.setBortleClass(null); // back to unknown
      final cleared = (await locations.getLocationById(siteId))!;
      expect(cleared.bortleClass, isNull);
      expect(cleared.bortleSource, isNull);
    },
  );

  // TASK 10.3 (ADR-013 §6): the fixed Moon > 0.8 / Bortle >= 7 sky warning
  // was removed; Bortle is context only (see planner_sky_darkness_test).
}
