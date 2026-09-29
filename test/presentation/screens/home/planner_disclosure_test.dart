// S6.7 (P6.4; ADR-019 §7; UX-05): technical depth one tap away behind
// factual summaries. Collapsed, each section states a fact; the "never
// hidden" items (the plan's shared rules) stay visible; Budget details'
// lines equal the calculator on ADR-009's vectors; a section's state
// survives a restart. Through the real app and database.

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
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/fit_analyzer.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/shared/app_words.dart';
import 'package:astroplan/presentation/shared/context_line.dart';
import 'package:astroplan/presentation/shared/night_text.dart';
import 'package:astroplan/presentation/widgets/capture_plan/capture_assumptions_panel.dart';
import 'package:astroplan/presentation/widgets/capture_plan/capture_budget_summary.dart';
import 'package:astroplan/presentation/widgets/planner_sections.dart';
import 'package:astroplan/presentation/widgets/sky_darkness_widget.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_device_time_zone.dart';
import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/in_memory_display_preferences.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

const _s = 1000; // ms per second

CaptureBlock _light(double s, int n, String filter) => CaptureBlock(
  frameType: FrameType.light,
  exposureTimeSeconds: s,
  frameCount: n,
  filterName: filter,
);

CaptureBlock _cal(FrameType t, double s, int n, CalibrationPolicy p) =>
    CaptureBlock(
      frameType: t,
      exposureTimeSeconds: s,
      frameCount: n,
      calibrationPolicy: p,
    );

void main() {
  late AppDatabase db;
  late PlannerHarness vm;

  /// The planner on a tall view, so every section is built; [store] is the
  /// display preferences a restart keeps.
  Future<void> start(
    WidgetTester tester, {
    InMemoryDisplayPreferences? store,
    bool newDatabase = true,
  }) async {
    tester.view.physicalSize = const Size(800, 5000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      if (newDatabase) {
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
        addTearDown(() => tester.runAsync(db.close));
      }
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
        displayPreferences: store,
      );
      await vm.ready;
      await vm.choosePlan(); // S6.8: nothing is preselected
      await vm.disclosure.load(); // as main.dart does before runApp
    });
    AppRouter.router.go(AppRouter.session());
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);
  }

  Future<void> blocks(WidgetTester tester, List<CaptureBlock> b) =>
      tester.runAsync(() async {
        while (vm.captureBlocks.isNotEmpty) {
          await vm.removeCaptureBlock(0);
        }
        for (final block in b) {
          await vm.addCaptureBlock(block);
        }
        await vm.plan.idle;
      });

  Future<void> openSection(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key('section.$key')));
    await settle(tester);
  }

  testWidgets('collapsed, each section states a fact and hides its detail', (
    tester,
  ) async {
    await start(tester);
    for (final key in PlannerSections.all) {
      expect(vm.disclosure.isOpen(key), isFalse, reason: key);
      expect(find.byKey(Key('section.$key')), findsOneWidget, reason: key);
    }
    final rig = vm.selectedEquipment!;
    final summaries = {
      PlannerSections.budgetDetails: CaptureBudgetSummary.budgetSummary(
        vm.captureBudget,
      ),
      PlannerSections.gainHelp: 'Per filter and exposure, against one frame',
      PlannerSections.assumptions: CaptureAssumptionsPanel.summary(
        vm.planningPreferences,
      ),
      PlannerSections.sky: SkyDarknessWidget.summary(vm.skyDarkness),
    };
    for (final MapEntry(:key, :value) in summaries.entries) {
      expect(
        find.descendant(
          of: find.byKey(Key('section.$key')),
          matching: find.text(value),
        ),
        findsOneWidget,
        reason: key,
      );
    }
    // The rig's: its focal length, focal ratio and tracking.
    final rigSummary = find.descendant(
      of: find.byKey(const Key('section.${PlannerSections.rigDetails}')),
      matching: find.byType(Text),
    );
    expect(
      tester.widgetList<Text>(rigSummary).map((t) => t.data).join(' '),
      allOf(
        contains('mm · f/'),
        contains('${AppWords.tracking}: ${rig.trackingType.label}'),
      ),
    );
    // Numbers, not "Advanced" or "More"; no verdict words.
    expect(summaries[PlannerSections.budgetDetails], contains('needed'));
    expect(summaries[PlannerSections.assumptions], contains('°'));
    for (final word in ['Advanced', 'More', 'good', 'fine']) {
      expect(find.textContaining(word), findsNothing, reason: word);
    }
    // The detail itself is one tap away.
    for (final hidden in [
      'Integration (light exposure)',
      'Time between frames',
      'Focal length',
      'Open Light Pollution Map',
    ]) {
      expect(find.text(hidden), findsNothing, reason: hidden);
    }
    expect(find.byKey(const Key('capturePlan.gainHelp')), findsNothing);
  });

  testWidgets('with every section collapsed, the "never hidden" items stay '
      'visible', (tester) async {
    await start(tester);
    // A rig whose stored focal ratio needs review (trap 3), untracked, with
    // no RAW file size.
    await tester.runAsync(() async {
      final repo = DriftEquipmentRepository(db);
      final id = await repo.insertEquipment(
        const EquipmentProfile(
          id: 0,
          name: 'Old scope',
          sensorWidthMm: 23.5,
          sensorHeightMm: 15.7,
          pixelPitchUm: 3.76,
          resolutionWidthPx: 6248,
          resolutionHeightPx: 4176,
          focalLengthMm: 400,
          focalRatio: 72,
          trackingType: TrackingType.untracked,
        ),
      );
      final rig = (await repo.getAllEquipment()).singleWhere((r) => r.id == id);
      await vm.setEquipment(rig);
      await vm.plan.idle;
    });
    await blocks(tester, [_light(30, 20, 'L')]);
    await settle(tester);
    for (final key in PlannerSections.all) {
      expect(vm.disclosure.isOpen(key), isFalse, reason: key);
    }

    // An unknown that weakens a result: storage and the sky, as unknown.
    expect(vm.captureBudget.storageMB, isNull);
    expect(find.text('Estimated Storage'), findsOneWidget);
    expect(find.text('Unknown'), findsWidgets);
    expect(
      find.descendant(
        of: find.byKey(const Key('section.${PlannerSections.sky}')),
        matching: find.text('Unknown'),
      ),
      findsOneWidget,
    );
    // Unavailable weather, in the planner's row.
    expect(
      find.text(WeatherText.summary(vm.nightWeather, vm.nightWeatherSummary)),
      findsOneWidget,
    );
    // Active constraints: the darkness limit and minimum altitude.
    expect(
      find.text(CaptureAssumptionsPanel.summary(vm.planningPreferences)),
      findsOneWidget,
    );
    // Capability warnings (TASK 8.6) and the focal ratio's review flag.
    expect(vm.rigCapability?.npf, isNotNull);
    expect(find.text('NPF (untracked)'), findsOneWidget);
    expect(find.textContaining('f/72 — please review'), findsOneWidget);
    expect(find.text('Focal length'), findsNothing); // folded

    // The reason a result cannot be evaluated: a target that never rises.
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
    expect(find.text(vm.fitAnalysis.reason), findsOneWidget);
    // Integration stays in the status, whatever the verdict.
    expect(find.textContaining(AppWords.integration), findsWidgets);
  });

  testWidgets('each Budget details line equals the calculator (ADR-009 §8 '
      'E3 and E4)', (tester) async {
    await start(tester);
    await openSection(tester, PlannerSections.budgetDetails);
    String line(String key) {
      final texts = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byKey(Key('budget.$key')),
              matching: find.byType(Text),
            ),
          )
          .map((t) => t.data!)
          .toList();
      return texts.last;
    }

    // E3: an untracked phone, darks in the window, per-frame 1 s.
    await tester.runAsync(
      () => vm.setPlanningPreferences(
        PlanningPreferences(perFrameOverheadSeconds: 1),
      ),
    );
    await blocks(tester, [
      _light(10, 300, 'L'),
      _cal(FrameType.dark, 10, 30, CalibrationPolicy.inWindow),
    ]);
    await settle(tester);
    var b = vm.captureBudget;
    expect(b.integrationMs, 3000 * _s);
    expect(b.acquisitionMs, 3300 * _s);
    expect(b.inWindowCalibrationMs, 330 * _s);
    expect(b.windowLoadMs, 3630 * _s);
    expect(b.sessionBudgetMs, 3630 * _s);
    expect(line('integration'), formatBudgetDuration(b.integrationMs));
    expect(line('imagingTime'), formatBudgetDuration(b.acquisitionMs));
    expect(line('calibrationIn'), formatBudgetDuration(330 * _s));
    expect(line('timeNeeded'), startsWith(formatBudgetDuration(3630 * _s)));
    expect(line('calibrationOut'), 'None');
    expect(line('setup'), 'Not included');
    expect(line('totalTime'), formatBudgetDuration(b.sessionBudgetMs));

    // E4: calibration outside the window, library darks, setup, filter
    // change, per-frame 3 s.
    await tester.runAsync(
      () => vm.setPlanningPreferences(
        PlanningPreferences(
          perFrameOverheadSeconds: 3,
          filterChangeSeconds: 30,
          setupMinutes: 45,
        ),
      ),
    );
    await blocks(tester, [
      _light(180, 60, 'L'),
      _light(180, 20, 'R'),
      _cal(FrameType.flat, 2, 30, CalibrationPolicy.outsideWindow),
      _cal(FrameType.dark, 180, 20, CalibrationPolicy.library),
      _cal(FrameType.bias, 0.001, 50, CalibrationPolicy.outsideWindow),
    ]);
    await settle(tester);
    b = vm.captureBudget;
    expect(b.integrationMs, 14400 * _s);
    expect(b.acquisitionMs, 14670 * _s);
    expect(b.windowLoadMs, 14670 * _s);
    expect(b.outsideWindowCalibrationMs, 300050);
    expect(b.setupMs, 2700 * _s);
    expect(b.sessionBudgetMs, 17670050);
    expect(line('integration'), formatBudgetDuration(14400 * _s));
    expect(line('imagingTime'), formatBudgetDuration(14670 * _s));
    expect(find.byKey(const Key('budget.calibrationIn')), findsNothing);
    expect(line('timeNeeded'), startsWith(formatBudgetDuration(14670 * _s)));
    expect(line('calibrationOut'), formatBudgetDuration(300050));
    expect(line('setup'), startsWith(formatBudgetDuration(2700 * _s)));
    expect(line('totalTime'), formatBudgetDuration(17670050));
    expect(line('library'), '1 block, no time needed');
    // The zone rule once per section (trap 2): the context line, the
    // conditions and, for the setup's start time, Budget details.
    expect(line('setup'), contains('start by'));
    expect(
      find.text(
        ContextLine.zoneRule(
          vm.sessionNight!.startUtc,
          zoneId: vm.site.displayZoneId,
        ),
      ),
      findsNWidgets(3),
    );
    // The collapsed summary says the same numbers.
    expect(find.text(CaptureBudgetSummary.budgetSummary(b)), findsOneWidget);
  });

  testWidgets('a section left open is open again after a restart', (
    tester,
  ) async {
    final store = InMemoryDisplayPreferences();
    await start(tester, store: store);
    expect(find.text('Integration (light exposure)'), findsNothing);
    await openSection(tester, PlannerSections.budgetDetails);
    expect(find.text('Integration (light exposure)'), findsOneWidget);

    // A new app start on the same stores: a new ViewModel graph.
    final before = vm.disclosure;
    await tester.pumpWidget(const SizedBox());
    await start(tester, store: store, newDatabase: false);
    expect(identical(vm.disclosure, before), isFalse);
    expect(find.text('Integration (light exposure)'), findsOneWidget);
    expect(
      find.text('Time between frames'),
      findsNothing,
    ); // still closed (S7.2b's label)
  });
}

/// Pumps fixed frames with real-time gaps (database work; TASK 12.2).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 200));
  }
}
