// S6.8 (P6.2, P6.1's New plan; RD-04; UX-24): nothing the user did not
// choose looks chosen. A fresh install selects no target and no rig and
// starts with an empty capture plan, a neutral status and "Start from the
// example plan"; the example is badged until the first edit (TASK 4.4); New
// plan keeps the site and the rig and asks for a target; the shipped rig
// says it is an example where it is listed and chosen. Through the real app
// and database.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/example_capture_plan.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/shared/app_words.dart';
import 'package:astroplan/presentation/shared/example_text.dart';
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

  /// A fresh install with a site, the seeded catalog and the seeded rig.
  Future<void> start(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
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
          timeZoneId: 'Europe/Ljubljana',
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': siteId});
      final clock = FixedClock(DateTime.utc(2026, 11, 10, 16));
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoForecast(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: clock,
        sessionRepository: DriftSessionRepository(db, clock: clock),
      );
      await vm.ready;
    });
    addTearDown(() => tester.runAsync(db.close));
    AppRouter.router.go(AppRouter.session());
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  final status = find.byKey(const Key('planner.status'));
  Finder inStatus(String text) =>
      find.descendant(of: status, matching: find.text(text));
  final offer = find.byKey(const Key('capturePlan.useExample'));

  testWidgets('a fresh install: no target, no rig, an empty capture plan '
      'with the offer, and a neutral status', (tester) async {
    await start(tester);
    expect(vm.selectedTarget, isNull);
    expect(vm.selectedEquipment, isNull);
    expect(vm.captureBlocks, isEmpty);

    expect(inStatus(AppWords.needsTarget), findsOneWidget);
    expect(find.byKey(const Key('status.choose')), findsOneWidget);
    expect(find.byKey(const Key('planner.noTarget')), findsOneWidget);
    expect(find.byKey(const Key('planner.noRig')), findsOneWidget);
    expect(find.textContaining('Target:'), findsNothing);
    expect(find.textContaining('${AppWords.rig}:'), findsNothing);
    expect(offer, findsOneWidget);
    expect(find.text(ExampleText.plan), findsNothing);
    // Neutral: the status names the missing input, not a failure.
    for (final verdict in [AppWords.noWindow, AppWords.doesNotFit]) {
      expect(inStatus(verdict), findsNothing);
    }
  });

  testWidgets('the offer fills exactly the example plan, badged until the '
      'first edit (TASK 4.4)', (tester) async {
    await start(tester);
    await tester.tap(offer);
    await settle(tester);
    await tester.runAsync(() => vm.plan.idle);

    final example = ExampleCapturePlan.blocks();
    expect(vm.captureBlocks, hasLength(example.length));
    expect(ExampleCapturePlan.matches(vm.captureBlocks), isTrue);
    expect(vm.isExampleCapturePlan, isTrue);
    expect(find.text(ExampleText.plan), findsOneWidget);
    expect(offer, findsNothing);
    final stored = await tester.runAsync(
      () => DriftSessionRepository(db).get(vm.activeSessionId!),
    );
    expect(ExampleCapturePlan.matches(stored!.blocks), isTrue);

    await tester.runAsync(
      () => vm.plan.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          filterName: 'Ha',
          exposureTimeSeconds: 300,
          frameCount: 7,
        ),
      ),
    );
    await settle(tester);
    expect(vm.isExampleCapturePlan, isFalse);
    expect(find.text(ExampleText.plan), findsNothing);
  });

  testWidgets('New plan keeps the site and the rig and asks for a target', (
    tester,
  ) async {
    await start(tester);
    await tester.runAsync(() => vm.choosePlan());
    await settle(tester);
    final rig = vm.selectedEquipment!;
    final site = vm.activeSite!;
    expect(inStatus(AppWords.needsTarget), findsNothing);

    await tester.tap(find.byKey(const Key('planner.menu')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('planner.newPlan')));
    await settle(tester);
    // The chosen plan has unsaved changes: Discard them (S6.3).
    await tester.tap(find.byKey(const Key('unsaved.discard')));
    await settle(tester);
    await tester.runAsync(() => vm.plan.idle);

    expect(vm.selectedTarget, isNull);
    expect(vm.selectedEquipment!.id, rig.id);
    expect(vm.activeSite!.id, site.id);
    expect(vm.captureBlocks, isEmpty);
    expect(inStatus(AppWords.needsTarget), findsOneWidget);
    expect(find.byKey(const Key('status.choose')), findsOneWidget);
    expect(find.textContaining('${AppWords.rig}: ${rig.name}'), findsOneWidget);
    expect(offer, findsOneWidget);
  });

  testWidgets('the shipped rig says it is an example where it is chosen and '
      'listed', (tester) async {
    await start(tester);
    await tester.runAsync(() => vm.choosePlan());
    await settle(tester);
    expect(vm.selectedEquipment!.isExample, isTrue);
    expect(find.text(ExampleText.rigNote), findsOneWidget);

    AppRouter.router.push(AppRouter.selectRig);
    await settle(tester);
    expect(find.textContaining('${ExampleText.rig} · '), findsOneWidget);
  });
}

/// Pumps fixed frames with real-time gaps (database work; TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
