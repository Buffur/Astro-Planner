import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/repositories/target_repository.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/domain/repositories/equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_logbook_repository.dart';
import 'package:astroplan/domain/repositories/logbook_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/domain/repositories/location_repository.dart';
import 'package:astroplan/data/repositories/light_pollution_repository.dart';
import 'package:astroplan/data/repositories/open_meteo_weather_repository.dart';
import 'package:astroplan/presentation/viewmodels/planner_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/theme_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astroplan/domain/models/astro_target.dart' as domain;
import 'package:astroplan/domain/models/equipment_profile.dart' as domain;
import 'package:astroplan/domain/models/weather_conditions.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';

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

void main() {
  late AppDatabase database;
  late DriftTargetRepository targetRepo;
  late DriftEquipmentRepository equipmentRepo;
  late DriftLogbookRepository logbookRepo;
  late DriftLocationRepository locationRepo;
  late PlannerViewModel plannerViewModel;
  late domain.AstroTarget testTarget;
  late domain.EquipmentProfile testEquip;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase(NativeDatabase.memory());
    targetRepo = DriftTargetRepository(database);
    equipmentRepo = DriftEquipmentRepository(database);
    logbookRepo = DriftLogbookRepository(database);
    locationRepo = DriftLocationRepository(database);
    
    testTarget = domain.AstroTarget(
      id: 1, catalogId: 'M42', commonName: 'Orion Nebula', type: 'Nebula',
      rightAscension: 5.59, declination: -5.45
    );
    await targetRepo.insertTarget(testTarget);
    
    testEquip = domain.EquipmentProfile(
      id: 1, name: 'ASI2600MC', aperture: 4.0, focalLength: 400.0,
      sensorWidth: 23.5, sensorHeight: 15.6, resolutionWidth: 6000, resolutionHeight: 4000,
      pixelPitch: 3.76, opticalMultiplier: 1.0
    );
    await equipmentRepo.insertEquipment(testEquip);

    plannerViewModel = PlannerViewModel(
      targetRepo, equipmentRepo, MockWeatherRepository(), locationRepo, LightPollutionRepository()
    );
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('E2E Flow: Planner -> Save -> Logbook', (WidgetTester tester) async {
    // Use a taller surface so the Save Session button is within hittable bounds
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppDatabase>.value(value: database),
          Provider<TargetRepository>.value(value: targetRepo),
          Provider<EquipmentRepository>.value(value: equipmentRepo),
          Provider<LogbookRepository>.value(value: logbookRepo),
          Provider<LocationRepository>.value(value: locationRepo),
          ChangeNotifierProvider.value(value: plannerViewModel),
          ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ],
        child: const AstroPlanApp(),
      ),
    );
    
    plannerViewModel.setTarget(testTarget);
    plannerViewModel.setEquipment(testEquip);
    await tester.pumpAndSettle();

    expect(find.text('Session Planner'), findsOneWidget);
    
    // Scroll down to reveal the Save Session button
    final listFinder = find.byType(Scrollable).first;
    final saveButtonFinder = find.text('Save Session');
    await tester.dragUntilVisible(
      saveButtonFinder,
      listFinder,
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
    
    await tester.tap(saveButtonFinder);
    await tester.pump(const Duration(seconds: 1)); // allow SnackBar to render
    
    expect(find.text('Session saved to Logbook!'), findsOneWidget);

    // Scroll back to top to reveal AppBar icons
    await tester.drag(listFinder, const Offset(0, 2000));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.book));
    await tester.pumpAndSettle();

    expect(find.text('Logbook'), findsWidgets);
    expect(find.textContaining('Orion Nebula'), findsOneWidget);
    expect(find.textContaining('ASI2600MC'), findsOneWidget);
  });
}
