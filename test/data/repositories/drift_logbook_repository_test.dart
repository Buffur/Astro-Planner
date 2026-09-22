import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_logbook_repository.dart';
import 'package:astroplan/domain/models/session_log.dart' as domain;

void main() {
  late AppDatabase database;
  late DriftLogbookRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftLogbookRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('can insert and retrieve session logs', () async {
    final log = domain.SessionLog(
      id: 0,
      targetName: 'M42',
      equipmentName: 'Pixel 8 Pro',
      sessionDate: DateTime(2026, 1, 1),
      plannedLightFrames: 100,
    );

    await repository.addLog(log);

    final logs = await repository.getAllLogs();
    expect(logs.length, 1);
    expect(logs.first.targetName, 'M42');
    expect(logs.first.plannedLightFrames, 100);
  });

  // TASK 4.2, TD-011: addLog used to return void, so the ViewModel could
  // never learn the new row's id and route a second save to updateLog.
  test('addLog returns the new row id', () async {
    final id = await repository.addLog(
      domain.SessionLog(
        id: 0,
        targetName: 'M42',
        equipmentName: 'Pixel 8 Pro',
        sessionDate: DateTime(2026, 1, 1),
        plannedLightFrames: 100,
      ),
    );
    expect(id, greaterThan(0));

    final logs = await repository.getAllLogs();
    expect(logs.single.id, id);
  });

  // TASK 4.2, TD-039: was unordered (oldest first, raw insertion order).
  test('getAllLogs returns newest-saved first', () async {
    final firstId = await repository.addLog(
      domain.SessionLog(
        id: 0,
        targetName: 'First',
        equipmentName: 'Rig',
        sessionDate: DateTime(2026, 1, 1),
        plannedLightFrames: 10,
      ),
    );
    final secondId = await repository.addLog(
      domain.SessionLog(
        id: 0,
        targetName: 'Second',
        equipmentName: 'Rig',
        sessionDate: DateTime(2026, 1, 2),
        plannedLightFrames: 10,
      ),
    );
    final thirdId = await repository.addLog(
      domain.SessionLog(
        id: 0,
        targetName: 'Third',
        equipmentName: 'Rig',
        sessionDate: DateTime(2026, 1, 3),
        plannedLightFrames: 10,
      ),
    );

    final logs = await repository.getAllLogs();
    expect(logs.map((l) => l.id), [thirdId, secondId, firstId]);
    expect(logs.map((l) => l.targetName), ['Third', 'Second', 'First']);
  });
}
