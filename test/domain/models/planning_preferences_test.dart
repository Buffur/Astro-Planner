import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlanningPreferences defaults (documented assumptions)', () {
    final p = PlanningPreferences();

    test('match the values the app used before TASK 5.2', () {
      expect(p.minAltitudeDeg, 20.0);
      expect(p.dewMarginC, 2.0);
      expect(p.feasibilityMarginPercent, 15.0); // the old fixed 85 %
      expect(p.feasibilityMarginFraction, closeTo(0.15, 1e-12));
      expect(p.perFrameOverheadSeconds, 5.0); // the old hard-coded 5 s
      expect(p.darknessLimit, DarknessLimit.astronomical);
      expect(p.darknessLimit.degrees, -18.0);
    });

    test('optional overheads are off ("not included"), ADR-009 §4', () {
      expect(p.ditherEveryNFrames, isNull);
      expect(p.refocusEveryMinutes, isNull);
      expect(p.filterChangeSeconds, isNull);
      expect(p.meridianFlipSeconds, isNull);
      expect(p.setupMinutes, isNull);
    });
  });

  group('clamping', () {
    test('every value is clamped to its range', () {
      final p = PlanningPreferences(
        minAltitudeDeg: 90,
        feasibilityMarginPercent: -5,
        dewMarginC: 50,
        perFrameOverheadSeconds: 1000,
        ditherEveryNFrames: 0,
        refocusEveryMinutes: 1,
        filterChangeSeconds: -1,
        meridianFlipSeconds: 1e9,
        setupMinutes: 1e9,
      );
      expect(p.minAltitudeDeg, 60.0);
      expect(p.feasibilityMarginPercent, 0.0);
      expect(p.dewMarginC, 10.0);
      expect(p.perFrameOverheadSeconds, 120.0);
      expect(p.ditherEveryNFrames, 1);
      expect(p.refocusEveryMinutes, 10.0);
      expect(p.filterChangeSeconds, 0.0);
      expect(p.meridianFlipSeconds, 1800.0);
      expect(p.setupMinutes, 240.0);
    });

    test('non-finite input falls back to the range minimum', () {
      expect(PlanningPreferences(minAltitudeDeg: double.nan).minAltitudeDeg, 5);
    });

    test('boundaries are accepted as-is', () {
      expect(PlanningPreferences(minAltitudeDeg: 5).minAltitudeDeg, 5);
      expect(PlanningPreferences(minAltitudeDeg: 60).minAltitudeDeg, 60);
    });
  });

  test('DarknessLimit.fromDegrees maps unknown values to astronomical', () {
    expect(DarknessLimit.fromDegrees(-12), DarknessLimit.nautical);
    expect(DarknessLimit.fromDegrees(-15), DarknessLimit.deepNautical);
    expect(DarknessLimit.fromDegrees(null), DarknessLimit.astronomical);
    expect(DarknessLimit.fromDegrees(-7), DarknessLimit.astronomical);
  });

  test('copyWith keeps optional overheads; withOptionalOverheads toggles', () {
    final on = PlanningPreferences().withOptionalOverheads(
      ditherEveryNFrames: (3,),
      setupMinutes: (30.0,),
    );
    expect(on.ditherEveryNFrames, 3);
    expect(on.copyWith(minAltitudeDeg: 30).ditherEveryNFrames, 3);
    final off = on.withOptionalOverheads(ditherEveryNFrames: (null,));
    expect(off.ditherEveryNFrames, isNull);
    expect(off.setupMinutes, 30.0);
    expect(off, isNot(on));
    expect(PlanningPreferences(), PlanningPreferences());
  });
}
