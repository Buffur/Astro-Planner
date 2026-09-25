import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/screens/settings/settings_screen.dart';

import '../../../support/planner_harness.dart';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/no_snapshot_weather.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

void main() {
  late AppDatabase database;
  late PlannerHarness vm;

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 3000);
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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> build(WidgetTester tester) async {
    await tester.runAsync(() async {
      database = AppDatabase(NativeDatabase.memory());
      vm = PlannerHarness(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _NoWeather(),
        DriftLocationRepository(database),
        locationService: FakeLocationService(),
      );
      await vm.ready;
    });
    addTearDown(() => tester.runAsync(database.close));
  }

  testWidgets('shows defaults, and off overheads as "Not included"', (
    tester,
  ) async {
    await build(tester);
    await pump(tester);
    expect(find.text('20°'), findsOneWidget);
    expect(find.text('15 %'), findsOneWidget);
    expect(find.text('5 s'), findsOneWidget);
    expect(find.text('Not included'), findsNWidgets(5));
    expect(find.textContaining('not scientific laws'), findsOneWidget);
  });

  // TASK 16.3: place names are opt-in, and the switch says what is sent.
  testWidgets('the place-name switch turns lookups on', (tester) async {
    await build(tester);
    await tester.runAsync(() => vm.settings.setPlaceNameLookup(false));
    await pump(tester);
    final tile = find.byKey(const Key('settings.placeNames'));
    await tester.ensureVisible(tile);
    expect(find.textContaining('OpenStreetMap Nominatim'), findsOneWidget);
    expect(tester.widget<SwitchListTile>(tile).value, isFalse);
    await tester.tap(tile);
    await tester.pump();
    expect(vm.settings.placeNameLookup, isTrue);
    expect(tester.widget<SwitchListTile>(tile).value, isTrue);
  });

  testWidgets('moving a slider persists its value', (tester) async {
    await build(tester);
    await pump(tester);
    final slider = find.descendant(
      of: find.byKey(const Key('settings.minAltitude')),
      matching: find.byType(Slider),
    );
    // Drag to the far right: the range maximum (60°).
    await tester.drag(slider, const Offset(2000, 0));
    await tester.pump();
    expect(vm.minAltitude, 60.0);
    await tester.runAsync(() async {
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('minAltitude'), 60.0);
    });
  });

  testWidgets('choosing a darkness limit and switching an overhead on', (
    tester,
  ) async {
    await build(tester);
    await pump(tester);
    await tester.tap(find.text('−12°'));
    await tester.pump();
    expect(vm.planningPreferences.darknessLimit, DarknessLimit.nautical);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('settings.dither')),
        matching: find.byType(Switch),
      ),
    );
    await tester.pump();
    expect(vm.planningPreferences.ditherEveryNFrames, 3);
    expect(find.text('Every 3 lights, 15 s each'), findsOneWidget);
  });
}
