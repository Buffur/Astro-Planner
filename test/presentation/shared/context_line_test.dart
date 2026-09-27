// S5.6 (ADR-019 §5, §6): the context line. Each part reports its tap; the
// zone rule follows the site (its zone, or the labelled device zone); no
// site means no night; the shared night picker returns the chosen evening
// and stays red or black in field mode by its theme alone.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:astroplan/core/theme/app_theme.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/presentation/shared/context_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

final _night = CalendarDate(2026, 11, 13);
final _start = DateTime.utc(2026, 11, 13, 11); // mean solar noon, roughly

Future<({List<String> taps})> _pump(
  WidgetTester tester, {
  String? site = 'Ljubljana',
  CalendarDate? night,
  String? zoneId = 'Europe/Ljubljana',
  ThemeData? theme,
}) async {
  final taps = <String>[];
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.light,
      home: Scaffold(
        body: ContextLine(
          siteName: site,
          night: night,
          zoneId: zoneId,
          nightStartUtc: _start,
          onSite: () => taps.add('site'),
          onNight: () => taps.add('night'),
        ),
      ),
    ),
  );
  return (taps: taps);
}

void main() {
  testWidgets('each part reports its own tap', (tester) async {
    final r = await _pump(tester, night: _night);
    expect(find.text('Ljubljana'), findsOneWidget);
    expect(find.text('Fri, Nov 13'), findsOneWidget);
    await tester.tap(find.byKey(const Key('context.site')));
    await tester.tap(find.byKey(const Key('context.night')));
    expect(r.taps, ['site', 'night']);
  });

  testWidgets('each part is a labelled 48 dp button', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, night: _night);
    expect(
      tester.getSemantics(find.byKey(const Key('context.site'))),
      matchesSemantics(
        label: 'Site: Ljubljana',
        hint: 'Choose a site',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.byKey(const Key('context.night'))),
      matchesSemantics(
        label: 'Night: Fri, Nov 13',
        hint: 'Choose a night',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    for (final k in ['context.site', 'context.night']) {
      expect(
        tester.getSize(find.byKey(Key(k))).height,
        greaterThanOrEqualTo(48),
      );
    }
    handle.dispose();
  });

  testWidgets('the zone rule: the site\'s zone, named once', (tester) async {
    await _pump(tester, night: _night);
    expect(
      find.text('Times in site zone Europe/Ljubljana, CET, UTC+01:00'),
      findsOneWidget,
    );
  });

  testWidgets('a site without a zone: times are labelled as the device '
      'zone', (tester) async {
    await _pump(tester, night: _night, zoneId: null);
    final caption = tester.widget<Text>(find.byKey(const Key('context.zone')));
    expect(caption.data, startsWith('Times in device zone, UTC'));
  });

  testWidgets('no site: no night and no zone rule, and the site part asks '
      'for one', (tester) async {
    final r = await _pump(tester, site: null, night: null);
    expect(find.text(ContextLine.noSite), findsOneWidget);
    expect(find.byKey(const Key('context.night')), findsNothing);
    expect(find.byKey(const Key('context.zone')), findsNothing);
    await tester.tap(find.byKey(const Key('context.site')));
    expect(r.taps, ['site']);
  });

  group('the night picker', () {
    /// Opens the picker over a bare app in [theme].
    Future<void> open(WidgetTester tester, {ThemeData? theme}) async {
      await tester.pumpWidget(
        RepaintBoundary(
          key: const Key('shot'),
          child: MaterialApp(
            // The debug banner is not the app's (AstroPlanApp hides it).
            debugShowCheckedModeBanner: false,
            theme: theme ?? AppTheme.light,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => pickNight(
                    context,
                    initial: _night,
                    today: DateTime(2026, 11, 10),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
    }

    testWidgets('returns the chosen evening, and null when cancelled', (
      tester,
    ) async {
      CalendarDate? picked;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async => picked = await pickNight(
                  context,
                  initial: _night,
                  today: DateTime(2026, 11, 10),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Choose a night'), findsOneWidget);
      await tester.tap(find.text('20'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(picked, CalendarDate(2026, 11, 20));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(picked, isNull);
    });

    testWidgets('is red or black in field mode by its theme alone (no '
        'colour filter)', (tester) async {
      await open(tester, theme: AppTheme.fieldTheme);
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const Key('shot')),
      );
      final bytes = (await tester.runAsync(() async {
        final image = await boundary.toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        image.dispose();
        return data!;
      }))!;
      expect(_coloured(bytes), 0);

      // Sanity: the same check sees colour in the light theme.
      await tester.pumpWidget(const SizedBox()); // a fresh app
      await open(tester);
      final light = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const Key('shot')),
      );
      final lightBytes = (await tester.runAsync(() async {
        final image = await light.toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        image.dispose();
        return data!;
      }))!;
      expect(_coloured(lightBytes), greaterThan(0));
    });
  });
}

/// Pixels whose green or blue channel is not zero.
int _coloured(ByteData bytes) {
  var n = 0;
  for (var i = 0; i < bytes.lengthInBytes; i += 4) {
    if (bytes.getUint8(i + 1) != 0 || bytes.getUint8(i + 2) != 0) n++;
  }
  return n;
}
