import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/repositories/light_pollution_repository.dart';
import 'package:astroplan/domain/models/planning_preferences.dart';
import 'package:astroplan/domain/models/weather_conditions.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/presentation/screens/settings/settings_screen.dart';
import 'package:astroplan/presentation/viewmodels/planner_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/fake_location_service.dart';

class _NoWeather implements WeatherRepository {
  @override
  Future<WeatherConditions?> getCurrentWeather(
    double lat,
    double lon, {
    bool forceRefresh = false,
  }) async => null;
}

void main() {
  late AppDatabase database;
  late PlannerViewModel vm;

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: vm,
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
      vm = PlannerViewModel(
        DriftTargetRepository(database),
        DriftEquipmentRepository(database),
        _NoWeather(),
        DriftLocationRepository(database),
        LightPollutionRepository(),
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
    await tester.tap(find.text('-12°'));
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
