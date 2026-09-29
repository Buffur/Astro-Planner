// TASK 15.3: accessibility guideline tests. Every main screen, scrolled top
// to bottom, in the light, dark and field (red) themes at 100 % and 200 %
// text: no layout exception (overflow), Android's 48 px tap targets, a label
// on every tappable element, and WCAG AA text contrast in the light and dark
// themes (S1.10: with a full forecast on screen, UX-32). Field mode's secondary red is below AA by design (dark
// adaptation; documented in ARCHITECTURE.md B16), so contrast is not
// asserted there. Plus the altitude chart's text alternative.

import 'dart:typed_data';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/presentation/widgets/planner_sections.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_capture_file_access.dart';
import '../support/fake_device_time_zone.dart';
import '../support/jpeg_fixture.dart';
import '../support/fake_location_service.dart';
import '../support/fake_reverse_geocoder.dart';
import '../support/planner_harness.dart';
import '../support/tiff_fixture.dart';
import '../support/legacy_run.dart';

/// Every hour of the night with every variable filled, on whole UTC hours
/// as the provider serves them, so the sweep renders the weather card, its
/// ranges and the hour strip (S1.10; the blind spot UX-32).
class _FullForecast implements WeatherRepository {
  _FullForecast(this.clock);

  final Clock clock;

  @override
  Future<WeatherFetch> fetchSnapshot({
    required double latitude,
    required double longitude,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    final first = DateTime.utc(
      startUtc.year,
      startUtc.month,
      startUtc.day,
      startUtc.hour,
    );
    return WeatherFetched(
      WeatherSnapshot(
        provider: 'open-meteo',
        model: 'best_match',
        fetchedAtUtc: clock.nowUtc(),
        latitude: latitude,
        longitude: longitude,
        hours: [
          for (
            var t = first;
            t.isBefore(endUtc);
            t = t.add(const Duration(hours: 1))
          )
            WeatherHour(
              timeUtc: t,
              cloudCoverPct: 100,
              cloudCoverLowPct: 18,
              cloudCoverMidPct: 45,
              cloudCoverHighPct: 100,
              precipitationProbabilityPct: 35,
              windSpeedKmh: 12.5,
              windGustsKmh: 28.4,
              temperatureC: -12.5,
              dewPointC: -14.2,
              relativeHumidityPct: 88,
              visibilityM: 24140,
            ),
        ],
      ),
    );
  }
}

enum _Theme { light, dark, field }

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// A phone-width view with the app on a site, the catalog, the seeded rig,
/// a planned session and a run in progress. The view is 412 logical px wide
/// (a phone) and tall enough for a whole page: a node half scrolled under an
/// app bar reports a clipped size to the tap-target guideline, which would
/// be a false failure.
Future<({PlannerHarness vm, int running, int planned, int ended})> _pumpApp(
  WidgetTester tester, {
  required _Theme theme,
  required double textScale,
}) async {
  tester.view.physicalSize = const Size(412, 10000);
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.platformBrightnessTestValue = theme == _Theme.light
      ? Brightness.light
      : Brightness.dark;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  AppRouter.router.go(AppRouter.tonight);
  late AppDatabase db;
  late PlannerHarness vm;
  late int running, planned, ended;
  await tester.runAsync(() async {
    db = AppDatabase(NativeDatabase.memory());
    await CatalogSeeder(DriftTargetRepository(db)).seedIfNeeded();
    await EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded();
    final siteId = await DriftLocationRepository(db).insertLocation(
      domain.LocationProfile(
        id: 0,
        name: 'Ljubljana',
        latitude: 46.05,
        longitude: 14.51,
        elevation: 300,
        timeZoneId: 'Europe/Ljubljana',
      ),
    );
    SharedPreferences.setMockInitialValues({'activeLocationId': siteId});
    final clock = FixedClock(DateTime.utc(2026, 11, 10, 18));
    vm = PlannerHarness(
      DriftTargetRepository(db),
      DriftEquipmentRepository(db),
      _FullForecast(clock),
      DriftLocationRepository(db),
      locationService: FakeLocationService(),
      reverseGeocoder: FakeReverseGeocoder(),
      deviceTimeZone: FakeDeviceTimeZone(),
      clock: clock,
      sessionRepository: DriftSessionRepository(db, clock: clock),
      // S3.6: a file matching the seeded rig, so the import review shows a
      // match, its reasons, a conflict switch and every action.
      captureFiles: FakeCaptureFileAccess()..file('light.jpg', _seedJpeg()),
    );
    await vm.ready;
    await vm.choosePlan(); // S6.8: nothing is preselected
    planned = (await vm.analysis.saveSession()).id;
    // S8.4: an old run in progress (the tracker left); its result form.
    running = (await startLegacyRun(
      DriftSessionRepository(db, clock: clock),
      (await DriftSessionRepository(db).get(planned))!,
    )).id;
    // TD-087: a Saved plan whose night (9 Nov) has ended, awaiting its
    // result, so the sweep sees the Saved-plan result form too.
    ended = (await _savedEndedPlan(
      DriftSessionRepository(db, clock: clock),
      (await DriftSessionRepository(db).get(planned))!,
    )).id;
    if (theme == _Theme.field) await vm.theme.toggleFieldMode();
  });
  addTearDown(() => tester.runAsync(db.close));
  await tester.pumpWidget(
    MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
  );
  await _settle(tester);
  return (vm: vm, running: running, planned: planned, ended: ended);
}

/// A copy of [saved]'s plan saved for 9 Nov, whose night has ended by the
/// sweep's clock (10 Nov, 18:00 UTC).
Future<Session> _savedEndedPlan(
  DriftSessionRepository repo,
  Session saved,
) async {
  final night = CalendarDate(2026, 11, 9);
  final plan = SessionPlan(
    eveningDate: night,
    timeZoneId: 'Europe/Ljubljana',
    siteId: saved.siteId,
    targetId: saved.targetId,
    rigId: saved.rigId,
    blocks: saved.blocks,
    targetLabel: saved.record.targetName,
    rigLabel: saved.record.equipmentName,
    siteLabel: saved.record.locationName,
  );
  final prefs = PlanningPreferences();
  final row = await repo.create(plan);
  return repo.savePlan(
    row.id,
    plan,
    SessionSnapshotBuilder.build(
      takenAtUtc: DateTime.utc(2026, 11, 9, 18),
      night: SessionNight(
        eveningDate: night,
        startUtc: DateTime.utc(2026, 11, 9, 11),
        endUtc: DateTime.utc(2026, 11, 10, 11),
        latitude: 46.05,
        longitude: 14.51,
        timeContextId: 'Europe/Ljubljana',
      ),
      timeZoneId: 'Europe/Ljubljana',
      preferences: prefs,
      budget: CaptureBudgetCalculator.calculate(
        blocks: saved.blocks,
        overheads: CaptureOverheads.fromPreferences(prefs),
        targetTransitsInWindow: false,
      ),
      blocks: saved.blocks,
    ),
  );
}

/// Checks the page; one taller than the view is scrolled a screen at a time
/// and checked again. Returns every problem found.
Future<List<String>> _audit(
  WidgetTester tester, {
  required bool contrast,
}) async {
  final problems = <String>[];
  for (var page = 0; page < 60; page++) {
    Object? error;
    while ((error = tester.takeException()) != null) {
      // The message and, for a layout error, the widget that caused it.
      final lines = error.toString().split('\n');
      final where = lines.where((l) => l.contains('.dart:')).take(1);
      problems.add('exception: ${[lines.first, ...where].join(' at ')}');
    }
    for (final g in [
      androidTapTargetGuideline,
      labeledTapTargetGuideline,
      if (contrast) textContrastGuideline,
    ]) {
      final result = await g.evaluate(tester);
      if (!result.passed) problems.add('${g.description}: ${result.reason}');
    }
    final lists = find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    );
    if (lists.evaluate().isEmpty) break;
    final position = tester.state<ScrollableState>(lists.first).position;
    if (position.pixels >= position.maxScrollExtent) break;
    position.jumpTo(
      (position.pixels + 9000).clamp(0.0, position.maxScrollExtent),
    );
    await tester.pump();
  }
  return problems;
}

/// A camera JPEG naming the seeded rig's camera and optics, with a rounded
/// f/5.6 (a listed difference from the seed's f/5.56).
Uint8List _seedJpeg() {
  final exif = TiffFixture()
    ..ifd0.addAll([
      FixtureEntry.ascii(271, 'ZWO'),
      FixtureEntry.ascii(272, 'ASI2600MC'),
    ])
    ..exif = [
      FixtureEntry.rational(37386, 400, 1),
      FixtureEntry.rational(33437, 56, 10),
      FixtureEntry.long(40962, 6248),
      FixtureEntry.long(40963, 4176),
    ];
  return jpegFile([exifApp1(exif.build().bytes)]);
}

void main() {
  for (final theme in _Theme.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('every screen meets the guidelines: ${theme.name}, '
          '${(scale * 100).round()} % text', (tester) async {
        final app = await _pumpApp(tester, theme: theme, textScale: scale);
        final handle = tester.ensureSemantics();
        final routes = [
          AppRouter.tonight,
          AppRouter.candidates,
          AppRouter.sessions,
          AppRouter.sessionDetail(app.planned),
          AppRouter.library,
          AppRouter.libraryRigs,
          AppRouter.libraryTargets,
          AppRouter.librarySites,
          AppRouter.selectRig, // S9.1: the same lists, choosing
          AppRouter.selectTarget,
          AppRouter.selectSite,
          AppRouter.logbookProgress,
          AppRouter.settings,
          AppRouter.about,
          AppRouter.session(),
          AppRouter.siteEdit,
          AppRouter.results(app.running),
          AppRouter.results(app.planned), // TD-087: its night not ended yet
          AppRouter.results(app.ended), // TD-087: no outcome chosen yet
          AppRouter.welcome,
          AppRouter.metadata,
          AppRouter.nightMoon, // S6.5
          AppRouter.weather, // S6.5
        ];
        final report = <String>[];
        for (final route in routes) {
          AppRouter.router.go(route);
          await _settle(tester);
          if (route == AppRouter.metadata) {
            await tester.runAsync(app.vm.vms.metadataImport!.pickAndRead);
            await _settle(tester);
            expect(find.byKey(const Key('import.open.1')), findsOneWidget);
          }
          final problems = await _audit(
            tester,
            contrast: theme != _Theme.field,
          );
          if (problems.isNotEmpty) {
            report.add('$route:\n${problems.join('\n')}');
          }
        }
        // TD-087: the Saved plan's form with Not done chosen, so the sweep
        // sees the reason chips.
        AppRouter.router.go(AppRouter.results(app.ended));
        await _settle(tester);
        final notDone = find.byKey(const Key('results.outcome.notDone'));
        await tester.ensureVisible(notDone);
        await tester.tap(notDone);
        await _settle(tester);
        expect(find.byKey(const Key('results.reason.clouds')), findsOneWidget);
        final reasons = await _audit(tester, contrast: theme != _Theme.field);
        if (reasons.isNotEmpty) {
          report.add('result form, Not done:\n${reasons.join('\n')}');
        }
        // S6.7: the planner again with every section open, so the sweep
        // sees the detail that is one tap away too.
        for (final key in PlannerSections.all) {
          await app.vm.disclosure.setOpen(key, true);
        }
        AppRouter.router.go(AppRouter.session());
        await _settle(tester);
        final open = await _audit(tester, contrast: theme != _Theme.field);
        if (open.isNotEmpty) {
          report.add('planner, sections open:\n${open.join('\n')}');
        }
        // S6.8: a new plan: no target, and an empty capture plan with the
        // offer of the example.
        await tester.runAsync(app.vm.newSession);
        AppRouter.router.go(AppRouter.session());
        await _settle(tester);
        expect(find.byKey(const Key('capturePlan.useExample')), findsOneWidget);
        final fresh = await _audit(tester, contrast: theme != _Theme.field);
        if (fresh.isNotEmpty) {
          report.add('planner, new plan:\n${fresh.join('\n')}');
        }
        handle.dispose();
        expect(report, isEmpty, reason: report.join('\n\n'));
      });
    }
  }

  // S1.10 (UX-32): the sweep would miss a weather-card overflow again if the
  // forecast stopped rendering.
  testWidgets('the sweep renders a forecast', (tester) async {
    await _pumpApp(tester, theme: _Theme.light, textScale: 2.0);
    // S6.5: the full forecast is on the Weather detail.
    AppRouter.router.go(AppRouter.weather);
    await _settle(tester);
    expect(find.byKey(const Key('weather.hours')), findsOneWidget);
    expect(find.byKey(const Key('weather.ranges')), findsOneWidget);
    // UX-31: a range label never runs into its value.
    final label = tester.getRect(find.text('Low cloud (below 3 km)'));
    final value = tester.getRect(find.text('18 %'));
    expect(value.left - label.right, greaterThanOrEqualTo(8));
    // S1.13 (SCI-02): precipitation covers the preceding hour.
    expect(
      find.text('Chance of precipitation (preceding hour)'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('weather.precipNote')), findsOneWidget);
  });

  testWidgets('the altitude chart has a text alternative', (tester) async {
    await _pumpApp(tester, theme: _Theme.light, textScale: 1.0);
    final handle = tester.ensureSemantics();
    AppRouter.router.go(AppRouter.session());
    await _settle(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('chart.altitude')),
      300,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
    expect(
      find.bySemanticsLabel(
        RegExp(
          r"Chart of the target's altitude through the night: .*"
          r'usable time .*listed below the chart\.',
        ),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });
}
