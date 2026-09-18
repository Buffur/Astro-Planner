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
import 'package:astroplan/domain/repositories/logbook_repository.dart';
import 'package:astroplan/domain/models/weather_conditions.dart';
import 'package:astroplan/domain/models/session_log.dart' as domain;
import 'package:astroplan/domain/models/location_profile.dart' as import_location_profile;
import 'package:astroplan/domain/repositories/location_repository.dart';
import 'package:astroplan/data/repositories/light_pollution_repository.dart';
import 'package:astroplan/presentation/viewmodels/planner_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/theme_viewmodel.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockWeatherRepository implements WeatherRepository {
  @override
  Future<WeatherConditions?> getCurrentWeather(double latitude, double longitude, {bool forceRefresh = false}) async {
    return const WeatherConditions(
      temperature: 15.0,
      cloudCover: 10.0,
      humidity: 50.0,
      dewPoint: 5.0,
    );
  }
}

class MockLogbookRepository implements LogbookRepository {
  @override
  Future<List<domain.SessionLog>> getAllLogs() async => [];
  @override
  Future<void> addLog(domain.SessionLog log) async {}
  @override
  Future<void> updateLog(domain.SessionLog log) async {}
  @override
  Future<void> deleteLog(int id) async {}
}

class MockLocationRepository implements LocationRepository {
  @override
  Future<int> insertLocation(import_location_profile.LocationProfile location) async => 1;
  @override
  Future<List<import_location_profile.LocationProfile>> getLocations() async => [];
  @override
  Future<import_location_profile.LocationProfile?> getLocationById(int id) async => null;
  @override
  Future<void> updateLocation(import_location_profile.LocationProfile location) async {}
  @override
  Future<void> deleteLocation(int id) async {}
}

void main() {
  testWidgets('App should boot and show session planner', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    
    final database = AppDatabase(NativeDatabase.memory());
    
    final targetRepo = DriftTargetRepository(database);
    final targetSeeder = CatalogSeeder(targetRepo);
    await targetSeeder.seedIfNeeded();

    final eqRepo = DriftEquipmentRepository(database);
    final eqSeeder = EquipmentSeeder(eqRepo);
    await eqSeeder.seedIfNeeded();

    final weatherRepo = MockWeatherRepository();
    final logbookRepo = MockLogbookRepository();
    final locationRepo = MockLocationRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppDatabase>.value(value: database),
          Provider<TargetRepository>.value(value: targetRepo),
          Provider<EquipmentRepository>.value(value: eqRepo),
          Provider<WeatherRepository>.value(value: weatherRepo),
          Provider<LogbookRepository>.value(value: logbookRepo),
          Provider<LocationRepository>.value(value: locationRepo),
          Provider<LightPollutionRepository>(create: (_) => LightPollutionRepository()),
          ChangeNotifierProvider(create: (_) => PlannerViewModel(targetRepo, eqRepo, weatherRepo, locationRepo, LightPollutionRepository())),
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

