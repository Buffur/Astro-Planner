// S11.C1 (TD-092, S11F-01): the shell keeps the Logbook tab alive, and the
// planner covers it. A plan saved while the Logbook is out of view must be
// listed when the Logbook comes back into view, without a restart. Found on
// the emulator in S11.3. Through the real app, router and database.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

void main() {
  late AppDatabase db;
  late PlannerHarness vm;

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// The Logbook's entries on screen.
  Finder entries() => find.byWidgetPredicate(
    (w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('logbook.title.'),
  );

  /// A plan for [night], saved through the lifecycle (as the planner's Save).
  Future<void> savePlanFor(WidgetTester tester, CalendarDate night) =>
      tester.runAsync(() async {
        await vm.lifecycle.newSession();
        await vm.choosePlan();
        await vm.plan.setEveningDate(night);
        await vm.plan.idle;
        await vm.analysis.saveSession();
        await vm.plan.idle;
      });

  Future<void> start(WidgetTester tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({});
      final clock = FixedClock(DateTime.utc(2026, 11, 10, 16));
      db = AppDatabase(NativeDatabase.memory());
      await CatalogSeeder(DriftTargetRepository(db)).seedIfNeeded();
      await EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded();
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoForecast(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        sessionRepository: DriftSessionRepository(db, clock: clock),
        clock: clock,
      );
      await vm.ready;
      await vm.site.setLocation(46.05, 14.51);
    });
    addTearDown(() => tester.runAsync(db.close));
    await savePlanFor(tester, CalendarDate(2026, 11, 12));
    AppRouter.router.go(AppRouter.sessions);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
    expect(entries(), findsOneWidget);
  }

  testWidgets('a plan saved while another tab is shown is listed on coming '
      'back to the Logbook', (tester) async {
    await start(tester);
    await tester.tap(find.text('Tonight').last);
    await settle(tester);
    await savePlanFor(tester, CalendarDate(2026, 11, 14));
    await tester.tap(find.text('Logbook').last);
    await settle(tester);
    expect(entries(), findsNWidgets(2));
  });

  testWidgets('a plan saved in the planner opened over the Logbook is listed '
      'when the planner closes', (tester) async {
    await start(tester);
    AppRouter.router.push(AppRouter.session());
    await settle(tester);
    expect(find.text('Plan'), findsWidgets);
    await savePlanFor(tester, CalendarDate(2026, 11, 14));
    AppRouter.router.pop();
    await settle(tester);
    expect(entries(), findsNWidgets(2));
  });
}
