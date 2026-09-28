// TASK 6.4: the sky card shows when the Moon is up and its closest approach
// to the target — annotations only, no "impact %" — from MoonConditions.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';

import '../../support/planner_harness.dart';

import 'package:astroplan/presentation/widgets/sky_darkness_widget.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_location_service.dart';
import '../../support/no_snapshot_weather.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

void main() {
  testWidgets('Moon illumination, up-times and closest approach render', (
    tester,
  ) async {
    late AppDatabase database;
    late PlannerHarness vm;
    await tester.runAsync(() async {
      database = AppDatabase(NativeDatabase.memory());
      final targets = DriftTargetRepository(database);
      await CatalogSeeder(targets).seedIfNeeded(); // M42
      final locations = DriftLocationRepository(database);
      final id = await locations.insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'London',
          latitude: 51.5,
          longitude: -0.1,
          elevation: 10,
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': id});
      vm = PlannerHarness(
        targets,
        DriftEquipmentRepository(database),
        _NoWeather(),
        locations,
        locationService: FakeLocationService(),
        clock: FixedClock(DateTime.utc(2026, 3, 1, 18)),
      );
      await vm.ready;
      await vm.choosePlan(); // S6.8: nothing is preselected
    });
    addTearDown(() => tester.runAsync(database.close));

    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: const MaterialApp(
          home: Scaffold(
            // S6.5: the Moon moved to the Night & Moon detail.
            body: SingleChildScrollView(child: MoonSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final c = vm.moonConditions!;
    final pct = (c.illuminationAtMidnight * 100).round();
    expect(find.text('Moon Illumination at midnight: $pct %'), findsOneWidget);
    expect(find.textContaining('approx'), findsNothing);
    expect(find.byKey(const Key('sky.moonUp')), findsOneWidget);
    expect(find.textContaining('Moon up'), findsOneWidget);
    final approach = c.closestApproachWhileBothUp!;
    expect(
      find.textContaining(
        'Closest to the target while both are up: '
        '${approach.separationDeg.round()}°',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('%', findRichText: true), findsOneWidget);
    expect(find.textContaining('impact'), findsNothing);
  });
}
