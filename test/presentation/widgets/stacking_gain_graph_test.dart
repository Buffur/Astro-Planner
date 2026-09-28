// S6.11 (P6.10): one relative √N graph per (filter, exposure) group, drawn
// from the domain's points, its marked value the budget's group value, the
// label unchanged, a text alternative giving each group's value, and no
// overflow at 200 % text in the light, dark and field themes.

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/shared/app_words.dart';
import 'package:astroplan/presentation/widgets/capture_plan/stacking_gain_graph.dart';
import 'package:astroplan/presentation/widgets/capture_plan_widget.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_location_service.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

CaptureBlock _light(double s, int n, String? filter) => CaptureBlock(
  frameType: FrameType.light,
  filterName: filter,
  exposureTimeSeconds: s,
  frameCount: n,
);

void main() {
  late AppDatabase db;
  late PlannerHarness vm;

  Future<void> start(WidgetTester tester, {ThemeData? theme}) async {
    tester.view.physicalSize = const Size(412, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase(NativeDatabase.memory());
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoForecast(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
      );
      await vm.ready;
      for (final b in [
        _light(60, 100, 'Ha'),
        _light(60, 20, 'Ha'), // same group: 120 frames
        _light(300, 12, 'Ha'), // another exposure: another group
        _light(30, 1, null),
      ]) {
        await vm.plan.addCaptureBlock(b);
      }
    });
    addTearDown(() => tester.runAsync(db.close));
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: SingleChildScrollView(child: CapturePlanWidget()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('one graph per group, never combined; each draws the domain\'s '
      'points and marks the group\'s value', (tester) async {
    await start(tester);
    final groups = vm.captureBudget.lightGroups;
    expect(groups, hasLength(3));
    final graphs = tester
        .widgetList<StackingGainGraph>(find.byType(StackingGainGraph))
        .toList();
    expect(graphs, hasLength(groups.length));
    for (final (i, g) in groups.indexed) {
      final curve = graphs[i].curve;
      expect(curve.frames, g.frames);
      expect(curve.markedGain, g.relativeStackingGain);
      expect(curve.points, g.gainCurve.points);
      final painter =
          tester
                  .widget<CustomPaint>(
                    find.descendant(
                      of: find.byWidget(graphs[i]),
                      matching: find.byType(CustomPaint),
                    ),
                  )
                  .painter!
              as StackingGainPainter;
      expect(painter.curve.points, g.gainCurve.points);
    }
    expect(groups.first.frames, 120, reason: 'the two Ha 60 s blocks');
  });

  testWidgets('the label is unchanged and the number stays; the text '
      'alternative gives each group\'s value', (tester) async {
    await start(tester);
    final handle = tester.ensureSemantics();
    expect(find.text(AppWords.relativeStackingGain), findsOneWidget);
    expect(find.textContaining('SNR'), findsNothing);
    for (final g in vm.captureBudget.lightGroups) {
      final value = '${g.relativeStackingGain.toStringAsFixed(1)}x';
      expect(find.text(value), findsOneWidget, reason: 'the number stays');
      expect(
        find.bySemanticsLabel(
          RegExp(
            'Relative stacking gain graph, .*: ${RegExp.escape(value)} '
            'at ${g.frames} frames',
          ),
        ),
        findsOneWidget,
      );
    }
    handle.dispose();
  });

  for (final (name, theme) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
    ('field', AppTheme.fieldTheme),
  ]) {
    testWidgets('no overflow at 200 % text ($name)', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await start(tester, theme: theme);
      expect(find.byType(StackingGainGraph), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  }
}
