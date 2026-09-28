// S6.12 (P6.11; UX-08): the night and opportunity timeline. The mapping
// draws exactly the opportunity's bands and windows and the fit's end;
// ticks fall on whole local hours in the site's zone and follow the
// device's 12- or 24-hour setting; labels sit outside the plot and never
// overlap; bands have no seams and their edges are drawn (field mode); the
// text alternative names the windows, the usable time and the capture end.

import 'package:astroplan/core/theme/app_palette.dart';
import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/imaging_opportunity.dart';
import 'package:astroplan/domain/models/iana_time_context.dart';
import 'package:astroplan/domain/services/imaging_opportunity_calculator.dart';
import 'package:astroplan/domain/services/session_night_resolver.dart';
import 'package:astroplan/presentation/shared/night_time_formatter.dart';
import 'package:astroplan/presentation/widgets/altitude_chart_widget.dart';
import 'package:astroplan/presentation/widgets/timeline_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _pleiades = AstroTarget(
  id: 1,
  catalogId: 'M45',
  type: 'Open Cluster',
  rightAscension: 56.87,
  declination: 24.11,
);

const _zone = 'Europe/Ljubljana';

ImagingOpportunity _night(CalendarDate date, {String zone = _zone}) {
  final ctx = IanaTimeContext.tryCreate(zone)!;
  final night = SessionNightResolver.forEveningDate(
    date,
    latitude: 46.05,
    longitude: 14.51,
    timeContext: ctx,
  );
  return ImagingOpportunityCalculator.calculate(
    night: night,
    target: _pleiades,
    darknessLimitDeg: -18,
    minAltitudeDeg: 30,
  );
}

SkyBand _kind(double sun) =>
    sun > 0 ? SkyBand.day : (sun > -18 ? SkyBand.twilight : SkyBand.dark);

void main() {
  final o = _night(CalendarDate(2026, 11, 10));

  group('the mapping', () {
    test('bands: contiguous, merged (no seams), each sample in its own '
        'kind, over the whole grid', () {
      final d = TimelineData.of(o);
      final s = o.samples;
      expect(d.bands.first.startUtc, s.first.instantUtc);
      expect(d.bands.last.endUtc, s.last.instantUtc);
      for (var i = 1; i < d.bands.length; i++) {
        expect(d.bands[i].startUtc, d.bands[i - 1].endUtc);
        expect(d.bands[i].kind, isNot(d.bands[i - 1].kind));
      }
      // Far fewer rectangles than samples (UX-08's 288 seams).
      expect(d.bands.length, lessThan(8));
      for (var i = 0; i + 1 < s.length; i++) {
        final t = s[i].instantUtc;
        final band = d.bands.lastWhere((b) => !b.startUtc.isAfter(t));
        expect(band.kind, _kind(s[i].sunAltitudeDeg), reason: '$t');
      }
      expect(d.bandEdges, [for (final b in d.bands.skip(1)) b.startUtc]);
    });

    test('windows are exactly the opportunity\'s; no time across a gap', () {
      final d = TimelineData.of(o);
      expect(d.windows, [
        for (final w in o.windows) TimelineSpan(w.startUtc, w.endUtc),
      ]);
      expect(d.windows, isNotEmpty);
    });

    test('the capture end is the fit\'s, and only inside the night; so is '
        'now', () {
      final inside = o.windows.first.startUtc.add(const Duration(hours: 1));
      final d = TimelineData.of(o, captureEndUtc: inside, nowUtc: inside);
      expect(d.captureEndUtc, inside);
      expect(d.nowUtc, inside);
      final outside = o.night.endUtc.add(const Duration(days: 2));
      final e = TimelineData.of(o, captureEndUtc: outside, nowUtc: outside);
      expect(e.captureEndUtc, isNull);
      expect(e.nowUtc, isNull);
    });

    test('ticks fall on whole hours of the site\'s wall clock', () {
      final ticks = TimelineData.hourTicks(
        o.night.startUtc,
        o.night.endUtc,
        zoneId: _zone,
      );
      expect(ticks.length, inInclusiveRange(23, 25));
      for (final t in ticks) {
        final local = NightTimeFormatter.wallClock(t.instantUtc, zoneId: _zone);
        expect(local.minute, 0);
        expect(local.hour, t.localHour);
      }
    });

    test('a half-hour zone still gets whole local hours', () {
      final ticks = TimelineData.hourTicks(
        DateTime.utc(2026, 11, 10, 6),
        DateTime.utc(2026, 11, 10, 12),
        zoneId: 'Asia/Kolkata',
      );
      expect(ticks.first.instantUtc, DateTime.utc(2026, 11, 10, 6, 30));
      expect(ticks.first.localHour, 12);
      expect(ticks, hasLength(6));
    });

    test('at the autumn DST change the repeated hour appears twice', () {
      // Ljubljana, 25 Oct 2026: 03:00 CEST becomes 02:00 CET.
      final ticks = TimelineData.hourTicks(
        DateTime.utc(2026, 10, 24, 22),
        DateTime.utc(2026, 10, 25, 3),
        zoneId: _zone,
      );
      expect(ticks.map((t) => t.localHour), [0, 1, 2, 2, 3, 4]);
    });
  });

  group('the widget', () {
    Future<TimelinePainter> pump(
      WidgetTester tester, {
      bool use24h = false,
      double textScale = 1,
      ThemeData? theme,
      DateTime? captureEnd,
      TimelineDensity density = TimelineDensity.full,
    }) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme ?? AppTheme.light,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(412, 915),
              alwaysUse24HourFormat: use24h,
              textScaler: TextScaler.linear(textScale),
            ),
            child: Scaffold(
              body: SingleChildScrollView(
                child: AltitudeChartWidget(
                  opportunity: o,
                  zoneId: _zone,
                  captureEndUtc: captureEnd,
                  density: density,
                ),
              ),
            ),
          ),
        ),
      );
      return tester
              .widget<CustomPaint>(
                find.descendant(
                  of: find.byType(AltitudeChartWidget),
                  matching: find.byType(CustomPaint),
                ),
              )
              .painter!
          as TimelinePainter;
    }

    Size sizeOf(WidgetTester tester) => tester.getSize(
      find.descendant(
        of: find.byType(AltitudeChartWidget),
        matching: find.byType(CustomPaint),
      ),
    );

    testWidgets('times follow the device\'s 12-hour setting', (tester) async {
      final p = await pump(tester);
      expect(p.ticks.every((t) => t.$2.contains('M')), isTrue); // AM/PM
    });

    testWidgets('and its 24-hour setting', (tester) async {
      final p = await pump(tester, use24h: true);
      expect(
        p.ticks.every((t) => RegExp(r'^\d{2}:00$').hasMatch(t.$2)),
        isTrue,
      );
    });

    for (final scale in [1.0, 2.0]) {
      testWidgets('labels sit outside the plot and never overlap '
          '(${(scale * 100).round()} % text)', (tester) async {
        final p = await pump(tester, textScale: scale);
        final g = p.geometry(sizeOf(tester));
        expect(g.timeLabels, isNotEmpty);
        expect(g.altitudeLabels, hasLength(3));
        for (final (_, r) in [...g.altitudeLabels, ...g.timeLabels]) {
          expect(r.overlaps(g.plot), isFalse, reason: '$r vs ${g.plot}');
        }
        for (var i = 1; i < g.timeLabels.length; i++) {
          expect(
            g.timeLabels[i].$2.left,
            greaterThan(g.timeLabels[i - 1].$2.right),
          );
        }
        for (final (i, _) in g.timeLabels) {
          expect(p.ticks[i].$1.localHour % g.hourStep, 0);
        }
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('the capture end is drawn from the fit, and named in the '
        'text alternative with the windows and the usable time', (
      tester,
    ) async {
      final end = o.windows.first.startUtc.add(const Duration(hours: 2));
      final handle = tester.ensureSemantics();
      final p = await pump(tester, captureEnd: end);
      expect(p.data.captureEndUtc, end);
      expect(find.text('Capture ends'), findsOneWidget);
      final ctx = tester.element(find.byType(AltitudeChartWidget));
      String at(DateTime t) => NightTimeFormatter.instant(
        ctx,
        t,
        windowStartUtc: o.night.startUtc,
        zoneId: _zone,
      );
      final label = AltitudeChartWidget.describe(o, p.data, at);
      for (final w in o.windows) {
        expect(label, contains('${at(w.startUtc)} – ${at(w.endUtc)}'));
      }
      expect(label, contains('usable time'));
      expect(label, contains('capture ends ${at(end)}'));
      expect(find.bySemanticsLabel(label), findsOneWidget);
      handle.dispose();
    });

    testWidgets('field mode: the band edges are drawn, in a red-only token', (
      tester,
    ) async {
      final p = await pump(tester, theme: AppTheme.fieldTheme);
      expect(p.palette, AppPalette.field);
      expect(p.data.bandEdges, isNotEmpty);
      final bands = {
        AppPalette.field.chartDay,
        AppPalette.field.chartTwilight,
        AppPalette.field.chartDark,
      };
      expect(bands, hasLength(3));
      expect(AppPalette.field.chartGrid, isNot(AppPalette.field.chartDark));
    });

    testWidgets('compact: no altitude labels, Moon or legend', (tester) async {
      final p = await pump(tester, density: TimelineDensity.compact);
      expect(p.moonAltitudesDeg, isNull);
      expect(p.geometry(sizeOf(tester)).altitudeLabels, isEmpty);
      expect(find.text('Imaging window'), findsNothing);
      expect(sizeOf(tester).height, 88);
    });
  });
}
