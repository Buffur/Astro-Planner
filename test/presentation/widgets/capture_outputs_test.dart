// S6.10 (P6.9; 08 §17): the capture plan's outputs lead with Time needed ·
// Total time (Budget details holds every line); "what fits" comes only from
// the fit's own outputs; storage says what it rests on, or why it is
// unknown and how to supply it; an edit briefly marks what it changed.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/models/spec_provenance.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/fit_analyzer.dart';
import 'package:astroplan/presentation/shared/block_text.dart';
import 'package:astroplan/presentation/shared/change_mark.dart';
import 'package:astroplan/presentation/widgets/capture_plan/capture_budget_summary.dart';
import 'package:astroplan/presentation/widgets/capture_plan_widget.dart';
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

const _s = 1000; // ms per second

const _m42 = AstroTarget(
  id: 1,
  catalogId: 'M42',
  rightAscension: 83.82,
  declination: -5.39,
  type: 'Nebula',
);

EquipmentProfile _rig({
  double? rawMB,
  Map<EquipmentSpec, SpecProvenance> provenance = const {},
}) => EquipmentProfile(
  id: 1,
  name: 'Refractor',
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.6,
  pixelPitchUm: 3.76,
  resolutionWidthPx: 6000,
  resolutionHeightPx: 4000,
  focalLengthMm: 400,
  focalRatio: 5,
  averageRawFileSizeMB: rawMB,
  specProvenance: provenance,
);

CaptureBlock _light(double s, int n, String filter) => CaptureBlock(
  frameType: FrameType.light,
  filterName: filter,
  exposureTimeSeconds: s,
  frameCount: n,
);

void main() {
  late AppDatabase db;
  late PlannerHarness vm;

  /// The capture plan on a real database: a site, M42 and [rig] (none when
  /// null), with no blocks.
  Future<void> start(WidgetTester tester, {EquipmentProfile? rig}) async {
    tester.view.physicalSize = const Size(412, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      db = AppDatabase(NativeDatabase.memory());
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
      final targets = DriftTargetRepository(db);
      final id = await targets.insertTarget(_m42);
      await vm.plan.setTarget((await targets.getTargetById(id))!);
      if (rig != null) {
        final rigs = DriftEquipmentRepository(db);
        final rigId = await rigs.insertEquipment(rig);
        await vm.plan.setEquipment((await rigs.getEquipmentById(rigId))!);
      }
      await vm.plan.idle;
    });
    addTearDown(() => tester.runAsync(db.close));
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: CapturePlanWidget()),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> blocks(WidgetTester tester, List<CaptureBlock> b) async {
    await tester.runAsync(() async {
      while (vm.plan.captureBlocks.isNotEmpty) {
        await vm.plan.removeCaptureBlock(0);
      }
      for (final block in b) {
        await vm.plan.addCaptureBlock(block);
      }
      await vm.plan.idle;
    });
    await tester.pump();
    await tester.pump(const Duration(seconds: 2)); // past any change mark
  }

  String textOf(WidgetTester tester, Key key) =>
      tester.widget<Text>(find.byKey(key)).data!;

  testWidgets('Time needed · Total time equal the calculator (ADR-009 §8 '
      'E1)', (tester) async {
    await start(tester, rig: _rig());
    await tester.runAsync(
      () => vm.setPlanningPreferences(
        PlanningPreferences(
          perFrameOverheadSeconds: 2,
          ditherEveryNFrames: 3,
          ditherSettleSeconds: 20,
          refocusEveryMinutes: 60,
          refocusSeconds: 120,
        ),
      ),
    );
    await blocks(tester, [_light(120, 90, 'Ha')]);
    final b = vm.captureBudget;
    expect(b.integrationMs, 10800 * _s);
    expect(b.windowLoadMs, 11920 * _s);
    expect(b.sessionBudgetMs, 11920 * _s);
    expect(
      CaptureBudgetSummary.budgetSummary(b),
      'Time needed 3 h 19 min · Total time 3 h 19 min',
    );
    expect(find.text(CaptureBudgetSummary.budgetSummary(b)), findsOneWidget);
  });

  group('storage', () {
    testWidgets('known: equals the budget, with what it rests on', (
      tester,
    ) async {
      await start(tester, rig: _rig(rawMB: 50));
      await blocks(tester, [
        _light(60, 20, 'L'),
        CaptureBlock(
          frameType: FrameType.dark,
          exposureTimeSeconds: 60,
          frameCount: 10,
        ),
      ]);
      expect(vm.captureBudget.storageMB, 1500);
      expect(
        tester
            .widgetList<Text>(
              find.descendant(
                of: find.byKey(const Key('capturePlan.storage')),
                matching: find.byType(Text),
              ),
            )
            .last
            .data,
        '1500.0 MB',
      );
      expect(
        textOf(tester, const Key('capturePlan.storageNote')),
        allOf(contains('average RAW file size'), isNot(contains('itself'))),
      );
      expect(find.byKey(const Key('capturePlan.setFileSize')), findsNothing);
    });

    testWidgets('known from an estimated RAW size: says so', (tester) async {
      await start(
        tester,
        rig: _rig(
          rawMB: 25,
          provenance: const {
            EquipmentSpec.rawFileSize: SpecProvenance(
              'metadata:dng:file-size',
              SpecConfidence.estimated,
            ),
          },
        ),
      );
      await blocks(tester, [_light(60, 4, 'L')]);
      expect(vm.captureBudget.storageMB, 100);
      expect(
        textOf(tester, const Key('capturePlan.storageNote')),
        contains("The rig's RAW size is itself an estimate, from one file."),
      );
    });

    testWidgets('unknown: says why and how to supply it', (tester) async {
      await start(tester, rig: _rig());
      await blocks(tester, [_light(60, 4, 'L')]);
      expect(vm.captureBudget.storageMB, isNull);
      expect(find.text('Unknown'), findsOneWidget);
      expect(
        textOf(tester, const Key('capturePlan.storageNote')),
        allOf(
          contains('RAW file size is not known for this rig'),
          contains("rig's editor"),
          contains('Add from a photo'),
        ),
      );
      expect(find.byKey(const Key('capturePlan.setFileSize')), findsOneWidget);
    });

    testWidgets('unknown without a rig: says there is none', (tester) async {
      await start(tester);
      await blocks(tester, [_light(60, 4, 'L')]);
      expect(
        textOf(tester, const Key('capturePlan.storageNote')),
        contains('no rig chosen'),
      );
      expect(find.byKey(const Key('capturePlan.setFileSize')), findsNothing);
    });
  });

  group('what fits equals the fit\'s outputs', () {
    void expectRowsMatchTheFit(WidgetTester tester) {
      final fit = vm.fitAnalysis;
      final fill = vm.analysis.fillWindowBlockIndex;
      for (final (i, block) in vm.captureBlocks.indexed) {
        final expected = BlockText.whatFits(
          block,
          unplaced: fit.unplacedFramesByBlock[i] ?? 0,
          upTo: i == fill ? vm.analysis.fillWindowFrameCount : null,
          spare: i == fill ? vm.analysis.fillWindowSpareFrames : null,
        );
        final row = find.byKey(Key('capture.whatFits.$i'));
        if (expected == null) {
          expect(row, findsNothing, reason: 'block $i');
        } else {
          expect(textOf(tester, Key('capture.whatFits.$i')), expected);
        }
      }
    }

    testWidgets('a short plan: how many more still fit', (tester) async {
      await start(tester, rig: _rig());
      await blocks(tester, [_light(60, 2, 'L')]);
      expect(vm.fitAnalysis.state, FitState.fits);
      final max = vm.analysis.fillWindowFrameCount!;
      expect(max, greaterThan(2));
      expect(vm.analysis.fillWindowSpareFrames, max - 2);
      expect(
        textOf(tester, const Key('capture.whatFits.0')),
        '+${max - 2} frames still fit tonight',
      );
      expectRowsMatchTheFit(tester);
    });

    testWidgets('a plan that does not fit: what does not fit, and up to how '
        'many do', (tester) async {
      await start(tester, rig: _rig());
      await blocks(tester, [_light(300, 20, 'Ha'), _light(300, 400, 'OIII')]);
      final fit = vm.fitAnalysis;
      expect(fit.state, FitState.doesNotFit);
      final unplaced = fit.unplacedFramesByBlock[1]!;
      expect(unplaced, greaterThan(0));
      final max = vm.analysis.fillWindowFrameCount!;
      expect(max, greaterThan(0), reason: 'part of the last block fits');
      expect(
        textOf(tester, const Key('capture.whatFits.1')),
        '$unplaced frames do not fit tonight · up to $max × 300 s fit',
      );
      expectRowsMatchTheFit(tester);
    });

    testWidgets('nothing is said while the fit cannot measure the plan', (
      tester,
    ) async {
      await start(tester); // no rig: the target and night are there
      await blocks(tester, [
        CaptureBlock(
          frameType: FrameType.dark,
          exposureTimeSeconds: 60,
          frameCount: 10,
        ),
      ]);
      expect(vm.fitAnalysis.state, FitState.nothingToFit);
      expect(find.byKey(const Key('capture.whatFits.0')), findsNothing);
    });
  });

  group('cause and effect: a changed value is briefly marked', () {
    double tintOf(WidgetTester tester, Finder mark) =>
        (tester.widget<DecoratedBox>(mark).decoration as BoxDecoration)
            .color!
            .a;

    Future<void> pumpMark(WidgetTester tester, int value, {bool? reduced}) =>
        tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduced ?? false),
              child: ChangeMark(value: value, child: const Text('value')),
            ),
          ),
        );

    final mark = find.byKey(const Key('changeMark'));

    testWidgets('not on the first build; on a change, then fading', (
      tester,
    ) async {
      await pumpMark(tester, 1);
      expect(tintOf(tester, mark), 0);
      await pumpMark(tester, 1);
      expect(tintOf(tester, mark), 0, reason: 'same value');
      await pumpMark(tester, 2);
      await tester.pump(const Duration(milliseconds: 50));
      expect(tintOf(tester, mark), greaterThan(0));
      await tester.pump(const Duration(seconds: 2));
      expect(tintOf(tester, mark), 0);
    });

    testWidgets('never with reduced motion', (tester) async {
      await pumpMark(tester, 1, reduced: true);
      await pumpMark(tester, 2, reduced: true);
      await tester.pump(const Duration(milliseconds: 50));
      expect(tintOf(tester, mark), 0);
    });

    testWidgets('an edit marks Time needed · Total time', (tester) async {
      await start(tester, rig: _rig());
      await blocks(tester, [_light(60, 10, 'L')]);
      final budgetMark = find.ancestor(
        of: find.text(CaptureBudgetSummary.budgetSummary(vm.captureBudget)),
        matching: find.byKey(const Key('changeMark')),
      );
      expect(tintOf(tester, budgetMark.first), 0);
      await tester.runAsync(() => vm.plan.addCaptureBlock(_light(60, 5, 'R')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      final changed = find.ancestor(
        of: find.text(CaptureBudgetSummary.budgetSummary(vm.captureBudget)),
        matching: find.byKey(const Key('changeMark')),
      );
      expect(tintOf(tester, changed.first), greaterThan(0));
      await tester.runAsync(() => vm.plan.idle);
    });
  });
}
