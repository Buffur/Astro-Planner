// TASK 10.3: the "Tonight for this target" list renders the same
// ImagingOpportunity as the chart — windows with annotations, every
// excluded period with its reasons, and why a night has no window.

import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/imaging_opportunity.dart';
import 'package:astroplan/domain/models/night_weather.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/services/imaging_opportunity_calculator.dart';
import 'package:astroplan/presentation/shared/opportunity_text.dart';
import 'package:astroplan/presentation/widgets/tonight_opportunity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Calc = ImagingOpportunityCalculator;

final _night = SessionNight(
  eveningDate: CalendarDate(2026, 9, 24),
  startUtc: DateTime.utc(2026, 9, 24, 12),
  endUtc: DateTime.utc(2026, 9, 25, 12),
  latitude: 46.05,
  longitude: 14.51,
  timeContextId: 'test',
);

DateTime _t(int h, [int m = 0]) =>
    h >= 12 ? DateTime.utc(2026, 9, 24, h, m) : DateTime.utc(2026, 9, 25, h, m);

bool _in(DateTime t, DateTime a, DateTime b) => !t.isBefore(a) && t.isBefore(b);

List<double> _series(double Function(DateTime t) f) => [
  for (var i = 0; i < Calc.gridCount; i++) f(Calc.instantAt(_night, i)),
];

// ADR-013 V3: Sun dark [20, 04), target high [22, 06), Moon up [21, 02)
// 85 % lit, Moon gate at 50 %.
ImagingOpportunity _v3({OpportunityWeather? weather}) => Calc.fromSamples(
  night: _night,
  sunAltitudesDeg: _series((t) => _in(t, _t(20), _t(4)) ? -20 : 0),
  targetAltitudesDeg: _series((t) => _in(t, _t(22), _t(6)) ? 40 : 10),
  darknessLimitDeg: -18,
  minAltitudeDeg: 30,
  gates: const OptionalGates(moonMinIlluminationPct: 50),
  moon: OpportunityMoon(
    altitudesDeg: _series((t) => _in(t, _t(21), _t(2)) ? 20 : -10),
    separationsDeg: _series((_) => 40),
    illumination: 0.85,
  ),
  weather: weather,
);

Future<void> _pump(WidgetTester tester, ImagingOpportunity o) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(alwaysUse24HourFormat: true),
        child: Scaffold(
          body: SingleChildScrollView(
            // UTC: the test zone must not depend on the machine.
            child: OpportunityList(opportunity: o, zoneId: 'UTC'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('OpportunityText', () {
    test('durations', () {
      expect(OpportunityText.duration(const Duration(minutes: 45)), '45 min');
      expect(OpportunityText.duration(const Duration(hours: 2)), '2 h');
      expect(
        OpportunityText.duration(const Duration(hours: 5, minutes: 35)),
        '5 h 35 min',
      );
    });

    test('reasons list every failing gate, in a fixed order', () {
      final o = _v3();
      final segment = o.excluded.firstWhere(
        (s) => _in(_t(21, 30), s.startUtc, s.endUtc),
      );
      expect(
        OpportunityText.reasons(segment, o),
        'target below 30°; Moon up and at least 50 % lit (your Moon gate)',
      );
      final day = o.excluded.first;
      expect(
        OpportunityText.reasons(day, o),
        'Sun above −18°; target below 30°',
      );
    });

    test('annotations: Moon facts and the forecast, no verdict', () {
      final o = _v3(
        weather: OpportunityWeather(
          snapshot: WeatherSnapshot(
            provider: 'open-meteo',
            model: 'best_match',
            fetchedAtUtc: _t(12),
            latitude: 46.05,
            longitude: 14.51,
            hours: [
              WeatherHour(timeUtc: _t(2), cloudCoverPct: 10),
              WeatherHour(timeUtc: _t(3), cloudCoverPct: 30),
            ],
          ),
          age: WeatherAge.stale,
          dewMarginC: 2,
        ),
      );
      final w = o.windows.single;
      expect(OpportunityText.moon(w), 'Moon down (85 % lit at midnight)');
      expect(
        OpportunityText.weather(w),
        'cloud 10–30 %, 1 h without forecast, stale forecast',
      );
    });

    test('every no-window reason has its own sentence', () {
      final o = _v3();
      final texts = {
        for (final r in NoWindowReason.values) OpportunityText.noWindow(r, o),
      };
      expect(texts, hasLength(NoWindowReason.values.length));
      expect(
        OpportunityText.noWindow(NoWindowReason.noDarkness, o),
        'No imaging window: the Sun never gets below −18° tonight.',
      );
    });
  });

  // Acceptance: every excluded period shows its reason.
  testWidgets('every excluded period is listed with its reasons', (
    tester,
  ) async {
    final o = _v3();
    await _pump(tester, o);

    expect(
      find.text('02:00 (+1) – 04:00 (+1) · 2 h · max 40° at 02:00 (+1)'),
      findsOneWidget,
    );
    for (var i = 0; i < o.excluded.length; i++) {
      final text = tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(Key('opportunity.excluded.$i')),
              matching: find.byType(Text),
            ),
          )
          .data!;
      expect(text, endsWith(OpportunityText.reasons(o.excluded[i], o)));
      expect(o.excluded[i].reasons, isNotEmpty);
    }
    expect(
      find.text(
        '22:00 – 02:00 (+1): Moon up and at least 50 % lit '
        '(your Moon gate)',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('opportunity.noWindow')), findsNothing);
  });

  testWidgets('a night without a window says why', (tester) async {
    final o = Calc.fromSamples(
      night: _night,
      sunAltitudesDeg: _series((_) => -5),
      targetAltitudesDeg: _series((_) => 40),
      darknessLimitDeg: -18,
      minAltitudeDeg: 30,
    );
    await _pump(tester, o);
    expect(
      find.text('No imaging window: the Sun never gets below −18° tonight.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('opportunity.excluded.0')), findsOneWidget);
  });
}
