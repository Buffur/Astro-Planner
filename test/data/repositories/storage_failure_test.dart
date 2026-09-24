// TASK 15.1: a failure-path test per repository. A store that cannot be
// read or written surfaces as a typed, logged StorageFailure — never as a
// raw database/preferences error, and never silently. The weather
// repository's failures are typed results (test/data/services/
// open_meteo_forecast_test.dart).

import 'package:astroplan/core/diagnostics/app_log.dart';
import 'package:astroplan/core/time/clock.dart';
import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/data/repositories/drift_session_repository.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/repositories/shared_prefs_display_preferences_repository.dart';
import 'package:astroplan/data/repositories/shared_prefs_first_run_repository.dart';
import 'package:astroplan/data/repositories/shared_prefs_planner_state_repository.dart';
import 'package:astroplan/data/repositories/shared_prefs_planning_preferences_repository.dart';
import 'package:astroplan/data/repositories/shared_prefs_weather_snapshot_store.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
import 'package:astroplan/domain/models/capture_block.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:astroplan/domain/models/session.dart';
import 'package:astroplan/domain/repositories/storage_failure.dart';
import 'package:drift/drift.dart'
    show QueryInterceptor, QueryExecutor, ApplyInterceptor;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Makes database statements fail on demand (after the schema is created).
class _FailingInterceptor extends QueryInterceptor {
  bool failReads = false;
  bool failWrites = false;

  Never _fail() => throw Exception('simulated disk I/O error');

  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) => failReads ? _fail() : executor.runSelect(statement, args);

  @override
  Future<int> runInsert(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) => failWrites ? _fail() : executor.runInsert(statement, args);

  @override
  Future<int> runUpdate(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) => failWrites ? _fail() : executor.runUpdate(statement, args);
}

final Matcher _storageFailure = throwsA(isA<StorageFailure>());

SessionPlan _plan() => SessionPlan(
  eveningDate: CalendarDate(2026, 9, 24),
  timeZoneId: 'Europe/Ljubljana',
  siteId: null,
  targetId: null,
  rigId: null,
  blocks: [
    CaptureBlock(
      id: 0,
      frameType: FrameType.light,
      exposureTimeSeconds: 300,
      frameCount: 10,
    ),
  ],
  targetLabel: 'M31',
  rigLabel: 'Rig',
);

void main() {
  setUp(AppLog.clear);

  group('Drift repositories', () {
    late _FailingInterceptor failing;
    late AppDatabase db;

    setUp(() async {
      failing = _FailingInterceptor();
      db = AppDatabase(NativeDatabase.memory().interceptWith(failing));
      await db.customSelect('SELECT 1').get(); // create the schema first
    });

    tearDown(() => db.close());

    test('equipment: an unreadable database is a StorageFailure', () async {
      failing.failReads = true;
      await expectLater(
        DriftEquipmentRepository(db).getAllEquipment(),
        _storageFailure,
      );
      expect(AppLog.recent.last.level, LogLevel.error);
      expect(AppLog.recent.last.scope, 'storage');
    });

    test('locations: a failed write is a StorageFailure', () async {
      failing.failWrites = true;
      await expectLater(
        DriftLocationRepository(db).insertLocation(
          domain.LocationProfile(
            id: 0,
            name: 'Dark Site',
            latitude: 46,
            longitude: 14,
            elevation: 300,
          ),
        ),
        _storageFailure,
      );
    });

    test('targets: an unreadable database is a StorageFailure', () async {
      failing.failReads = true;
      await expectLater(
        DriftTargetRepository(db).searchTargets('M31'),
        _storageFailure,
      );
    });

    test('sessions: a failed write is a StorageFailure and is rolled '
        'back', () async {
      final repo = DriftSessionRepository(
        db,
        clock: FixedClock(DateTime.utc(2026, 9, 24, 18)),
      );
      failing.failWrites = true;
      await expectLater(repo.create(_plan()), _storageFailure);
      failing.failWrites = false;
      expect(await repo.list(), isEmpty);
    });

    test('sessions: a lifecycle refusal is not a storage failure', () async {
      final repo = DriftSessionRepository(
        db,
        clock: FixedClock(DateTime.utc(2026, 9, 24, 18)),
      );
      final draft = await repo.create(_plan());
      await expectLater(
        repo.complete(draft.id),
        throwsA(isA<SessionStateError>()),
      );
    });
  });

  group('SharedPreferences repositories: an unreadable value', () {
    test('display preferences', () async {
      SharedPreferences.setMockInitialValues({'fieldMode': 'yes'});
      await expectLater(
        SharedPrefsDisplayPreferencesRepository().loadFieldMode(),
        _storageFailure,
      );
      expect(AppLog.recent.single.scope, 'storage');
    });

    test('first run', () async {
      SharedPreferences.setMockInitialValues({'firstRunDone': 'yes'});
      await expectLater(
        SharedPrefsFirstRunRepository().isDone(),
        _storageFailure,
      );
    });

    test('planning preferences', () async {
      SharedPreferences.setMockInitialValues({'minAltitude': 'high'});
      await expectLater(
        SharedPrefsPlanningPreferencesRepository().load(),
        _storageFailure,
      );
    });

    test('planner state', () async {
      SharedPreferences.setMockInitialValues({'targetId': 'M31'});
      await expectLater(
        SharedPrefsPlannerStateRepository().getSelectedTargetId(),
        _storageFailure,
      );
    });

    test('weather cache: an unreadable store fails; an unreadable entry is '
        'absent and logged', () async {
      SharedPreferences.setMockInitialValues({'a': 5, 'b': 'not json'});
      final store = SharedPrefsWeatherSnapshotStore();
      await expectLater(store.read('a'), _storageFailure);
      AppLog.clear();
      expect(await store.read('b'), isNull);
      expect(AppLog.recent.single.level, LogLevel.warning);
    });
  });
}
