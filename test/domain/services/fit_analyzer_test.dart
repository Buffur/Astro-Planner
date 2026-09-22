// ADR-009 §8 test vectors, fit half (TASK 5.5), plus margin, inverse and
// no-window cases. Expected values come from ADR-009 §8 (independent scratch
// model), except E1b, corrected by the TASK 5.5 erratum recorded in
// ADR-009 §8: under §4/§6 the flip is dropped when the plan ends before the
// transit.

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/models/visibility_window.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/fit_analyzer.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:astroplan/domain/services/visibility_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Clock times on the night of 2026-10-10 (UTC); hours < 12 are next day.
DateTime _t(int h, [int m = 0, int s = 0]) =>
    DateTime.utc(2026, 10, h < 12 ? 11 : 10, h, m, s);

VisibilityWindow _w(DateTime a, DateTime b) =>
    VisibilityWindow(start: a, end: b);

CaptureBlock _light(double s, int n, {String? filter}) => CaptureBlock(
  frameType: FrameType.light,
  exposureTimeSeconds: s,
  frameCount: n,
  filterName: filter,
);

const _s = 1000;

FitResult _fit(
  List<CaptureBlock> blocks,
  CaptureOverheads o,
  List<VisibilityWindow> windows, {
  double margin = 0.15,
  DateTime? transit,
  bool transitInWindow = false,
}) => FitAnalyzer.analyze(
  budget: CaptureBudgetCalculator.calculate(
    blocks: blocks,
    overheads: o,
    targetTransitsInWindow: transitInWindow,
  ),
  windows: windows,
  marginFraction: margin,
  transitUtc: transit,
);

void main() {
  final w1 = [_w(_t(21), _t(3))];
  final w2 = [_w(_t(22), _t(23, 30)), _w(_t(1), _t(4))];
  const e1 = CaptureOverheads(
    perFrameMs: 2 * _s,
    ditherEveryNFrames: 3,
    ditherMs: 20 * _s,
    refocusEveryMs: 3600 * _s,
    refocusMs: 120 * _s,
    meridianFlipMs: 300 * _s,
  );

  group('ADR-009 §8 fit vectors', () {
    test('E1 fits, ends 00:18:40', () {
      final f = _fit(
        [_light(120, 90, filter: 'Ha')],
        const CaptureOverheads(
          perFrameMs: 2 * _s,
          ditherEveryNFrames: 3,
          ditherMs: 20 * _s,
          refocusEveryMs: 3600 * _s,
          refocusMs: 120 * _s,
        ),
        w1,
      );
      expect(f.state, FitState.fits);
      expect(f.endUtc, _t(0, 18, 40));
      expect(f.lostTailsMs, isEmpty);
      expect(f.reason, contains('to spare'));
    });

    test(
      'E1b (erratum): transit 00:40 after the plan ends -> flip dropped',
      () {
        final f = _fit(
          [_light(120, 90, filter: 'Ha')],
          e1,
          w1,
          transit: _t(0, 40),
          transitInWindow: true,
        );
        expect(f.state, FitState.fits);
        expect(f.flipDropped, isTrue);
        expect(f.flipApplied, isFalse);
        expect(f.endUtc, _t(0, 18, 40));
        expect(f.reason, contains('meridian flip is not needed'));
      },
    );

    test(
      'E1b variant: transit 22:00 mid-plan -> flip applied, ends 00:23:40',
      () {
        final f = _fit(
          [_light(120, 90, filter: 'Ha')],
          e1,
          w1,
          transit: _t(22),
          transitInWindow: true,
        );
        expect(f.flipApplied, isTrue);
        expect(f.flipDropped, isFalse);
        expect(f.endUtc, _t(0, 23, 40));
      },
    );

    test('E2a split window, 40 frames: fits, ends 02:56:55, 215 s lost', () {
      final f = _fit(
        [_light(300, 40)],
        const CaptureOverheads(perFrameMs: 5 * _s),
        w2,
      );
      expect(f.state, FitState.fits);
      expect(f.endUtc, _t(2, 56, 55));
      expect(f.lostTailsMs, [215 * _s]);
      expect(f.unusedMs, 4000 * _s);
    });

    test('E2b 52 frames: tight, ends 03:57:55', () {
      final f = _fit(
        [_light(300, 52)],
        const CaptureOverheads(perFrameMs: 5 * _s),
        w2,
      );
      expect(f.state, FitState.tight);
      expect(f.endUtc, _t(3, 57, 55));
      expect(f.lostTailsMs, [215 * _s]);
    });

    test('E2c 53 frames: does not fit although 16 165 s <= 16 200 s', () {
      final f = _fit(
        [_light(300, 53)],
        const CaptureOverheads(perFrameMs: 5 * _s),
        w2,
      );
      expect(f.state, FitState.doesNotFit);
      expect(f.unplacedFramesByBlock, {0: 1});
      expect(f.lostTailsMs, [215 * _s, 125 * _s]);
      expect(f.nightsNeeded, 2);
      expect(f.reason, contains("1 frame don't fit"));
      expect(f.reason, contains('About 2 similar nights'));
    });

    test('E2 inverse: at most 52 frames of 300 s can be placed', () {
      expect(
        FitAnalyzer.maxPlaceableFrames(
          exposureSeconds: 300,
          windows: w2,
          overheads: const CaptureOverheads(perFrameMs: 5 * _s),
        ),
        52,
      );
    });

    test('E3 untracked smartphone, darks in-window: fits, ends 23:10:30', () {
      final f = _fit(
        [
          _light(10, 300),
          CaptureBlock(
            frameType: FrameType.dark,
            exposureTimeSeconds: 10,
            frameCount: 30,
            calibrationPolicy: CalibrationPolicy.inWindow,
          ),
        ],
        const CaptureOverheads(perFrameMs: 1 * _s),
        [_w(_t(22, 10), _t(2, 40))],
      );
      expect(f.state, FitState.fits);
      expect(f.endUtc, _t(23, 10, 30));
    });

    test('E4: fits, ends 01:34:30 (outside-window calibration not placed)', () {
      final f = _fit(
        [
          _light(180, 60, filter: 'L'),
          _light(180, 20, filter: 'R'),
          CaptureBlock(
            frameType: FrameType.flat,
            exposureTimeSeconds: 2,
            frameCount: 30,
          ),
          CaptureBlock(
            frameType: FrameType.dark,
            exposureTimeSeconds: 180,
            frameCount: 20,
            calibrationPolicy: CalibrationPolicy.library,
          ),
          CaptureBlock(
            frameType: FrameType.bias,
            exposureTimeSeconds: 0.001,
            frameCount: 50,
          ),
        ],
        const CaptureOverheads(
          perFrameMs: 3 * _s,
          filterChangeMs: 30 * _s,
          setupMs: 2700 * _s,
        ),
        [_w(_t(21, 30), _t(4, 30))],
      );
      expect(f.state, FitState.fits);
      expect(f.endUtc, _t(1, 34, 30));
    });

    test('E5 no window: state and the supplied reason', () {
      final f = FitAnalyzer.analyze(
        budget: CaptureBudgetCalculator.calculate(blocks: [_light(120, 30)]),
        windows: const [],
        noWindowReason:
            'No usable window: the Sun never gets below -18° tonight.',
      );
      expect(f.state, FitState.noWindow);
      expect(f.reason, contains('never gets below'));
      expect(f.endUtc, isNull);
    });

    for (final (n, state, end, tails) in [
      (102, FitState.fits, _t(23, 42), <int>[]),
      (103, FitState.tight, _t(23, 43), <int>[]),
      (120, FitState.tight, _t(0), <int>[]),
      (121, FitState.doesNotFit, null, [0]),
    ]) {
      test('E6 margin boundary: $n x 60 s in 2 h -> ${state.name}', () {
        final f = _fit(
          [_light(60, n)],
          const CaptureOverheads(perFrameMs: 0),
          [_w(_t(22), _t(0))],
        );
        expect(f.state, state);
        if (end != null) expect(f.endUtc, end);
        expect(f.lostTailsMs, tails);
      });
    }

    test(
      'E7: fits under ADR-009 (the old rule said infeasible), ends 23:02',
      () {
        final f = _fit(
          [
            _light(300, 24),
            CaptureBlock(
              frameType: FrameType.dark,
              exposureTimeSeconds: 300,
              frameCount: 20,
            ),
          ],
          const CaptureOverheads(perFrameMs: 5 * _s),
          [_w(_t(21), _t(0, 30))],
        );
        expect(f.state, FitState.fits);
        expect(f.endUtc, _t(23, 2));
      },
    );
  });

  group('margin configuration', () {
    List<CaptureBlock> plan(int n) => [_light(60, n)];
    const o = CaptureOverheads(perFrameMs: 0);
    final twoHours = [_w(_t(22), _t(0))];

    test('a smaller margin turns E6 103 from tight to fits', () {
      expect(_fit(plan(103), o, twoHours, margin: 0.10).state, FitState.fits);
    });

    test('a larger margin turns 90 frames tight; 0 % only tight never', () {
      expect(_fit(plan(90), o, twoHours).state, FitState.fits);
      expect(_fit(plan(90), o, twoHours, margin: 0.30).state, FitState.tight);
      expect(_fit(plan(120), o, twoHours, margin: 0).state, FitState.fits);
    });
  });

  test('a plan with no light frames has nothing to fit', () {
    final f = FitAnalyzer.analyze(
      budget: CaptureBudgetCalculator.calculate(
        blocks: [
          CaptureBlock(
            frameType: FrameType.flat,
            exposureTimeSeconds: 2,
            frameCount: 20,
          ),
        ],
      ),
      windows: [_w(_t(22), _t(0))],
    );
    expect(f.state, FitState.nothingToFit);
  });

  test('inverse with no windows is 0; single window is floor(avail/unit)', () {
    expect(
      FitAnalyzer.maxPlaceableFrames(exposureSeconds: 60, windows: const []),
      0,
    );
    expect(
      FitAnalyzer.maxPlaceableFrames(
        exposureSeconds: 60,
        windows: [_w(_t(22), _t(0))],
        overheads: const CaptureOverheads(perFrameMs: 0),
      ),
      120,
    );
  });

  group('noWindowReason', () {
    final night = SessionNightResolver.forEveningDate(
      CalendarDate(2026, 6, 20),
      latitude: 51.5,
      longitude: -0.13,
      timeContext: MeanSolarTimeContext(-0.13),
    );
    final timeline = VisibilityCalculator.calculateNightTimelineForNight(night);

    test('London in June: the Sun never reaches -18°', () {
      expect(
        FitAnalyzer.noWindowReason(
          timeline: timeline,
          darknessLimitDeg: -18,
          minAltitudeDeg: 20,
        ),
        contains('never gets below -18°'),
      );
    });

    test('at -12° there is darkness, so the target is the reason', () {
      expect(
        FitAnalyzer.noWindowReason(
          timeline: timeline,
          darknessLimitDeg: -12,
          minAltitudeDeg: 20,
        ),
        contains('never rises above 20°'),
      );
    });
  });
}
