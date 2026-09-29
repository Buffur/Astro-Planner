// S7.3b (ADR-020 §8, amending ADR-009 §2, §4 and §6): in-camera long-exposure
// noise reduction. When it applies, each light frame is followed by one dark
// of the light's exposure, inside the light's atomic event; its time is
// in-window calibration, never integration or acquisition.
//
// Expected values are ADR-020 §8's vectors, computed by hand for the ADR and
// re-derived below from the plan alone (SCIENTIFIC_INTEGRITY Part C rule 3),
// never from the implementation. Window W5 is 22:00-00:00 (7,200 s), margin
// 15 % (the tight limit is 6,120 s).

import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/visibility_window.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/fit_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

/// Clock times on the night of 2026-10-10 (UTC); hours < 12 are next day.
DateTime _t(int h, [int m = 0, int s = 0]) =>
    DateTime.utc(2026, 10, h < 12 ? 11 : 10, h, m, s);

CaptureBlock _lights(int n, {double s = 60}) => CaptureBlock(
  frameType: FrameType.light,
  exposureTimeSeconds: s,
  frameCount: n,
);

const _s = 1000;
const _on = CaptureOverheads(perFrameMs: 5 * _s, inCameraNoiseReduction: true);
const _off = CaptureOverheads(perFrameMs: 5 * _s);

void main() {
  final w5 = [VisibilityWindow(start: _t(22), end: _t(0))];

  ({CaptureBudget budget, FitResult fit}) run(int n, CaptureOverheads o) {
    final budget = CaptureBudgetCalculator.calculate(
      blocks: [_lights(n)],
      overheads: o,
    );
    return (
      budget: budget,
      fit: FitAnalyzer.analyze(budget: budget, windows: w5),
    );
  }

  test('E8: 30 x 60 s, per-frame 5 s, noise reduction on', () {
    final r = run(30, _on);
    // Integration 30 x 60 = 1,800 s; acquisition 30 x (60 + 5) = 1,950 s;
    // in-window calibration 30 x 60 = 1,800 s (the in-camera darks);
    // window load 1,950 + 1,800 = 3,750 s.
    expect(r.budget.integrationMs, 1800 * _s);
    expect(r.budget.acquisitionMs, 1950 * _s);
    expect(r.budget.inWindowCalibrationMs, 1800 * _s);
    expect(r.budget.inCameraDarkMs, 1800 * _s);
    expect(r.budget.windowLoadMs, 3750 * _s);
    // Events of 60 + 60 + 5 = 125 s; 30 x 125 = 3,750 s from 22:00 ends at
    // 23:02:30; 3,750 <= 6,120, so it fits with the margin.
    expect(r.fit.state, FitState.fits);
    expect(r.fit.endUtc, _t(23, 2, 30));
    expect(r.fit.lostTailsMs, isEmpty);
  });

  test('E8b: 60 x 60 s with noise reduction does not fit: 57 placed, '
      '3 unplaced, a 75 s tail', () {
    final r = run(60, _on);
    // Integration 3,600 s; acquisition 60 x 65 = 3,900 s; darks 3,600 s;
    // load 7,500 s > 7,200 s.
    expect(r.budget.integrationMs, 3600 * _s);
    expect(r.budget.acquisitionMs, 3900 * _s);
    expect(r.budget.inWindowCalibrationMs, 3600 * _s);
    expect(r.budget.windowLoadMs, 7500 * _s);
    // floor(7,200 / 125) = 57 events (7,125 s); 7,200 - 7,125 = 75 s lost.
    expect(r.fit.state, FitState.doesNotFit);
    expect(r.fit.unplacedFramesByBlock, {0: 3});
    expect(r.fit.placedMs, 57 * 125 * _s);
    expect(r.fit.lostTailsMs, [75 * _s]);
  });

  test('E8c: E8b with noise reduction off fits and ends 23:05:00', () {
    final r = run(60, _off);
    // Events of 65 s; 60 x 65 = 3,900 s from 22:00 ends 23:05:00.
    expect(r.budget.integrationMs, 3600 * _s);
    expect(r.budget.acquisitionMs, 3900 * _s);
    expect(r.budget.inWindowCalibrationMs, 0);
    expect(r.budget.inCameraDarkMs, 0);
    expect(r.budget.windowLoadMs, 3900 * _s);
    expect(r.fit.state, FitState.fits);
    expect(r.fit.endUtc, _t(23, 5));
  });

  test('the dark is never split from its light: a window too short for the '
      'whole event loses its tail', () {
    // 22:00-22:03:00 (180 s) holds one 125 s event and loses 55 s; the
    // second event starts in the next window.
    final windows = [
      VisibilityWindow(start: _t(22), end: _t(22, 3)),
      VisibilityWindow(start: _t(23), end: _t(0)),
    ];
    final fit = FitAnalyzer.analyze(
      budget: CaptureBudgetCalculator.calculate(
        blocks: [_lights(2)],
        overheads: _on,
      ),
      windows: windows,
    );
    expect(fit.lostTailsMs, [55 * _s]);
    expect(fit.endUtc, _t(23, 2, 5));
  });

  test('calibration blocks take no in-camera dark; √N and the light groups '
      'are unchanged', () {
    final budget = CaptureBudgetCalculator.calculate(
      blocks: [
        _lights(10),
        CaptureBlock(
          frameType: FrameType.dark,
          exposureTimeSeconds: 60,
          frameCount: 10,
          calibrationPolicy: CalibrationPolicy.inWindow,
        ),
      ],
      overheads: _on,
    );
    // Lights' darks 10 x 60 = 600 s; the dark block 10 x (60 + 5) = 650 s.
    expect(budget.inCameraDarkMs, 600 * _s);
    expect(budget.inWindowCalibrationMs, 1250 * _s);
    expect(budget.lightGroups.single.frames, 10);
  });

  test('"Fill tonight\'s window" counts the darks: 57 frames fit W5', () {
    expect(
      FitAnalyzer.maxFramesForBlock(
        blocks: [_lights(1)],
        blockIndex: 0,
        windows: w5,
        overheads: _on,
      ),
      57,
    );
    expect(
      FitAnalyzer.maxFramesForBlock(
        blocks: [_lights(1)],
        blockIndex: 0,
        windows: w5,
        overheads: _off,
      ),
      110, // floor(7,200 / 65)
    );
  });

  group('the switch applies only to cameras and Unknown (ADR-020 §8)', () {
    for (final c in CameraClass.values) {
      final applies =
          c == CameraClass.dslrMirrorless || c == CameraClass.unknown;
      test('${c.label}: ${applies ? 'counted' : 'kept and ignored'}', () {
        final rig = EquipmentProfile(
          id: 1,
          name: 'Rig',
          cameraClass: c,
          inCameraNoiseReduction: true,
          sensorWidthMm: 23.5,
          sensorHeightMm: 15.6,
          pixelPitchUm: 3.9,
          resolutionWidthPx: 6000,
          resolutionHeightPx: 4000,
          focalLengthMm: 400,
          focalRatio: 5.6,
        );
        expect(c.offersInCameraNoiseReduction, applies);
        expect(rig.noiseReductionApplies, applies);
        expect(rig.inCameraNoiseReduction, isTrue, reason: 'kept as stored');
        expect(rig.withEditProvenance(null).inCameraNoiseReduction, isTrue);
      });
    }
  });
}
