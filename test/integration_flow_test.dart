import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/repositories/target_repository.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/domain/repositories/equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/domain/repositories/session_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/domain/repositories/location_repository.dart';

import 'support/planner_harness.dart';

import 'package:astroplan/presentation/viewmodels/theme_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astroplan/domain/models/astro_target.dart' as domain;
import 'package:astroplan/domain/models/equipment_profile.dart' as domain;
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';

import 'support/fake_location_service.dart';
import 'support/no_snapshot_weather.dart';

import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';

class MockWeatherRepository
    with NoSnapshotWeather
    implements WeatherRepository {}

void main() {
  late AppDatabase database;
  late DriftTargetRepository targetRepo;
  late DriftEquipmentRepository equipmentRepo;
  late DriftSessionRepository sessionRepo;
  late DriftLocationRepository locationRepo;
  late PlannerHarness plannerViewModel;
  late domain.AstroTarget testTarget;
  late domain.EquipmentProfile testEquip;

  setUp(() async {
    // AppRouter.router is a shared static singleton (TD-037): reset it so a
    // navigation in one test doesn't leak into the next (now that this file
    // has more than one test).
    // TASK 12.2: start in the session planner (ADR-015).
    AppRouter.router.go(AppRouter.session());
    database = AppDatabase(NativeDatabase.memory());
    targetRepo = DriftTargetRepository(database);
    equipmentRepo = DriftEquipmentRepository(database);
    sessionRepo = DriftSessionRepository(database);
    locationRepo = DriftLocationRepository(database);

    // A saved location, so isDefaultLocation is false and sessionNight
    // resolves (TASK 2.4): Save Session needs a night to save.
    final locId = await locationRepo.insertLocation(
      domain.LocationProfile(
        id: 0,
        name: 'Test Site',
        latitude: 51.5072,
        longitude: -0.1276,
        elevation: 10,
      ),
    );
    SharedPreferences.setMockInitialValues({'activeLocationId': locId});

    testTarget = domain.AstroTarget(
      id: 1,
      catalogId: 'M42',
      commonName: 'Orion Nebula',
      type: 'Nebula',
      rightAscension: 83.85, // degrees (5.59 h x 15)
      declination: -5.45,
    );
    await targetRepo.insertTarget(testTarget);

    testEquip = domain.EquipmentProfile(
      id: 1,
      name: 'ASI2600MC',
      focalRatio: 4.0,
      focalLengthMm: 400.0,
      sensorWidthMm: 23.5,
      sensorHeightMm: 15.6,
      resolutionWidthPx: 6000,
      resolutionHeightPx: 4000,
      pixelPitchUm: 3.76,
      averageRawFileSizeMB: 50.0,
    );
    await equipmentRepo.insertEquipment(testEquip);
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('E2E Flow: Planner -> Save -> Logbook', (
    WidgetTester tester,
  ) async {
    // Use a taller surface so the Save Session button is within hittable bounds
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // The ViewModel's async initialisation (SharedPreferences, in-memory Drift)
    // needs the real event loop, which the fake-async test zone never runs.
    await tester.runAsync(() async {
      plannerViewModel = PlannerHarness(
        targetRepo,
        equipmentRepo,
        MockWeatherRepository(),
        locationRepo,
        locationService: FakeLocationService(),
        sessionRepository: sessionRepo,
      );
      await plannerViewModel.ready;
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppDatabase>.value(value: database),
          Provider<TargetRepository>.value(value: targetRepo),
          ChangeNotifierProvider(create: (_) => TargetsViewModel(targetRepo)),
          Provider<EquipmentRepository>.value(value: equipmentRepo),
          ChangeNotifierProvider(create: (_) => GearViewModel(equipmentRepo)),
          Provider<SessionRepository>.value(value: sessionRepo),
          ChangeNotifierProvider(create: (_) => SessionsViewModel(sessionRepo)),
          Provider<LocationRepository>.value(value: locationRepo),
          ...plannerViewModel.providers,
          ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ],
        child: const AstroPlanApp(),
      ),
    );

    // TASK 11.4: these autosave to the database, which needs the real
    // event loop.
    await tester.runAsync(() async {
      await plannerViewModel.setTarget(testTarget);
      await plannerViewModel.setEquipment(testEquip);
    });
    await tester.pumpAndSettle();

    expect(find.text('Session planner'), findsOneWidget);

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
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pump(const Duration(seconds: 1)); // allow SnackBar to render

    expect(find.text('Session saved to Logbook!'), findsOneWidget);

    // Scroll back to top to reveal AppBar icons
    await tester.drag(listFinder, const Offset(0, 2000));
    await tester.pumpAndSettle();

    // TASK 12.2: the logbook is the Sessions tab.
    AppRouter.router.go(AppRouter.sessions);
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sessions'), findsWidgets);
    expect(find.textContaining('Orion Nebula'), findsOneWidget);
    expect(find.textContaining('ASI2600MC'), findsOneWidget);
    // TASK 11.3: Save stores a planned session with a plan snapshot.
    expect(find.text('Planned'), findsOneWidget);
  });

  testWidgets(
    'TASK 4.2, TD-011: tapping Save Session twice produces one row, not two',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.runAsync(() async {
        plannerViewModel = PlannerHarness(
          targetRepo,
          equipmentRepo,
          MockWeatherRepository(),
          locationRepo,
          locationService: FakeLocationService(),
          sessionRepository: sessionRepo,
        );
        await plannerViewModel.ready;
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppDatabase>.value(value: database),
            Provider<TargetRepository>.value(value: targetRepo),
            ChangeNotifierProvider(create: (_) => TargetsViewModel(targetRepo)),
            Provider<EquipmentRepository>.value(value: equipmentRepo),
            ChangeNotifierProvider(create: (_) => GearViewModel(equipmentRepo)),
            Provider<SessionRepository>.value(value: sessionRepo),
            ChangeNotifierProvider(
              create: (_) => SessionsViewModel(sessionRepo),
            ),
            Provider<LocationRepository>.value(value: locationRepo),
            ...plannerViewModel.providers,
            ChangeNotifierProvider(create: (_) => ThemeViewModel()),
          ],
          child: const AstroPlanApp(),
        ),
      );

      await tester.runAsync(() async {
        await plannerViewModel.setTarget(testTarget);
        await plannerViewModel.setEquipment(testEquip);
      });
      await tester.pumpAndSettle();

      final listFinder = find.byType(Scrollable).first;
      final saveButtonFinder = find.text('Save Session');
      await tester.dragUntilVisible(
        saveButtonFinder,
        listFinder,
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      for (var i = 0; i < 2; i++) {
        await tester.tap(saveButtonFinder);
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 200)),
        );
        await tester.pump(const Duration(seconds: 1));
      }

      final sessions = (await tester.runAsync(sessionRepo.list))!;
      expect(sessions, hasLength(1));
      expect(sessions.single.planSnapshot, isNotNull);
    },
  );
}
