// S1.6 (RT-05 / UX-12; RD-05 interim): New, Duplicate and opening another
// session ask before leaving a plan with unsaved changes; an untouched
// draft is replaced without asking. Through the real app and database.

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

final _discardTitle = find.text('Discard unsaved changes?');
final _discard = find.byKey(const Key('unsavedPlan.discard'));

void main() {
  late AppDatabase db;
  late PlannerHarness vm;

  Future<void> start(WidgetTester tester, String location) async {
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
    AppRouter.router.go(location);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
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
    await start(tester, AppRouter.session());
    final before = vm.activeSessionId;
    await tester.tap(find.byTooltip('New Session'));
    await settle(tester);
    expect(_discardTitle, findsNothing);
    expect(vm.activeSessionId, isNot(before));
  });

  testWidgets('New with unsaved changes asks: Cancel keeps the plan, Discard '
      'starts a new one', (tester) async {
    await start(tester, AppRouter.session());
    await edit(tester);
    final before = vm.activeSessionId;

    await tester.tap(find.byTooltip('New Session'));
    await settle(tester);
    expect(_discardTitle, findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(vm.activeSessionId, before);
    expect(vm.captureBlocks.last.frameCount, 7);

    await tester.tap(find.byTooltip('New Session'));
    await settle(tester);
    await tester.tap(_discard);
    await settle(tester);
    expect(vm.activeSessionId, isNot(before));
    expect(vm.isExampleCapturePlan, isTrue);
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
      await tester.tap(find.byTooltip('New Session'));
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
    await tester.tap(find.byTooltip('Duplicate for another night'));
    await settle(tester);
    expect(_discardTitle, findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('Duplicate for which night?'), findsNothing);

    await tester.tap(find.byTooltip('Duplicate for another night'));
    await settle(tester);
    await tester.tap(_discard);
    await settle(tester);
    expect(find.text('Duplicate for which night?'), findsOneWidget);
  });

  testWidgets("Tonight's New session asks too", (tester) async {
    await start(tester, AppRouter.tonight);
    await edit(tester);
    final before = vm.activeSessionId;
    final button = find.byKey(const Key('tonight.newSession'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await settle(tester);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(vm.activeSessionId, before);
    expect(find.text('Session planner'), findsNothing);

    await tester.tap(button);
    await settle(tester);
    await tester.tap(_discard);
    await settle(tester);
    expect(vm.activeSessionId, isNot(before));
    expect(find.text('Session planner'), findsOneWidget);
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
    await tester.tap(find.text('Cancel'));
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
}

/// Pumps fixed frames with real-time gaps (database reads; TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
