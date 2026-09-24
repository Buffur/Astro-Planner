import 'package:astroplan/data/repositories/shared_prefs_planner_state_repository.dart';
import 'package:astroplan/data/repositories/shared_prefs_planning_preferences_repository.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/repositories/storage_failure.dart';
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

    // TASK 8.6: the NPF k preference.
    test('NPF k defaults to 1, round-trips and is clamped to 1-3', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = SharedPrefsPlanningPreferencesRepository();
      expect((await repo.load()).npfK, 1.0);
      await repo.save(PlanningPreferences(npfK: 2));
      expect((await repo.load()).npfK, 2.0);
      SharedPreferences.setMockInitialValues({'npfK': 7.0});
      expect((await repo.load()).npfK, 3.0);
      expect(PlanningPreferences(npfK: 0).npfK, 1.0);
    });

    // TASK 10.2: the optional Moon and cloud gates (ADR-013 §2).
    test('optional gates are off by default and round-trip', () async {
      SharedPreferences.setMockInitialValues({});
      final loaded = await repo.load();
      expect(loaded.moonGateEnabled, isFalse);
      expect(loaded.cloudGateEnabled, isFalse);
      expect(loaded.optionalGates.moonMinIlluminationPct, isNull);
      expect(loaded.optionalGates.cloudMaxPct, isNull);

      final saved = PlanningPreferences(
        moonGateEnabled: true,
        moonGateMinIlluminationPct: 70,
        cloudGateEnabled: true,
        cloudGateMaxPct: 30,
      );
      await repo.save(saved);
      final back = await repo.load();
      expect(back, saved);
      expect(back.optionalGates.moonMinIlluminationPct, 70);
      expect(back.optionalGates.cloudMaxPct, 30);
      expect(PlanningPreferences(cloudGateMaxPct: 150).cloudGateMaxPct, 100);
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
      final blocks = [
        CaptureBlock(
          frameType: FrameType.light,
          filterName: 'Ha',
          exposureTimeSeconds: 300,
          frameCount: 24,
          gain: CaptureGain.gain(100),
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
      expect(loaded[0].gain, CaptureGain.gain(100));
      expect(loaded[1].frameType, FrameType.flat);
      expect(loaded[1].binning, 2);
    });

    test(
      'plan JSON is versioned (v2) and a pre-5.3 v1 list still loads',
      () async {
        SharedPreferences.setMockInitialValues({});
        await repo.saveCaptureBlocks([
          CaptureBlock(
            frameType: FrameType.dark,
            exposureTimeSeconds: 60,
            frameCount: 5,
            calibrationPolicy: CalibrationPolicy.library,
          ),
        ]);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('captureBlocks'), startsWith('{"version":2,'));
        expect(
          (await repo.loadCaptureBlocks())!.single.calibrationPolicy,
          CalibrationPolicy.library,
        );

        SharedPreferences.setMockInitialValues({
          'captureBlocks':
              '[{"id":0,"frameType":"light","filterName":"L",'
              '"exposureTimeSeconds":60.0,"frameCount":10,"binning":1,'
              '"gainIso":"100"},'
              '{"id":0,"frameType":"dark","exposureTimeSeconds":60.0,'
              '"frameCount":5,"binning":1,"gainIso":null},'
              '{"id":0,"frameType":"flat","exposureTimeSeconds":0,'
              '"frameCount":5,"binning":1}]',
        });
        final legacy = (await repo.loadCaptureBlocks())!;
        // The invalid flat (0 s) is skipped; the rest of the plan survives.
        expect(legacy, hasLength(2));
        expect(legacy[0].gain, CaptureGain.unknown(100));
        expect(legacy[1].calibrationPolicy, CalibrationPolicy.outsideWindow);
      },
    );

    test('a corrupt saved plan throws a typed StorageFailure (the ViewModel '
        'falls back; TASK 15.1)', () async {
      SharedPreferences.setMockInitialValues({'captureBlocks': 'not json'});
      await expectLater(
        repo.loadCaptureBlocks(),
        throwsA(
          isA<StorageFailure>().having(
            (f) => f.cause,
            'cause',
            isA<FormatException>(),
          ),
        ),
      );
    });
  });
}
