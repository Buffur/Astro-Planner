// S6.6 (P6.3; ADR-019 §6; UX-01 to UX-03): the planner answers first. On a
// phone-sized first screen it shows which plan (target, night, site,
// state), the verdict with time needed and usable time, the integration,
// the main reason and the next action; the status says exactly what
// FitAnalyzer and the budget say; without a target or a rig the structure
// stays, with a neutral status. Through the real app and database.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/fit_analyzer.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/shared/app_words.dart';
import 'package:astroplan/presentation/shared/status_block.dart';
import 'package:astroplan/presentation/widgets/altitude_chart_widget.dart';
import 'package:astroplan/presentation/widgets/plan_status.dart';
import 'package:astroplan/presentation/widgets/timeline_data.dart';
import 'package:astroplan/presentation/widgets/tonight_opportunity_widget.dart';
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

  Future<void> start(
    WidgetTester tester, {
    Size size = const Size(412, 915),
    bool seedRig = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
      await CatalogSeeder(DriftTargetRepository(db)).seedIfNeeded();
      if (seedRig) {
        await EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded();
      }
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
      await vm.choosePlan(); // S6.8: nothing is preselected
    });
    addTearDown(() => tester.runAsync(db.close));
    AppRouter.router.go(AppRouter.session());
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  /// [finder] is wholly on the first screen, above the bottom bar.
  void onFirstScreen(WidgetTester tester, Finder finder, String what) {
    expect(finder, findsWidgets, reason: what);
    final rect = tester.getRect(finder.first);
    final bar = tester.getRect(find.byKey(const Key('planner.save')));
    expect(rect.top, greaterThanOrEqualTo(0), reason: what);
    expect(rect.bottom, lessThanOrEqualTo(bar.top), reason: what);
  }

  for (final (theme, brightness, field) in [
    ('light', Brightness.light, false),
    ('dark', Brightness.dark, false),
    ('field', Brightness.dark, true),
  ]) {
    testWidgets('the first screen answers the seven questions ($theme)', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await start(tester);
      if (field) {
        await tester.runAsync(() => vm.theme.toggleFieldMode());
        await settle(tester);
      }
      final fit = vm.fitAnalysis;
      final identity = find.byKey(const Key('planner.identity'));
      // 1. Which target, night, site and rig-independent state.
      onFirstScreen(tester, identity, 'the target, night and state');
      onFirstScreen(tester, find.byKey(const Key('context.site')), 'site');
      onFirstScreen(tester, find.byKey(const Key('context.night')), 'night');
      // 2–4. The verdict with time needed and usable time.
      onFirstScreen(
        tester,
        find.text(
          StatusBlock.headline(
            fit.state,
            needed: Duration(milliseconds: fit.windowLoadMs),
            usable: Duration(milliseconds: fit.availableMs),
          ),
        ),
        'the verdict with time needed and usable time',
      );
      // 5. The integration planned.
      onFirstScreen(
        tester,
        find.textContaining(AppWords.integration, findRichText: true),
        'the integration',
      );
      // 6. The main reason.
      onFirstScreen(tester, find.text(fit.reason), 'the main reason');
      // 7. The next useful action: Save plan, always in reach.
      expect(find.byKey(const Key('planner.save')), findsOneWidget);
    });
  }

  testWidgets('the status says what FitAnalyzer and the budget say, whatever '
      'the verdict', (tester) async {
    await start(tester, size: const Size(800, 3000));
    Future<void> blocks(List<CaptureBlock> b) => tester.runAsync(() async {
      while (vm.captureBlocks.isNotEmpty) {
        await vm.removeCaptureBlock(0);
      }
      for (final block in b) {
        await vm.addCaptureBlock(block);
      }
      await vm.plan.idle;
    });
    CaptureBlock light(int n) => CaptureBlock(
      frameType: FrameType.light,
      filterName: 'Ha',
      exposureTimeSeconds: 300,
      frameCount: n,
    );

    final seen = <FitState>{};
    for (final plan in [
      [light(2)],
      [light(500)],
    ]) {
      await blocks(plan);
      await settle(tester);
      final fit = vm.fitAnalysis;
      seen.add(fit.state);
      expect(
        find.text(
          StatusBlock.headline(
            fit.state,
            needed: Duration(milliseconds: fit.windowLoadMs),
            usable: Duration(milliseconds: fit.availableMs),
          ),
        ),
        findsOneWidget,
      );
      expect(find.text(fit.reason), findsOneWidget);
    }
    expect(seen, containsAll([FitState.fits, FitState.doesNotFit]));

    // Filled to the window: whatever the fit calls it (fits or tight).
    await tester.runAsync(() => vm.fillWindow());
    await settle(tester);
    final filled = vm.fitAnalysis;
    expect(filled.state, anyOf(FitState.fits, FitState.tight));
    expect(
      find.text(
        StatusBlock.headline(
          filled.state,
          needed: Duration(milliseconds: filled.windowLoadMs),
          usable: Duration(milliseconds: filled.availableMs),
        ),
      ),
      findsOneWidget,
    );

    // A target that never rises here: no window, in the fit's words.
    await tester.runAsync(
      () => vm.setTarget(
        AstroTarget(
          id: vm.selectedTarget!.id,
          catalogId: 'NGC 104',
          commonName: '47 Tucanae',
          type: 'Globular cluster',
          rightAscension: 6.02,
          declination: -72.08,
        ),
      ),
    );
    await settle(tester);
    expect(vm.fitAnalysis.state, FitState.noWindow);
    expect(find.text(AppWords.noWindow), findsOneWidget);
    expect(find.text(vm.fitAnalysis.reason), findsOneWidget);
  });

  // S6.12 (P6.11): the timeline's intervals are the opportunity's, and the
  // planned capture is drawn as far as the fit exposes it: its end.
  testWidgets("the timeline draws the opportunity's windows and the fit's "
      'end', (tester) async {
    await start(tester, size: const Size(800, 3000));
    final painter =
        tester
                .widget<CustomPaint>(
                  find.descendant(
                    of: find.byType(AltitudeChartWidget),
                    matching: find.byType(CustomPaint),
                  ),
                )
                .painter!
            as TimelinePainter;
    final o = vm.conditions.imagingOpportunity!;
    expect(painter.data.windows, [
      for (final w in o.windows) TimelineSpan(w.startUtc, w.endUtc),
    ]);
    final fit = vm.fitAnalysis;
    expect(fit.state, anyOf(FitState.fits, FitState.tight));
    expect(painter.data.captureEndUtc, fit.endUtc);
    expect(fit.endUtc, isNotNull);
  });

  // S6.16 (ADR-019 §6 as amended by the owner, DECISIONS E.1 "Stage 6
  // corrective pass decided"): the answer, then the context, the target, the
  // rig and the capture plan, then the target's night as supporting
  // analysis, then the conditions.
  testWidgets('the order: status, context, target, rig, capture plan, the '
      "target's night, the conditions", (tester) async {
    await start(tester, size: const Size(800, 8000));
    final order = [
      ('status', find.byKey(const Key('planner.status'))),
      ('context', find.byKey(const Key('planner.context'))),
      ('target', find.byKey(const Key('planner.target'))),
      ('rig', find.byKey(const Key('planner.rig'))),
      ('capture plan', find.text(AppWords.capturePlan)),
      ("the target's night", find.text(TonightOpportunityWidget.title)),
      ('the chart', find.byType(AltitudeChartWidget)),
      ('Night & Moon', find.byKey(const Key('planner.night'))),
      ('Weather', find.byKey(const Key('planner.weather'))),
      ('Sky darkness', find.text('Sky darkness')),
    ];
    for (final (name, f) in order) {
      expect(f, findsOneWidget, reason: name);
    }
    for (var i = 1; i < order.length; i++) {
      expect(
        tester.getTopLeft(order[i].$2).dy,
        greaterThan(tester.getTopLeft(order[i - 1].$2).dy),
        reason: '${order[i].$1} after ${order[i - 1].$1}',
      );
    }
    // The finish (S6.16): the context on a card, the answer marked in its
    // status colour, the sections in the section-heading role.
    expect(
      find.descendant(
        of: find.byKey(const Key('planner.context')),
        matching: find.byKey(const Key('context.card')),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('planner.statusMark')), findsOneWidget);
    final heading = tester.widget<Text>(find.text(AppWords.capturePlan));
    final theme = Theme.of(tester.element(find.text(AppWords.capturePlan)));
    expect(heading.style?.fontSize, theme.textTheme.titleMedium?.fontSize);
    expect(heading.style?.fontWeight, theme.textTheme.titleMedium?.fontWeight);
  });

  // TD-075 (S6.16): a missing input has its own reason; the fit's reason for
  // an empty plan is shown only once the planning context exists.
  testWidgets("a missing target has its own reason, never the empty plan's; "
      'then an empty plan says so', (tester) async {
    await start(tester, size: const Size(800, 3000));
    final target = vm.selectedTarget!;
    await tester.runAsync(() async {
      await vm.newSession(); // keeps the site and rig; no target, no blocks
      await vm.plan.idle;
    });
    await settle(tester);
    final status = find.byKey(const Key('planner.status'));
    Finder inStatus(String text) =>
        find.descendant(of: status, matching: find.text(text));
    expect(vm.captureBlocks, isEmpty);
    expect(inStatus(AppWords.needsTarget), findsOneWidget);
    expect(inStatus(PlanStatus.targetReason), findsOneWidget);
    expect(find.textContaining('no light frames'), findsNothing);

    await tester.runAsync(() async {
      await vm.plan.setTarget(target);
      await vm.plan.idle;
    });
    await settle(tester);
    expect(vm.fitAnalysis.state, FitState.nothingToFit);
    expect(inStatus(AppWords.needsBlock), findsOneWidget);
    expect(inStatus(vm.fitAnalysis.reason), findsOneWidget);
    expect(vm.fitAnalysis.reason, contains('no light frames'));
  });

  testWidgets('without a rig the structure stays and the status is neutral', (
    tester,
  ) async {
    await start(tester, seedRig: false, size: const Size(800, 3000));
    expect(vm.selectedEquipment, isNull);
    expect(find.text(PlanStatus.needsRig), findsOneWidget);
    expect(find.text(PlanStatus.rigReason), findsOneWidget);
    expect(find.byKey(const Key('status.choose')), findsOneWidget);
    expect(find.byKey(const Key('planner.noRig')), findsOneWidget);
    // The rest of the plan is still there.
    expect(find.text(AppWords.capturePlan), findsOneWidget);
    expect(find.byKey(const Key('planner.night')), findsOneWidget);
  });
}

/// Pumps fixed frames with real-time gaps (database work; TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
