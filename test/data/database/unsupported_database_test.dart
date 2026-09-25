// S1.5 (TASK 3.2 / RT-03 / TD-047; ADR-008 §2): at startup a database this
// build cannot open is detected before anything reads it; a below-floor
// file can be reset (kept as a .bak, never deleted) after the user
// confirms, and a newer one is never reset. Real files on disk, so the
// close-then-rename sequence is exercised as the app runs it.

import 'dart:io';

import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

/// An empty database stamped at [schemaVersion].
class _StampedAtVersion extends GeneratedDatabase {
  _StampedAtVersion(super.e, this.schemaVersion);

  @override
  final int schemaVersion;

  @override
  Iterable<TableInfo> get allTables => const [];

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => const [];
}

Future<void> _stamp(File file, int version) async {
  final db = _StampedAtVersion(NativeDatabase(file), version);
  await db.customStatement('CREATE TABLE marker (note TEXT);');
  await db.customStatement("INSERT INTO marker VALUES ('old data');");
  await db.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('astroplan_s15_');
    file = File(p.join(dir.path, 'astroplan.sqlite'));
  });

  tearDown(() => dir.deleteSync(recursive: true));

  // S1.V1 (TD-059): the app opens its file lazily on a background isolate,
  // where Drift wraps the refusal in a DriftRemoteException. These use that
  // same connection (`openDatabaseConnection`), as `main.dart` does.
  group('through the production connection', () {
    AppDatabase production() =>
        AppDatabase(openDatabaseConnection(() async => file));

    for (final (version, newer) in [(7, false), (18, true)]) {
      test('v$version is refused as ${newer ? 'newer' : 'below the floor'}, '
          'typed, and the file is unchanged', () async {
        await _stamp(file, version);
        final before = file.readAsBytesSync();
        final db = production();
        final refused = await refusedSchemaVersion(db);
        await db.close();
        expect(refused, isNotNull);
        expect(refused!.foundVersion, version);
        expect(refused.isNewerThanApp, newer);
        expect(file.readAsBytesSync(), before);
      });
    }

    test('a current database opens', () async {
      final db = production();
      expect(await refusedSchemaVersion(db), isNull);
      await db.close();
    });

    test('an unrelated open failure is still a failure', () async {
      final notAFile = Directory(p.join(dir.path, 'astroplan.sqlite'))
        ..createSync();
      final db = AppDatabase(
        openDatabaseConnection(() async => File(notAFile.path)),
      );
      await expectLater(
        refusedSchemaVersion(db),
        throwsA(isNot(isA<UnsupportedSchemaVersionException>())),
      );
      await db.close().catchError((Object e) => null);
    });

    test('a below-floor file refused there can be reset', () async {
      await _stamp(file, 7);
      final before = file.readAsBytesSync();
      final db = production();
      final refused = (await refusedSchemaVersion(db))!;
      final backup = await resetRefusedDatabase(db, file, refused);
      expect(backup.readAsBytesSync(), before);
      expect(file.existsSync(), isFalse);
      final fresh = production();
      expect(await refusedSchemaVersion(fresh), isNull);
      await fresh.close();
    });
  });

  test('a current database opens: nothing is refused', () async {
    final db = AppDatabase(NativeDatabase(file));
    expect(await refusedSchemaVersion(db), isNull);
    await db.close();
  });

  test(
    'a newer database is refused, left unchanged, and never reset',
    () async {
      final app = AppDatabase(NativeDatabase.memory());
      final newer = app.schemaVersion + 1;
      await app.close();
      await _stamp(file, newer);
      final before = file.readAsBytesSync();

      final db = AppDatabase(NativeDatabase(file));
      final refused = (await refusedSchemaVersion(db))!;
      expect(refused.isNewerThanApp, isTrue);
      expect(refused.foundVersion, newer);
      await expectLater(
        resetRefusedDatabase(db, file, refused),
        throwsArgumentError,
      );
      expect(file.readAsBytesSync(), before);
      expect(File('${file.path}.v$newer.bak').existsSync(), isFalse);
      await db.close();
    },
  );

  test('a below-floor database is refused and unchanged until the reset; '
      'the reset keeps it as a .bak and a fresh database works', () async {
    await _stamp(file, 7);
    final before = file.readAsBytesSync();

    final db = AppDatabase(NativeDatabase(file));
    final refused = (await refusedSchemaVersion(db))!;
    expect(refused.isNewerThanApp, isFalse);
    expect(refused.foundVersion, 7);
    expect(file.readAsBytesSync(), before, reason: 'untouched until confirmed');

    final backup = await resetRefusedDatabase(db, file, refused);
    expect(backup.path, '${file.path}.v7.bak');
    expect(backup.readAsBytesSync(), before, reason: 'kept, never deleted');
    expect(file.existsSync(), isFalse);

    SharedPreferences.setMockInitialValues({});
    final fresh = AppDatabase(NativeDatabase(file));
    expect(await refusedSchemaVersion(fresh), isNull);
    final targets = DriftTargetRepository(fresh);
    await CatalogSeeder(targets).seedIfNeeded();
    expect(await targets.getAllTargets(), hasLength(164));
    await fresh.close();
  });
}
