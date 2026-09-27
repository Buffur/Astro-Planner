// S1.12 (ENG-08 = RT-04): an edit tapped right after Save or Start, before
// their database work has finished, must not be lost or mixed into the
// saved or started session. Driven through the planner's own buttons with
// the real database — no injected delays.

import 'dart:async';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/session.dart';
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
  late DriftSessionRepository sessions;
  late PlannerHarness vm;

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
      final clock = FixedClock(DateTime.utc(2026, 11, 10, 18));
      sessions = DriftSessionRepository(db, clock: clock);
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoForecast(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: clock,
        sessionRepository: sessions,
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

  final deleteBlock = find.byTooltip('Delete block');

  testWidgets('Save, then an edit: the planner and the stored session agree, '
      'and the edit counts as unsaved', (tester) async {
    await start(tester);
    final saveButton = find.text('Save plan');
    await tester.ensureVisible(deleteBlock.first);
    final before = vm.captureBlocks.length;

    await tester.tap(saveButton);
    await tester.tap(deleteBlock.first); // before Save has finished
    await settle(tester);
    await tester.runAsync(() => vm.plan.idle);

    expect(vm.captureBlocks, hasLength(before - 1));
    final stored = (await tester.runAsync(
      () => sessions.get(vm.activeSessionId!),
    ))!;
    expect(stored.blocks, hasLength(before - 1));
    expect(stored.status, SessionStatus.draft, reason: 'edited after Save');
    expect(stored.plannedAtUtc, isNotNull, reason: 'it was saved');
    expect(stored.planSnapshot!.json['blocks'], hasLength(before));
    expect(vm.plan.hasUnsavedChanges, isTrue);
  });

  testWidgets('Start, then an edit: the run keeps the plan it started with; '
      'the edit goes to the planner\'s copy', (tester) async {
    await start(tester);
    await tester.ensureVisible(deleteBlock.first);
    final before = vm.captureBlocks.length;
    // S6.2: Track live is in the ⋮ menu, for a saved plan.
    await tester.tap(find.text('Save plan'));
    await settle(tester);
    final original = vm.activeSessionId!;
    await tester.tap(find.byKey(const Key('planner.menu')));
    await settle(tester);

    await tester.tap(find.byKey(const Key('planner.start')));
    // Before Start has finished. The closing menu still covers the row's
    // Delete for its exit animation, so the edit is the call that button
    // makes (S6.2 moved Start into the menu).
    unawaited(vm.plan.removeCaptureBlock(0));
    await settle(tester);
    await tester.runAsync(() => vm.plan.idle);

    final run = (await tester.runAsync(() => sessions.get(original)))!;
    expect(run.status, SessionStatus.inProgress);
    expect(run.blocks, hasLength(before), reason: 'as started');
    expect(run.executionStartSnapshot!.json['blocks'], hasLength(before));

    expect(vm.activeSessionId, isNot(original));
    expect(vm.captureBlocks, hasLength(before - 1));
    final copy = (await tester.runAsync(
      () => sessions.get(vm.activeSessionId!),
    ))!;
    expect(copy.blocks, hasLength(before - 1), reason: 'the edit is kept');
  });
}

/// Pumps fixed frames with real-time gaps (database work; TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
