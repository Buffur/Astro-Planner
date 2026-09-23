import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/main.dart';
import 'package:provider/provider.dart';
import 'package:drift/native.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/repositories/target_repository.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/domain/repositories/equipment_repository.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/repositories/session_repository.dart';
import 'package:astroplan/domain/models/location_profile.dart'
    as import_location_profile;
import 'package:astroplan/domain/repositories/location_repository.dart';
import 'package:astroplan/presentation/viewmodels/planner_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/theme_viewmodel.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_location_service.dart';
import 'support/no_snapshot_weather.dart';

class MockWeatherRepository
    with NoSnapshotWeather
    implements WeatherRepository {}

class MockLocationRepository implements LocationRepository {
  @override
  Future<int> insertLocation(
    import_location_profile.LocationProfile location,
  ) async => 1;
  @override
  Future<List<import_location_profile.LocationProfile>> getLocations() async =>
      [];
  @override
  Future<import_location_profile.LocationProfile?> getLocationById(
    int id,
  ) async => null;
  @override
  Future<void> updateLocation(
    import_location_profile.LocationProfile location,
  ) async {}
  @override
  Future<void> deleteLocation(int id) async {}
}

void main() {
  testWidgets('App should boot and show session planner', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    final database = AppDatabase(NativeDatabase.memory());

    final targetRepo = DriftTargetRepository(database);
    final targetSeeder = CatalogSeeder(targetRepo);
    await targetSeeder.seedIfNeeded();

    final eqRepo = DriftEquipmentRepository(database);
    final eqSeeder = EquipmentSeeder(eqRepo);
    await eqSeeder.seedIfNeeded();

    final weatherRepo = MockWeatherRepository();
    final sessionRepo = DriftSessionRepository(database);
    final locationRepo = MockLocationRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppDatabase>.value(value: database),
          Provider<TargetRepository>.value(value: targetRepo),
          Provider<EquipmentRepository>.value(value: eqRepo),
          Provider<WeatherRepository>.value(value: weatherRepo),
          Provider<SessionRepository>.value(value: sessionRepo),
          Provider<LocationRepository>.value(value: locationRepo),
          ChangeNotifierProvider(
            create: (_) => PlannerViewModel(
              targetRepo,
              eqRepo,
              weatherRepo,
              locationRepo,
              locationService: FakeLocationService(),
            ),
          ),
          ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ],
        child: const AstroPlanApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Session Planner'), findsOneWidget);

    await database.close();
  });
}
