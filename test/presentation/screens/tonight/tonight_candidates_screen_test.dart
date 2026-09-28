// TASK 10.4: "Tonight's candidates" — the ViewModel evaluates every target
// with the same inputs as Home's opportunity card, and the screen sorts,
// filters and opens a target.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/domain/services/candidate_evaluator.dart';
import 'package:astroplan/presentation/screens/tonight/tonight_candidates_screen.dart';

import '../../../support/planner_harness.dart';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_device_time_zone.dart';
import '../../../support/fake_location_service.dart';
import '../../../support/fake_reverse_geocoder.dart';
import '../../../support/no_snapshot_weather.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

void main() {
  late AppDatabase database;

  Future<PlannerHarness> build({bool withSite = true}) async {
    database = AppDatabase(NativeDatabase.memory());
    final targets = DriftTargetRepository(database);
    await CatalogSeeder(targets).seedIfNeeded();
    // A rig, so rows carry a frame fill (S1.8).
    await EquipmentSeeder(DriftEquipmentRepository(database)).seedIfNeeded();
    final locations = DriftLocationRepository(database);
    final prefs = <String, Object>{};
    if (withSite) {
      prefs['activeLocationId'] = await locations.insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Ljubljana',
          latitude: 46.05,
          longitude: 14.51,
          elevation: 300,
        ),
      );
    }
    SharedPreferences.setMockInitialValues(prefs);
    final vm = PlannerHarness(
      targets,
      DriftEquipmentRepository(database),
      _NoWeather(),
      locations,
      locationService: FakeLocationService(),
      reverseGeocoder: FakeReverseGeocoder(),
      deviceTimeZone: FakeDeviceTimeZone(),
      clock: FixedClock(DateTime.utc(2026, 11, 10, 18)),
    );
    await vm.ready;
    await vm.choosePlan(); // S6.8: nothing is preselected
    return vm;
  }

  test('every target is evaluated like the single-target view', () async {
    final vm = await build();
    addTearDown(database.close);
    final rows = (await vm.tonightCandidates())!;
    final all = await DriftTargetRepository(database).getAllTargets();
    expect(rows, hasLength(all.length));

    final selected = vm.selectedTarget!;
    final mine = rows.firstWhere((r) => r.target.id == selected.id);
    final single = CandidateEvaluator.candidateOf(
      selected,
      vm.imagingOpportunity!,
    );
    expect(mine.usableTime, single.usableTime);
    expect(mine.firstWindowStartUtc, single.firstWindowStartUtc);
    expect(mine.maxAltitudeDeg, single.maxAltitudeDeg);
    expect(mine.minMoonSeparationDeg, single.minMoonSeparationDeg);
    expect(rows.where((r) => r.hasWindow), isNotEmpty);
  });

  test('without a site there is nothing to evaluate', () async {
    final vm = await build(withSite: false);
    addTearDown(database.close);
    expect(await vm.tonightCandidates(), isNull);
  });

  testWidgets('sorted by usable time; filters; a tap opens the target', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    late PlannerHarness vm;
    await tester.runAsync(() async => vm = await build());
    addTearDown(() => tester.runAsync(database.close));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/tonight',
          builder: (_, _) => const TonightCandidatesScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    router.push('/tonight');
    await tester.pump();

    // The evaluation runs on a background isolate.
    for (var i = 0; i < 100; i++) {
      if (find.byKey(const Key('tonight.header')).evaluate().isNotEmpty) break;
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    final header = tester
        .widget<Text>(find.byKey(const Key('tonight.header')))
        .data!;
    // S6.14 (RD-10 = O1): the header names the order.
    expect(header, contains('sorted by usable time, then frame fill'));
    expect(header, isNot(contains('(no score)')));
    // S1.8: the planner's frame-fill wording (SCI-06); no "Home" (UX-20).
    expect(find.textContaining("of the frame's short side"), findsWidgets);
    expect(find.textContaining('fills '), findsNothing);
    expect(
      find.textContaining("Tap a target to make it the plan's target."),
      findsOneWidget,
    );

    final evaluated = await tester.runAsync(() async {
      return (await vm.tonightCandidates())!;
    });
    final rows = CandidateList.sort(
      CandidateList.filter(evaluated!),
      CandidateSort.usableTime,
    );
    final first = find.byKey(Key('tonight.row.${rows.first.target.id}'));
    expect(first, findsOneWidget);
    expect(header, contains('${rows.length} of'));

    await tester.tap(find.byKey(const Key('tonight.all')));
    await tester.pump();
    final allHeader = tester
        .widget<Text>(find.byKey(const Key('tonight.header')))
        .data!;
    expect(allHeader, isNot(contains('${rows.length} of')));

    await tester.tap(first);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(vm.selectedTarget!.id, rows.first.target.id);
    expect(find.text('home'), findsOneWidget);
  });
}
