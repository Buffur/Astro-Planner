// TASK 15.3: accessibility guideline tests. Every main screen, scrolled top
// to bottom, in the light, dark and field (red) themes at 100 % and 200 %
// text: no layout exception (overflow), Android's 48 px tap targets, a label
// on every tappable element, and WCAG AA text contrast in the light and dark
// themes. Field mode's secondary red is below AA by design (dark
// adaptation; documented in ARCHITECTURE.md B16), so contrast is not
// asserted there. Plus the altitude chart's text alternative.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_device_time_zone.dart';
import '../support/fake_location_service.dart';
import '../support/fake_reverse_geocoder.dart';
import '../support/no_snapshot_weather.dart';
import '../support/planner_harness.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

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
Future<({PlannerHarness vm, int running, int planned})> _pumpApp(
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
  late int running, planned;
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
      _NoWeather(),
      DriftLocationRepository(db),
      locationService: FakeLocationService(),
      reverseGeocoder: FakeReverseGeocoder(),
      deviceTimeZone: FakeDeviceTimeZone(),
      clock: clock,
      sessionRepository: DriftSessionRepository(db, clock: clock),
    );
    await vm.ready;
    planned = (await vm.analysis.saveSession()).id;
    running = (await vm.analysis.startSession()).id;
    await vm.execution!.open(running);
    if (theme == _Theme.field) await vm.theme.toggleFieldMode();
  });
  addTearDown(() => tester.runAsync(db.close));
  await tester.pumpWidget(
    MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
  );
  await _settle(tester);
  return (vm: vm, running: running, planned: planned);
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
          AppRouter.libraryProgress,
          AppRouter.settings,
          AppRouter.about,
          AppRouter.session(),
          AppRouter.siteEdit,
          AppRouter.run(app.running),
          AppRouter.results(app.running),
          AppRouter.welcome,
        ];
        final report = <String>[];
        for (final route in routes) {
          AppRouter.router.go(route);
          await _settle(tester);
          final problems = await _audit(
            tester,
            contrast: theme != _Theme.field,
          );
          if (problems.isNotEmpty) {
            report.add('$route:\n${problems.join('\n')}');
          }
        }
        handle.dispose();
        expect(report, isEmpty, reason: report.join('\n\n'));
      });
    }
  }

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
