// S7.3a (ADR-020 §6; RG-10 = L1, D1): the calibration matrix's required
// matches, pure. Darks and dark flats match exposure, ISO or gain and
// binning; bias the ISO or gain and binning; flats the filter and binning.
// Unknown never fails a check; binning counts only where the class offers
// it. A dark flat is a frame type of its own, calibration on its policy's
// budget line.

import 'package:astroplan/domain/models/camera_class.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/services/calibration_match.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

CaptureBlock _b(
  FrameType type, {
  String? filter,
  double exposure = 300,
  int count = 10,
  int binning = 1,
  CaptureGain gain = CaptureGain.none,
  CalibrationPolicy? policy,
}) => CaptureBlock(
  frameType: type,
  filterName: filter,
  exposureTimeSeconds: exposure,
  frameCount: count,
  binning: binning,
  gain: gain,
  calibrationPolicy: type == FrameType.light
      ? null
      : policy ?? CalibrationPolicy.outsideWindow,
);

const _astro = CameraClass.astroMono;
const _dslr = CameraClass.dslrMirrorless;

void main() {
  final ha = _b(
    FrameType.light,
    filter: 'Ha',
    exposure: 300,
    binning: 2,
    gain: CaptureGain.gain(100),
  );
  final oiii = _b(
    FrameType.light,
    filter: 'OIII',
    exposure: 180,
    binning: 2,
    gain: CaptureGain.gain(100),
  );

  group('darks', () {
    test('match a light on exposure, gain and binning', () {
      final dark = _b(
        FrameType.dark,
        exposure: 180,
        binning: 2,
        gain: CaptureGain.gain(100),
      );
      expect(CalibrationMatch.of(dark, [ha, oiii, dark], _astro), isEmpty);
    });

    test('an exposure no light has is a mismatch, compared in whole '
        'milliseconds', () {
      final dark = _b(
        FrameType.dark,
        exposure: 240,
        binning: 2,
        gain: CaptureGain.gain(100),
      );
      expect(CalibrationMatch.of(dark, [ha, oiii], _astro), [
        CalibrationMismatch.matchesNoLight,
      ]);
      final close = _b(
        FrameType.dark,
        exposure: 300.0004,
        binning: 2,
        gain: CaptureGain.gain(100),
      );
      expect(CalibrationMatch.of(close, [ha], _astro), isEmpty);
    });

    test('another gain or binning is a mismatch', () {
      expect(
        CalibrationMatch.of(
          _b(FrameType.dark, binning: 2, gain: CaptureGain.gain(200)),
          [ha],
          _astro,
        ),
        [CalibrationMismatch.matchesNoLight],
      );
      expect(
        CalibrationMatch.of(
          _b(FrameType.dark, binning: 1, gain: CaptureGain.gain(100)),
          [ha],
          _astro,
        ),
        [CalibrationMismatch.matchesNoLight],
      );
    });

    test('unknown never fails: an ISO or gain not recorded on either side, '
        'and binning where the class does not offer it', () {
      expect(
        CalibrationMatch.of(_b(FrameType.dark, binning: 2), [ha], _astro),
        isEmpty,
      );
      final dslrLight = _b(FrameType.light, gain: CaptureGain.iso(800));
      expect(
        CalibrationMatch.of(
          _b(FrameType.dark, binning: 3, gain: CaptureGain.iso(800)),
          [dslrLight],
          _dslr,
        ),
        isEmpty,
      );
    });

    test('without lights, a dark matches none', () {
      expect(CalibrationMatch.of(_b(FrameType.dark), const [], _astro), [
        CalibrationMismatch.matchesNoLight,
      ]);
    });
  });

  test('darks twice (S7.3b, ADR-020 §8): a matching dark while in-camera '
      'noise reduction applies; never a bias, never without it', () {
    final dark = _b(
      FrameType.dark,
      exposure: 300,
      binning: 2,
      gain: CaptureGain.gain(100),
    );
    expect(CalibrationMatch.of(dark, [ha], _dslr, noiseReduction: true), [
      CalibrationMismatch.darksTwice,
    ]);
    expect(CalibrationMatch.of(dark, [ha], _dslr), isEmpty);
    // A dark that matches no light is that warning alone.
    expect(
      CalibrationMatch.of(
        _b(FrameType.dark, exposure: 240, gain: CaptureGain.gain(100)),
        [ha],
        _dslr,
        noiseReduction: true,
      ),
      [CalibrationMismatch.matchesNoLight],
    );
    final bias = _b(
      FrameType.bias,
      exposure: 0.001,
      gain: CaptureGain.gain(100),
    );
    expect(
      CalibrationMatch.of(bias, [ha], _dslr, noiseReduction: true),
      isEmpty,
    );
    expect(CalibrationMismatch.darksTwice.fixable, isFalse);
    expect(CalibrationMismatch.matchesNoLight.fixable, isTrue);
  });

  test('bias matches the ISO or gain and binning; its exposure is its own', () {
    final bias = _b(
      FrameType.bias,
      exposure: 0.001,
      binning: 2,
      gain: CaptureGain.gain(100),
    );
    expect(CalibrationMatch.of(bias, [ha], _astro), isEmpty);
    expect(
      CalibrationMatch.of(
        _b(FrameType.bias, exposure: 0.001, gain: CaptureGain.gain(0)),
        [ha],
        _astro,
      ),
      [CalibrationMismatch.matchesNoLight],
    );
  });

  test('flats match a light filter and binning; their exposure is their '
      'own', () {
    final flat = _b(FrameType.flat, filter: 'Ha', exposure: 2, binning: 2);
    expect(CalibrationMatch.of(flat, [ha], _astro), isEmpty);
    expect(
      CalibrationMatch.of(
        _b(FrameType.flat, filter: 'SII', exposure: 2, binning: 1),
        [ha],
        _astro,
      ),
      [
        CalibrationMismatch.filterUnused,
        CalibrationMismatch.binningMatchesNoLight,
      ],
    );
  });

  test('a light filter without flats is named only when the plan has '
      'flats', () {
    final flatHa = _b(FrameType.flat, filter: 'Ha', exposure: 2, binning: 2);
    expect(CalibrationMatch.lightFiltersWithoutFlats([ha, oiii]), isEmpty);
    expect(CalibrationMatch.lightFiltersWithoutFlats([ha, oiii, flatHa]), [
      'OIII',
    ]);
  });

  test('dark flats match a flat, not a light', () {
    final flat = _b(
      FrameType.flat,
      filter: 'Ha',
      exposure: 2,
      binning: 2,
      gain: CaptureGain.gain(100),
    );
    final darkFlat = _b(
      FrameType.darkFlat,
      exposure: 2,
      binning: 2,
      gain: CaptureGain.gain(100),
    );
    expect(CalibrationMatch.of(darkFlat, [ha, flat], _astro), isEmpty);
    expect(CalibrationMatch.of(darkFlat, [ha], _astro), [
      CalibrationMismatch.matchesNoFlat,
    ]);
    expect(CalibrationMatch.sourcesFor(FrameType.darkFlat, [ha, flat]), [flat]);
    expect(CalibrationMatch.sourcesFor(FrameType.dark, [ha, flat]), [ha]);
  });

  group('the one-tap fix', () {
    test('copies what the block must match, and keeps its own values', () {
      final dark = _b(
        FrameType.dark,
        exposure: 60,
        count: 25,
        policy: CalibrationPolicy.inWindow,
      );
      final m = CalibrationMatch.matched(dark, ha);
      expect(
        (m.exposureTimeSeconds, m.gain, m.binning, m.frameCount),
        (300.0, CaptureGain.gain(100), 2, 25),
      );
      expect(m.calibrationPolicy, CalibrationPolicy.inWindow);
      expect(m.filterName, isNull);
      expect(CalibrationMatch.of(m, [ha], _astro), isEmpty);

      final bias = CalibrationMatch.matched(
        _b(FrameType.bias, exposure: 0.001),
        ha,
      );
      expect(bias.exposureTimeSeconds, 0.001, reason: 'its own exposure');
      expect(bias.gain, CaptureGain.gain(100));

      final flat = CalibrationMatch.matched(
        _b(
          FrameType.flat,
          filter: 'SII',
          exposure: 2,
          gain: CaptureGain.gain(0),
        ),
        ha,
      );
      expect((flat.filterName, flat.binning), ('Ha', 2));
      expect(flat.exposureTimeSeconds, 2);
      expect(flat.gain, CaptureGain.gain(0), reason: 'a flat keeps its gain');
    });

    test('what each type takes from its source (S7.V1, TD-083)', () {
      final exposure = {
        for (final t in FrameType.values) t: CalibrationMatch.takesExposure(t),
      };
      final sensitivity = {
        for (final t in FrameType.values)
          t: CalibrationMatch.takesSensitivity(t),
      };
      expect(exposure, {
        FrameType.light: false,
        FrameType.dark: true,
        FrameType.flat: false,
        FrameType.bias: false,
        FrameType.darkFlat: true,
      });
      expect(sensitivity, {
        FrameType.light: false,
        FrameType.dark: true,
        FrameType.flat: false,
        FrameType.bias: true,
        FrameType.darkFlat: true,
      });
    });

    test('a flat matches a light filter that has no flat yet', () {
      final flatHa = _b(FrameType.flat, filter: 'Ha', exposure: 2, binning: 2);
      final stray = _b(FrameType.flat, filter: 'SII', exposure: 2, binning: 2);
      expect(
        CalibrationMatch.defaultSource(stray, [ha, oiii, flatHa, stray]),
        oiii,
      );
      expect(
        CalibrationMatch.defaultSource(_b(FrameType.dark), [ha, oiii]),
        ha,
      );
      expect(
        CalibrationMatch.defaultSource(_b(FrameType.dark), const []),
        isNull,
      );
    });
  });

  test('the dark-flat type is stored by name and parsed, any case', () {
    for (final text in ['darkFlat', 'DARKFLAT', 'darkflat']) {
      expect(CaptureBlock.tryParseFrameType(text), FrameType.darkFlat);
    }
  });

  test('dark flats are calibration on their policy\'s line, never '
      'integration (ADR-009)', () {
    final lights = _b(FrameType.light, exposure: 60, count: 10);
    final inWindow = _b(
      FrameType.darkFlat,
      exposure: 2,
      count: 20,
      policy: CalibrationPolicy.inWindow,
    );
    const overheads = CaptureOverheads(perFrameMs: 5000);
    final b = CaptureBudgetCalculator.calculate(
      blocks: [lights, inWindow],
      overheads: overheads,
    );
    // Computed by hand: 10 × 60 s = 600 000 ms integration; 20 × (2 + 5) s.
    expect(b.integrationMs, 600000);
    expect(b.inWindowCalibrationMs, 140000);
    expect(b.outsideWindowCalibrationMs, 0);
    final outside = CaptureBudgetCalculator.calculate(
      blocks: [lights, _b(FrameType.darkFlat, exposure: 2, count: 20)],
      overheads: overheads,
    );
    expect(outside.inWindowCalibrationMs, 0);
    expect(outside.outsideWindowCalibrationMs, 140000);
    final library = CaptureBudgetCalculator.calculate(
      blocks: [
        lights,
        _b(
          FrameType.darkFlat,
          exposure: 2,
          count: 20,
          policy: CalibrationPolicy.library,
        ),
      ],
      overheads: overheads,
    );
    expect(
      library.inWindowCalibrationMs + library.outsideWindowCalibrationMs,
      0,
    );
  });
}
