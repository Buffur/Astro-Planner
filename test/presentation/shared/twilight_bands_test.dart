// S9.6: the Night & Moon bar's bands come only from the domain's
// crossings: which standard twilights enclose which stretch of the night,
// from sunset to sunrise. A night without darkness has no dark band; a
// window the Sun never leaves has no bar.

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/night_timeline.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/services/visibility_calculator.dart';
import 'package:astroplan/presentation/shared/twilight_bands.dart';
import 'package:flutter_test/flutter_test.dart';

final _night = SessionNight(
  eveningDate: CalendarDate(2026, 11, 10),
  startUtc: DateTime.utc(2026, 11, 10, 11),
  endUtc: DateTime.utc(2026, 11, 11, 11),
  latitude: 46.05,
  longitude: 14.51,
  timeContextId: 'Europe/Ljubljana',
);

DateTime _t(int day, int h, [int m = 0]) => DateTime.utc(2026, 11, day, h, m);

NightTimeline _timeline({
  required SunThresholdResult civil,
  required SunThresholdResult nautical,
  required SunThresholdResult astronomical,
  SunThresholdResult? sun,
}) => NightTimeline(
  night: _night,
  sunriseSunset:
      sun ?? SunCrossing(-0.833, duskUtc: _t(10, 16), dawnUtc: _t(11, 6)),
  civilTwilight: civil,
  nauticalTwilight: nautical,
  astronomicalTwilight: astronomical,
);

void main() {
  test(
    'a mid-latitude night: civil, nautical, astronomical, dark and back',
    () {
      final bands = TwilightBands.of(
        _timeline(
          civil: SunCrossing(
            -6,
            duskUtc: _t(10, 16, 30),
            dawnUtc: _t(11, 5, 30),
          ),
          nautical: SunCrossing(-12, duskUtc: _t(10, 17), dawnUtc: _t(11, 5)),
          astronomical: SunCrossing(
            -18,
            duskUtc: _t(10, 17, 30),
            dawnUtc: _t(11, 4, 30),
          ),
        ),
      )!;
      expect(bands.map((b) => b.depth), [1, 2, 3, 4, 3, 2, 1]);
      expect(bands.first.startUtc, _t(10, 16));
      expect(bands.last.endUtc, _t(11, 6));
      expect(bands[3], TwilightBand(_t(10, 17, 30), _t(11, 4, 30), 4));
      for (var i = 0; i + 1 < bands.length; i++) {
        expect(bands[i].endUtc, bands[i + 1].startUtc, reason: 'contiguous');
      }
    },
  );

  test('no astronomical darkness (a summer night far north): no dark band', () {
    final bands = TwilightBands.of(
      _timeline(
        civil: SunCrossing(-6, duskUtc: _t(10, 17), dawnUtc: _t(11, 5)),
        nautical: SunCrossing(-12, duskUtc: _t(10, 18), dawnUtc: _t(11, 4)),
        astronomical: const SunNeverBelow(-18),
      ),
    )!;
    expect(bands.map((b) => b.depth), [1, 2, 3, 2, 1]);
  });

  test('the Sun never sets in the window: no bar', () {
    expect(
      TwilightBands.of(
        _timeline(
          sun: const SunNeverBelow(-0.833),
          civil: const SunNeverBelow(-6),
          nautical: const SunNeverBelow(-12),
          astronomical: const SunNeverBelow(-18),
        ),
      ),
      isNull,
    );
  });

  test('a crossing outside the window is clipped to it', () {
    final bands = TwilightBands.of(
      _timeline(
        sun: const SunAlwaysBelow(-0.833),
        civil: const SunAlwaysBelow(-6),
        nautical: SunCrossing(-12, dawnUtc: _t(11, 3), belowAtStart: true),
        astronomical: const SunNeverBelow(-18),
      ),
    )!;
    expect(bands.first.startUtc, _night.startUtc);
    expect(bands.last.endUtc, _night.endUtc);
    expect(bands.map((b) => b.depth), [3, 2]);
  });

  test('a real night from the calculator: Ljubljana, 10 Nov 2026', () {
    final timeline = VisibilityCalculator.calculateNightTimelineForNight(
      _night,
    );
    final bands = TwilightBands.of(timeline)!;
    expect(bands.map((b) => b.depth), [1, 2, 3, 4, 3, 2, 1]);
  });
}
