// TASK 16.3 (owner decision, PD-12): place-name lookups are opt-in. Off by
// default, nothing is sent to Nominatim; switching on looks the chosen
// position up; switching off clears the name. The choice is saved.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/repositories/shared_prefs_privacy_preferences_repository.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/reverse_geocoder.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/in_memory_privacy_preferences.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late FakeReverseGeocoder geocoder;
  late InMemoryPrivacyPreferences privacy;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase(NativeDatabase.memory());
    geocoder = FakeReverseGeocoder(
      result: const PlaceNameFound('Ljubljana', attribution: 'OSM'),
    );
    privacy = InMemoryPrivacyPreferences();
  });

  tearDown(() => database.close());

  Future<PlannerHarness> build() async {
    final vm = PlannerHarness(
      DriftTargetRepository(database),
      DriftEquipmentRepository(database),
      _NoWeather(),
      DriftLocationRepository(database),
      locationService: FakeLocationService(),
      reverseGeocoder: geocoder,
      deviceTimeZone: FakeDeviceTimeZone('Europe/Ljubljana'),
      clock: FixedClock(DateTime.utc(2026, 9, 23, 12)),
      privacyPreferences: privacy,
    );
    await vm.ready;
    return vm;
  }

  test('the app default is off: nothing saved reads as off', () async {
    expect(
      await SharedPrefsPrivacyPreferencesRepository().loadPlaceNameLookup(),
      isFalse,
    );
  });

  test('off: a chosen position is never sent to Nominatim', () async {
    final vm = await build();
    expect(vm.settings.placeNameLookup, isFalse);
    await vm.setLocation(46.05, 14.51);
    await pumpEventQueue();
    expect(geocoder.lookups, isEmpty);
    expect(vm.site.locationName, isNull);
  });

  test('switching on looks the position up; off clears the name; the '
      'choice is saved', () async {
    final vm = await build();
    await vm.setLocation(46.05, 14.51);
    await vm.settings.setPlaceNameLookup(true);
    await pumpEventQueue();
    expect(geocoder.lookups, [(46.05, 14.51)]);
    expect(vm.site.locationName, 'Ljubljana');
    expect(privacy.placeNameLookup, isTrue);

    await vm.settings.setPlaceNameLookup(false);
    await pumpEventQueue();
    expect(vm.site.locationName, isNull);
    expect(geocoder.lookups, hasLength(1)); // nothing more was sent
    expect(privacy.placeNameLookup, isFalse);
  });

  test(
    'a saved "on" is restored at start and the position looked up',
    () async {
      privacy.placeNameLookup = true;
      final first = await build();
      await first.setLocation(46.05, 14.51); // remembered transient position
      geocoder.lookups.clear();

      final again = await build();
      await pumpEventQueue();
      expect(again.settings.placeNameLookup, isTrue);
      expect(again.site.locationName, 'Ljubljana');
      expect(geocoder.lookups, isNotEmpty);
    },
  );
}
