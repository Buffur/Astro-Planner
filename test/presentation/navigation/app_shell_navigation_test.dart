// TASK 12.2 (ADR-015): the navigation shell — every screen is reachable per
// the route map, each tab keeps its state, Android back pops within a tab
// and then returns to Tonight, and the planner opens above the tabs.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/equipment_repository.dart';
import 'package:astroplan/domain/repositories/location_repository.dart';
import 'package:astroplan/domain/repositories/session_repository.dart';
import 'package:astroplan/domain/repositories/target_repository.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';

import '../../support/planner_harness.dart';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/route_paths.dart';

import 'package:astroplan/presentation/viewmodels/library_viewmodels.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

void main() {
  late AppDatabase db;
  late PlannerHarness vm;

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    AppRouter.router.go(AppRouter.tonight);
    late DriftSessionRepository sessions;
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      await CatalogSeeder(DriftTargetRepository(db)).seedIfNeeded();
      await EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded();
      final siteId = await DriftLocationRepository(db).insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Ljubljana',
          latitude: 46.05,
          longitude: 14.51,
          elevation: 300,
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': siteId});
      sessions = DriftSessionRepository(db);
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoWeather(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: FixedClock(DateTime.utc(2026, 11, 10, 18)),
        sessionRepository: sessions,
      );
      await vm.ready;
    });
    addTearDown(() => tester.runAsync(db.close));
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AppDatabase>.value(value: db),
          Provider<TargetRepository>.value(value: DriftTargetRepository(db)),
          ChangeNotifierProvider(
            create: (_) => TargetsViewModel(DriftTargetRepository(db)),
          ),
          Provider<EquipmentRepository>.value(
            value: DriftEquipmentRepository(db),
          ),
          ChangeNotifierProvider(
            create: (_) => GearViewModel(DriftEquipmentRepository(db)),
          ),
          Provider<LocationRepository>.value(
            value: DriftLocationRepository(db),
          ),
          Provider<SessionRepository>.value(value: sessions),
          ChangeNotifierProvider(create: (_) => SessionsViewModel(sessions)),
          ...vm.providers,
        ],
        child: const AstroPlanApp(),
      ),
    );
    await settle(tester);
  }

  /// The visible page's app-bar title (a pushed route does not change
  /// the router's `uri`, so tests look at what is on screen). Since S6.16
  /// Tonight's title is its page's own header, not the app bar's.
  Finder title(String text) => text == 'Tonight'
      ? find.byKey(const Key('tonight.title'))
      : find.widgetWithText(AppBar, text);

  Future<void> back(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await settle(tester);
  }

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await settle(tester);
  }

  testWidgets('the app opens on Tonight with four tabs', (tester) async {
    await pumpApp(tester);
    expect(title('Tonight'), findsOneWidget);
    final bar = find.byType(NavigationBar);
    expect(bar, findsOneWidget);
    for (final tab in ['Tonight', 'Sessions', 'Library', 'Settings']) {
      expect(
        find.descendant(of: bar, matching: find.text(tab)),
        findsOneWidget,
      );
    }
  });

  // Acceptance: every screen is reachable per the map.
  testWidgets('every route in the map opens its screen', (tester) async {
    await pumpApp(tester);
    final expected = {
      AppRouter.tonight: 'Open planner',
      AppRouter.candidates: "Tonight's candidates",
      AppRouter.sessions: 'Sessions',
      AppRouter.library: 'Library',
      AppRouter.libraryRigs: 'Select Equipment',
      AppRouter.libraryTargets: 'Select Target',
      AppRouter.librarySites: 'Sites',
      AppRouter.settings: 'Planning Settings',
      AppRouter.about: 'About & data sources',
      AppRouter.session(): 'Plan',
      AppRouter.selectTarget: 'Select Target',
      AppRouter.selectRig: 'Select Equipment',
      AppRouter.selectSite: 'Sites',
    };
    for (final entry in expected.entries) {
      AppRouter.router.go(entry.key);
      await settle(tester);
      expect(
        find.text(entry.value),
        findsWidgets,
        reason: '${entry.key} shows "${entry.value}"',
      );
    }
    expect(
      allRoutePaths(),
      containsAll([
        AppRouter.siteEdit,
        AppRouter.sitePick,
        AppRouter.position,
        '/session/:id',
      ]),
    );
    for (final old in ['/logbook', '/equipment', '/target', '/about']) {
      expect(allRoutePaths(), isNot(contains(old)), reason: old);
    }
  });

  testWidgets('back pops within a tab, then returns to Tonight', (
    tester,
  ) async {
    await pumpApp(tester);
    await tapTab(tester, 'Library');
    await tester.tap(find.text('Rigs'));
    await settle(tester);
    expect(title('Select Equipment'), findsOneWidget);

    await back(tester);
    expect(title('Select Equipment'), findsNothing);
    expect(title('Library'), findsOneWidget);
    await back(tester);
    expect(title('Tonight'), findsOneWidget);
  });

  testWidgets('each tab keeps its place', (tester) async {
    await pumpApp(tester);
    await tapTab(tester, 'Library');
    await tester.tap(find.text('Sites'));
    await settle(tester);
    await tapTab(tester, 'Settings');
    expect(title('Planning Settings'), findsOneWidget);
    await tapTab(tester, 'Library');
    expect(title('Sites'), findsOneWidget, reason: 'the pushed page is kept');
  });

  testWidgets('the planner opens above the tabs and back returns to Tonight', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('tonight.openPlanner')));
    await settle(tester);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await back(tester);
    expect(title('Tonight'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}

/// Lets database and isolate futures complete and page transitions finish.
/// Fixed frames rather than `pumpAndSettle`: the candidates screen shows a
/// progress indicator while its background isolate runs.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}
