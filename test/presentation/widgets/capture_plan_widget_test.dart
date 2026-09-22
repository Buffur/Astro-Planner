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
import 'package:astroplan/data/database/app_database.dart' hide CaptureBlock;
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/light_pollution_repository.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/weather_conditions.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/viewmodels/planner_viewmodel.dart';
import 'package:astroplan/presentation/widgets/capture_plan_widget.dart';

import '../../support/fake_location_service.dart';

class _MockWeather implements WeatherRepository {
  @override
  Future<WeatherConditions?> getCurrentWeather(
    double lat,
    double lon, {
    bool forceRefresh = false,
  }) async => null;
}

void main() {
  late AppDatabase database;
  late PlannerViewModel vm;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    final locationRepo = DriftLocationRepository(database);
    final locId = await locationRepo.insertLocation(
      const domain.LocationProfile(
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
      LightPollutionRepository(),
      locationService: FakeLocationService(),
    );
    await vm.ready;
    vm.captureBlocks.clear();
  });

  tearDown(() async {
    await database.close();
  });

  Widget wrap() {
    return ChangeNotifierProvider<PlannerViewModel>.value(
      value: vm,
      child: const MaterialApp(home: Scaffold(body: CapturePlanWidget())),
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
        const CaptureBlock(
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
}
