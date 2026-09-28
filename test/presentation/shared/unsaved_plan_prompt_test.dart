// S6.3 (U1, W1, V3, UX-12; S4-DEF-04 = R; supersedes S1.6's guard): New
// plan, Copy to another night, Tonight's New and Open ask Save · Discard ·
// Cancel before leaving a plan with unsaved changes, and each answer does
// what it says; an untouched never-saved draft is replaced without asking and
// deleted. Through the real app and database. The first cases are S1.6's,
// mapped to the new prompt.

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
import 'package:astroplan/domain/models/session.dart';
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

final _discardTitle = find.text('Unsaved changes');
final _discard = find.byKey(const Key('unsaved.discard'));
final _cancel = find.byKey(const Key('unsaved.cancel'));
final _save = find.byKey(const Key('unsaved.save'));

void main() {
  late AppDatabase db;
  late PlannerHarness vm;
  late DriftSessionRepository sessions;

  /// [choose]: the plan a user makes (S6.8: nothing is preselected); false
  /// keeps the first run's untouched, empty plan.
  Future<void> start(
    WidgetTester tester,
    String location, {
    bool choose = true,
  }) async {
    tester.view.physicalSize = const Size(800, 2400);
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
      if (choose) await vm.choosePlan();
    });
    addTearDown(() => tester.runAsync(db.close));
    AppRouter.router.go(location);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  /// Picks a plan action from the planner's ⋮ menu (S6.2 moved New and
  /// Copy there from the app bar).
  Future<void> planAction(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(const Key('planner.menu')));
    await settle(tester);
    await tester.tap(find.byKey(Key(key)));
  }

  Future<void> edit(WidgetTester tester) => tester.runAsync(
    () => vm.addCaptureBlock(
      CaptureBlock(
        frameType: FrameType.light,
        filterName: 'Ha',
        exposureTimeSeconds: 300,
        frameCount: 7,
      ),
    ),
  );

  testWidgets('New on an untouched draft does not ask', (tester) async {
    await start(tester, AppRouter.session(), choose: false);
    final before = vm.activeSessionId;
    await planAction(tester, 'planner.newPlan');
    await settle(tester);
    expect(_discardTitle, findsNothing);
    expect(vm.activeSessionId, isNot(before));
    // S6.3: the untouched draft is not left behind.
    expect(await tester.runAsync(() => sessions.get(before!)), isNull);
  });

  testWidgets('New with unsaved changes asks: Cancel keeps the plan, Discard '
      'starts a new one', (tester) async {
    await start(tester, AppRouter.session());
    await edit(tester);
    final before = vm.activeSessionId;

    await planAction(tester, 'planner.newPlan');
    await settle(tester);
    expect(_discardTitle, findsOneWidget);
    await tester.tap(_cancel);
    await settle(tester);
    expect(vm.activeSessionId, before);
    expect(vm.captureBlocks.last.frameCount, 7);

    await planAction(tester, 'planner.newPlan');
    await settle(tester);
    await tester.tap(_discard);
    await settle(tester);
    expect(vm.activeSessionId, isNot(before));
    // S6.8 (RD-04): a new plan has no target and an empty capture plan
    // (before: the example plan).
    expect(vm.selectedTarget, isNull);
    expect(vm.captureBlocks, isEmpty);
  });

  // The accessibility sweep's three themes (S1.17): contrast is not asserted
  // in field mode, whose secondary red is below AA by design (B16).
  for (final (theme, brightness, field) in [
    ('light', Brightness.light, false),
    ('dark', Brightness.dark, false),
    ('field', Brightness.dark, true),
  ]) {
    testWidgets('the dialog is accessible at 200 % text ($theme)', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final semantics = tester.ensureSemantics();
      await start(tester, AppRouter.session());
      if (field) {
        await tester.runAsync(() => vm.theme.toggleFieldMode());
        await settle(tester);
        expect(vm.theme.isFieldMode, isTrue);
      }
      tester.view.physicalSize = const Size(412, 915);
      await edit(tester);
      await planAction(tester, 'planner.newPlan');
      await settle(tester);
      expect(_discardTitle, findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'no overflow');
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      if (!field) {
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      }
      semantics.dispose();
    });
  }

  // S1.V4 (TD-062): the detail page keeps the Session it loaded; opening the
  // current session again must not bring that stale copy back.
  testWidgets('reopening the current session from its detail keeps the live '
      'plan, through a Save and a restart', (tester) async {
    await start(tester, AppRouter.session());
    final saved = await tester.runAsync(() => vm.saveSession());
    AppRouter.router.go(AppRouter.sessionDetail(saved!.id));
    await settle(tester);
    final open = find.byKey(const Key('detail.openInPlanner'));
    await tester.ensureVisible(open);
    await tester.tap(open);
    await settle(tester);
    await edit(tester);
    expect(vm.captureBlocks.last.frameCount, 7);

    AppRouter.router.pop();
    await settle(tester);
    await tester.ensureVisible(open);
    await tester.tap(open);
    await settle(tester);
    expect(_discardTitle, findsNothing);
    expect(vm.activeSessionId, saved.id);
    expect(vm.captureBlocks.last.frameCount, 7);
    expect(vm.plan.hasUnsavedChanges, isTrue);

    await tester.runAsync(() => vm.saveSession());
    final stored = await tester.runAsync(
      () => DriftSessionRepository(db).get(saved.id),
    );
    expect(stored!.blocks.last.frameCount, 7);
    final restarted = await tester.runAsync(() async {
      final again = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoForecast(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone(),
        sessionRepository: DriftSessionRepository(db),
      );
      await again.ready;
      return again;
    });
    expect(restarted!.captureBlocks.last.frameCount, 7);
  });

  testWidgets('Duplicate with unsaved changes asks before the date picker', (
    tester,
  ) async {
    await start(tester, AppRouter.session());
    await edit(tester);
    await planAction(tester, 'planner.copy');
    await settle(tester);
    expect(_discardTitle, findsOneWidget);
    await tester.tap(_cancel);
    await settle(tester);
    expect(find.text('Choose a night'), findsNothing);

    await planAction(tester, 'planner.copy');
    await settle(tester);
    await tester.tap(_discard);
    await settle(tester);
    expect(find.text('Choose a night'), findsOneWidget);
  });

  testWidgets("Tonight's New session asks too", (tester) async {
    await start(tester, AppRouter.tonight);
    await edit(tester);
    final before = vm.activeSessionId;
    final button = find.byKey(const Key('tonight.newSession'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await settle(tester);
    await tester.tap(_cancel);
    await settle(tester);
    expect(vm.activeSessionId, before);
    expect(find.text('Plan'), findsNothing);

    await tester.tap(button);
    await settle(tester);
    await tester.tap(_discard);
    await settle(tester);
    expect(vm.activeSessionId, isNot(before));
    expect(find.text('Plan'), findsOneWidget);
  });

  testWidgets('opening another session asks; opening the current one does '
      'not', (tester) async {
    await start(tester, AppRouter.session());
    final saved = await tester.runAsync(() => vm.saveSession());
    await tester.runAsync(() => vm.newSession());
    await edit(tester);
    final before = vm.activeSessionId;

    AppRouter.router.go(AppRouter.sessionDetail(saved!.id));
    await settle(tester);
    final open = find.byKey(const Key('detail.openInPlanner'));
    await tester.ensureVisible(open);
    await tester.tap(open);
    await settle(tester);
    expect(_discardTitle, findsOneWidget);
    await tester.tap(_cancel);
    await settle(tester);
    expect(vm.activeSessionId, before);

    await tester.tap(open);
    await settle(tester);
    await tester.tap(_discard);
    await settle(tester);
    expect(vm.activeSessionId, saved.id);

    // Now current: opening it again asks nothing.
    AppRouter.router.go(AppRouter.sessionDetail(saved.id));
    await settle(tester);
    await tester.ensureVisible(open);
    await tester.tap(open);
    await settle(tester);
    expect(_discardTitle, findsNothing);
  });

  // S6.3: every answer at every caller. Before each case the planner holds
  // a plan with unsaved changes (never saved, or saved then changed), and
  // another saved plan exists for Open.
  const callers = ['New plan', 'Copy', "Tonight's New", 'Open'];
  const answers = [
    ('Save', false),
    ('Discard', false),
    ('Discard', true),
    ('Cancel', false),
    ('dismiss', false),
  ];

  Future<int> otherSavedPlan(WidgetTester tester) async {
    final saved = await tester.runAsync(() => vm.saveSession());
    await tester.runAsync(() => vm.newSession());
    // S6.8: New asks for a target; choose one so the plan can be saved.
    await tester.runAsync(() => vm.choosePlan());
    await settle(tester);
    return saved!.id;
  }

  Future<void> trigger(WidgetTester tester, String caller, int other) async {
    switch (caller) {
      case 'New plan':
        await planAction(tester, 'planner.newPlan');
      case 'Copy':
        await planAction(tester, 'planner.copy');
      case "Tonight's New":
        AppRouter.router.go(AppRouter.tonight);
        await settle(tester);
        final button = find.byKey(const Key('tonight.newSession'));
        await tester.ensureVisible(button);
        await tester.tap(button);
      case 'Open':
        AppRouter.router.go(AppRouter.sessionDetail(other));
        await settle(tester);
        final open = find.byKey(const Key('detail.openInPlanner'));
        await tester.ensureVisible(open);
        await tester.tap(open);
    }
    await settle(tester);
  }

  for (final caller in callers) {
    for (final (answer, savedFirst) in answers) {
      final what = savedFirst ? 'a saved plan with changes' : 'a new plan';
      testWidgets('$caller, $answer on $what', (tester) async {
        await start(tester, AppRouter.session());
        final other = await otherSavedPlan(tester);
        if (savedFirst) await tester.runAsync(() => vm.saveSession());
        await edit(tester);
        await settle(tester);
        final before = vm.activeSessionId!;
        final was = (await tester.runAsync(() => sessions.get(before)))!;

        await trigger(tester, caller, other);
        expect(_discardTitle, findsOneWidget);
        switch (answer) {
          case 'Save':
            await tester.tap(_save);
          case 'Discard':
            await tester.tap(_discard);
          case 'Cancel':
            await tester.tap(_cancel);
          case 'dismiss':
            await tester.tapAt(const Offset(5, 5));
        }
        await settle(tester);
        final goesOn = answer == 'Save' || answer == 'Discard';
        if (goesOn && caller == 'Copy') {
          await tester.tap(find.text('OK'));
          await settle(tester);
        }
        await tester.runAsync(() => vm.plan.idle);
        final row = await tester.runAsync(() => sessions.get(before));

        if (!goesOn) {
          expect(vm.activeSessionId, before);
          expect(row!.status, was.status);
          expect(row.blocks.last.frameCount, 7, reason: 'the change stays');
          return;
        }
        expect(vm.activeSessionId, caller == 'Open' ? other : isNot(before));
        if (answer == 'Save') {
          expect(row!.status, SessionStatus.planned);
          expect(row.blocks.last.frameCount, 7, reason: 'saved as edited');
        } else if (savedFirst) {
          expect(row!.status, SessionStatus.planned, reason: 'reverted');
          expect(row.blocks.last.frameCount, isNot(7));
          expect(row.planSnapshot!.json, was.planSnapshot!.json);
          expect(row.plannedAtUtc, was.plannedAtUtc);
        } else {
          expect(row, isNull, reason: 'a never-saved plan is deleted');
        }
      });
    }
  }

  PlannerHarness restart() => PlannerHarness(
    DriftTargetRepository(db),
    DriftEquipmentRepository(db),
    _NoForecast(),
    DriftLocationRepository(db),
    locationService: FakeLocationService(),
    reverseGeocoder: FakeReverseGeocoder(),
    deviceTimeZone: FakeDeviceTimeZone(),
    clock: FixedClock(DateTime.utc(2026, 11, 10, 18)),
    sessionRepository: sessions,
  );

  testWidgets('after Discard, and after replacing an untouched plan, a '
      'restart resumes the new plan', (tester) async {
    await start(tester, AppRouter.session());
    await edit(tester);
    final discarded = vm.activeSessionId!;
    await planAction(tester, 'planner.newPlan');
    await settle(tester);
    await tester.tap(_discard);
    await settle(tester);
    final untouched = vm.activeSessionId!;
    await planAction(tester, 'planner.newPlan');
    await settle(tester);
    expect(_discardTitle, findsNothing, reason: 'untouched: no prompt');
    await tester.runAsync(() => vm.plan.idle);
    final current = vm.activeSessionId!;

    final again = await tester.runAsync(() async {
      final h = restart();
      await h.ready;
      return h;
    });
    expect(again!.activeSessionId, current);
    expect(await tester.runAsync(() => sessions.get(discarded)), isNull);
    expect(await tester.runAsync(() => sessions.get(untouched)), isNull);
  });

  testWidgets('V3: a site change on a saved plan is an unsaved change', (
    tester,
  ) async {
    await start(tester, AppRouter.session());
    await tester.runAsync(() async {
      await vm.saveSession();
      final id = await DriftLocationRepository(db).insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Second site',
          latitude: 45.8,
          longitude: 15.9,
          elevation: 200,
          timeZoneId: 'Europe/Zagreb',
        ),
      );
      await vm.site.selectSite(id);
      await vm.plan.idle;
    });
    await settle(tester);
    expect(vm.plan.hasUnsavedChanges, isTrue);
    await planAction(tester, 'planner.newPlan');
    await settle(tester);
    expect(_discardTitle, findsOneWidget);
  });

  testWidgets('W1: a copy is a new plan that is not saved; leaving it asks', (
    tester,
  ) async {
    await start(tester, AppRouter.session(), choose: false);
    await planAction(tester, 'planner.copy');
    await settle(tester);
    expect(_discardTitle, findsNothing, reason: 'the original was untouched');
    await tester.tap(find.text('OK'));
    await settle(tester);
    await tester.runAsync(() => vm.plan.idle);
    expect(vm.plan.hasUnsavedChanges, isTrue);

    await planAction(tester, 'planner.newPlan');
    await settle(tester);
    expect(_discardTitle, findsOneWidget);
  });

  testWidgets('a refused Discard changes nothing and says why', (tester) async {
    await start(tester, AppRouter.session());
    final targetId = vm.selectedTarget!.id;
    await tester.runAsync(() => vm.saveSession());
    await edit(tester);
    final before = vm.activeSessionId!;
    await tester.runAsync(
      () => DriftTargetRepository(db).deleteTarget(targetId),
    );

    await planAction(tester, 'planner.newPlan');
    await settle(tester);
    await tester.tap(_discard);
    await settle(tester);

    expect(find.textContaining("Couldn't discard the changes"), findsOneWidget);
    expect(vm.activeSessionId, before);
    final row = (await tester.runAsync(() => sessions.get(before)))!;
    expect(row.status, SessionStatus.draft);
    expect(row.blocks.last.frameCount, 7);
  });
}

/// Pumps fixed frames with real-time gaps (database reads; TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
