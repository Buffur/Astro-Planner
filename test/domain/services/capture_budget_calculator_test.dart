// ADR-009 §8 test vectors E1–E7 (budget half; the fit half is TASK 5.5).
//
// Expected values come from ADR-009 §8, computed independently of this code
// with a scratch model (SCIENTIFIC_INTEGRITY Part C rule 3). Every parameter
// is stated per test; nothing depends on a default except where noted.

import 'package:astroplan/domain/models/altitude_curve.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/models/visibility_window.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

CaptureBlock _light(double s, int n, {String? filter}) => CaptureBlock(
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

const _s = 1000; // ms per second

void main() {
  group('ADR-009 §8 vectors', () {
    test('E1 guided cooled rig: 29 dithers, 3 refocus', () {
      final b = CaptureBudgetCalculator.calculate(
        blocks: [_light(120, 90, filter: 'Ha')],
        overheads: const CaptureOverheads(
          perFrameMs: 2 * _s,
          ditherEveryNFrames: 3,
          ditherMs: 20 * _s,
          refocusEveryMs: 3600 * _s,
          refocusMs: 120 * _s,
        ),
      );
      expect(b.integrationMs, 10800 * _s);
      expect(b.acquisitionMs, 11920 * _s);
      expect(b.inWindowCalibrationMs, 0);
      expect(b.windowLoadMs, 11920 * _s);
      expect(b.sessionBudgetMs, 11920 * _s);
      expect(b.countOf(BudgetEventKind.dither), 29);
      expect(b.countOf(BudgetEventKind.refocus), 3);
      expect(b.setupMs, isNull); // not included
    });

    test('E1b: + meridian flip 300 s, transit inside the window', () {
      final b = CaptureBudgetCalculator.calculate(
        blocks: [_light(120, 90, filter: 'Ha')],
        overheads: const CaptureOverheads(
          perFrameMs: 2 * _s,
          ditherEveryNFrames: 3,
          ditherMs: 20 * _s,
          refocusEveryMs: 3600 * _s,
          refocusMs: 120 * _s,
          meridianFlipMs: 300 * _s,
        ),
        targetTransitsInWindow: true,
      );
      expect(b.acquisitionMs, 12220 * _s);
      expect(b.countOf(BudgetEventKind.meridianFlip), 1);
    });

    test('flip enabled but no transit in a window: not counted', () {
      final b = CaptureBudgetCalculator.calculate(
        blocks: [_light(120, 90)],
        overheads: const CaptureOverheads(
          perFrameMs: 0,
          meridianFlipMs: 300 * _s,
        ),
      );
      expect(b.countOf(BudgetEventKind.meridianFlip), 0);
      expect(b.acquisitionMs, 10800 * _s);
    });

    for (final (n, integ, acq) in [
      (40, 12000, 12200),
      (52, 15600, 15860),
      (53, 15900, 16165),
    ]) {
      test('E2 split window, $n × 300 s, per-frame 5 s', () {
        final b = CaptureBudgetCalculator.calculate(
          blocks: [_light(300, n)],
          overheads: const CaptureOverheads(perFrameMs: 5 * _s),
        );
        expect(b.integrationMs, integ * _s);
        expect(b.acquisitionMs, acq * _s);
        expect(b.windowLoadMs, acq * _s);
        // Every frame is one atomic 305 s event (for the TASK 5.5 fit).
        expect(b.sequence, hasLength(n));
        expect(b.sequence.every((e) => e.durationMs == 305 * _s), isTrue);
      });
    }

    test('E3 untracked smartphone, darks in-window', () {
      final b = CaptureBudgetCalculator.calculate(
        blocks: [
          _light(10, 300),
          _cal(FrameType.dark, 10, 30, CalibrationPolicy.inWindow),
        ],
        overheads: const CaptureOverheads(perFrameMs: 1 * _s),
      );
      expect(b.integrationMs, 3000 * _s);
      expect(b.acquisitionMs, 3300 * _s);
      expect(b.inWindowCalibrationMs, 330 * _s);
      expect(b.windowLoadMs, 3630 * _s);
      expect(b.outsideWindowCalibrationMs, 0);
      expect(b.sessionBudgetMs, 3630 * _s);
    });

    test(
      'E4 outside-window calibration, library darks, setup, filter change',
      () {
        final b = CaptureBudgetCalculator.calculate(
          blocks: [
            _light(180, 60, filter: 'L'),
            _light(180, 20, filter: 'R'),
            _cal(FrameType.flat, 2, 30, CalibrationPolicy.outsideWindow),
            _cal(FrameType.dark, 180, 20, CalibrationPolicy.library),
            _cal(FrameType.bias, 0.001, 50, CalibrationPolicy.outsideWindow),
          ],
          overheads: const CaptureOverheads(
            perFrameMs: 3 * _s,
            filterChangeMs: 30 * _s,
            setupMs: 2700 * _s,
          ),
        );
        expect(b.integrationMs, 14400 * _s);
        expect(b.acquisitionMs, 14670 * _s);
        expect(b.inWindowCalibrationMs, 0);
        expect(b.windowLoadMs, 14670 * _s);
        expect(b.outsideWindowCalibrationMs, 300050); // 150 s + 150.05 s
        expect(b.setupMs, 2700 * _s);
        expect(b.sessionBudgetMs, 17670050); // 17 670.05 s
        expect(b.countOf(BudgetEventKind.filterChange), 1);
        expect(b.libraryBlockIndexes, [3]);
        expect(b.blocks[3].totalMs, 0);
      },
    );

    test('E5 no window: the budget is still computed (fit says no window)', () {
      final b = CaptureBudgetCalculator.calculate(
        blocks: [_light(120, 30)],
        overheads: const CaptureOverheads(perFrameMs: 2 * _s),
      );
      expect(b.integrationMs, 3600 * _s);
      expect(b.windowLoadMs, 3660 * _s);
    });

    for (final n in [102, 103, 120, 121]) {
      test('E6 margin boundary budget, $n × 60 s, per-frame 0', () {
        final b = CaptureBudgetCalculator.calculate(
          blocks: [_light(60, n)],
          overheads: const CaptureOverheads(perFrameMs: 0),
        );
        expect(b.windowLoadMs, n * 60 * _s);
      });
    }

    test('E7 darks at the default policy are outside the window', () {
      final b = CaptureBudgetCalculator.calculate(
        blocks: [
          _light(300, 24),
          CaptureBlock(
            frameType: FrameType.dark,
            exposureTimeSeconds: 300,
            frameCount: 20,
          ), // default policy
        ],
        overheads: const CaptureOverheads(perFrameMs: 5 * _s),
      );
      expect(b.integrationMs, 7200 * _s);
      expect(b.windowLoadMs, 7320 * _s);
      expect(b.outsideWindowCalibrationMs, 6100 * _s);
      expect(b.sessionBudgetMs, 13420 * _s);
    });
  });

  group('edge cases', () {
    test('empty plan: all zero, storage zero when size known', () {
      final b = CaptureBudgetCalculator.calculate(
        blocks: const [],
        averageRawFileSizeMB: 50,
      );
      expect(b.windowLoadMs, 0);
      expect(b.sessionBudgetMs, 0);
      expect(b.sequence, isEmpty);
      expect(b.storageMB, 0);
    });

    test('no dither after the last light frame; none with 1 frame', () {
      final one = CaptureBudgetCalculator.calculate(
        blocks: [_light(60, 1)],
        overheads: const CaptureOverheads(ditherEveryNFrames: 1),
      );
      expect(one.countOf(BudgetEventKind.dither), 0);
      final three = CaptureBudgetCalculator.calculate(
        blocks: [_light(60, 3)],
        overheads: const CaptureOverheads(ditherEveryNFrames: 1),
      );
      expect(three.countOf(BudgetEventKind.dither), 2);
    });

    test(
      'storage: unknown file size is null, never zero; library excluded',
      () {
        final blocks = [
          _light(60, 10),
          _cal(FrameType.dark, 60, 5, CalibrationPolicy.library),
          _cal(FrameType.flat, 1, 5, CalibrationPolicy.outsideWindow),
        ];
        expect(
          CaptureBudgetCalculator.calculate(blocks: blocks).storageMB,
          isNull,
        );
        final known = CaptureBudgetCalculator.calculate(
          blocks: blocks,
          averageRawFileSizeMB: 25,
        );
        expect(known.storageMB, 375); // (10 + 5) × 25
        expect(known.blocks[1].storageMB, 0);
      },
    );

    test('overheads from preferences: defaults = 5 s per frame only', () {
      final o = CaptureOverheads.fromPreferences(PlanningPreferences());
      expect(o.perFrameMs, 5000);
      expect(o.ditherEveryNFrames, isNull);
      expect(o.refocusEveryMs, isNull);
      expect(o.filterChangeMs, isNull);
      expect(o.meridianFlipMs, isNull);
      expect(o.setupMs, isNull);
      final on = CaptureOverheads.fromPreferences(
        PlanningPreferences().withOptionalOverheads(
          refocusEveryMinutes: (60.0,),
          setupMinutes: (45.0,),
        ),
      );
      expect(on.refocusEveryMs, 3600000);
      expect(on.setupMs, 2700000);
    });
  });

  group('transitFallsInWindows', () {
    final night = SessionNightResolver.forEveningDate(
      CalendarDate(2026, 3, 1),
      latitude: 0,
      longitude: 0,
      timeContext: MeanSolarTimeContext(0),
    );
    AltitudeCurve curve(int peakIndex) => AltitudeCurve(
      night: night,
      samples: [
        for (var i = 0; i <= 288; i++)
          AltitudeSample(
            instantUtc: night.startUtc.add(Duration(minutes: 5 * i)),
            sunAltitudeDeg: -30,
            targetAltitudeDeg: 60 - (i - peakIndex).abs() * 0.1,
          ),
      ],
    );
    final peak = night.startUtc.add(const Duration(hours: 12));
    final window = VisibilityWindow(
      start: peak.subtract(const Duration(hours: 1)),
      end: peak.add(const Duration(hours: 1)),
    );

    test('interior maximum inside a window', () {
      expect(
        CaptureBudgetCalculator.transitFallsInWindows(curve(144), [window]),
        isTrue,
      );
    });

    test('maximum outside every window, or at the night edge', () {
      expect(
        CaptureBudgetCalculator.transitFallsInWindows(curve(20), [window]),
        isFalse,
      );
      expect(
        CaptureBudgetCalculator.transitFallsInWindows(curve(0), [window]),
        isFalse,
      );
      expect(
        CaptureBudgetCalculator.transitFallsInWindows(curve(144), const []),
        isFalse,
      );
    });
  });
}
