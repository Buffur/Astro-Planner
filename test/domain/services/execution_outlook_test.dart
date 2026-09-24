// CALC-36 (TASK 13.3): the tracker's countdowns and remaining window vs
// remaining plan, computed from the night's timeline, the target's curve
// and the Moon's rise/set passed in with "now". Also the snapshot
// accessors the tracker reads (night, target, windows, limits).

import 'package:astroplan/domain/models/altitude_curve.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/execution.dart';
import 'package:astroplan/domain/models/night_timeline.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/execution_machine.dart';
import 'package:astroplan/domain/services/execution_outlook.dart';
import 'package:astroplan/domain/services/moon_calculator.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:flutter_test/flutter_test.dart';

final _night = SessionNight(
  eveningDate: CalendarDate(2026, 12, 15),
  startUtc: DateTime.utc(2026, 12, 15, 11),
  endUtc: DateTime.utc(2026, 12, 16, 11),
  latitude: 46.05,
  longitude: 14.51,
  timeContextId: 'Europe/Ljubljana',
);

DateTime _h(int hour, [int minute = 0]) =>
    DateTime.utc(2026, 12, 15).add(Duration(hours: hour, minutes: minute));

CaptureBlock _block(
  int id,
  FrameType type,
  int frames, {
  CalibrationPolicy? policy,
}) => CaptureBlock(
  id: id,
  frameType: type,
  exposureTimeSeconds: 60,
  frameCount: frames,
  calibrationPolicy: policy,
);

final _blocks = [
  _block(1, FrameType.light, 100),
  _block(2, FrameType.dark, 20, policy: CalibrationPolicy.inWindow),
  _block(3, FrameType.flat, 30, policy: CalibrationPolicy.outsideWindow),
];

ExecutionState _state({int confirmedLights = 0}) {
  var s = ExecutionMachine.fold({1, 2, 3}, const []);
  s = ExecutionMachine.apply(
    s,
    ExecutionMachine.next(s, ExecutionEventKind.started, _h(18), blockId: 1),
  );
  if (confirmedLights > 0) {
    s = ExecutionMachine.apply(
      s,
      ExecutionMachine.next(
        s,
        ExecutionEventKind.framesConfirmed,
        _h(18, 30),
        blockId: 1,
        delta: confirmedLights,
      ),
    );
  }
  return s;
}

/// A target curve rising to 60° at 22:00 and setting below 20° at 03:00.
AltitudeCurve _curve() => AltitudeCurve(
  night: _night,
  samples: [
    for (var m = 0; m <= 24 * 60; m += 5)
      AltitudeSample(
        instantUtc: _night.startUtc.add(Duration(minutes: m)),
        sunAltitudeDeg: -30,
        // 11:00 + 11 h = 22:00 peak; 5° per hour either side.
        targetAltitudeDeg: 60 - 5 * ((m / 60) - 11).abs(),
      ),
  ],
);

ExecutionOutlook _outlook(DateTime now, {ExecutionState? state}) =>
    ExecutionOutlook.compute(
      nowUtc: now,
      blocks: _blocks,
      state: state ?? _state(),
      perFrameOverheadSeconds: 5,
      windows: [(_h(18), _h(20)), (_h(21), _h(27))],
      timeline: NightTimeline(
        night: _night,
        sunriseSunset: const SunNeverBelow(-0.833),
        civilTwilight: const SunNeverBelow(-6),
        nauticalTwilight: const SunNeverBelow(-12),
        astronomicalTwilight: SunCrossing(
          -18,
          duskUtc: _h(17, 40),
          dawnUtc: _h(29, 10), // 05:10 the next morning
          belowAtStart: false,
          belowAtEnd: false,
        ),
      ),
      curve: _curve(),
      minAltitudeDeg: 20,
      moon: MoonRiseSet(
        events: [
          MoonEvent(MoonEventKind.set, _h(19)),
          MoonEvent(MoonEventKind.rise, _h(25, 30)),
        ],
        aboveAtStart: true,
      ),
    );

void main() {
  test('astronomical dawn ahead, then none once passed', () {
    expect(_outlook(_h(19)).astronomicalDawnUtc, _h(29, 10));
    expect(_outlook(_h(29, 30)).astronomicalDawnUtc, isNull);
  });

  test('the target: the first sample below the limit after now', () {
    // 60 - 5·|t - 11 h| < 20 → more than 8 h from 22:00 → after 06:00.
    final o = _outlook(_h(23));
    expect(o.targetBelowLimitNow, isFalse);
    expect(o.targetBelowLimitUtc, _h(30, 5));
    final early = _outlook(_h(12));
    expect(early.targetBelowLimitNow, isTrue);
    expect(early.targetBelowLimitUtc, isNull);
  });

  test('the Moon: up or down now, and the next rise', () {
    final before = _outlook(_h(18));
    expect(before.moonUp, isTrue);
    expect(before.moonriseUtc, _h(25, 30));
    final after = _outlook(_h(26));
    expect(after.moonUp, isTrue);
    expect(after.moonriseUtc, isNull);
    expect(_outlook(_h(20)).moonUp, isFalse);
  });

  test('remaining window: only the time ahead of now', () {
    expect(_outlook(_h(17)).remainingWindow, const Duration(hours: 8));
    expect(_outlook(_h(19)).remainingWindow, const Duration(hours: 7));
    expect(_outlook(_h(22)).remainingWindow, const Duration(hours: 5));
    expect(_outlook(_h(28)).remainingWindow, Duration.zero);
  });

  test('remaining plan: lights and in-window calibration left × (exposure '
      '+ overhead); outside-window calibration excluded', () {
    // (100 + 20) × 65 s = 7800 s.
    expect(_outlook(_h(19)).remainingPlan, const Duration(seconds: 7800));
    // 40 lights confirmed: (60 + 20) × 65 s = 5200 s.
    expect(
      _outlook(_h(19), state: _state(confirmedLights: 40)).remainingPlan,
      const Duration(seconds: 5200),
    );
  });

  test('without a curve, timeline or Moon nothing is guessed', () {
    final o = ExecutionOutlook.compute(
      nowUtc: _h(19),
      blocks: _blocks,
      state: _state(),
      perFrameOverheadSeconds: 5,
      windows: const [],
    );
    expect(o.astronomicalDawnUtc, isNull);
    expect(o.targetBelowLimitUtc, isNull);
    expect(o.targetBelowLimitNow, isFalse);
    expect(o.moonriseUtc, isNull);
    expect(o.moonUp, isNull);
    expect(o.remainingWindow, Duration.zero);
  });

  test('the snapshot gives back the night, target, limits and windows', () {
    final prefs = PlanningPreferences(minAltitudeDeg: 25);
    final snap = SessionSnapshotBuilder.build(
      takenAtUtc: _h(18),
      night: _night,
      timeZoneId: 'Europe/Ljubljana',
      preferences: prefs,
      budget: CaptureBudgetCalculator.calculate(
        blocks: _blocks,
        overheads: CaptureOverheads.fromPreferences(prefs),
        targetTransitsInWindow: false,
      ),
      blocks: _blocks,
    );
    expect(snap.night!.startUtc, _night.startUtc);
    expect(snap.night!.endUtc, _night.endUtc);
    expect(snap.night!.latitude, 46.05);
    expect(snap.timeZoneId, 'Europe/Ljubljana');
    expect(snap.minAltitudeDeg, 25);
    expect(snap.target, isNull, reason: 'no target chosen');
    expect(snap.windows, isEmpty, reason: 'no opportunity recorded');
  });
}
