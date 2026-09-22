// Tests for PlannerViewModel's capture-block editing (roadmap TASK 4.1).
//
// TD-010: reorderCaptureBlocks() re-applied the classic `newIndex -= 1`
// adjustment on top of one the widget's onReorderItem callback already makes
// (Flutter's ReorderableListView.onReorderItem contract: "adjusts the
// newIndex parameter for a removed item at the oldIndex"), so a block
// dragged downward landed one slot short of where it was dropped. Fixed by
// removing the extra adjustment — these tests call reorderCaptureBlocks with
// already-adjusted indices, exactly as onReorderItem would.

import 'package:flutter_test/flutter_test.dart';
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

import '../../support/fake_location_service.dart';

class _MockWeather implements WeatherRepository {
  @override
  Future<WeatherConditions?> getCurrentWeather(
    double lat,
    double lon, {
    bool forceRefresh = false,
  }) async => null;
}

CaptureBlock _block(String label, {int frameCount = 10}) {
  return CaptureBlock(
    frameType: FrameType.light,
    filterName: label,
    exposureTimeSeconds: 60.0,
    frameCount: frameCount,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late DriftLocationRepository locationRepo;
  late PlannerViewModel vm;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    locationRepo = DriftLocationRepository(database);

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
      LightPollutionRepository(),
      locationService: FakeLocationService(),
    );

    await vm.ready;
    // Start from a known, empty plan — the default seed (3 blocks) would
    // make the reorder assertions harder to read.
    vm.captureBlocks.clear();
    for (final label in ['A', 'B', 'C', 'D']) {
      await vm.addCaptureBlock(_block(label));
    }
  });

  tearDown(() async {
    await database.close();
  });

  List<String> labels() => vm.captureBlocks.map((b) => b.filterName!).toList();

  group('PlannerViewModel.reorderCaptureBlocks (TASK 4.1, TD-010)', () {
    test('starts as A, B, C, D', () {
      expect(labels(), ['A', 'B', 'C', 'D']);
    });

    test(
      'dragging the first item down one slot (already-adjusted index)',
      () async {
        // A dragged from 0 to just after B: onReorderItem's contract gives
        // newIndex=1 (post-removal), not 2.
        await vm.reorderCaptureBlocks(0, 1);
        expect(labels(), ['B', 'A', 'C', 'D']);
      },
    );

    test('dragging an item down to the last slot', () async {
      // A dragged to the end: post-removal index is 3 (list length - 1).
      await vm.reorderCaptureBlocks(0, 3);
      expect(labels(), ['B', 'C', 'D', 'A']);
    });

    test('dragging the last item up one slot', () async {
      await vm.reorderCaptureBlocks(3, 2);
      expect(labels(), ['A', 'B', 'D', 'C']);
    });

    test('dragging an item up to the first slot', () async {
      await vm.reorderCaptureBlocks(3, 0);
      expect(labels(), ['D', 'A', 'B', 'C']);
    });

    test('dragging the second item down to the end', () async {
      await vm.reorderCaptureBlocks(1, 3);
      expect(labels(), ['A', 'C', 'D', 'B']);
    });

    test('triggers notifyListeners()', () async {
      var notified = false;
      vm.addListener(() => notified = true);
      await vm.reorderCaptureBlocks(0, 1);
      expect(notified, isTrue);
    });
  });

  group('PlannerViewModel.updateCaptureBlock (TASK 4.1, TD-012)', () {
    test('replaces the block at the given index', () async {
      final updated = _block('B-edited', frameCount: 99);
      await vm.updateCaptureBlock(1, updated);
      expect(vm.captureBlocks[1].filterName, 'B-edited');
      expect(vm.captureBlocks[1].frameCount, 99);
      expect(labels(), ['A', 'B-edited', 'C', 'D']);
    });

    test('does nothing for an out-of-range index', () async {
      await vm.updateCaptureBlock(99, _block('nope'));
      expect(labels(), ['A', 'B', 'C', 'D']);
    });
  });
}
