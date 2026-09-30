// S10.2 (Stage 10, D10-6): the reproducible performance scenarios. The
// quality gate runs them on the host as a smoke test and never asserts on
// timing; on an Android device or emulator, in profile mode, they record
// frame timings (build and raster) and elapsed times:
//
//   flutter drive --profile --no-dds -d <device> \
//     --driver=test_driver/perf_driver.dart \
//     --target=integration_test/perf_scenarios_test.dart
//
// The results are written to build/integration_response_data.json and are
// recorded in docs/refinement/evidence/STAGE_10_MEASUREMENTS.md. The
// scenarios follow the plan's priority: the rig editor (the owner's lag,
// 08 §22), the planner's frequent edits, the detail screens, the Logbook at
// a realistic volume, first-run seeding (ENG-12), the session list's
// queries (ENG-11) and the candidates (TASK 10.4).

import 'dart:io';

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/location_profile.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/models/session_night.dart';
import 'package:astroplan/domain/models/session_result.dart';
import 'package:astroplan/domain/models/weather_snapshot.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/capture_budget_calculator.dart';
import 'package:astroplan/domain/services/session_snapshot_builder.dart';
import 'package:astroplan/main.dart';
import 'package:astroplan/presentation/navigation/app_router.dart';
import 'package:astroplan/presentation/widgets/capture_plan_widget.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/support/fake_device_time_zone.dart';
import '../test/support/fake_location_service.dart';
import '../test/support/fake_reverse_geocoder.dart';
import '../test/support/in_memory_display_preferences.dart';
import '../test/support/in_memory_first_run.dart';
import '../test/support/planner_harness.dart';

/// Whether timings are recorded: only on a device (profile mode gives
/// meaningful numbers); the host run is a smoke test.
final bool _measure = Platform.isAndroid;

/// The Logbook's history: a realistic local volume on a device (a few
/// hundred saved plans and results, the plan's S10.5), a handful on the host.
final int _history = _measure ? 300 : 12;

class _Clock extends Clock {
  _Clock(this.now);
  final DateTime now;
  @override
  DateTime nowUtc() => now;
}

/// A clear forecast on whole UTC hours, as Open-Meteo serves it.
class _Forecast implements WeatherRepository {
  _Forecast(this.clock);
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
              cloudCoverPct: 20,
              temperatureC: 3,
              dewPointC: -1,
              relativeHumidityPct: 70,
              windSpeedKmh: 8,
            ),
        ],
      ),
    );
  }
}

final _blocks = [
  CaptureBlock(
    frameType: FrameType.light,
    filterName: 'L',
    exposureTimeSeconds: 300,
    frameCount: 20,
  ),
  CaptureBlock(
    frameType: FrameType.light,
    filterName: 'R',
    exposureTimeSeconds: 120,
    frameCount: 10,
  ),
];

/// [count] saved plans on past nights, two in three with a result.
Future<void> _seedHistory(DriftSessionRepository repo, int count) async {
  final prefs = PlanningPreferences();
  final budget = CaptureBudgetCalculator.calculate(
    blocks: _blocks,
    overheads: CaptureOverheads.fromPreferences(prefs),
    targetTransitsInWindow: false,
  );
  const names = ['M42', 'M31', 'M33', 'M45', 'M81', 'M101', 'NGC 7000'];
  for (var i = 0; i < count; i++) {
    final day = DateTime.utc(2026, 11, 1).subtract(Duration(days: i + 2));
    final date = CalendarDate(day.year, day.month, day.day);
    final plan = SessionPlan(
      eveningDate: date,
      timeZoneId: 'Europe/Ljubljana',
      siteId: null,
      targetId: null,
      rigId: null,
      blocks: _blocks,
      targetLabel: names[i % names.length],
      rigLabel: 'ASI2600MC + 400 mm',
    );
    final snapshot = SessionSnapshotBuilder.build(
      takenAtUtc: day.add(const Duration(hours: 15)),
      night: SessionNight(
        eveningDate: date,
        startUtc: day.add(const Duration(hours: 11)),
        endUtc: day.add(const Duration(hours: 35)),
        latitude: 46.05,
        longitude: 14.51,
        timeContextId: 'Europe/Ljubljana',
      ),
      preferences: prefs,
      budget: budget,
      blocks: _blocks,
    );
    final s = await repo.create(plan);
    await repo.savePlan(s.id, plan, snapshot);
    if (i % 3 == 0) continue;
    await repo.recordResult(
      s.id,
      i % 3 == 1
          ? const CompletedAsPlanned(notes: ResultNotes())
          : const NotDone(reason: NotDoneReason.clouds, notes: ResultNotes()),
    );
  }
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final timings = <String, int>{};

  /// Runs [action]; on a device, records its frames under [key].
  Future<void> watch(String key, Future<void> Function() action) async {
    if (!_measure) return action();
    await binding.watchPerformance(action, reportKey: key);
  }

  /// Times [work] in milliseconds, under [key].
  Future<T> time<T>(String key, Future<T> Function() work) async {
    final sw = Stopwatch()..start();
    final result = await work();
    timings[key] = sw.elapsedMilliseconds;
    return result;
  }

  Future<void> settle(WidgetTester tester, [int rounds = 10]) async {
    for (var i = 0; i < rounds; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await settle(tester);
  }

  /// Types [text] one character at a time, as a user does.
  Future<void> type(WidgetTester tester, Finder field, String text) async {
    for (var i = 1; i <= text.length; i++) {
      await tester.enterText(field, text.substring(0, i));
      await tester.pump(const Duration(milliseconds: 80));
    }
  }

  testWidgets('the Stage 10 scenarios', (tester) async {
    final clock = _Clock(DateTime.utc(2026, 11, 10, 16));
    final dir = Directory.systemTemp.createTempSync('astroplan_perf');
    addTearDown(() => dir.deleteSync(recursive: true));
    late AppDatabase db;
    late PlannerHarness vm;

    await tester.runAsync(() async {
      // ENG-12: the first run's seeding, on a new database file.
      db = AppDatabase(NativeDatabase(File('${dir.path}/perf.sqlite')));
      await time(
        'seed.catalog.ms',
        () => CatalogSeeder(DriftTargetRepository(db)).seedIfNeeded(),
      );
      await time(
        'seed.equipment.ms',
        () => EquipmentSeeder(DriftEquipmentRepository(db)).seedIfNeeded(),
      );
      final sessions = DriftSessionRepository(db, clock: clock);
      await time('history.seed.ms', () => _seedHistory(sessions, _history));
      // ENG-11: the list the Logbook loads, rows and their blocks.
      final listed = await time('history.list.ms', () => sessions.list());
      expect(listed.length, greaterThanOrEqualTo(_history));

      final siteId = await DriftLocationRepository(db).insertLocation(
        LocationProfile(
          id: 0,
          name: 'Ljubljana',
          latitude: 46.05,
          longitude: 14.51,
          elevation: 300,
          timeZoneId: 'Europe/Ljubljana',
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': siteId});
      vm = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _Forecast(clock),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        reverseGeocoder: FakeReverseGeocoder(),
        deviceTimeZone: FakeDeviceTimeZone('Europe/Ljubljana'),
        clock: clock,
        sessionRepository: sessions,
        displayPreferences: InMemoryDisplayPreferences(),
        firstRun: InMemoryFirstRun(done: true),
      );
      await vm.ready;
      await vm.theme.load();
      await vm.tonight.load();
      await vm.choosePlan();
      // TASK 10.4: tonight's candidates through the ViewModel.
      final rows = await time('candidates.ms', vm.tonightCandidates);
      expect(rows, isNotEmpty);
    });
    addTearDown(() => tester.runAsync(db.close));

    AppRouter.router.go(AppRouter.tonight);
    await tester.pumpWidget(
      MultiProvider(providers: vm.providers, child: const AstroPlanApp()),
    );
    await settle(tester);

    // 1. The rig editor (08 §22): open, focus a field (the keyboard opens
    // on a device), type.
    AppRouter.router.go(AppRouter.libraryRigs);
    await settle(tester);
    await watch('rigEditor.open', () => tap(tester, find.byTooltip('Add rig')));
    final pixel = find.byKey(const Key('equipmentEditor.pixelSize'));
    await watch('rigEditor.focus', () async {
      await tap(tester, pixel);
      await settle(tester, 20);
    });
    await watch('rigEditor.type', () => type(tester, pixel, '3.7612'));
    await watch('rigEditor.typeName', () async {
      final name = find.widgetWithText(TextFormField, 'Rig name');
      await tap(tester, name);
      await type(tester, name, 'Refractor 400');
    });
    await tap(tester, find.text('Cancel'));

    // 2. The planner: open it, edit a block through its dialog, change the
    // night and the target, open a section.
    await watch('planner.open', () async {
      AppRouter.router.go(AppRouter.session());
      await settle(tester, 20);
    });
    final list = find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .first;
    await tester.scrollUntilVisible(
      find.byType(CapturePlanWidget),
      300,
      scrollable: list,
    );
    await settle(tester, 3);
    final firstBlock = find
        .descendant(
          of: find.byType(CapturePlanWidget),
          matching: find.byType(ListTile),
        )
        .first;
    await watch('planner.blockDialog', () async {
      await tap(tester, firstBlock);
      final count = find.widgetWithText(TextFormField, 'Frame Count');
      await tap(tester, count);
      await type(tester, count, '36');
      await tap(tester, find.byKey(const Key('blockDialog.submit')));
    });
    await watch('planner.blockEdit', () async {
      // Two exposure edits, then two frame-count edits.
      for (final s in [240.0, 180.0]) {
        await tester.runAsync(
          () => vm.plan.updateCaptureBlock(
            0,
            vm.plan.captureBlocks.first.copyWith(exposureTimeSeconds: s),
          ),
        );
        await settle(tester, 3);
      }
      for (final n in [40, 44]) {
        await tester.runAsync(
          () => vm.plan.updateCaptureBlock(
            0,
            vm.plan.captureBlocks.first.copyWith(frameCount: n),
          ),
        );
        await settle(tester, 3);
      }
    });
    await watch('planner.nightChange', () async {
      await tester.runAsync(
        () => vm.plan.setEveningDate(CalendarDate(2026, 11, 12)),
      );
      await settle(tester, 12);
    });
    await watch('planner.targetChange', () async {
      await tester.runAsync(() async {
        final t = (await DriftTargetRepository(db).searchTargets('M31')).first;
        await vm.plan.setTarget(t);
      });
      await settle(tester, 12);
    });
    // The budget's detail section (PlannerSections.budgetDetails).
    final section = find.byKey(const Key('section.planner.budgetDetails'));
    await tester.scrollUntilVisible(section, 300, scrollable: list);
    await settle(tester, 3);
    await watch('planner.section', () => tap(tester, section));

    // 3. The detail screens.
    await watch('detail.nightMoon', () async {
      AppRouter.router.go(AppRouter.nightMoon);
      await settle(tester, 12);
    });
    await watch('detail.weather', () async {
      AppRouter.router.go(AppRouter.weather);
      await settle(tester, 12);
    });

    // 4. The Logbook at a realistic volume: open, search, filter, an entry.
    await watch('logbook.open', () async {
      AppRouter.router.go(AppRouter.sessions);
      await settle(tester, 15);
    });
    await watch('logbook.search', () async {
      await tap(tester, find.byKey(const Key('logbook.searchToggle')));
      await type(tester, find.byKey(const Key('logbook.search')), 'M3');
      await settle(tester);
    });
    await watch('logbook.filters', () async {
      await tap(tester, find.byKey(const Key('logbook.filters')));
      await tap(tester, find.byKey(const Key('logbook.filter.completed')));
      await settle(tester);
    });
    // Close the filter panel on its barrier.
    await tester.tapAt(const Offset(20, 20));
    await settle(tester);
    await watch('logbook.entry', () async {
      AppRouter.router.go(AppRouter.sessions);
      await settle(tester);
      final entry = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('logbook.title.'),
      );
      await tap(tester, entry.first);
      await settle(tester, 12);
    });

    binding.reportData = {...?binding.reportData, 'timings': timings};
  });
}
