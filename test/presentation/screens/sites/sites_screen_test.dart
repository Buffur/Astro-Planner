// Widget tests for the sites list and editor (TASK 7.3): the active site is
// marked and switchable; deleting the active site keeps the position; the
// editor validates, pre-fills the device zone, and saves.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/screens/sites/site_editor_screen.dart';
import 'package:astroplan/presentation/screens/sites/sites_screen.dart';

import '../../../support/planner_harness.dart';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_device_time_zone.dart';
import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/no_snapshot_weather.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

void main() {
  late AppDatabase database;
  late DriftLocationRepository locations;
  late PlannerHarness vm;

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> build(
    WidgetTester tester, {
    List<domain.LocationProfile> sites = const [],
  }) async {
    await tester.runAsync(() async {
      database = AppDatabase(NativeDatabase.memory());
      locations = DriftLocationRepository(database);
      for (final site in sites) {
        await locations.insertLocation(site);
      }
      vm = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _NoWeather(),
        locations,
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone('Europe/Ljubljana'),
        clock: FixedClock(DateTime.utc(2026, 9, 23, 12)),
      );
      await vm.ready;
    });
    addTearDown(() => tester.runAsync(database.close));
  }

  Future<void> pump(
    WidgetTester tester, {
    String at = '/sites',
    Object? extra,
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Scaffold()),
        GoRoute(path: '/sites', builder: (_, _) => const SitesScreen()),
        GoRoute(
          path: AppRouter.siteEdit,
          builder: (_, state) => SiteEditorScreen(
            args: state.extra as SiteEditorArgs? ?? const SiteEditorArgs(),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    router.push(at, extra: extra);
    await tester.pumpAndSettle();
  }

  domain.LocationProfile site(String name, double lat, double lon) =>
      domain.LocationProfile(
        id: 0,
        name: name,
        latitude: lat,
        longitude: lon,
        elevation: 300,
        timeZoneId: 'Europe/Ljubljana',
      );

  IconData? leadingIcon(WidgetTester tester, int id) {
    final tile = tester.widget<ListTile>(find.byKey(ValueKey('site-$id')));
    return (tile.leading as Icon).icon;
  }

  testWidgets('the active site is marked, and tapping another selects it', (
    tester,
  ) async {
    await build(
      tester,
      sites: [site('Home', 46.05, 14.51), site('Dark site', 46.2, 14.1)],
    );
    await tester.runAsync(() => vm.selectSite(1));
    await pump(tester);

    expect(leadingIcon(tester, 1), Icons.radio_button_checked);
    expect(leadingIcon(tester, 2), Icons.radio_button_unchecked);

    await tester.tap(find.text('Dark site'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(vm.activeSite?.id, 2);
    expect(leadingIcon(tester, 2), Icons.radio_button_checked);
  });

  testWidgets('deleting the active site keeps its position as unsaved', (
    tester,
  ) async {
    await build(tester, sites: [site('Home', 46.05, 14.51)]);
    await tester.runAsync(() => vm.selectSite(1));
    await pump(tester);

    await tester.tap(find.byTooltip('Delete site'));
    await tester.pumpAndSettle();
    expect(find.textContaining('This is the active site'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(vm.sites, isEmpty);
    expect(vm.activeSite, isNull);
    expect(find.textContaining('not saved'), findsOneWidget);
    expect(find.text('Save as site'), findsOneWidget);
    expect(find.text('No saved sites yet.'), findsOneWidget);
  });

  testWidgets('the editor rejects missing and out-of-range values', (
    tester,
  ) async {
    await build(tester);
    await pump(tester, at: AppRouter.siteEdit);

    await tester.tap(find.byTooltip('Save site'));
    await tester.pumpAndSettle();
    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Latitude is required'), findsOneWidget);
    expect(find.text('Elevation is required'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Latitude (°)'),
      '91',
    );
    await tester.tap(find.byTooltip('Save site'));
    await tester.pumpAndSettle();
    expect(find.text('Latitude must be between -90 and 90'), findsOneWidget);
    expect(vm.sites, isEmpty);
  });

  testWidgets('a new site defaults to the device zone and becomes active', (
    tester,
  ) async {
    await build(tester);
    await pump(tester, at: AppRouter.siteEdit);

    expect(find.text('Europe/Ljubljana (device zone)'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Backyard',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Latitude (°)'),
      '46.05',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Longitude (°)'),
      '14,51',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Elevation (m)'),
      '295',
    );
    await tester.tap(find.byTooltip('Save site'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    final saved = vm.sites.single;
    expect(saved.name, 'Backyard');
    expect(saved.longitude, 14.51);
    expect(saved.timeZoneId, 'Europe/Ljubljana');
    expect(vm.activeSite?.id, saved.id);
    expect(find.byType(SiteEditorScreen), findsNothing, reason: 'popped');
  });

  testWidgets('"Save as site" starts from the current position', (
    tester,
  ) async {
    await build(tester);
    await tester.runAsync(() => vm.setLocation(45.5, 13.7));
    await pump(tester);

    await tester.tap(find.text('Save as site'));
    await tester.pumpAndSettle();

    expect(find.text('New site'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '45.50000'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '13.70000'), findsOneWidget);
  });

  testWidgets('editing a site keeps what was not changed', (tester) async {
    await build(tester, sites: [site('Home', 46.05, 14.51)]);
    await tester.runAsync(() => vm.selectSite(1));
    await pump(tester);

    await tester.tap(find.byTooltip('Edit site'));
    await tester.pumpAndSettle();
    expect(find.text('Edit site'), findsOneWidget);
    expect(find.text('Europe/Ljubljana'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Garden',
    );
    await tester.tap(find.byTooltip('Save site'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    final saved = vm.sites.single;
    expect(saved.name, 'Garden');
    expect(saved.latitude, 46.05);
    expect(saved.elevation, 300);
    expect(saved.timeZoneId, 'Europe/Ljubljana');
    expect(vm.locationName, 'Garden');
  });

  // TASK 7.4 (PD-05 option B): manual Bortle/SQM, recorded as "user" with
  // the date of the edit.
  testWidgets('Bortle and SQM entered in the editor are stored as user', (
    tester,
  ) async {
    await build(tester, sites: [site('Home', 46.05, 14.51)]);
    await tester.runAsync(() => vm.selectSite(1));
    await pump(tester);

    await tester.tap(find.byTooltip('Edit site'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(DropdownButtonFormField<int?>, 'Unknown'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bortle 5').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'SQM (mag/arcsec²)'),
      '20.4',
    );
    await tester.tap(find.byTooltip('Save site'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    final saved = vm.sites.single;
    expect(saved.bortleClass, 5);
    expect(saved.bortleSource, 'user');
    expect(saved.bortleDate, vm.today);
    expect(saved.sqm, 20.4);
    expect(saved.sqmSource, 'user');
    expect(saved.sqmDate, vm.today);
    expect(vm.skyDarkness.bortleClass, 5);
  });

  testWidgets('an out-of-range SQM is rejected', (tester) async {
    await build(tester);
    await pump(tester, at: AppRouter.siteEdit);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'SQM (mag/arcsec²)'),
      '30',
    );
    await tester.tap(find.byTooltip('Save site'));
    await tester.pumpAndSettle();
    expect(find.text('SQM must be between 15 and 23'), findsOneWidget);
  });
}
