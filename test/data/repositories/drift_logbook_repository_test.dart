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
}
