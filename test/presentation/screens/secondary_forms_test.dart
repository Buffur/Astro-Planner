// S9.2 (P9.2; DESIGN_SYSTEM §9): the rig, target and site editors follow
// the form pattern: a sentence-case title from the glossary and one primary
// Save (a FilledButton) labelled the same way.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

void main() {
  late AppDatabase db;
  late PlannerHarness vm;

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> start(WidgetTester tester, String route) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      await CatalogSeeder(DriftTargetRepository(db)).seedIfNeeded();
      await EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded();
      final sites = DriftLocationRepository(db);
      final id = await sites.insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Home',
          latitude: 46.05,
          longitude: 14.51,
          timeZoneId: 'Europe/Ljubljana',
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': id});
      final clock = FixedClock(DateTime.utc(2026, 11, 10, 18));
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoForecast(),
        sites,
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: clock,
        sessionRepository: DriftSessionRepository(db, clock: clock),
      );
      await vm.ready;
    });
    addTearDown(() => tester.runAsync(db.close));
    AppRouter.router.go(route);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  testWidgets('the rig editor: "Add rig" / "Edit rig", one primary Save', (
    tester,
  ) async {
    await start(tester, AppRouter.libraryRigs);
    await tester.tap(find.byTooltip('Add rig'));
    await settle(tester);
    expect(find.text('Add rig'), findsWidgets);
    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('the target editor: "Add a target" / "Edit target", one '
      'primary Save', (tester) async {
    await start(tester, AppRouter.libraryTargets);
    await tester.tap(find.byTooltip('Add a target'));
    await settle(tester);
    expect(find.text('Add a target'), findsWidgets);
    expect(find.widgetWithText(TextFormField, 'Name *'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('the site editor: "Edit site", one primary "Save site"', (
    tester,
  ) async {
    await start(tester, AppRouter.librarySites);
    await tester.tap(find.text('Home'));
    await settle(tester);
    expect(find.text('Edit site'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Save site'), findsOneWidget);
    expect(find.byTooltip('Save site'), findsNothing, reason: 'one Save');
  });
}
