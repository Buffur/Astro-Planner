// TASK 15.2: the planner's costly derived values are computed once per
// input, not on every read (widgets read them several times per frame);
// every input change — and a night rolling over with the clock alone —
// recomputes them. Plus a tolerant benchmark: a cached planner frame and
// tonight's candidates through the ViewModel.

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
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

class _Clock extends Clock {
  DateTime now = DateTime.utc(2026, 11, 10, 18);
  @override
  DateTime nowUtc() => now;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late _Clock clock;
  late PlannerHarness vm;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    final targets = DriftTargetRepository(db);
    final equipment = DriftEquipmentRepository(db);
    await CatalogSeeder(targets).seedIfNeeded();
    await EquipmentSeeder(equipment).seedIfNeeded();
    final locations = DriftLocationRepository(db);
    final siteId = await locations.insertLocation(
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
    clock = _Clock();
    vm = PlannerHarness(
      targets,
      equipment,
      _NoWeather(),
      locations,
      locationService: FakeLocationService(),
      reverseGeocoder: FakeReverseGeocoder(),
      deviceTimeZone: FakeDeviceTimeZone(),
      clock: clock,
      sessionRepository: DriftSessionRepository(db, clock: clock),
    );
    await vm.ready;
    // A meridian flip makes the budget and the fit use the target's transit.
    await vm.settings.setPlanningPreferences(
      vm.settings.planningPreferences.withOptionalOverheads(
        meridianFlipSeconds: (300,),
      ),
    );
    expect(vm.plan.sessionNight, isNotNull);
    expect(vm.plan.selectedTarget, isNotNull);
  });

  tearDown(() async {
    await vm.plan.idle;
    await db.close();
  });

  test('repeated reads return the same computed values', () {
    final c = vm.conditions, a = vm.analysis;
    expect(identical(c.nightTimeline, c.nightTimeline), isTrue);
    expect(identical(a.captureBudget, a.captureBudget), isTrue);
    expect(identical(a.fitAnalysis, a.fitAnalysis), isTrue);
  });

  test('a plan edit recomputes the budget and the fit', () async {
    final a = vm.analysis;
    final budget = a.captureBudget, fit = a.fitAnalysis;
    final frames = budget.lightFrameCount;
    await vm.plan.addCaptureBlock(
      CaptureBlock(
        id: 0,
        frameType: FrameType.light,
        exposureTimeSeconds: 120,
        frameCount: 7,
      ),
    );
    expect(a.captureBudget.lightFrameCount, frames + 7);
    expect(identical(a.fitAnalysis, fit), isFalse);
  });

  test('a preference change recomputes the fit', () async {
    final fit = vm.analysis.fitAnalysis;
    await vm.settings.setMinAltitude(vm.settings.minAltitude + 10);
    expect(identical(vm.analysis.fitAnalysis, fit), isFalse);
  });

  test(
    'another night recomputes the timeline, the budget and the fit',
    () async {
      final c = vm.conditions, a = vm.analysis;
      final timeline = c.nightTimeline!, fit = a.fitAnalysis;
      await vm.plan.setEveningDate(CalendarDate(2026, 12, 20));
      expect(c.nightTimeline!.night, isNot(timeline.night));
      expect(identical(a.fitAnalysis, fit), isFalse);
    },
  );

  test('a night rolling over with the clock alone is not served stale', () {
    final c = vm.conditions, a = vm.analysis;
    final night = vm.plan.sessionNight!;
    final timeline = c.nightTimeline!, fit = a.fitAnalysis;
    clock.now = clock.now.add(const Duration(days: 1)); // no notification
    expect(vm.plan.sessionNight, isNot(night));
    expect(c.nightTimeline!.night, isNot(timeline.night));
    expect(identical(a.fitAnalysis, fit), isFalse);
  });

  test('a target change recomputes the fit', () async {
    final fit = vm.analysis.fitAnalysis;
    final other = (await vm.vms.targetList.search('M31')).first;
    await vm.plan.setTarget(other);
    expect(identical(vm.analysis.fitAnalysis, fit), isFalse);
  });

  // Tolerant benchmark (TASK 15.2 acceptance): measured on the test
  // machine, with wide margins; device traces are an owner checklist item.
  test('benchmark: a cached planner frame and the candidates', () async {
    final p = vm.plan, c = vm.conditions, a = vm.analysis;
    void frame() {
      p.sessionNight;
      c.currentAltitude;
      c.imagingOpportunity;
      c.moonConditions;
      c.nightTimeline;
      c.nightWeatherSummary;
      a.rigCapability;
      a.captureBudget;
      a.fitAnalysis;
      a.fillWindowFrameCount;
    }

    frame(); // fills the caches
    final sw = Stopwatch()..start();
    for (var i = 0; i < 100; i++) {
      frame();
    }
    sw.stop();
    // Measured about 0.08 ms per frame (2.5 ms before TASK 15.2).
    expect(sw.elapsedMicroseconds / 100, lessThan(1000));

    final candidates = Stopwatch()..start();
    final rows = await c.tonightCandidates();
    candidates.stop();
    expect(rows, hasLength(greaterThan(100))); // the bundled catalog
    expect(candidates.elapsed, lessThan(const Duration(seconds: 1)));
  });
}
