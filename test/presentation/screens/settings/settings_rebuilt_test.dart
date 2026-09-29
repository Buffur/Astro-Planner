// S9.4 (RG-13 answered by S9.3; D9-3; RD-11 = S9, TD-050): Settings in
// sections by what a value changes; the Moon and cloud gates reachable, and
// their thresholds used by the planner; the optional overheads' values
// editable within the model's ranges; the per-frame range the model's; a
// failed save reported.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/repositories/planning_preferences_repository.dart';
import 'package:astroplan/domain/repositories/storage_failure.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/screens/settings/settings_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_device_time_zone.dart';
import '../../../support/fake_location_service.dart';
import '../../../support/no_snapshot_weather.dart';
import '../../../support/planner_harness.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

/// A store that cannot be written (a full disk).
class _Broken implements PlanningPreferencesRepository {
  @override
  Future<PlanningPreferences> load() async => PlanningPreferences();

  @override
  Future<void> save(PlanningPreferences preferences) async =>
      throw const StorageFailure('disk full');
}

void main() {
  late AppDatabase database;
  late PlannerHarness vm;

  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Ljubljana, the night of 24 Nov 2026 (near full Moon: the Moon is up
  /// and bright through the dark hours), M42 and the example plan.
  Future<void> build(
    WidgetTester tester, {
    PlanningPreferencesRepository? preferences,
  }) async {
    await tester.runAsync(() async {
      database = AppDatabase(NativeDatabase.memory());
      await CatalogSeeder(DriftTargetRepository(database)).seedIfNeeded();
      await EquipmentSeeder(DriftEquipmentRepository(database)).seedIfNeeded();
      final sites = DriftLocationRepository(database);
      final id = await sites.insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Ljubljana',
          latitude: 46.05,
          longitude: 14.51,
          timeZoneId: 'Europe/Ljubljana',
        ),
      );
      SharedPreferences.setMockInitialValues({'activeLocationId': id});
      vm = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _NoWeather(),
        sites,
        locationService: FakeLocationService(),
        deviceTimeZone: FakeDeviceTimeZone(),
        clock: FixedClock(DateTime.utc(2026, 11, 24, 16)),
        preferencesRepository: preferences,
      );
      await vm.ready;
      await vm.choosePlan();
    });
    addTearDown(() => tester.runAsync(database.close));
    tester.view.physicalSize = const Size(800, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiProvider(
        providers: vm.providers,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();
  }

  Finder inTile(String key, Type type) =>
      find.descendant(of: find.byKey(Key(key)), matching: find.byType(type));

  testWidgets('the sections, in order, each saying what it changes', (
    tester,
  ) async {
    await build(tester);
    expect(find.text('Settings'), findsOneWidget);
    final headings = [
      'Imaging window',
      'Fit and capture time',
      'Guidance',
      'Display',
      'Privacy',
      'Data',
      'About',
    ];
    final ys = [
      for (final h in headings) tester.getTopLeft(find.text(h).first).dy,
    ];
    expect(ys, orderedEquals([...ys]..sort()));
    expect(
      find.text('Changes advice only; never the imaging window or the fit.'),
      findsOneWidget,
    );
  });

  testWidgets('TD-050: the Moon gate turned on at a threshold changes the '
      'imaging window the planner computes', (tester) async {
    await build(tester);
    final before = vm.imagingOpportunity!.usableTime;
    expect(before, greaterThan(Duration.zero));

    await tester.tap(inTile('settings.moonGate', Switch));
    await tester.pump();
    expect(vm.planningPreferences.moonGateEnabled, isTrue);
    expect(
      find.text('Excludes time when the Moon is up and at least 50 % lit.'),
      findsOneWidget,
    );
    // Drag the threshold to 0 %: any Moon above the horizon excludes time.
    await tester.drag(
      inTile('settings.moonGate', Slider),
      const Offset(-2000, 0),
    );
    await tester.pump();
    expect(vm.planningPreferences.moonGateMinIlluminationPct, 0);
    expect(vm.imagingOpportunity!.usableTime, lessThan(before));

    await tester.tap(inTile('settings.cloudGate', Switch));
    await tester.pump();
    expect(vm.planningPreferences.optionalGates.cloudMaxPct, 50);
    await tester.runAsync(() async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('moonGateEnabled'), isTrue);
      expect(prefs.getBool('cloudGateEnabled'), isTrue);
    });
  });

  testWidgets('the time between frames reaches the model\'s 120 s', (
    tester,
  ) async {
    await build(tester);
    await tester.drag(
      inTile('settings.perFrame', Slider),
      const Offset(3000, 0),
    );
    await tester.pump();
    expect(
      vm.planningPreferences.perFrameOverheadSeconds,
      PlanningPreferences.perFrameRange.$2,
    );
  });

  testWidgets('an overhead\'s value is edited within its range, persists and '
      'changes the budget', (tester) async {
    await build(tester);
    await tester.tap(inTile('settings.dither', Switch));
    await tester.pump();
    final load = vm.captureBudget.windowLoadMs;
    await tester.tap(find.byTooltip('Settle: more'));
    await tester.pump();
    expect(vm.planningPreferences.ditherSettleSeconds, 20);
    expect(vm.captureBudget.windowLoadMs, greaterThan(load));
    await tester.tap(find.byTooltip('Every: less'));
    await tester.pump();
    expect(vm.planningPreferences.ditherEveryNFrames, 2);
    await tester.runAsync(() async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('ditherSettleSeconds'), 20);
      expect(prefs.getInt('ditherEveryNFrames'), 2);
    });
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byTooltip('Every: less'));
      await tester.pump();
    }
    expect(vm.planningPreferences.ditherEveryNFrames, 1, reason: 'the floor');
  });

  testWidgets('a setting that cannot be saved says so', (tester) async {
    await build(tester, preferences: _Broken());
    await tester.tap(inTile('settings.cloudGate', Switch));
    await tester.pump();
    expect(find.textContaining("Couldn't save the setting"), findsOneWidget);
  });
}
