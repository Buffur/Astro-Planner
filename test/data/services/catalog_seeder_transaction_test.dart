// S10.5 (ENG-12): the first run's catalog seed is one transaction. Each row
// used to be its own autocommit, one sync to storage per row: 13-15 s
// before the first frame on an emulator (docs/refinement/evidence/
// STAGE_10_MEASUREMENTS.md). The per-row failure handling (S1.2) is
// covered, unchanged, by catalog_seeder_test.dart.

import 'dart:io';

import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:drift/drift.dart'
    show QueryInterceptor, QueryExecutor, TransactionExecutor, ApplyInterceptor;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records, for each insert into the targets table, whether it ran inside a
/// transaction, and counts the transactions begun.
class _Recorder extends QueryInterceptor {
  final List<bool> targetInserts = [];
  int transactions = 0;

  @override
  TransactionExecutor beginTransaction(QueryExecutor parent) {
    transactions++;
    return super.beginTransaction(parent);
  }

  @override
  Future<int> runInsert(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) {
    if (statement.contains('"astro_targets"')) {
      targetInserts.add(executor is TransactionExecutor);
    }
    return executor.runInsert(statement, args);
  }
}

void main() {
  final assetJson = File(CatalogSeeder.assetPath).readAsStringSync();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a new database is seeded in one transaction: every catalog row, '
      'one commit', () async {
    final recorder = _Recorder();
    final db = AppDatabase(NativeDatabase.memory().interceptWith(recorder));
    addTearDown(db.close);
    final repository = DriftTargetRepository(db);
    await repository.getAllTargets(); // opens the schema outside the count
    recorder.transactions = 0;

    await CatalogSeeder(
      repository,
      loadAsset: () async => assetJson,
    ).seedIfNeeded();

    final catalog = TargetCatalog.parse(assetJson);
    expect(recorder.targetInserts, hasLength(catalog.entries.length));
    expect(recorder.targetInserts, everyElement(isTrue));
    // The aliases (S7.4) and the targets: two transactions in all.
    expect(recorder.transactions, 2);
    expect(await repository.getAllTargets(), hasLength(catalog.entries.length));
  });
}
