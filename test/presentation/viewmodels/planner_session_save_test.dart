// TASK 11.3: the planner saves through SessionRepository — a planned
// session with a plan snapshot; saving again updates it; a frozen session is
// never modified; opening a session follows its references by id.

import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/repositories/weather_repository.dart';

import '../../support/planner_harness.dart';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_device_time_zone.dart';
import '../../support/fake_location_service.dart';
import '../../support/fake_reverse_geocoder.dart';
import '../../support/no_snapshot_weather.dart';

class _NoWeather with NoSnapshotWeather implements WeatherRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DriftSessionRepository sessions;
  late DriftTargetRepository targets;
  late DriftEquipmentRepository equipment;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    targets = DriftTargetRepository(db);
    equipment = DriftEquipmentRepository(db);
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
    sessions = DriftSessionRepository(
      db,
      clock: FixedClock(DateTime.utc(2026, 11, 10, 18)),
    );
  });

  tearDown(() => db.close());

  Future<PlannerHarness> build() async {
    final vm = PlannerHarness(
      targets,
      equipment,
      _NoWeather(),
      DriftLocationRepository(db),
      locationService: FakeLocationService(),
      reverseGeocoder: FakeReverseGeocoder(),
      deviceTimeZone: FakeDeviceTimeZone(),
      clock: FixedClock(DateTime.utc(2026, 11, 10, 18)),
      sessionRepository: sessions,
    );
    await vm.ready;
    await vm.choosePlan(); // S6.8: nothing is preselected
    return vm;
  }

  test('save creates a planned session with references and a snapshot; '
      'saving again updates the same one', () async {
    final vm = await build();
    final first = await vm.saveSession();
    expect(first.status, SessionStatus.planned);
    expect(first.eveningDate, vm.eveningDate);
    expect(first.timeZoneId, 'Europe/Ljubljana');
    expect(first.targetId, vm.selectedTarget!.id);
    expect(first.rigId, vm.selectedEquipment!.id);
    expect(first.siteId, vm.activeSite!.id);
    final snap = first.planSnapshot!;
    expect(snap.rigName, vm.selectedEquipment!.name);
    expect(snap.siteName, 'Ljubljana');
    expect(snap.json['opportunity'], isNotNull);

    final second = await vm.saveSession();
    expect(second.id, first.id);
    expect(await sessions.list(), hasLength(1));
  });

  test('a frozen session is never modified: saving after opening it creates '
      'a new one', () async {
    final vm = await build();
    final saved = await vm.saveSession();
    await sessions.start(saved.id, saved.planSnapshot!);
    await sessions.complete(saved.id);

    // TASK 11.4 (owner): a frozen session opens as a copy in a new draft.
    await vm.openSession((await sessions.get(saved.id))!);
    expect(vm.activeSessionId, isNot(saved.id));
    final again = await vm.saveSession();
    expect(again.id, isNot(saved.id));
    expect((await sessions.get(saved.id))!.status, SessionStatus.completed);
  });

  test('opening a session follows its references by id', () async {
    final vm = await build();
    final saved = await vm.saveSession();
    final all = await targets.getAllTargets();
    final other = all.firstWhere((t) => t.id != vm.selectedTarget!.id);
    // TASK 11.4: edits autosave into the current session, so start a new
    // draft before changing the target.
    await vm.newSession();
    await vm.setTarget(other);

    await vm.openSession((await sessions.get(saved.id))!);
    expect(vm.selectedTarget!.id, saved.targetId);
    expect(vm.eveningDate, saved.eveningDate);
    expect(vm.activeSessionId, saved.id);
  });
}
