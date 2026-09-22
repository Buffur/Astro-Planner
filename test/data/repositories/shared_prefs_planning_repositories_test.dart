import 'package:astroplan/data/repositories/shared_prefs_planner_state_repository.dart';
import 'package:astroplan/data/repositories/shared_prefs_planning_preferences_repository.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SharedPrefsPlanningPreferencesRepository', () {
    final repo = SharedPrefsPlanningPreferencesRepository();

    test('nothing saved -> documented defaults', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await repo.load(), PlanningPreferences());
    });

    test('reads the pre-TASK 5.2 keys, so saved values survive', () async {
      SharedPreferences.setMockInitialValues({
        'minAltitude': 30.0,
        'dewPointThreshold': 3.5,
      });
      final p = await repo.load();
      expect(p.minAltitudeDeg, 30.0);
      expect(p.dewMarginC, 3.5);
    });

    test('round trip, including optional overheads on and off', () async {
      SharedPreferences.setMockInitialValues({});
      final saved = PlanningPreferences(
        minAltitudeDeg: 25,
        darknessLimit: DarknessLimit.nautical,
        feasibilityMarginPercent: 20,
        dewMarginC: 1.5,
        perFrameOverheadSeconds: 2,
        ditherEveryNFrames: 4,
        ditherSettleSeconds: 25,
        refocusEveryMinutes: 45,
        meridianFlipSeconds: 240,
      );
      await repo.save(saved);
      expect(await repo.load(), saved);

      await repo.save(saved.withOptionalOverheads(ditherEveryNFrames: (null,)));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('ditherEveryNFrames'), isFalse);
      expect((await repo.load()).ditherEveryNFrames, isNull);
    });

    test('out-of-range stored values are clamped on load', () async {
      SharedPreferences.setMockInitialValues({'minAltitude': 99.0});
      expect((await repo.load()).minAltitudeDeg, 60.0);
    });
  });

  group('SharedPrefsPlannerStateRepository', () {
    final repo = SharedPrefsPlannerStateRepository();

    test('ids round trip under the pre-TASK 5.2 keys', () async {
      SharedPreferences.setMockInitialValues({});
      await repo.setActiveLocationId(7);
      await repo.setSelectedTargetId(8);
      await repo.setSelectedEquipmentId(9);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('activeLocationId'), 7);
      expect(prefs.getInt('targetId'), 8);
      expect(prefs.getInt('equipmentId'), 9);
      expect(await repo.getActiveLocationId(), 7);
      expect(await repo.getSelectedTargetId(), 8);
      expect(await repo.getSelectedEquipmentId(), 9);
    });

    test('capture plan round trip; none saved -> null', () async {
      SharedPreferences.setMockInitialValues({});
      expect(await repo.loadCaptureBlocks(), isNull);
      const blocks = [
        CaptureBlock(
          frameType: FrameType.light,
          filterName: 'Ha',
          exposureTimeSeconds: 300,
          frameCount: 24,
          gainIso: '100',
        ),
        CaptureBlock(
          frameType: FrameType.flat,
          exposureTimeSeconds: 2,
          frameCount: 30,
          binning: 2,
        ),
      ];
      await repo.saveCaptureBlocks(blocks);
      final loaded = (await repo.loadCaptureBlocks())!;
      expect(loaded.length, 2);
      expect(loaded[0].filterName, 'Ha');
      expect(loaded[0].frameCount, 24);
      expect(loaded[0].gainIso, '100');
      expect(loaded[1].frameType, FrameType.flat);
      expect(loaded[1].binning, 2);
    });

    test('a corrupt saved plan throws (the ViewModel falls back)', () async {
      SharedPreferences.setMockInitialValues({'captureBlocks': 'not json'});
      expect(repo.loadCaptureBlocks(), throwsFormatException);
    });
  });
}
