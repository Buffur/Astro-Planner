// Widget tests for the sites list and editor (TASK 7.3): the active site is
// marked and switchable; deleting the active site keeps the position; the
// editor validates, pre-fills the device zone, and saves. S7.5 (RG-08 = E2,
// RG-09 = S3/M2, UX-21): elevation optional and unknown when empty; "Use
// current position" fills the form only; Bortle and SQM in a collapsed,
// remembered section with the map link; back with changes asks.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/services/location_service.dart';
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

  late FakeLocationService gps;

  Future<void> build(
    WidgetTester tester, {
    List<domain.LocationProfile> sites = const [],
    FakeLocationService? locationService,
  }) async {
    gps = locationService ?? FakeLocationService();
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
        locationService: gps,
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

  Future<void> openSkyDarkness(WidgetTester tester) async {
    await tester.tap(
      find.byKey(const Key('section.${SiteEditorScreen.skyDarknessSection}')),
    );
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Save site'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  Future<void> typeSite(WidgetTester tester) async {
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
      '14.51',
    );
  }

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
    // S7.5 (RG-08 = E2): elevation is optional; empty is unknown.
    expect(find.text('Elevation is required'), findsNothing);

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
    await openSkyDarkness(tester); // S7.5: collapsed by default
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
    await openSkyDarkness(tester); // S7.5: collapsed by default

    await tester.enterText(
      find.widgetWithText(TextFormField, 'SQM (mag/arcsec²)'),
      '30',
    );
    await tester.tap(find.byTooltip('Save site'));
    await tester.pumpAndSettle();
    expect(find.text('SQM must be between 15 and 23'), findsOneWidget);
  });

  group('S7.5: the site form', () {
    testWidgets('an empty elevation is saved as unknown, never 0; a stored '
        'one is kept', (tester) async {
      await build(tester);
      await pump(tester, at: AppRouter.siteEdit);
      await typeSite(tester);
      await save(tester);
      final saved = vm.sites.single;
      expect(saved.elevation, isNull);
      expect(saved.name, 'Backyard');
    });

    testWidgets('an edited site with an unknown elevation shows it empty and '
        'keeps it unknown', (tester) async {
      await build(
        tester,
        sites: [
          domain.LocationProfile(
            id: 0,
            name: 'Hill',
            latitude: 46.1,
            longitude: 14.6,
            timeZoneId: 'Europe/Ljubljana',
          ),
        ],
      );
      await tester.runAsync(() => vm.selectSite(1));
      await pump(
        tester,
        at: AppRouter.siteEdit,
        extra: SiteEditorArgs(site: vm.sites.single),
      );
      final field = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Elevation (m)'),
      );
      expect(field.controller!.text, isEmpty);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'),
        'Hilltop',
      );
      await save(tester);
      expect(vm.sites.single.elevation, isNull);
      expect(vm.sites.single.name, 'Hilltop');
    });

    testWidgets('"Use current position" asks only on the tap, fills the '
        'coordinates, and stores nothing until Save', (tester) async {
      await build(
        tester,
        locationService: FakeLocationService(
          location: const DeviceLocation(latitude: 45.8123, longitude: 15.9771),
        ),
      );
      await pump(tester, at: AppRouter.siteEdit);
      expect(gps.calls, 0);
      final before = (vm.site.latitude, vm.site.longitude);

      await tester.tap(find.byKey(const Key('siteEditor.useCurrentPosition')));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(gps.calls, 1);
      expect(find.widgetWithText(TextFormField, '45.81230'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '15.97710'), findsOneWidget);
      expect(vm.sites, isEmpty, reason: 'nothing saved');
      expect(
        (vm.site.latitude, vm.site.longitude),
        before,
        reason: 'the fix only fills the form (trap 2)',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'),
        'Field',
      );
      await save(tester);
      expect(vm.sites.single.latitude, 45.8123);
    });

    testWidgets('a GPS failure says why and changes no field', (tester) async {
      await build(tester);
      await pump(tester, at: AppRouter.siteEdit);
      await tester.tap(find.byKey(const Key('siteEditor.useCurrentPosition')));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      final lat = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Latitude (°)'),
      );
      expect(lat.controller!.text, isEmpty);
    });

    // S7V-02 / TD-084 (S7.V2): Back asks about an edit to any one field.
    Future<void> editOnly(
      WidgetTester tester,
      String label,
      String text,
    ) async {
      final field = find.widgetWithText(TextFormField, label);
      await tester.ensureVisible(field);
      await tester.enterText(field, text);
      await tester.pumpAndSettle();
    }

    Future<void> back(WidgetTester tester, {required bool system}) async {
      if (system) {
        await tester.binding.handlePopRoute();
      } else {
        await tester.pageBack();
      }
      await tester.pumpAndSettle();
    }

    const edits = [
      ('Name', 'Changed name'),
      ('Elevation (m)', '450'),
      ('Notes', 'Private note'),
    ];
    for (final existing in [true, false]) {
      for (final system in [false, true]) {
        for (final item in edits) {
          testWidgets('back guards a ${item.$1}-only edit '
              '(${existing ? 'existing' : 'new'} site, '
              '${system ? 'system' : 'app bar'} Back)', (tester) async {
            await build(
              tester,
              sites: existing ? [site('Original', 46, 14)] : const [],
            );
            await pump(
              tester,
              at: AppRouter.siteEdit,
              extra: existing ? SiteEditorArgs(site: vm.sites.single) : null,
            );
            await editOnly(tester, item.$1, item.$2);
            await back(tester, system: system);
            expect(find.text('Unsaved changes'), findsOneWidget);
            expect(find.byType(SiteEditorScreen), findsOneWidget);
          });
        }
      }
    }

    testWidgets('an edit typed back to the original leaves without asking', (
      tester,
    ) async {
      await build(tester, sites: [site('Original', 46, 14)]);
      await pump(
        tester,
        at: AppRouter.siteEdit,
        extra: SiteEditorArgs(site: vm.sites.single),
      );
      await editOnly(tester, 'Name', 'Changed name');
      await editOnly(tester, 'Name', 'Original');
      await editOnly(tester, 'Elevation (m)', '450');
      await editOnly(tester, 'Elevation (m)', '300');
      await back(tester, system: false);
      expect(find.text('Unsaved changes'), findsNothing);
      expect(find.byType(SiteEditorScreen), findsNothing);
    });

    testWidgets('a new site with only the device zone filled in leaves '
        'without asking', (tester) async {
      await build(tester);
      await pump(tester, at: AppRouter.siteEdit);
      expect(find.text('Europe/Ljubljana (device zone)'), findsOneWidget);
      await back(tester, system: true);
      expect(find.text('Unsaved changes'), findsNothing);
      expect(find.byType(SiteEditorScreen), findsNothing);
    });

    testWidgets('a name-only edit: Cancel keeps it, Discard stores nothing, '
        'Save stores it', (tester) async {
      await build(tester, sites: [site('Original', 46, 14)]);
      await pump(
        tester,
        at: AppRouter.siteEdit,
        extra: SiteEditorArgs(site: vm.sites.single),
      );
      await editOnly(tester, 'Name', 'Changed name');
      await back(tester, system: false);
      await tester.tap(find.byKey(const Key('unsaved.cancel')));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextFormField, 'Changed name'), findsOne);

      await back(tester, system: false);
      await tester.tap(find.byKey(const Key('unsaved.discard')));
      await tester.pumpAndSettle();
      expect(find.byType(SiteEditorScreen), findsNothing);
      expect(vm.sites.single.name, 'Original');

      await pump(
        tester,
        at: AppRouter.siteEdit,
        extra: SiteEditorArgs(site: vm.sites.single),
      );
      await editOnly(tester, 'Notes', 'Private note');
      await back(tester, system: false);
      await tester.tap(find.byKey(const Key('unsaved.save')));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(find.byType(SiteEditorScreen), findsNothing);
      expect(vm.sites.single.notes, 'Private note');
      expect(vm.sites.single.name, 'Original');
    });

    testWidgets('back without changes leaves; with changes it asks: Cancel '
        'stays, Discard leaves without saving', (tester) async {
      await build(tester);
      await pump(tester, at: AppRouter.siteEdit);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(SiteEditorScreen), findsNothing);

      await pump(tester, at: AppRouter.siteEdit);
      await typeSite(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Unsaved changes'), findsOneWidget);
      await tester.tap(find.byKey(const Key('unsaved.cancel')));
      await tester.pumpAndSettle();
      expect(find.byType(SiteEditorScreen), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Backyard'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('unsaved.discard')));
      await tester.pumpAndSettle();
      expect(find.byType(SiteEditorScreen), findsNothing);
      expect(vm.sites, isEmpty);
    });

    testWidgets('Save in the prompt saves and leaves', (tester) async {
      await build(tester);
      await pump(tester, at: AppRouter.siteEdit);
      await typeSite(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('unsaved.save')));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      expect(vm.sites.single.name, 'Backyard');
      expect(find.byType(SiteEditorScreen), findsNothing);
    });

    testWidgets('sky darkness: collapsed, its summary states what is '
        'stored, remembered; the map link needs valid coordinates', (
      tester,
    ) async {
      await build(
        tester,
        sites: [
          domain.LocationProfile(
            id: 0,
            name: 'Home',
            latitude: 46.05,
            longitude: 14.51,
            bortleClass: 4,
            bortleSource: 'user',
            timeZoneId: 'Europe/Ljubljana',
          ),
        ],
      );
      await tester.runAsync(() => vm.selectSite(1));
      await pump(
        tester,
        at: AppRouter.siteEdit,
        extra: SiteEditorArgs(site: vm.sites.single),
      );
      expect(find.text('Sky darkness (optional)'), findsOneWidget);
      expect(find.text('Bortle 4'), findsOneWidget, reason: 'the summary');
      expect(find.text('SQM (mag/arcsec²)'), findsNothing, reason: 'closed');

      await openSkyDarkness(tester);
      expect(
        vm.disclosure.isOpen(SiteEditorScreen.skyDarknessSection),
        isTrue,
        reason: 'remembered like the planner sections',
      );
      TextButton link() => tester.widget<TextButton>(
        find.byKey(const Key('siteEditor.mapLink')),
      );
      expect(link().onPressed, isNotNull);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Latitude (°)'),
        '95',
      );
      await tester.pump();
      expect(link().onPressed, isNull);
    });

    testWidgets('a new site: sky darkness Unknown; an out-of-range SQM in the '
        'closed section opens it and shows the message', (tester) async {
      await build(tester);
      await pump(tester, at: AppRouter.siteEdit);
      expect(find.text('Unknown'), findsOneWidget, reason: 'the summary');
      await openSkyDarkness(tester);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'SQM (mag/arcsec²)'),
        '30',
      );
      await openSkyDarkness(tester); // closes it again
      await typeSite(tester);
      await save(tester);
      expect(find.text('SQM must be between 15 and 23'), findsOneWidget);
      expect(vm.sites, isEmpty);
    });
  });
}
