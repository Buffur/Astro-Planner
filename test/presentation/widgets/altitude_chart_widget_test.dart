// Widget test for AltitudeChartWidget (roadmap TASK 2.3, updated TASK 2.4
// for the SessionNight-based constructor).
//
// The widget went from sampling astronomy inside its CustomPainter to
// consuming a domain-computed AltitudeCurve (TD-023, DEV-A3). This test
// checks it still renders for a normal night and for a polar-night site,
// without throwing, and that "now" outside the window doesn't draw a dot.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/site_time_context.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:astroplan/presentation/widgets/altitude_chart_widget.dart';

const _pleiades = AstroTarget(
  id: 1,
  catalogId: 'M45',
  type: 'Open Cluster',
  rightAscension: 56.87,
  declination: 24.11,
);

Future<void> pumpChart(
  WidgetTester tester, {
  required AstroTarget target,
  required double latitude,
  required double longitude,
  required CalendarDate eveningDate,
  double minAltitude = 20.0,
}) {
  final night = SessionNightResolver.forEveningDate(
    eveningDate,
    latitude: latitude,
    longitude: longitude,
    timeContext: MeanSolarTimeContext(longitude),
  );
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AltitudeChartWidget(
          target: target,
          night: night,
          minAltitude: minAltitude,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('renders for a normal London winter night', (tester) async {
    await pumpChart(
      tester,
      target: _pleiades,
      latitude: 51.5072,
      longitude: -0.1276,
      eveningDate: CalendarDate(2025, 12, 21),
    );
    await tester.pump();

    expect(find.text('Visibility & Altitude'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('renders for a polar-night site without throwing', (
    tester,
  ) async {
    await pumpChart(
      tester,
      target: const AstroTarget(
        id: 2,
        catalogId: 'Test',
        type: 'Test',
        rightAscension: 0.0,
        declination: 89.0,
      ),
      latitude: 69.6492,
      longitude: 18.9553,
      eveningDate: CalendarDate(2026, 12, 20),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('renders for a session date far from today (no "now" dot)', (
    tester,
  ) async {
    // The night is nowhere near the real clock's "now", so the painter's
    // now-dot branch is skipped — this exercises that path without one.
    await pumpChart(
      tester,
      target: _pleiades,
      latitude: 51.5072,
      longitude: -0.1276,
      eveningDate: CalendarDate(2020, 1, 1),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
