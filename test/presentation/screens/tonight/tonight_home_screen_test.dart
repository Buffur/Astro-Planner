// The Tonight dashboard and first-run flow (TASK 12.5): the states for no
// site, no rig, no forecast, fits and doesn't fit; no overflow at 200 %
// text on a small phone; the first-run setup is offered once, only without
// a site, and Skip / Done close it for good.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/in_memory_first_run.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

const _m42 = AstroTarget(
  id: 1,
  catalogId: 'M42',
  commonName: 'Orion Nebula',
  type: 'Nebula',
  rightAscension: 83.82,
  declination: -5.39,
);

const _rig = EquipmentProfile(
  id: 1,
  name: 'Refractor 400',
  focalRatio: 5.0,
  focalLengthMm: 400.0,
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.6,
  resolutionWidthPx: 6000,
  resolutionHeightPx: 4000,
  pixelPitchUm: 3.76,
  averageRawFileSizeMB: 50.0,
);

CaptureBlock _lights(int count) => CaptureBlock(
  frameType: FrameType.light,
  filterName: 'L',
  exposureTimeSeconds: 60,
  frameCount: count,
);

void main() {
  late AppDatabase database;
  late PlannerHarness vm;
  late InMemoryFirstRun firstRun;

  /// Builds the app. [site] sets a transient position at 46° N, 14.5° E;
  /// the clock is a December evening, when M42 is well placed.
  Future<void> start(
    WidgetTester tester, {
    bool site = true,
    bool rig = true,
    bool firstRunDone = true,
    int? lightFrames,
  }) async {
    AppRouter.router.go(AppRouter.tonight);
    SharedPreferences.setMockInitialValues({});
    firstRun = InMemoryFirstRun(done: firstRunDone);
    await tester.runAsync(() async {
      database = AppDatabase(NativeDatabase.memory());
      final targets = DriftTargetRepository(database);
      final rigs = DriftEquipmentRepository(database);
      await targets.insertTarget(_m42);
      if (rig) await rigs.insertEquipment(_rig);
      vm = PlannerHarness(
        targets,
        rigs,
        _NoForecast(),
        DriftLocationRepository(database),
        locationService: FakeLocationService(),
        sessionRepository: DriftSessionRepository(database),
        clock: FixedClock(DateTime.utc(2026, 12, 15, 17)),
        firstRun: firstRun,
      );
      await vm.ready;
      // S6.8: nothing is preselected; a first run has chosen nothing yet.
      if (firstRunDone) await vm.choosePlan();
      await vm.tonight.load();
      if (site) await vm.site.setLocation(46.05, 14.5);
      if (lightFrames != null) {
        while (vm.plan.captureBlocks.isNotEmpty) {
          await vm.plan.removeCaptureBlock(0);
        }
        await vm.plan.addCaptureBlock(_lights(lightFrames));
      }
      await vm.plan.idle;
      await vm.conditions.idle;
    });
    addTearDown(() => tester.runAsync(database.close));
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  testWidgets('no site: the site prompt replaces the night rows', (
    tester,
  ) async {
    await start(tester, site: false);
    expect(find.byKey(const Key('tonight.noSite')), findsOneWidget);
    expect(find.byKey(const Key('tonight.night')), findsNothing);
    expect(find.byKey(const Key('tonight.fit')), findsNothing);
    expect(find.text('Use current position'), findsOneWidget);
  });

  testWidgets('with a site: night, Moon and weather rows', (tester) async {
    await start(tester);
    expect(find.byKey(const Key('tonight.noSite')), findsNothing);
    expect(find.byKey(const Key('tonight.night')), findsOneWidget);
    expect(find.textContaining('Sunset to sunrise:'), findsOneWidget);
    expect(find.textContaining('Dark (Sun below −18°):'), findsOneWidget);
    expect(find.byKey(const Key('tonight.moon')), findsOneWidget);
    // S1.13 (SCI-09): the night's value, and when it applies.
    expect(find.textContaining('% lit at midnight'), findsOneWidget);
  });

  testWidgets('no forecast: says so, never a number', (tester) async {
    await start(tester);
    final weather = find.byKey(const Key('tonight.weather'));
    expect(weather, findsOneWidget);
    expect(
      find.descendant(
        of: weather,
        matching: find.textContaining('No forecast'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: weather, matching: find.textContaining('%')),
      findsNothing,
    );
  });

  testWidgets('no rig: says so and offers the rig picker', (tester) async {
    await start(tester, rig: false);
    expect(find.byKey(const Key('tonight.noRig')), findsOneWidget);
    await tester.tap(find.text('Choose rig'));
    await settle(tester);
    expect(find.text('Select Equipment'), findsWidgets);
  });

  testWidgets('a small plan fits, with the reason and usable time', (
    tester,
  ) async {
    await start(tester, lightFrames: 10);
    expect(find.text('Fits'), findsOneWidget);
    expect(find.byKey(const Key('tonight.fitReason')), findsOneWidget);
    expect(find.textContaining('Usable time tonight:'), findsOneWidget);
  });

  testWidgets("a huge plan doesn't fit, with the reason", (tester) async {
    await start(tester, lightFrames: 2000);
    expect(find.text("Doesn't fit"), findsOneWidget);
    expect(find.byKey(const Key('tonight.fitReason')), findsOneWidget);
  });

  group('200 % text on a 360 × 640 dp phone: no overflow', () {
    Future<void> big(WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    }

    testWidgets('with a site and a plan', (tester) async {
      await big(tester);
      await start(tester, lightFrames: 2000);
      await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
      await settle(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('without a site or rig', (tester) async {
      await big(tester);
      await start(tester, site: false, rig: false);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the first-run page', (tester) async {
      await big(tester);
      await start(tester, site: false, firstRunDone: false);
      expect(find.text('Welcome to Astro Planner'), findsOneWidget);
      await tester.drag(find.byType(ListView).last, const Offset(0, -3000));
      await settle(tester);
      expect(tester.takeException(), isNull);
    });
  });

  group('first run (owner decisions)', () {
    testWidgets('offered on a start without a site; Skip closes it for good', (
      tester,
    ) async {
      await start(tester, site: false, firstRunDone: false);
      expect(find.text('Welcome to Astro Planner'), findsOneWidget);
      expect(find.textContaining('asks for location permission'), findsOne);

      await tester.tap(find.byKey(const Key('welcome.skip')));
      await settle(tester);
      expect(find.text('Welcome to Astro Planner'), findsNothing);
      expect(find.byKey(const Key('tonight.noSite')), findsOneWidget);
      expect(firstRun.done, isTrue);
    });

    testWidgets('Done closes it for good too', (tester) async {
      await start(tester, site: false, firstRunDone: false);
      await tester.scrollUntilVisible(
        find.byKey(const Key('welcome.done')),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.byKey(const Key('welcome.done')));
      await settle(tester);
      expect(find.text('Welcome to Astro Planner'), findsNothing);
      expect(firstRun.done, isTrue);
    });

    testWidgets('a step opens the normal picker and comes back', (
      tester,
    ) async {
      await start(tester, site: false, firstRunDone: false);
      await tester.tap(find.byKey(const Key('welcome.chooseRig')));
      await settle(tester);
      expect(find.text('Select Equipment'), findsWidgets);
      await tester.pageBack();
      await settle(tester);
      expect(find.text('Welcome to Astro Planner'), findsOneWidget);
    });

    // S6.8 (RD-04, UX-24): no step reads as done that the user did not do;
    // the example rig, once chosen, says it is one.
    testWidgets('the page shows nothing as chosen that the user did not '
        'choose', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await start(tester, site: false, firstRunDone: false);
      String status(String step) => tester
          .widgetList<Text>(
            find.descendant(
              of: find.byKey(Key('welcome.$step')),
              matching: find.byType(Text),
            ),
          )
          .elementAt(1)
          .data!;
      expect(status('site'), 'Not set');
      expect(status('rig'), 'Not chosen');
      expect(status('target'), 'Not chosen');

      await tester.runAsync(() async {
        final rigs = DriftEquipmentRepository(database);
        final id = await rigs.insertEquipment(EquipmentSeeder.defaults.first);
        await vm.plan.setEquipment((await rigs.getEquipmentById(id))!);
      });
      await settle(tester);
      expect(status('rig'), endsWith('(example rig)'));
      expect(status('target'), 'Not chosen');
    });

    testWidgets('not offered when a site is already set', (tester) async {
      await start(tester, firstRunDone: false);
      expect(find.text('Welcome to Astro Planner'), findsNothing);
    });

    testWidgets('not offered again once done', (tester) async {
      await start(tester, site: false);
      expect(find.text('Welcome to Astro Planner'), findsNothing);
    });
  });
}

/// Pumps fixed frames with real-time gaps: database writes and the
/// candidates isolate never let pumpAndSettle finish (TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
