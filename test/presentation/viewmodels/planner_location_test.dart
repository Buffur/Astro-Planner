// Tests for PlannerViewModel's use of the LocationService seam (TASK 1.1).
//
// Covers:
//   - `ready` completes on first launch without touching GPS
//   - permission denied / location services off (service returns null): the
//     ViewModel keeps its default coordinates, saves no location, and does not
//     throw
//   - a position from the service becomes the active location

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/light_pollution_repository.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/weather_conditions.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/location_service.dart';
import 'package:astroplan/presentation/viewmodels/planner_viewmodel.dart';

import '../../support/fake_location_service.dart';

class _MockWeather implements WeatherRepository {
  @override
  Future<WeatherConditions?> getCurrentWeather(
    double lat,
    double lon, {
    bool forceRefresh = false,
  }) async => null;
}

/// Bortle lookup that never goes to the network.
class _NoBortle extends LightPollutionRepository {
  @override
  Future<int?> fetchBortleClass(double lat, double lon) async => null;
}

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

  PlannerViewModel buildViewModel(FakeLocationService service) {
    return PlannerViewModel(
      DriftTargetRepository(database),
      DriftEquipmentRepository(database),
      _MockWeather(),
      locationRepo,
      _NoBortle(),
      locationService: service,
    );
  }

  group('PlannerViewModel location (TASK 1.1)', () {
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
        expect(service.calls, 1, reason: 'startup asks for the position once');
        expect(vm.latitude, 51.5072);
        expect(vm.longitude, -0.1276);
        expect(await locationRepo.getLocations(), isEmpty);

        // Asking again explicitly, still denied, changes nothing and does not throw.
        await vm.useCurrentLocation();
        expect(service.calls, 2);
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
}
