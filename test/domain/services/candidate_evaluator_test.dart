// TASK 10.4: tonight's candidates — the batch equals the single-target view
// exactly, 250 targets evaluate well under a second, and sorting/filtering
// are plain column sorts (no score).

import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/imaging_opportunity.dart';
import 'package:astroplan/domain/models/night_weather.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/services/candidate_evaluator.dart';
import 'package:astroplan/domain/services/imaging_opportunity_calculator.dart';
import 'package:astroplan/domain/services/moon_calculator.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

// A night with a bright, high Moon (full Moon 2026-09-26).
final _night = SessionNightResolver.forEveningDate(
  CalendarDate(2026, 9, 24),
  latitude: 46.05,
  longitude: 14.51,
  timeContext: MeanSolarTimeContext(14.51),
);

AstroTarget _t(
  int id,
  String name,
  double ra,
  double dec, {
  String? source,
  double? size,
}) => AstroTarget(
  id: id,
  catalogId: name,
  type: id.isEven ? 'Galaxy' : 'Nebula',
  rightAscension: ra,
  declination: dec,
  source: source,
  angularSizeArcmin: size,
);

final _targets = [
  _t(1, 'M31', 10.68, 41.27, source: 'catalog:openngc', size: 190),
  _t(2, 'M42', 83.82, -5.39, source: 'catalog:openngc', size: 85),
  _t(3, 'M27', 299.90, 22.72, source: 'catalog:openngc', size: 8),
  _t(4, 'NGC7000', 314.75, 44.37, source: 'catalog:openngc', size: 120),
  _t(5, 'Mine', 180.0, 60.0, source: 'user'),
  _t(6, 'South', 0.0, -70.0, source: 'user'),
];

final _rig = EquipmentProfile(
  id: 1,
  name: 'Rig',
  focalRatio: 5,
  focalLengthMm: 400,
  sensorWidthMm: 23.5,
  sensorHeightMm: 15.6,
  resolutionWidthPx: 6000,
  resolutionHeightPx: 4000,
  pixelPitchUm: 3.76,
);

void main() {
  // Acceptance (1): results equal the single-target view.
  test(
    'each row equals the single-target view, gates and weather included',
    () {
      for (final gates in const [
        OptionalGates.none,
        OptionalGates(moonMinIlluminationPct: 60, cloudMaxPct: 50),
      ]) {
        final weather = OpportunityWeather(
          snapshot: WeatherSnapshot(
            provider: 'open-meteo',
            model: 'best_match',
            fetchedAtUtc: _night.startUtc,
            latitude: 46.05,
            longitude: 14.51,
            hours: [
              for (var h = 0; h < 24; h++)
                WeatherHour(
                  timeUtc: DateTime.utc(
                    2026,
                    9,
                    24,
                    12,
                  ).add(Duration(hours: h)),
                  cloudCoverPct: h.isEven ? 20 : 80,
                ),
            ],
          ),
          age: WeatherAge.current,
          dewMarginC: 2,
        );

        final rows = CandidateEvaluator.evaluate(
          night: _night,
          targets: _targets,
          darknessLimitDeg: -18,
          minAltitudeDeg: 20,
          gates: gates,
          weather: weather,
          equipment: _rig,
        );

        for (final (i, target) in _targets.indexed) {
          final single = CandidateEvaluator.candidateOf(
            target,
            ImagingOpportunityCalculator.calculate(
              night: _night,
              target: target,
              darknessLimitDeg: -18,
              minAltitudeDeg: 20,
              gates: gates,
              moon: MoonCalculator.conditionsForNight(_night, target: target),
              weather: weather,
            ),
            equipment: _rig,
          );
          final row = rows[i];
          expect(row.target, same(target));
          expect(row.usableTime, single.usableTime, reason: target.catalogId);
          expect(row.firstWindowStartUtc, single.firstWindowStartUtc);
          expect(row.lastWindowEndUtc, single.lastWindowEndUtc);
          expect(row.maxAltitudeDeg, single.maxAltitudeDeg);
          expect(row.minMoonSeparationDeg, single.minMoonSeparationDeg);
          expect(row.frameFillFraction, single.frameFillFraction);
          expect(row.noWindowReason, single.noWindowReason);
        }
        if (gates == OptionalGates.none) {
          expect(rows.where((r) => r.hasWindow), isNotEmpty);
          expect(
            rows.where((r) => r.minMoonSeparationDeg != null),
            isNotEmpty,
            reason: 'the Moon is up in some windows',
          );
        }
        expect(
          rows.firstWhere((r) => r.target.catalogId == 'South').noWindowReason,
          NoWindowReason.targetNeverHighEnough,
        );
      }
    },
  );

  // Acceptance (2): 250 targets under 1 s. Measured on the test machine;
  // the mid-range-device figure is not verified here (no device run).
  test('250 targets evaluate in under a second', () {
    final many = [
      for (var i = 0; i < 250; i++)
        _t(i, 'T$i', (i * 1.44) % 360, -60 + i * 0.5),
    ];
    // Warm up the JIT so the timing reflects the code, not compilation.
    CandidateEvaluator.evaluate(
      night: _night,
      targets: many.take(10).toList(),
      darknessLimitDeg: -18,
      minAltitudeDeg: 20,
    );
    final sw = Stopwatch()..start();
    final rows = CandidateEvaluator.evaluate(
      night: _night,
      targets: many,
      darknessLimitDeg: -18,
      minAltitudeDeg: 20,
    );
    sw.stop();
    expect(rows, hasLength(250));
    expect(sw.elapsed, lessThan(const Duration(seconds: 1)));
  });

  group('sort and filter', () {
    TonightCandidate row(
      String name, {
      int minutes = 0,
      int? startHour,
      double? alt,
      double? sep,
      double? fill,
      String type = 'Galaxy',
      String? source,
    }) => TonightCandidate(
      target: AstroTarget(
        id: name.hashCode,
        catalogId: name,
        type: type,
        rightAscension: 0,
        declination: 0,
        source: source,
      ),
      usableTime: Duration(minutes: minutes),
      firstWindowStartUtc: startHour == null
          ? null
          : DateTime.utc(2026, 9, 24, startHour),
      lastWindowEndUtc: startHour == null ? null : DateTime.utc(2026, 9, 25, 3),
      maxAltitudeDeg: alt,
      minMoonSeparationDeg: sep,
      frameFillFraction: fill,
      noWindowReason: minutes == 0
          ? NoWindowReason.targetNeverHighEnough
          : null,
    );

    final rows = [
      row(
        'b',
        minutes: 120,
        startHour: 22,
        alt: 50,
        sep: 30,
        fill: 0.2,
        source: 'catalog:openngc',
      ),
      row(
        'a',
        minutes: 120,
        startHour: 20,
        alt: 70,
        sep: null,
        fill: null,
        source: 'catalog:openngc',
      ),
      row(
        'c',
        minutes: 300,
        startHour: 21,
        alt: 40,
        sep: 90,
        fill: 0.9,
        type: 'Nebula',
        source: 'user',
      ),
      row('d'),
    ];

    List<String> names(List<TonightCandidate> r) => [
      for (final x in r) x.target.catalogId,
    ];

    test('each column sorts; unknown last; ties by name', () {
      expect(names(CandidateList.sort(rows, CandidateSort.usableTime)), [
        'c',
        'a',
        'b',
        'd',
      ]);
      expect(names(CandidateList.sort(rows, CandidateSort.windowStart)), [
        'a',
        'c',
        'b',
        'd',
      ]);
      expect(names(CandidateList.sort(rows, CandidateSort.maxAltitude)), [
        'a',
        'b',
        'c',
        'd',
      ]);
      expect(names(CandidateList.sort(rows, CandidateSort.moonSeparation)), [
        'c',
        'b',
        'a',
        'd',
      ]);
      expect(names(CandidateList.sort(rows, CandidateSort.frameFill)), [
        'c',
        'b',
        'a',
        'd',
      ]);
      expect(names(CandidateList.sort(rows, CandidateSort.name)), [
        'a',
        'b',
        'c',
        'd',
      ]);
    });

    test('filters: with a window, type, own targets', () {
      expect(names(CandidateList.filter(rows)), ['b', 'a', 'c']);
      expect(
        names(CandidateList.filter(rows, withWindowOnly: false)),
        hasLength(4),
      );
      expect(names(CandidateList.filter(rows, type: 'Nebula')), ['c']);
      expect(names(CandidateList.filter(rows, ownOnly: true)), ['c']);
    });
  });
}
