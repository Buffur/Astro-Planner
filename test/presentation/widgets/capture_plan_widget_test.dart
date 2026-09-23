// Widget tests for CapturePlanWidget (roadmap TASK 4.1, TD-012).
//
// Covers the two behaviors that weren't testable at the ViewModel level:
//   - the Add/Edit dialog rejects invalid exposure/frame-count input instead
//     of silently defaulting to 60 s x 30 frames;
//   - tapping an existing block opens a pre-filled Edit dialog whose Save
//     button calls updateCaptureBlock (previously unreachable from the UI).
// Reorder-index correctness (TD-010) is covered at the ViewModel level in
// planner_capture_blocks_test.dart, where it's deterministic and fast.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astroplan/data/database/app_database.dart'
    hide CaptureBlock, AstroTarget;
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/tracking_type.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/viewmodels/planner_viewmodel.dart';
import 'package:astroplan/presentation/widgets/capture_plan_widget.dart';

import '../../support/fake_location_service.dart';
import '../../support/no_snapshot_weather.dart';

class _MockWeather with NoSnapshotWeather implements WeatherRepository {}

void main() {
  late AppDatabase database;
  late PlannerViewModel vm;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    final locationRepo = DriftLocationRepository(database);
    final locId = await locationRepo.insertLocation(
      domain.LocationProfile(
        id: 0,
        name: 'Test',
        latitude: 51.5,
        longitude: -0.1,
        elevation: 10,
      ),
    );
    SharedPreferences.setMockInitialValues({'activeLocationId': locId});

    vm = PlannerViewModel(
      DriftTargetRepository(database),
      DriftEquipmentRepository(database),
      _MockWeather(),
      locationRepo,
      locationService: FakeLocationService(),
    );
    await vm.ready;
    // TASK 12.3: the plan is read-only outside the ViewModel.
    while (vm.captureBlocks.isNotEmpty) {
      await vm.removeCaptureBlock(0);
    }
  });

  tearDown(() async {
    await database.close();
  });

  Widget wrap() {
    return ChangeNotifierProvider<PlannerViewModel>.value(
      value: vm,
      // Home hosts the card inside a scrolling ListView; since TASK 5.6 the
      // card is taller than the 800x600 test surface, so scroll it here too.
      child: const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: CapturePlanWidget())),
      ),
    );
  }

  testWidgets('empty exposure and frame count are rejected, not defaulted', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();

    // The dialog is still open (validation failed) and no block was added.
    expect(find.text('Add Capture Block'), findsOneWidget);
    expect(find.text('Enter a positive number of seconds'), findsOneWidget);
    expect(find.text('Enter a whole number of at least 1'), findsOneWidget);
    expect(vm.captureBlocks, isEmpty);
  });

  testWidgets('a zero or negative exposure is rejected', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Exposure (seconds)'),
      '0',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Frame Count'),
      '10',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.text('Add Capture Block'), findsOneWidget);
    expect(vm.captureBlocks, isEmpty);
  });

  testWidgets('valid input adds a block and closes the dialog', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Exposure (seconds)'),
      '120',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Frame Count'),
      '15',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.text('Add Capture Block'), findsNothing);
    expect(vm.captureBlocks, hasLength(1));
    expect(vm.captureBlocks.single.exposureTimeSeconds, 120.0);
    expect(vm.captureBlocks.single.frameCount, 15);
  });

  testWidgets(
    'tapping a block opens a pre-filled edit dialog that updates it',
    (tester) async {
      await vm.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          filterName: 'L',
          exposureTimeSeconds: 60.0,
          frameCount: 30,
        ),
      );
      await tester.pumpWidget(wrap());
      await tester.pumpAndSettle();

      await tester.tap(find.text('LIGHT [L] '));
      await tester.pumpAndSettle();

      expect(find.text('Edit Capture Block'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Frame Count'),
        '45',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Capture Block'), findsNothing);
      expect(vm.captureBlocks, hasLength(1));
      expect(vm.captureBlocks.single.frameCount, 45);
      expect(vm.captureBlocks.single.exposureTimeSeconds, 60.0);
    },
  );

  testWidgets('stacking gain is labeled as relative, not SNR', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(
      find.text('Relative stacking gain (√N vs one frame)'),
      findsOneWidget,
    );
    expect(find.textContaining('SNR'), findsNothing);
  });

  testWidgets('unknown storage renders as Unknown, not a fabricated 0.0 MB', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(vm.estimatedStorageMB, isNull);
    expect(find.text('Unknown'), findsOneWidget);
    expect(find.textContaining('0.0 MB'), findsNothing);
  });

  testWidgets('the dialog saves a calibration policy and a typed gain', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.byIcon(Icons.add_circle));
    await tester.pumpAndSettle();

    await tester.tap(find.text('LIGHT').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('DARK').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('blockDialog.policy')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('During the window').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('blockDialog.gainKind')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ISO').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('blockDialog.gainValue')),
      '800',
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Exposure (seconds)'),
      '60',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Frame Count'),
      '10',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();

    final b = vm.captureBlocks.single;
    expect(b.frameType, FrameType.dark);
    expect(b.calibrationPolicy, CalibrationPolicy.inWindow);
    expect(b.gain, CaptureGain.iso(800));
  });

  testWidgets('breakdown, "Not included" assumptions and gain help render', (
    tester,
  ) async {
    await vm.addCaptureBlock(
      CaptureBlock(
        frameType: FrameType.light,
        filterName: 'Ha',
        exposureTimeSeconds: 300,
        frameCount: 20,
      ),
    );
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Integration (light exposure)'), findsOneWidget);
    expect(find.text('1h 40m'), findsOneWidget); // 20 x 300 s
    expect(find.text('Acquisition (lights + overheads)'), findsOneWidget);
    expect(find.text('Session budget'), findsOneWidget);
    expect(find.text('Ha · 300 s × 20'), findsOneWidget);
    expect(find.byKey(const Key('capturePlan.gainHelp')), findsOneWidget);
    expect(find.textContaining('not a signal-to-noise ratio'), findsOneWidget);

    await tester.ensureVisible(find.text('Assumptions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Assumptions'));
    await tester.pumpAndSettle();
    // Setup (summary) + dither, refocus, filter change, flip, setup (panel).
    expect(find.text('Not included'), findsNWidgets(6));
    expect(find.text('5 s'), findsOneWidget); // per-frame default
    expect(find.text('15 %'), findsOneWidget);
  });

  // TASK 8.6 acceptance: a phone with a 30 s block shows the NPF value and a
  // warning. Guidance only: the block stays in the plan.
  testWidgets('a phone on a tripod with a 30 s light block is warned', (
    tester,
  ) async {
    const phone = EquipmentProfile(
      id: 1,
      name: 'Phone',
      sensorWidthMm: 9.8,
      sensorHeightMm: 7.3,
      pixelPitchUm: 1.22,
      resolutionWidthPx: 8064,
      resolutionHeightPx: 6048,
      focalLengthMm: 6.86,
      focalRatio: 1.78,
      trackingType: TrackingType.untracked,
    );
    const target = AstroTarget(
      id: 1,
      catalogId: 'M42',
      rightAscension: 83.82,
      declination: -5.39,
      type: 'Nebula',
    );
    await tester.runAsync(() async {
      await vm.setEquipment(phone);
      await vm.setTarget(target);
      await vm.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          exposureTimeSeconds: 30,
          frameCount: 20,
        ),
      );
      await vm.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          exposureTimeSeconds: 2,
          frameCount: 100,
        ),
      );
    });
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    final npf = vm.rigCapability!.npf!;
    expect(npf.seconds, lessThan(30));
    expect(
      find.byKey(const Key('capture.subWarning')),
      findsOneWidget,
      reason: 'only the 30 s block, not the 2 s one',
    );
    expect(
      find.textContaining('Longer than the recommended max sub'),
      findsOneWidget,
    );
    expect(vm.captureBlocks, hasLength(2), reason: 'never blocks the plan');
  });

  testWidgets('a guided rig without a maximum exposure gets no warning', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await vm.setEquipment(
        const EquipmentProfile(
          id: 2,
          name: 'Guided scope',
          sensorWidthMm: 23.5,
          sensorHeightMm: 15.7,
          pixelPitchUm: 3.76,
          resolutionWidthPx: 6248,
          resolutionHeightPx: 4176,
          focalLengthMm: 400,
          focalRatio: 5.6,
          trackingType: TrackingType.guided,
        ),
      );
      await vm.addCaptureBlock(
        CaptureBlock(
          frameType: FrameType.light,
          exposureTimeSeconds: 600,
          frameCount: 10,
        ),
      );
    });
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('capture.subWarning')), findsNothing);
  });
}
