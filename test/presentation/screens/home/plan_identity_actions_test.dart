// S6.2 (UX-04, ADR-019 §3 and §6; TD-058): the planner says which plan it
// shows and in what state; its plan actions sit in the ⋮ menu, Track live
// only for a saved plan; each action says what happened; an edit made while
// New or Copy is creating the new draft lands in it. Driven through the
// planner with the real database.

import 'dart:async';

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
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/shared/night_time_formatter.dart';
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

final _extra = CaptureBlock(
  frameType: FrameType.light,
  filterName: 'Ha',
  exposureTimeSeconds: 300,
  frameCount: 7,
);

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

  final identity = find.byKey(const Key('planner.identity'));
  Finder inIdentity(String text) =>
      find.descendant(of: identity, matching: find.text(text));

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('planner.menu')));
    await settle(tester);
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('planner.save')));
    await settle(tester);
    await tester.runAsync(() => vm.plan.idle);
  }

  testWidgets('the identity shows the target, the night and the state: Not '
      'saved, then Saved, then Saved · changed', (tester) async {
    await start(tester);
    final target = vm.selectedTarget!;
    expect(inIdentity(target.commonName ?? target.catalogId), findsOneWidget);
    expect(
      inIdentity('Night of ${NightTimeFormatter.eveningDate(vm.eveningDate!)}'),
      findsOneWidget,
    );
    expect(inIdentity('Not saved'), findsOneWidget);

    await save(tester);
    expect(inIdentity('Saved'), findsOneWidget);

    await tester.runAsync(() => vm.addCaptureBlock(_extra));
    await settle(tester);
    expect(inIdentity('Saved · changed'), findsOneWidget);
    expect(find.text('Session planner'), findsNothing);
  });

  testWidgets('Track live is in the menu only for a saved plan', (
    tester,
  ) async {
    await start(tester);
    await openMenu(tester);
    expect(find.byKey(const Key('planner.newPlan')), findsOneWidget);
    expect(find.byKey(const Key('planner.copy')), findsOneWidget);
    expect(find.byKey(const Key('planner.start')), findsNothing);
    await tester.tapAt(const Offset(4, 4)); // close the menu
    await settle(tester);

    await save(tester);
    await openMenu(tester);
    expect(find.text('Track live (optional)'), findsOneWidget);
    expect(find.byKey(const Key('planner.start')), findsOneWidget);
  });

  testWidgets('each action says what happened: Save, New plan, Copy, Open', (
    tester,
  ) async {
    await start(tester);
    await save(tester);
    expect(find.text('Plan saved'), findsOneWidget);
    final saved = vm.activeSessionId!;

    await openMenu(tester);
    await tester.tap(find.byKey(const Key('planner.newPlan')));
    await settle(tester);
    expect(find.text('New plan started'), findsOneWidget);
    expect(vm.activeSessionId, isNot(saved));

    final night = vm.eveningDate!;
    await openMenu(tester);
    await tester.tap(find.byKey(const Key('planner.copy')));
    await settle(tester);
    expect(find.text('Choose a night'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await settle(tester);
    expect(
      find.text(
        'Copied to ${NightTimeFormatter.eveningDate(night.addDays(1))}',
      ),
      findsOneWidget,
    );
    expect(vm.eveningDate, night.addDays(1));

    AppRouter.router.go(AppRouter.sessionDetail(saved));
    await settle(tester);
    final open = find.byKey(const Key('detail.openInPlanner'));
    await tester.ensureVisible(open);
    await tester.tap(open);
    await settle(tester);
    // S6.3 (W1): the copy is a new plan that is not saved, so Open asks.
    expect(find.text('Unsaved changes'), findsOneWidget);
    await tester.tap(find.byKey(const Key('unsaved.discard')));
    await settle(tester);
    expect(find.text('Plan opened'), findsOneWidget);
    expect(vm.activeSessionId, saved);
  });

  testWidgets('TD-058: an edit made while New plan creates its draft lands in '
      'the new draft, not the old one', (tester) async {
    await start(tester);
    final old = vm.activeSessionId!;

    await openMenu(tester);
    await tester.tap(find.byKey(const Key('planner.newPlan')));
    // Before New has finished. The closing menu still covers the planner,
    // so the edit is the call the capture plan's buttons make.
    unawaited(vm.plan.addCaptureBlock(_extra));
    await settle(tester);
    await tester.runAsync(() => vm.plan.idle);

    expect(vm.activeSessionId, isNot(old));
    final created = (await tester.runAsync(
      () => sessions.get(vm.activeSessionId!),
    ))!;
    expect(created.blocks.last.frameCount, 7, reason: 'the edit is kept');
    // S6.3: the old draft was never edited, so the switch deletes it; the
    // edit is in the new draft (above), not lost with the old one.
    expect(await tester.runAsync(() => sessions.get(old)), isNull);
    expect(vm.plan.hasUnsavedChanges, isTrue);
  });

  testWidgets('TD-058: an edit made while Copy creates its draft lands in the '
      'copy, not the original', (tester) async {
    await start(tester);
    final original = vm.activeSessionId!;

    await openMenu(tester);
    await tester.tap(find.byKey(const Key('planner.copy')));
    await settle(tester);
    await tester.tap(find.text('OK'));
    // Before Copy has finished (the picker is still closing).
    unawaited(vm.plan.addCaptureBlock(_extra));
    await settle(tester);
    await tester.runAsync(() => vm.plan.idle);

    expect(vm.activeSessionId, isNot(original));
    final copy = (await tester.runAsync(
      () => sessions.get(vm.activeSessionId!),
    ))!;
    expect(copy.blocks.last.frameCount, 7, reason: 'the edit is kept');
    // S6.3: the original was never edited, so the switch deletes it; the
    // edit is in the copy (above), not lost with the original.
    expect(await tester.runAsync(() => sessions.get(original)), isNull);
  });
}

/// Pumps fixed frames with real-time gaps (database work; TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
