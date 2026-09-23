// Widget tests for Home's bootstrap-related states (roadmap TASK 1.2).
//
// Covers:
//   - the empty state offers actions to choose a target and equipment
//   - the default-location banner shows until a location is resolved
//   - a weather-repository failure renders an error/retry card instead of
//     hanging or crashing (the first screen never blocks on the network)
//   - a bootstrap-repository failure renders an error/retry view

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/repositories/target_repository.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/domain/repositories/equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_logbook_repository.dart';
import 'package:astroplan/domain/repositories/logbook_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/domain/repositories/location_repository.dart';
import 'package:astroplan/presentation/viewmodels/planner_viewmodel.dart';
import 'package:astroplan/presentation/viewmodels/theme_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/domain/models/astro_target.dart' as domain;
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/equipment_profile.dart' as domain;
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/weather_conditions.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/shared/night_time_formatter.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/flaky_target_repository.dart';
import '../../../support/no_snapshot_weather.dart';

class _MockWeather with NoSnapshotWeather implements WeatherRepository {
  @override
  Future<WeatherConditions?> getCurrentWeather(
    double lat,
    double lon, {
    bool forceRefresh = false,
  }) async {
    return const WeatherConditions(
      temperature: 15.0,
      cloudCover: 10.0,
      humidity: 50.0,
      dewPoint: 5.0,
    );
  }
}

class _ThrowingWeather with NoSnapshotWeather implements WeatherRepository {
  int calls = 0;

  @override
  Future<WeatherConditions?> getCurrentWeather(
    double lat,
    double lon, {
    bool forceRefresh = false,
  }) async {
    calls++;
    throw Exception('network down');
  }
}

void main() {
  late AppDatabase database;
  late DriftTargetRepository targetRepo;
  late DriftEquipmentRepository equipmentRepo;
  late DriftLogbookRepository logbookRepo;
  late DriftLocationRepository locationRepo;

  setUp(() {
    // AppRouter.router is a shared static singleton (TD-037): reset it so a
    // navigation in one test doesn't leak into the next.
    AppRouter.router.go('/');
    SharedPreferences.setMockInitialValues({});
    database = AppDatabase(NativeDatabase.memory());
    targetRepo = DriftTargetRepository(database);
    equipmentRepo = DriftEquipmentRepository(database);
    logbookRepo = DriftLogbookRepository(database);
    locationRepo = DriftLocationRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Widget wrap(PlannerViewModel vm) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        Provider<TargetRepository>.value(value: targetRepo),
        Provider<EquipmentRepository>.value(value: equipmentRepo),
        Provider<LogbookRepository>.value(value: logbookRepo),
        Provider<LocationRepository>.value(value: locationRepo),
        ChangeNotifierProvider.value(value: vm),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: const AstroPlanApp(),
    );
  }

  testWidgets('empty state offers actions to choose a target and equipment', (
    tester,
  ) async {
    late PlannerViewModel vm;
    await tester.runAsync(() async {
      vm = PlannerViewModel(
        targetRepo,
        equipmentRepo,
        _MockWeather(),
        locationRepo,
        locationService: FakeLocationService(),
      );
      await vm.ready;
    });

    await tester.pumpWidget(wrap(vm));
    await tester.pumpAndSettle();

    expect(find.text('Choose a Target'), findsOneWidget);
    expect(find.text('Choose Equipment'), findsOneWidget);

    await tester.tap(find.text('Choose a Target'));
    await tester.pumpAndSettle();

    expect(find.text('Select Target'), findsOneWidget);
  });

  testWidgets('a default location shows a banner that offers to set the site', (
    tester,
  ) async {
    late PlannerViewModel vm;
    await tester.runAsync(() async {
      vm = PlannerViewModel(
        targetRepo,
        equipmentRepo,
        _MockWeather(),
        locationRepo,
        locationService: FakeLocationService(),
      );
      await vm.ready;
    });

    await tester.pumpWidget(wrap(vm));
    await tester.pumpAndSettle();

    expect(find.textContaining('default location'), findsOneWidget);
    expect(find.text('Set site'), findsOneWidget);
    // TASK 7.3 first-run prompt: the permission is asked only on this tap.
    expect(find.text('Use current position'), findsOneWidget);
  });

  testWidgets('a saved location hides the default-location banner', (
    tester,
  ) async {
    final locId = await locationRepo.insertLocation(
      domain.LocationProfile(
        id: 0,
        name: 'Test Site',
        latitude: 51.5,
        longitude: -0.1,
        elevation: 10,
      ),
    );
    SharedPreferences.setMockInitialValues({'activeLocationId': locId});

    late PlannerViewModel vm;
    await tester.runAsync(() async {
      vm = PlannerViewModel(
        targetRepo,
        equipmentRepo,
        _MockWeather(),
        locationRepo,
        locationService: FakeLocationService(),
      );
      await vm.ready;
    });

    await tester.pumpWidget(wrap(vm));
    await tester.pumpAndSettle();

    expect(find.text('Session Planner'), findsOneWidget);
    expect(find.textContaining('default location'), findsNothing);
  });

  testWidgets(
    'a weather-repository failure shows a retry card instead of hanging',
    (tester) async {
      final testTarget = domain.AstroTarget(
        id: 1,
        catalogId: 'M42',
        commonName: 'Orion Nebula',
        type: 'Nebula',
        rightAscension: 83.85,
        declination: -5.45,
      );
      await targetRepo.insertTarget(testTarget);
      final testEquip = domain.EquipmentProfile(
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

      // A taller surface so the weather section (below the target card and
      // altitude chart) is scrolled into view and actually built.
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final throwingWeather = _ThrowingWeather();
      late PlannerViewModel vm;
      await tester.runAsync(() async {
        vm = PlannerViewModel(
          targetRepo,
          equipmentRepo,
          throwingWeather,
          locationRepo,
          locationService: FakeLocationService(),
        );
        await vm.ready;
      });

      // The first screen renders without waiting on weather at all.
      expect(vm.hasBootstrapError, isFalse);

      await tester.pumpWidget(wrap(vm));
      await tester.pump();
      expect(find.text('Session Planner'), findsOneWidget);

      // Weather loads after the first frame and fails.
      await tester.pumpAndSettle();
      expect(throwingWeather.calls, greaterThan(0));
      expect(find.text("Couldn't load weather."), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text("Couldn't load weather."), findsOneWidget);
      expect(throwingWeather.calls, greaterThan(1));
    },
  );

  testWidgets('a bootstrap-repository failure shows an error view with retry', (
    tester,
  ) async {
    final flakyTargets = FlakyTargetRepository(targetRepo);
    await targetRepo.insertTarget(
      domain.AstroTarget(
        id: 1,
        catalogId: 'M42',
        commonName: 'Orion Nebula',
        type: 'Nebula',
        rightAscension: 83.85,
        declination: -5.45,
      ),
    );

    late PlannerViewModel vm;
    await tester.runAsync(() async {
      vm = PlannerViewModel(
        flakyTargets,
        equipmentRepo,
        _MockWeather(),
        locationRepo,
        locationService: FakeLocationService(),
      );
      await vm.ready;
    });

    await tester.pumpWidget(wrap(vm));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't load your data."), findsOneWidget);
    expect(
      find.text('Select a Target and Equipment profile to begin planning.'),
      findsNothing,
    );

    flakyTargets.shouldThrow = false;
    await tester.runAsync(() => vm.retryBootstrap());
    await tester.pumpAndSettle();

    expect(find.text("Couldn't load your data."), findsNothing);
  });

  testWidgets('a saved site shows the correct evening date, not the UTC one '
      '(TASK 2.4, ADR-007 T1)', (tester) async {
    // San Francisco at 18:30 PDT on 2026-09-21 = 2026-09-22 01:30 UTC.
    // The old UTC-calendar-date rule would show the 22nd; the fix shows
    // the 21st (see planner_session_date_test.dart for the ViewModel-level
    // version of this same case).
    final locId = await locationRepo.insertLocation(
      domain.LocationProfile(
        id: 0,
        name: 'Test Site',
        latitude: 37.7749,
        longitude: -122.4194,
        elevation: 10,
      ),
    );
    SharedPreferences.setMockInitialValues({'activeLocationId': locId});

    // The Session Date section only renders once a target and equipment
    // are both selected.
    final testTarget = domain.AstroTarget(
      id: 1,
      catalogId: 'M42',
      commonName: 'Orion Nebula',
      type: 'Nebula',
      rightAscension: 83.85,
      declination: -5.45,
    );
    await targetRepo.insertTarget(testTarget);
    final testEquip = domain.EquipmentProfile(
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

    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    late PlannerViewModel vm;
    await tester.runAsync(() async {
      vm = PlannerViewModel(
        targetRepo,
        equipmentRepo,
        _MockWeather(),
        locationRepo,
        locationService: FakeLocationService(),
        clock: FixedClock(DateTime.utc(2026, 9, 22, 1, 30)),
      );
      await vm.ready;
    });

    vm.setTarget(testTarget);
    vm.setEquipment(testEquip);
    await tester.pumpWidget(wrap(vm));
    await tester.pumpAndSettle();

    final expectedDate = NightTimeFormatter.eveningDate(
      CalendarDate(2026, 9, 21),
    );
    expect(find.textContaining('Night of $expectedDate'), findsOneWidget);
    expect(find.textContaining('No site set'), findsNothing);
  });

  testWidgets('without a site, Home shows "No site set" and hides the altitude '
      'chart and Save Session (ADR-007 §9, TASK 2.4)', (tester) async {
    final testTarget = domain.AstroTarget(
      id: 1,
      catalogId: 'M42',
      commonName: 'Orion Nebula',
      type: 'Nebula',
      rightAscension: 83.85,
      declination: -5.45,
    );
    await targetRepo.insertTarget(testTarget);
    final testEquip = domain.EquipmentProfile(
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

    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    late PlannerViewModel vm;
    await tester.runAsync(() async {
      vm = PlannerViewModel(
        targetRepo,
        equipmentRepo,
        _MockWeather(),
        locationRepo,
        locationService: FakeLocationService(),
      );
      await vm.ready;
    });

    vm.setTarget(testTarget);
    vm.setEquipment(testEquip);
    await tester.pumpWidget(wrap(vm));
    await tester.pumpAndSettle();

    expect(find.textContaining('No site set'), findsOneWidget);
    expect(
      find.text("Set your site to see tonight's altitude chart."),
      findsOneWidget,
    );
    expect(find.text('Save Session'), findsNothing);
  });

  testWidgets('a gated feature has no entry point (TASK 4.3, TD-014, PD-06)', (
    tester,
  ) async {
    final locId = await locationRepo.insertLocation(
      domain.LocationProfile(
        id: 0,
        name: 'Test Site',
        latitude: 51.5,
        longitude: -0.1,
        elevation: 10,
      ),
    );
    SharedPreferences.setMockInitialValues({'activeLocationId': locId});

    final testTarget = domain.AstroTarget(
      id: 1,
      catalogId: 'M42',
      commonName: 'Orion Nebula',
      type: 'Nebula',
      rightAscension: 83.85,
      declination: -5.45,
    );
    await targetRepo.insertTarget(testTarget);
    final testEquip = domain.EquipmentProfile(
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

    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    late PlannerViewModel vm;
    await tester.runAsync(() async {
      vm = PlannerViewModel(
        targetRepo,
        equipmentRepo,
        _MockWeather(),
        locationRepo,
        locationService: FakeLocationService(),
      );
      await vm.ready;
    });

    vm.setTarget(testTarget);
    vm.setEquipment(testEquip);
    await tester.pumpWidget(wrap(vm));
    await tester.pumpAndSettle();

    // Hidden per PD-06 (FeatureScope: fieldMode, metadataImport false) —
    // no icon, tooltip or route.
    expect(find.byTooltip('Toggle Field Mode'), findsNothing);
    expect(find.byTooltip('Import Metadata'), findsNothing);
    expect(
      AppRouter.router.configuration.routes.whereType<GoRoute>().map(
        (r) => r.path,
      ),
      isNot(contains('/metadata')),
    );

    // Scroll through the whole body to check the light-pollution map card.
    final listFinder = find.byType(Scrollable).first;
    await tester.dragUntilVisible(
      find.text('Capture Plan'),
      listFinder,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    // Visible since TASK 7.4, its PD-06 phase (before, this asserted
    // findsNothing): with a site, the map opens at the site's coordinates.
    expect(find.text('Open Light Pollution Map'), findsOneWidget);

    // Stays visible per PD-06 (on the core path).
    expect(find.byTooltip('Logbook'), findsOneWidget);
    expect(
      AppRouter.router.configuration.routes.whereType<GoRoute>().map(
        (r) => r.path,
      ),
      contains('/logbook'),
    );
  });
}
