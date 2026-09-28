// TASK 5.6 acceptance: "a user can see why a plan doesn't fit and fix it
// with one action" — against real windows (London, M42, 2026-03-01 evening,
// fixed clock).

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' hide CaptureBlock;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/fit_analyzer.dart';

import '../../support/planner_harness.dart';

import 'package:astroplan/presentation/widgets/capture_plan_widget.dart';
import 'package:astroplan/presentation/widgets/plan_status.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_location_service.dart';
import '../../support/no_snapshot_weather.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

void main() {
  late AppDatabase database;
  late PlannerHarness vm;

  Future<void> build(WidgetTester tester) async {
    await tester.runAsync(() async {
      database = AppDatabase(NativeDatabase.memory());
      final targets = DriftTargetRepository(database);
      await CatalogSeeder(targets).seedIfNeeded(); // M42
      // S6.6: without a rig the status asks for one instead of the fill.
      await EquipmentSeeder(DriftEquipmentRepository(database)).seedIfNeeded();
      final locations = DriftLocationRepository(database);
      final id = await locations.insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'London',
          latitude: 51.5,
          longitude: -0.1,
          elevation: 10,
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': id});
      vm = PlannerHarness(
        targets,
        DriftEquipmentRepository(database),
        _NoWeather(),
        locations,
        locationService: FakeLocationService(),
        clock: FixedClock(DateTime.utc(2026, 3, 1, 18)),
      );
      await vm.ready;
      // A plan far larger than one night: 500 x 300 s of Ha.
      // TASK 12.3: the plan is read-only outside the ViewModel.
      while (vm.captureBlocks.isNotEmpty) {
        await vm.removeCaptureBlock(0);
      }
      await vm.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          filterName: 'Ha',
          exposureTimeSeconds: 300,
          frameCount: 500,
        ),
      );
    });
    addTearDown(() => tester.runAsync(database.close));
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: const MaterialApp(
          home: Scaffold(
            // S6.6: the verdict and "fill the window" are the planner's
            // status (PlanStatus), above the capture plan.
            body: SingleChildScrollView(
              child: Column(children: [PlanStatus(), CapturePlanWidget()]),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a plan that does not fit shows why, and one tap fixes it', (
    tester,
  ) async {
    await build(tester);
    expect(vm.visibilityWindows, isNotEmpty);
    expect(vm.fitAnalysis.state, FitState.doesNotFit);
    expect(find.textContaining("Doesn't fit"), findsOneWidget);
    expect(find.textContaining("don't fit tonight"), findsOneWidget);
    expect(find.textContaining('similar nights'), findsOneWidget);

    final target = vm.fillWindowFrameCount!;
    expect(target, inInclusiveRange(1, 499));
    final button = find.byKey(const Key('capturePlan.fillWindow'));
    expect(button, findsOneWidget);
    expect(
      find.textContaining('Trim Ha 300 s to $target frames'),
      findsOneWidget,
    );

    await tester.tap(button);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(vm.captureBlocks.single.frameCount, target);
    expect(vm.fitAnalysis.state, isNot(FitState.doesNotFit));
    expect(find.textContaining("Doesn't fit"), findsNothing);
    expect(find.textContaining('Capture ends'), findsOneWidget);
    // Already filled: the action disappears.
    expect(find.byKey(const Key('capturePlan.fillWindow')), findsNothing);
  });

  testWidgets('a short plan offers to fill the window instead', (tester) async {
    await build(tester);
    await tester.runAsync(
      () => vm.updateCaptureBlock(
        0,
        vm.captureBlocks.single.copyWith(frameCount: 2),
      ),
    );
    await tester.pumpAndSettle();
    expect(vm.fitAnalysis.state, FitState.fits);
    expect(
      find.textContaining("Fill tonight's window: Ha 300 s ×"),
      findsOneWidget,
    );
  });
}
