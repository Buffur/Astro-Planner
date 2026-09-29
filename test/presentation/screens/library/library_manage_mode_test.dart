// S9.1 (RD-07, TD-053; E.1, D9-1, D9-2): the Library manages. A tap on a
// rig, target or site opens it and never changes the plan or the active
// site; the same lists opened to choose (`/select/…`) still choose. "Plan
// this target" starts a new plan after the leave guard. Rigs, targets and
// sites are deleted through the shared confirmation, from a visible Delete
// or a swipe; a cancelled delete leaves everything as it was.

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

import '../../../support/fake_device_time_zone.dart';
import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

void main() {
  late AppDatabase db;
  late PlannerHarness vm;
  late int homeId;

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
      homeId = await sites.insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Home',
          latitude: 46.05,
          longitude: 14.51,
          elevation: 300,
          timeZoneId: 'Europe/Ljubljana',
        ),
      );
      await sites.insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Dark site',
          latitude: 45.9,
          longitude: 14.2,
          elevation: 900,
          timeZoneId: 'Europe/Ljubljana',
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': homeId});
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
      await vm.choosePlan(); // M42, the first rig, the example plan
      await vm.plan.idle;
    });
    addTearDown(() => tester.runAsync(db.close));
    AppRouter.router.go(route);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  testWidgets('a tap on a rig in the Library opens it; the plan keeps its '
      'rig', (tester) async {
    await start(tester, AppRouter.libraryRigs);
    final rig = vm.plan.selectedEquipment!;
    expect(find.byIcon(Icons.check_circle), findsNothing);
    await tester.tap(find.widgetWithText(ListTile, rig.name));
    await settle(tester);
    expect(find.text('Edit rig'), findsOneWidget);
    expect(find.byKey(const Key('rigEditor.delete')), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(vm.plan.selectedEquipment!.id, rig.id);
    expect(find.text('Rigs'), findsWidgets);
  });

  testWidgets('a tap on a target in the Library opens it; the plan keeps its '
      'target; Plan this target asks first, then plans it', (tester) async {
    await start(tester, AppRouter.libraryTargets);
    final m42 = vm.plan.selectedTarget!;
    await tester.enterText(find.byType(TextField).first, 'M31');
    await settle(tester);
    await tester.tap(find.widgetWithText(ListTile, 'Andromeda Galaxy (M31)'));
    await settle(tester);
    expect(find.text('Edit target'), findsOneWidget);
    expect(
      vm.plan.selectedTarget!.id,
      m42.id,
      reason: 'browsing chose nothing',
    );

    await tester.tap(find.byKey(const Key('targetEditor.plan')));
    await settle(tester);
    // The plan has unsaved edits (choosePlan): Save · Discard · Cancel.
    expect(find.byKey(const Key('unsaved.discard')), findsOneWidget);
    await tester.tap(find.byKey(const Key('unsaved.discard')));
    await settle(tester);
    expect(vm.plan.selectedTarget!.catalogId, 'M31');
    expect(find.text('New plan for Andromeda Galaxy'), findsOneWidget);
  });

  testWidgets('a tap on a site in the Library opens it and never changes the '
      'active site; from /select/site it does', (tester) async {
    await start(tester, AppRouter.librarySites);
    expect(vm.site.activeSite!.id, homeId);
    await tester.tap(find.text('Dark site'));
    await settle(tester);
    expect(vm.site.activeSite!.id, homeId, reason: 'browsing selects nothing');
    expect(find.text('Dark site'), findsWidgets); // the editor, pre-filled

    AppRouter.router.go(AppRouter.selectSite);
    await settle(tester);
    expect(find.text('Choose a site'), findsOneWidget);
    await tester.tap(find.text('Dark site'));
    await settle(tester);
    expect(vm.site.activeSite!.name, 'Dark site');
  });

  testWidgets('from /select/target a tap still chooses', (tester) async {
    await start(tester, AppRouter.tonight);
    AppRouter.router.push(AppRouter.selectTarget); // as the planner opens it
    await settle(tester);
    expect(find.text('Choose a target'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'M31');
    await settle(tester);
    await tester.tap(find.widgetWithText(ListTile, 'Andromeda Galaxy (M31)'));
    await settle(tester);
    expect(vm.plan.selectedTarget!.catalogId, 'M31');
  });

  testWidgets('deleting a rig: a cancelled swipe keeps it; the editor\'s '
      'Delete confirms, deletes and says so', (tester) async {
    await start(tester, AppRouter.libraryRigs);
    final before = await tester.runAsync(
      () => DriftEquipmentRepository(db).getAllEquipment(),
    );
    final last = before!.last;
    final row = find.widgetWithText(ListTile, last.name);

    await tester.drag(row, const Offset(-500, 0));
    await settle(tester);
    expect(find.text('Delete this rig?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm.cancel')));
    await settle(tester);
    expect(row, findsOneWidget, reason: 'the row springs back');

    await tester.tap(row);
    await settle(tester);
    await tester.tap(find.byKey(const Key('rigEditor.delete')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('confirm.action')));
    await settle(tester);
    expect(find.text('Rig deleted'), findsOneWidget);
    expect(find.widgetWithText(ListTile, last.name), findsNothing);
    final after = await tester.runAsync(
      () => DriftEquipmentRepository(db).getAllEquipment(),
    );
    expect(after, hasLength(before.length - 1));
  });

  testWidgets('deleting a site confirms through the shared dialog', (
    tester,
  ) async {
    await start(tester, AppRouter.librarySites);
    await tester.tap(find.byTooltip('Delete site').last);
    await settle(tester);
    expect(find.text('Delete this site?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm.action')));
    await settle(tester);
    expect(find.text('Site deleted'), findsOneWidget);
    expect(vm.site.sites.map((s) => s.name), ['Home']);
  });
}
