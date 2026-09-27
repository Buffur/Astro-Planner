// S5.5 (ADR-019 §7): a collapsible section's open or closed state is
// remembered per key across a restart; keys are independent; a broken
// store costs only the memory, logged.

import 'package:astroplan/core/diagnostics/app_log.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';
import 'package:astroplan/data/repositories/shared_prefs_display_preferences_repository.dart';
import 'package:astroplan/presentation/viewmodels/disclosure_viewmodel.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_location_service.dart';
import '../../support/in_memory_display_preferences.dart';
import '../../support/no_snapshot_weather.dart';
import '../../support/planner_harness.dart';

class _NoForecast with NoSnapshotWeather implements WeatherRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(AppLog.clear);

  // S5V-01 (S5.5's acceptance): a restart through the app's composed
  // ViewModel graph, as main.dart builds and loads it, keeps the state.
  test('a restart of the whole ViewModel graph on the same store keeps a '
      'section open', () async {
    SharedPreferences.setMockInitialValues({});
    final store = InMemoryDisplayPreferences();
    Future<PlannerHarness> start(AppDatabase db) async {
      final graph = PlannerHarness(
        DriftTargetRepository(db),
        DriftEquipmentRepository(db),
        _NoForecast(),
        DriftLocationRepository(db),
        locationService: FakeLocationService(),
        displayPreferences: store,
      );
      await graph.ready;
      await graph.disclosure.load(); // as main.dart does before runApp
      return graph;
    }

    final db1 = AppDatabase(NativeDatabase.memory());
    final before = await start(db1);
    await before.disclosure.setOpen('planner.budgetDetails', true);
    await db1.close();

    final db2 = AppDatabase(NativeDatabase.memory());
    final after = await start(db2); // a new app start
    addTearDown(db2.close);
    expect(identical(after.disclosure, before.disclosure), isFalse);
    expect(after.disclosure.isOpen('planner.budgetDetails'), isTrue);
    expect(after.disclosure.isOpen('planner.assumptions'), isFalse);
  });

  test('closed by default, or as the caller says until the user '
      'chooses', () async {
    final vm = DisclosureViewModel(InMemoryDisplayPreferences());
    await vm.load();
    expect(vm.isOpen('a'), isFalse);
    expect(vm.isOpen('a', initiallyOpen: true), isTrue);
    await vm.setOpen('a', false);
    expect(vm.isOpen('a', initiallyOpen: true), isFalse);
  });

  test('a choice is saved and restored after a restart; keys are '
      'independent', () async {
    final store = InMemoryDisplayPreferences();
    final before = DisclosureViewModel(store);
    await before.load();
    await before.setOpen('planner.budget', true);
    await before.setOpen('planner.assumptions', false);

    final after = DisclosureViewModel(store); // a new app start
    await after.load();
    expect(after.isOpen('planner.budget'), isTrue);
    expect(after.isOpen('planner.assumptions', initiallyOpen: true), isFalse);
    expect(after.isOpen('weather.variables'), isFalse);
  });

  test('an unreadable store remembers nothing and is logged', () async {
    final store = InMemoryDisplayPreferences(sections: {'a': true})
      ..failSections = true;
    final vm = DisclosureViewModel(store);
    await vm.load();
    expect(vm.isOpen('a'), isFalse);
    expect(AppLog.recent.single.message, 'Section states unreadable');
  });

  test('an unwritable store still opens the section, and is logged', () async {
    final store = InMemoryDisplayPreferences()..failSections = true;
    final vm = DisclosureViewModel(store);
    var notified = 0;
    vm.addListener(() => notified++);
    await vm.setOpen('a', true);
    expect(vm.isOpen('a'), isTrue);
    expect(notified, 1);
    expect(AppLog.recent.single.message, 'Section state not saved: a');
  });

  test('the SharedPreferences store keeps each section under its own key '
      'and ignores other preferences', () async {
    SharedPreferences.setMockInitialValues({'fieldMode': true});
    final repo = SharedPrefsDisplayPreferencesRepository();
    await repo.saveSectionState('planner.budget', true);
    await repo.saveSectionState('weather.variables', false);
    expect(await repo.loadSectionStates(), {
      'planner.budget': true,
      'weather.variables': false,
    });
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('section.planner.budget'), isTrue);
  });
}
