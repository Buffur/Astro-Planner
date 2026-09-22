import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_logbook_repository.dart';
import 'package:astroplan/domain/models/capture_block.dart' as domain;
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

  // TASK 5.3: block order, calibration policy and typed gain are persisted.
  test(
    'blocks keep their order, policy and gain through save and update',
    () async {
      domain.CaptureBlock block(domain.FrameType t, double exp) =>
          domain.CaptureBlock(
            frameType: t,
            exposureTimeSeconds: exp,
            frameCount: 3,
          );
      final blocks = [
        block(domain.FrameType.flat, 2),
        domain.CaptureBlock(
          frameType: domain.FrameType.light,
          exposureTimeSeconds: 300,
          frameCount: 20,
          gain: domain.CaptureGain.gain(120),
        ),
        domain.CaptureBlock(
          frameType: domain.FrameType.dark,
          exposureTimeSeconds: 300,
          frameCount: 10,
          calibrationPolicy: domain.CalibrationPolicy.inWindow,
        ),
      ];
      final id = await repository.addLog(
        domain.SessionLog(
          id: 0,
          targetName: 'M31',
          equipmentName: 'Rig',
          sessionDate: DateTime.utc(2026, 1, 1),
          captureBlocks: blocks,
        ),
      );

      var saved = (await repository.getAllLogs()).single.captureBlocks;
      expect(saved.map((b) => b.frameType), [
        domain.FrameType.flat,
        domain.FrameType.light,
        domain.FrameType.dark,
      ]);
      expect(saved[1].gain, domain.CaptureGain.gain(120));
      expect(saved[2].calibrationPolicy, domain.CalibrationPolicy.inWindow);
      expect(
        saved[0].calibrationPolicy,
        domain.CalibrationPolicy.outsideWindow,
      );

      // Reorder (dark first) and update: the new order is what comes back.
      final log = (await repository.getAllLogs()).single;
      await repository.updateLog(
        log.copyWith(captureBlocks: [saved[2], saved[0], saved[1]]),
      );
      saved = (await repository.getAllLogs()).single.captureBlocks;
      expect(saved.map((b) => b.frameType), [
        domain.FrameType.dark,
        domain.FrameType.flat,
        domain.FrameType.light,
      ]);
      expect(id, isPositive);
    },
  );

  test(
    'a stored row the domain rejects is skipped, not read as a light',
    () async {
      final id = await repository.addLog(
        domain.SessionLog(
          id: 0,
          targetName: 'M31',
          equipmentName: 'Rig',
          sessionDate: DateTime.utc(2026, 1, 1),
        ),
      );
      await database.customStatement(
        "INSERT INTO capture_blocks (session_log_id, frame_type, "
        "exposure_time_seconds, frame_count) VALUES ($id, 'mystery', 60, 5), "
        "($id, 'dark', 60, 0), ($id, 'dark', 60, 5);",
      );
      final blocks = (await repository.getAllLogs()).single.captureBlocks;
      expect(blocks, hasLength(1));
      expect(blocks.single.frameType, domain.FrameType.dark);
      expect(blocks.single.frameCount, 5);
    },
  );
}
