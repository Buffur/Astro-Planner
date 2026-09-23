// TASK 7.3: managing and switching saved sites through the ViewModel.
//
// Covers:
//   - acceptance: switching sites changes all night times (night window,
//     twilight timeline, display zone);
//   - the selection persists across a restart;
//   - saving a new site activates it; editing the active site applies at
//     once; editing another site leaves the active one alone;
//   - deleting the active site keeps its position as the transient position
//     (owner decision) and drops its zone; deleting another site changes
//     nothing else;
//   - an active site shows its own name and is not reverse-geocoded;
//   - the device zone is only a pass-through for the editor.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/night_timeline.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/viewmodels/planner_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/no_snapshot_weather.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

domain.LocationProfile _site(
  String name,
  double lat,
  double lon,
  String? zone, {
  int id = 0,
}) => domain.LocationProfile(
  id: id,
  name: name,
  latitude: lat,
  longitude: lon,
  elevation: 300,
  timeZoneId: zone,
);

DateTime? _astronomicalDusk(NightTimeline? timeline) =>
    switch (timeline?.astronomicalTwilight) {
      SunCrossing(:final duskUtc) => duskUtc,
      _ => null,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late DriftLocationRepository locations;
  late FakeReverseGeocoder geocoder;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase(NativeDatabase.memory());
    locations = DriftLocationRepository(database);
    geocoder = FakeReverseGeocoder();
  });

  tearDown(() => database.close());

  Future<PlannerViewModel> build() async {
    final vm = PlannerViewModel(
      DriftTargetRepository(database),
      DriftEquipmentRepository(database),
      _NoWeather(),
      locations,
      locationService: FakeLocationService(),
      reverseGeocoder: geocoder,
      deviceTimeZone: FakeDeviceTimeZone('Europe/Ljubljana'),
      clock: FixedClock(DateTime.utc(2026, 9, 23, 12)),
    );
    await vm.ready;
    return vm;
  }

  test('switching sites changes all night times (acceptance)', () async {
    final ljubljana = await locations.insertLocation(
      _site('Ljubljana', 46.05, 14.51, 'Europe/Ljubljana'),
    );
    final sanFrancisco = await locations.insertLocation(
      _site('San Francisco', 37.77, -122.42, 'America/Los_Angeles'),
    );
    final vm = await build();
    expect(vm.sites, hasLength(2));

    await vm.selectSite(ljubljana);
    final nightA = vm.sessionNight!;
    final duskA = _astronomicalDusk(vm.nightTimeline)!;
    expect(vm.displayZoneId, 'Europe/Ljubljana');

    await vm.selectSite(sanFrancisco);
    final nightB = vm.sessionNight!;
    final duskB = _astronomicalDusk(vm.nightTimeline)!;

    expect(vm.displayZoneId, 'America/Los_Angeles');
    expect(nightB.timeContextId, 'America/Los_Angeles');
    expect(nightB.startUtc, isNot(nightA.startUtc));
    // About nine hours of longitude apart: dusk moves by hours, not minutes.
    expect(duskB.difference(duskA).inHours.abs(), greaterThanOrEqualTo(6));
    expect(vm.latitude, 37.77);
  });

  test('the selection persists across a restart', () async {
    await locations.insertLocation(_site('A', 46.05, 14.51, null));
    final b = await locations.insertLocation(_site('B', 45.5, 13.7, null));
    final vm = await build();

    await vm.selectSite(b);

    final again = await build();
    expect(again.activeSite?.id, b);
    expect(again.latitude, 45.5);
    expect(again.isDefaultLocation, isFalse);
  });

  test('a newly saved site becomes the active one', () async {
    final vm = await build();
    expect(vm.isDefaultLocation, isTrue);

    final id = await vm.saveSite(
      _site('Backyard', 46.05, 14.51, 'Europe/Ljubljana'),
    );

    expect(vm.sites.single.id, id);
    expect(vm.activeSite?.id, id);
    expect(vm.isDefaultLocation, isFalse);
    expect(vm.displayZoneId, 'Europe/Ljubljana');
  });

  test('editing the active site applies at once', () async {
    final id = await locations.insertLocation(_site('A', 46.05, 14.51, null));
    final vm = await build();
    await vm.selectSite(id);

    await vm.saveSite(_site('A', 45.0, 13.0, 'Europe/Rome', id: id));

    expect(vm.latitude, 45.0);
    expect(vm.displayZoneId, 'Europe/Rome');
    expect(vm.activeSite?.timeZoneId, 'Europe/Rome');
  });

  test('editing another site leaves the active one alone', () async {
    final a = await locations.insertLocation(_site('A', 46.05, 14.51, null));
    final b = await locations.insertLocation(_site('B', 45.5, 13.7, null));
    final vm = await build();
    await vm.selectSite(a);

    await vm.saveSite(_site('B renamed', 45.5, 13.7, null, id: b));

    expect(vm.activeSite?.id, a);
    expect(vm.sites.map((s) => s.name), contains('B renamed'));
  });

  test('deleting the active site keeps its position, transient', () async {
    final id = await locations.insertLocation(
      _site('Doomed', 46.05, 14.51, 'Europe/Ljubljana'),
    );
    final vm = await build();
    await vm.selectSite(id);

    await vm.deleteSite(id);

    expect(vm.sites, isEmpty);
    expect(vm.activeSite, isNull);
    expect(vm.isDefaultLocation, isFalse);
    expect(vm.latitude, 46.05);
    expect(vm.longitude, 14.51);
    expect(vm.displayZoneId, isNull, reason: 'the zone was the site\'s');
    expect(vm.sessionNight, isNotNull);

    final again = await build();
    expect(again.activeSite, isNull);
    expect(again.latitude, 46.05);
  });

  test('deleting another site leaves the active one', () async {
    final a = await locations.insertLocation(_site('A', 46.05, 14.51, null));
    final b = await locations.insertLocation(_site('B', 45.5, 13.7, null));
    final vm = await build();
    await vm.selectSite(a);

    await vm.deleteSite(b);

    expect(vm.activeSite?.id, a);
    expect(vm.sites.single.id, a);
  });

  test('an active site shows its own name and is not geocoded', () async {
    final id = await locations.insertLocation(
      _site('Home', 46.05, 14.51, null),
    );
    final vm = await build();

    await vm.selectSite(id);

    expect(vm.locationName, 'Home');
    expect(vm.locationNameAttribution, isNull);
    expect(geocoder.lookups, isEmpty);
  });

  test('the device zone is passed through for the editor', () async {
    final vm = await build();
    expect(await vm.deviceZoneId(), 'Europe/Ljubljana');
  });
}
