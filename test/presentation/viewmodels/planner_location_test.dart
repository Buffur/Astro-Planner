// Tests for PlannerHarness's use of the LocationService seam (TASK 1.1).
//
// Covers:
//   - `ready` completes on first launch without touching GPS
//   - permission denied / location services off (service returns null): the
//     ViewModel keeps its default coordinates, saves no location, and does not
//     throw
//   - a position from the service becomes the active location
//   - TASK 7.2: each permission outcome is reported, never silently ignored;
//     settings pages open through the service; place names come from the
//     ReverseGeocoder with their attribution; a failure leaves the name
//     unknown; a stale answer is ignored; no http/geolocator import in
//     presentation or domain

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/location_service.dart';
import 'package:astroplan/domain/services/reverse_geocoder.dart';

import '../../support/planner_harness.dart';

import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/no_snapshot_weather.dart';

class _MockWeather with NoSnapshotWeather implements WeatherRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late DriftLocationRepository locationRepo;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    locationRepo = DriftLocationRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  PlannerHarness buildViewModel(
    FakeLocationService service, {
    ReverseGeocoder? geocoder,
  }) {
    return PlannerHarness(
      DriftTargetRepository(database),
      DriftEquipmentRepository(database),
      _MockWeather(),
      locationRepo,
      locationService: service,
      reverseGeocoder: geocoder ?? FakeReverseGeocoder(),
    );
  }

  group('PlannerHarness location (TASK 1.1)', () {
    // TASK 7.3 (owner decision): the first run shows a site prompt instead
    // of silently asking for GPS. Before 7.3 this test asserted that startup
    // asked the service once; it now asserts that startup asks nothing, so
    // the permission is only requested after the user chooses to.
    test(
      'first launch, permission denied: keeps the default location',
      () async {
        SharedPreferences.setMockInitialValues(
          {},
        ); // no saved location: first launch
        final service = FakeLocationService(); // null = denied / services off

        final vm = buildViewModel(service);
        await vm.ready;

        expect(vm.isLoading, isFalse);
        expect(service.calls, 0, reason: 'startup never asks for the position');
        expect(vm.latitude, 51.5072);
        expect(vm.longitude, -0.1276);
        expect(await locationRepo.getLocations(), isEmpty);

        // Asking explicitly, denied, changes nothing and does not throw.
        await vm.useCurrentLocation();
        expect(service.calls, 1);
        expect(vm.latitude, 51.5072);
        expect(vm.longitude, -0.1276);
        expect(await locationRepo.getLocations(), isEmpty);
      },
    );

    // TASK 7.1 (owner decision): a GPS fix is a *transient* position. Before
    // 7.1 this test asserted that the fix overwrote the saved site's
    // coordinates — the defect TD-027 describes and 7.1's acceptance
    // forbids ("no code path writes into a saved site without explicit user
    // action"). It now asserts the new contract instead.
    test(
      'a position from the service becomes the transient position',
      () async {
        final locId = await locationRepo.insertLocation(
          domain.LocationProfile(
            id: 0,
            name: 'Home',
            latitude: 51.5,
            longitude: -0.1,
            elevation: 10,
          ),
        );
        // A saved location means startup does not ask the service by itself.
        SharedPreferences.setMockInitialValues({'activeLocationId': locId});
        final service = FakeLocationService(
          location: const DeviceLocation(latitude: 48.8566, longitude: 2.3522),
        );

        final vm = buildViewModel(service);
        await vm.ready;
        expect(service.calls, 0);
        expect(vm.latitude, 51.5);

        await vm.useCurrentLocation();

        expect(service.calls, 1);
        expect(vm.latitude, 48.8566);
        expect(vm.longitude, 2.3522);
        // The saved site is untouched, and no longer active.
        final saved = await locationRepo.getLocationById(locId);
        expect(saved!.latitude, 51.5);
        expect(saved.longitude, -0.1);
        expect(vm.activeSite, isNull);
        expect(await locationRepo.getLocations(), hasLength(1));
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getInt('activeLocationId'), isNull);
        // The transient position is remembered for the next launch.
        final again = buildViewModel(FakeLocationService());
        await again.ready;
        expect(again.latitude, 48.8566);
        expect(again.longitude, 2.3522);
        expect(again.activeSite, isNull);
      },
    );
  });

  group('Location and geocoding services (TASK 7.2)', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    for (final failure in LocationFailure.values) {
      test('$failure is reported and changes nothing', () async {
        final vm = buildViewModel(FakeLocationService(failure: failure));
        await vm.ready;

        final result = await vm.useCurrentLocation();

        expect(result, isA<LocationUnavailable>());
        expect((result as LocationUnavailable).reason, failure);
        expect(vm.isDefaultLocation, isTrue);
        expect(vm.latitude, 51.5072);
      });
    }

    test('granted: the fix is reported and used', () async {
      final vm = buildViewModel(
        FakeLocationService(
          location: const DeviceLocation(latitude: 46.05, longitude: 14.51),
        ),
      );
      await vm.ready;

      final result = await vm.useCurrentLocation();

      expect(result, isA<LocationFound>());
      expect(vm.latitude, 46.05);
      expect(vm.longitude, 14.51);
      expect(vm.isDefaultLocation, isFalse);
    });

    test('locateDevice previews the fix without using it', () async {
      final vm = buildViewModel(
        FakeLocationService(
          location: const DeviceLocation(latitude: 46.05, longitude: 14.51),
        ),
      );
      await vm.ready;
      await vm.setLocation(40.0, -3.7);

      final result = await vm.locateDevice();

      expect(result, isA<LocationFound>());
      expect(vm.latitude, 40.0);
    });

    test('settings pages open through the service', () async {
      final service = FakeLocationService();
      final vm = buildViewModel(service);
      await vm.ready;

      await vm.openLocationSettings();
      await vm.openAppSettings();

      expect(service.locationSettingsOpened, 1);
      expect(service.appSettingsOpened, 1);
    });

    test('a place name comes with its attribution', () async {
      final geocoder = FakeReverseGeocoder(
        result: const PlaceNameFound(
          'Ljubljana',
          attribution: '© OpenStreetMap contributors',
        ),
      );
      final vm = buildViewModel(FakeLocationService(), geocoder: geocoder);
      await vm.ready;

      await vm.setLocation(46.05, 14.51);
      await pumpEventQueue();

      expect(geocoder.lookups.last, (46.05, 14.51));
      expect(vm.locationName, 'Ljubljana');
      expect(vm.locationNameAttribution, '© OpenStreetMap contributors');
    });

    test('a failed lookup leaves the name unknown, not stale', () async {
      final geocoder = FakeReverseGeocoder(
        result: const PlaceNameFound('Ljubljana', attribution: 'OSM'),
      );
      final vm = buildViewModel(FakeLocationService(), geocoder: geocoder);
      await vm.ready;
      await vm.setLocation(46.05, 14.51);
      await pumpEventQueue();
      expect(vm.locationName, 'Ljubljana');

      geocoder.result = const ReverseGeocodeFailed('offline');
      await vm.setLocation(40.0, -3.7);
      await pumpEventQueue();

      expect(vm.locationName, isNull);
      expect(vm.locationNameAttribution, isNull);
    });

    test('an answer for a position the user left is ignored', () async {
      final slow = _ControlledGeocoder();
      final vm = buildViewModel(FakeLocationService(), geocoder: slow);
      await vm.ready;

      await vm.setLocation(46.05, 14.51); // lookup A pending
      await vm.setLocation(40.0, -3.7); // lookup B pending
      slow.answer(1, const PlaceNameFound('Madrid', attribution: 'OSM'));
      slow.answer(0, const PlaceNameFound('Ljubljana', attribution: 'OSM'));
      await pumpEventQueue();

      expect(vm.locationName, 'Madrid');
    });

    // TASK 7.2 acceptance.
    test('no http or geolocator import in presentation or domain', () {
      final offenders =
          [
                ...Directory('lib/presentation').listSync(recursive: true),
                ...Directory('lib/domain').listSync(recursive: true),
              ]
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart'))
              .where((f) {
                final source = f.readAsStringSync();
                return source.contains('package:http/') ||
                    source.contains('package:geolocator/');
              })
              .map((f) => f.path)
              .toList();
      expect(offenders, isEmpty);
    });
  });
}

/// A geocoder whose answers the test releases by hand, in any order.
class _ControlledGeocoder implements ReverseGeocoder {
  final List<Completer<ReverseGeocodeResult>> _pending = [];

  @override
  Future<ReverseGeocodeResult> placeNameFor(double latitude, double longitude) {
    final completer = Completer<ReverseGeocodeResult>();
    _pending.add(completer);
    return completer.future;
  }

  /// Completes the [index]-th lookup (a first run makes none at startup).
  void answer(int index, ReverseGeocodeResult result) =>
      _pending[index].complete(result);
}
