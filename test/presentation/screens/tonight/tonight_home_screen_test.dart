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
import 'package:astroplan/domain/services/fit_analyzer.dart';
import 'package:astroplan/presentation/shared/status_block.dart';
import 'package:astroplan/presentation/widgets/plan_status.dart';
import 'package:astroplan/core/utils/quantity_text.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/presentation/shared/app_words.dart';
import 'package:astroplan/presentation/shared/night_text.dart';
import 'package:astroplan/presentation/shared/night_time_formatter.dart';
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

  // S6.13: the plan card's status says what is missing, in the planner's
  // words, and offers the picker (before: its own "No rig chosen" line).
  testWidgets('no rig: says so and offers the rig picker', (tester) async {
    await start(tester, rig: false);
    final status = find.byKey(const Key('tonight.status'));
    expect(
      find.descendant(of: status, matching: find.text(PlanStatus.needsRig)),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('tonight.chooseRig')));
    await settle(tester);
    expect(find.text('Select Equipment'), findsWidgets);
  });

  testWidgets('a small plan fits, with the reason and usable time', (
    tester,
  ) async {
    await start(tester, lightFrames: 10);
    // S6.13: the StatusBlock verdict, as in the planner: the headline
    // carries the usable time.
    final fit = vm.fitAnalysis;
    expect(fit.state, FitState.fits);
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
    expect(find.textContaining('usable'), findsWidgets);
    expect(find.text(fit.reason), findsOneWidget);
  });

  testWidgets("a huge plan doesn't fit, with the reason", (tester) async {
    await start(tester, lightFrames: 2000);
    final fit = vm.fitAnalysis;
    expect(fit.state, FitState.doesNotFit);
    expect(find.textContaining("Doesn't fit:"), findsOneWidget);
    expect(find.text(fit.reason), findsOneWidget);
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

  // S6.13 (P6.6; ADR-019 §5): plan first.
  group('plan first (S6.13)', () {
    testWidgets('the order: site and night, the plan with its answer, the '
        'night rows, then the secondary actions', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await start(tester, lightFrames: 10);
      double y(String key) => tester.getTopLeft(find.byKey(Key(key))).dy;
      final order = [
        'tonight.context',
        'tonight.plan',
        'tonight.night',
        'tonight.moon',
        'tonight.weather',
        'tonight.candidates',
        'tonight.newSession',
      ];
      for (var i = 1; i < order.length; i++) {
        expect(y(order[i]), greaterThan(y(order[i - 1])), reason: order[i]);
      }
      expect(find.byKey(const Key('tonight.status')), findsOneWidget);
      expect(find.byKey(const Key('tonight.planState')), findsOneWidget);
      expect(find.byKey(const Key('tonight.openPlanner')), findsOneWidget);
      expect(find.byKey(const Key('tonight.start')), findsNothing);
      // Tonight's own status words are gone ("Draft", S5.3's baseline).
      expect(find.text('Draft'), findsNothing);
    });

    testWidgets('without a target: Choose a target and What can I image '
        'tonight?', (tester) async {
      await start(tester, firstRunDone: false);
      final plan = find.byKey(const Key('tonight.plan'));
      expect(
        find.descendant(of: plan, matching: find.text(AppWords.needsTarget)),
        findsOneWidget,
      );
      expect(find.byKey(const Key('tonight.chooseTarget')), findsOneWidget);
      expect(find.byKey(const Key('tonight.planCandidates')), findsOneWidget);
      await tester.tap(find.byKey(const Key('tonight.chooseTarget')));
      await settle(tester);
      expect(find.text('Select Target'), findsWidgets);
    });

    // S6.16 (the owner's decisions, DECISIONS E.1 "Stage 6 corrective pass
    // decided"): the finish of the core screen.
    testWidgets('the title is a header in the scale\'s headline role; the '
        'context is on a card', (tester) async {
      await start(tester, lightFrames: 10);
      final handle = tester.ensureSemantics();
      final title = find.byKey(const Key('tonight.title'));
      expect(title, findsOneWidget);
      final ctx = tester.element(title);
      expect(
        tester.widget<Text>(title).style?.fontSize,
        Theme.of(ctx).textTheme.headlineSmall?.fontSize,
      );
      expect(
        tester.getSemantics(title),
        matchesSemantics(label: 'Tonight', isHeader: true),
      );
      handle.dispose();
      expect(
        find.descendant(
          of: find.byKey(const Key('tonight.context')),
          matching: find.byKey(const Key('context.card')),
        ),
        findsOneWidget,
      );
    });

    testWidgets('TD-077: "Your plan" is the card\'s heading; the target and '
        'rig read below it', (tester) async {
      await start(tester, lightFrames: 10);
      final handle = tester.ensureSemantics();
      final heading = find.byKey(const Key('tonight.planHeading'));
      final theme = Theme.of(tester.element(heading));
      final style = tester.widget<Text>(heading).style!;
      expect(tester.widget<Text>(heading).data, AppWords.yourPlan);
      expect(style.fontSize, theme.textTheme.titleMedium?.fontSize);
      expect(style.fontWeight, theme.textTheme.titleMedium?.fontWeight);
      expect(
        tester.getSemantics(heading),
        matchesSemantics(label: AppWords.yourPlan, isHeader: true),
      );
      handle.dispose();
      final target = tester
          .widget<Text>(find.byKey(const Key('tonight.planTarget')))
          .style!;
      expect(target.fontSize, theme.textTheme.bodyLarge?.fontSize);
      expect(target.fontWeight, theme.textTheme.bodyLarge?.fontWeight);
    });

    for (final chosen in [true, false]) {
      testWidgets('Open planner is the plan card\'s filled action (a target '
          'chosen: $chosen)', (tester) async {
        await start(tester, firstRunDone: chosen);
        final open = find.byKey(const Key('tonight.openPlanner'));
        expect(open, findsOneWidget);
        expect(tester.widget(open), isA<FilledButton>());
        expect(
          find.descendant(
            of: find.byKey(const Key('tonight.plan')),
            matching: open,
          ),
          findsOneWidget,
        );
      });
    }

    testWidgets('TD-080: without a target, each way to a target says what it '
        'offers, and What can I image tonight? is shown once', (tester) async {
      await start(tester, firstRunDone: false);
      final choose = find.byKey(const Key('tonight.chooseTarget'));
      final candidates = find.byKey(const Key('tonight.planCandidates'));
      expect(
        find.descendant(
          of: choose,
          matching: find.text('Any object in the catalogue'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: candidates,
          matching: find.text(
            'Candidates for this site and night, by usable time',
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('What can I image tonight?'), findsOneWidget);
      expect(find.byKey(const Key('tonight.candidates')), findsNothing);
      await tester.tap(candidates);
      await settle(tester);
      expect(find.text("Tonight's candidates"), findsWidgets);
    });

    testWidgets('TD-080: with a target, What can I image tonight? stays in the '
        'secondary actions', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await start(tester, lightFrames: 10);
      expect(find.byKey(const Key('tonight.planCandidates')), findsNothing);
      expect(find.byKey(const Key('tonight.chooseTarget')), findsNothing);
      expect(find.byKey(const Key('tonight.candidates')), findsOneWidget);
      expect(find.text('What can I image tonight?'), findsOneWidget);
    });

    testWidgets(
      "TD-075: the reason names the missing site or target, never the "
      "empty plan's",
      (tester) async {
        // No site and an empty plan: the case TD-075 was seen in.
        await start(tester, site: false);
        await tester.runAsync(() async {
          while (vm.plan.captureBlocks.isNotEmpty) {
            await vm.plan.removeCaptureBlock(0);
          }
          await vm.plan.idle;
        });
        await settle(tester);
        final status = find.byKey(const Key('tonight.status'));
        Finder inStatus(String text) =>
            find.descendant(of: status, matching: find.text(text));
        expect(inStatus(PlanStatus.needsSite), findsOneWidget);
        expect(inStatus(PlanStatus.siteReason), findsOneWidget);
        expect(find.textContaining('no light frames'), findsNothing);
      },
    );

    testWidgets('TD-075: without a target, the target\'s reason', (
      tester,
    ) async {
      await start(tester, firstRunDone: false);
      final status = find.byKey(const Key('tonight.status'));
      expect(vm.plan.captureBlocks, isEmpty);
      expect(
        find.descendant(of: status, matching: find.text(AppWords.needsTarget)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: status,
          matching: find.text(PlanStatus.targetReason),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('no light frames'), findsNothing);
    });

    testWidgets("the night picker changes the plan's night, and the plan "
        'autosaves', (tester) async {
      await start(tester, lightFrames: 10);
      expect(vm.plan.eveningDate, CalendarDate(2026, 12, 15));
      await tester.tap(find.byKey(const Key('context.night')));
      await settle(tester);
      expect(find.text('Choose a night'), findsOneWidget);
      await tester.tap(find.text('20'));
      await tester.tap(find.text('OK'));
      await settle(tester);
      await tester.runAsync(() => vm.plan.idle);
      expect(vm.plan.eveningDate, CalendarDate(2026, 12, 20));
      final stored = await tester.runAsync(
        () => DriftSessionRepository(database).get(vm.plan.activeSessionId!),
      );
      expect(stored!.eveningDate, CalendarDate(2026, 12, 20));
    });

    for (final limit in DarknessLimit.values) {
      testWidgets('the Dark row is the dark span at the user\'s limit '
          '(${limit.degrees.round()}°; TD-054)', (tester) async {
        await start(tester, lightFrames: 10);
        await tester.runAsync(
          () => vm.setPlanningPreferences(
            vm.planningPreferences.copyWith(darknessLimit: limit),
          ),
        );
        await settle(tester);
        final dark = vm.conditions.nightTimeline!.darkAtLimit!;
        expect(dark.thresholdDeg, limit.degrees);
        final ctx = tester.element(find.byKey(const Key('tonight.night')));
        final expected = DarkText.span(
          dark,
          (utc) => NightTimeFormatter.instant(
            ctx,
            utc,
            windowStartUtc: vm.conditions.nightTimeline!.night.startUtc,
            zoneId: vm.site.displayZoneId,
          ),
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('tonight.night')),
            matching: find.text(expected),
          ),
          findsOneWidget,
        );
        expect(expected, contains(QuantityText.degrees(limit.degrees)));
      });
    }

    testWidgets('the Moon row says what the Moon does while it is dark '
        '(UX-17)', (tester) async {
      await start(tester, lightFrames: 10);
      final during = vm.conditions.moonDuringDark!;
      expect(
        find.descendant(
          of: find.byKey(const Key('tonight.moon')),
          matching: find.text(MoonText.duringDark(during)),
        ),
        findsOneWidget,
      );
      // The noon-to-noon rise/set intervals are on Night & Moon only.
      expect(find.textContaining('from noon'), findsNothing);
    });

    testWidgets('New plan says what happened', (tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await start(tester, lightFrames: 10);
      final button = find.byKey(const Key('tonight.newSession'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await settle(tester);
      // The chosen plan has unsaved changes: Discard them (S6.3).
      await tester.tap(find.byKey(const Key('unsaved.discard')));
      await settle(tester);
      expect(find.text('New plan started'), findsOneWidget);
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
