// TASK 8.2: the curated OpenNGC catalog — parsing, spot checks against the
// source, versioned idempotent seeding that never resurrects deletions, and
// the one-time upgrade of untouched pre-8.2 seed rows.

import 'dart:convert';
import 'dart:io';

import 'package:astroplan/core/utils/astro_math.dart';
import 'package:astroplan/data/database/app_database.dart' hide AstroTarget;
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/target_types.dart';
import 'package:astroplan/domain/repositories/storage_failure.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final assetJson = File(CatalogSeeder.assetPath).readAsStringSync();
  final catalog = TargetCatalog.parse(assetJson);
  CatalogEntry entry(String id) =>
      catalog.entries.firstWhere((e) => e.id == id);

  group('the asset', () {
    test('164 objects: 109 Messier (M102 is an OpenNGC duplicate) and 55 '
        'showpieces; J2000, sourced, unique ids', () {
      expect(catalog.version, 2);
      expect(catalog.source, 'catalog:openngc@v20260501');
      expect(catalog.entries, hasLength(164));
      final messier = catalog.entries.where(
        (e) => RegExp(r'^M\d+$').hasMatch(e.id),
      );
      expect(messier, hasLength(109));
      expect(catalog.entries.any((e) => e.id == 'M102'), isFalse);
      expect(catalog.entries.map((e) => e.id).toSet(), hasLength(164));
      expect(catalog.entries.every((e) => e.since == 2), isTrue);
    });

    test('every object has a size except the two OpenNGC has none for', () {
      final noSize = catalog.entries
          .where((e) => e.sizeArcmin == null)
          .map((e) => e.id);
      expect(noSize, unorderedEquals(['M40', 'M73']));
    });

    test('types are fixed-coordinate app types only', () {
      final allowed = TargetTypes.selectable.toSet();
      for (final e in catalog.entries) {
        expect(allowed, contains(e.type), reason: e.id);
      }
    });

    test('stored degrees are the source text, parsed (every object)', () {
      for (final e in catalog.entries) {
        expect(
          e.rightAscension,
          closeTo(AstroMath.parseRightAscension(e.openNgcRa)!, 1e-6),
          reason: e.id,
        );
        expect(
          e.declination,
          closeTo(AstroMath.parseDeclination(e.openNgcDec)!, 1e-6),
          reason: e.id,
        );
      }
    });

    // Independent spot checks (SIMBAD J2000 positions, rounded; tolerance
    // 0.02° covers catalogue-to-catalogue differences for extended objects).
    test('spot checks against independent positions', () {
      final reference = {
        'M31': (10.6847, 41.2689),
        'M1': (83.6331, 22.0145),
        'M42': (83.8221, -5.3911),
        'M13': (250.4235, 36.4613),
        'M51': (202.4696, 47.1952),
        'NGC 5139': (201.6970, -47.4795),
        'NGC 7293': (337.4108, -20.8372),
      };
      reference.forEach((id, pos) {
        final e = entry(id);
        expect(e.rightAscension, closeTo(pos.$1, 0.02), reason: '$id RA');
        expect(e.declination, closeTo(pos.$2, 0.02), reason: '$id Dec');
      });
      expect(entry('M31').name, 'Andromeda Galaxy');
      expect(entry('M31').openNgcName, 'NGC0224');
      expect(entry('M45').openNgcName, 'Mel022');
      expect(entry('NGC 7000').name, 'North America Nebula');
    });

    test('the notice credits OpenNGC and its licence', () {
      final notice = File('assets/catalog/OPENNGC_NOTICE.txt')
          .readAsStringSync();
      expect(notice, contains('Mattia Verga'));
      expect(notice, contains('CC BY-SA 4.0'));
      expect(notice, contains('https://github.com/mattiaverga/OpenNGC'));
      expect(jsonDecode(assetJson)['licence'], contains('CC BY-SA 4.0'));
    });
  });

  group('seeding', () {
    late AppDatabase database;
    late DriftTargetRepository repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      repository = DriftTargetRepository(database);
    });

    tearDown(() => database.close());

    CatalogSeeder seeder({String? json}) =>
        CatalogSeeder(repository, loadAsset: () async => json ?? assetJson);

    Future<int?> storedVersion() async =>
        (await SharedPreferences.getInstance()).getInt(
          CatalogSeeder.versionKey,
        );

    test(
      'a fresh install gets the whole catalog, and it is idempotent',
      () async {
        SharedPreferences.setMockInitialValues({});
        await seeder().seedIfNeeded();
        expect(await repository.getAllTargets(), hasLength(164));
        expect(await storedVersion(), 2);

        await seeder().seedIfNeeded();
        expect(await repository.getAllTargets(), hasLength(164));
      },
    );

    test('deleted targets are never resurrected, even all of them', () async {
      SharedPreferences.setMockInitialValues({});
      await seeder().seedIfNeeded();
      final all = await repository.getAllTargets();
      final m31 = all.firstWhere((t) => t.catalogId == 'M31');
      await repository.deleteTarget(m31.id);
      await seeder().seedIfNeeded();
      expect(
        (await repository.getAllTargets()).any((t) => t.catalogId == 'M31'),
        isFalse,
      );

      for (final t in await repository.getAllTargets()) {
        await repository.deleteTarget(t.id);
      }
      await seeder().seedIfNeeded();
      expect(await repository.getAllTargets(), isEmpty);
    });

    test('a newer catalog adds only what it introduced', () async {
      SharedPreferences.setMockInitialValues({CatalogSeeder.versionKey: 2});
      final data = jsonDecode(assetJson) as Map<String, dynamic>;
      data['version'] = 3;
      (data['objects'] as List).add({
        ...(data['objects'] as List).first as Map<String, dynamic>,
        'id': 'NEW 1',
        'since': 3,
      });
      await seeder(json: jsonEncode(data)).seedIfNeeded();

      final all = await repository.getAllTargets();
      expect(all.map((t) => t.catalogId), ['NEW 1']);
      expect(await storedVersion(), 3);
    });

    test('upgrade from a pre-8.2 install: untouched old seeds are updated in '
        'place, edited rows are left alone', () async {
      SharedPreferences.setMockInitialValues({});
      // The five old seeds, as the old seeder wrote them (legacy: no source)…
      final ids = <String, int>{};
      for (final s in CatalogSeeder.legacySeeds) {
        ids[s.catalogId] = await repository.insertTarget(s);
      }
      // …except that the user had moved M31 (the TASK 8.1 editor would have
      // made its source "user").
      final m31 = (await repository.getTargetById(ids['M31']!))!;
      await repository.updateTarget(
        AstroTarget(
          id: m31.id,
          catalogId: 'M31',
          commonName: 'My M31',
          rightAscension: 10.7,
          declination: m31.declination,
          type: 'Galaxy',
          source: 'user',
        ),
      );
      final custom = await repository.insertTarget(
        const AstroTarget(
          id: 0,
          catalogId: 'Backyard blob',
          rightAscension: 1,
          declination: 2,
          type: 'Other',
          source: 'user',
        ),
      );

      await seeder().seedIfNeeded();

      final m42 = (await repository.getTargetById(ids['M42']!))!;
      expect(m42.source, 'catalog:openngc@v20260501', reason: 'same row id');
      expect(m42.rightAscension, entry('M42').rightAscension);
      expect(m42.angularSizeArcmin, 90);

      final myM31 = (await repository.getTargetById(ids['M31']!))!;
      expect(myM31.commonName, 'My M31');
      expect(myM31.rightAscension, 10.7);
      expect(myM31.source, 'user');

      final all = await repository.getAllTargets();
      expect(all.where((t) => t.catalogId == 'M31'), hasLength(2));
      expect(all.where((t) => t.catalogId == 'M42'), hasLength(1));
      expect(
        (await repository.getTargetById(custom))!.catalogId,
        'Backyard blob',
      );
      // 164 catalog objects + the user's M31 + the custom target.
      expect(all, hasLength(166));
      expect(await storedVersion(), 2);
    });

    // S1.2 (ENG-02, RT-02): failed inserts are not recorded as applied.
    group('failed inserts', () {
      test('every insert failing stores no version, and the next launch '
          'seeds everything', () async {
        SharedPreferences.setMockInitialValues({});
        final failing = _FailingTargets(database, (_) => true);
        await CatalogSeeder(
          failing,
          loadAsset: () async => assetJson,
        ).seedIfNeeded();
        expect(failing.attempts, 164);
        expect(await storedVersion(), isNull);
        expect(await repository.getAllTargets(), isEmpty);

        await seeder().seedIfNeeded();
        expect(await repository.getAllTargets(), hasLength(164));
        expect(await storedVersion(), 2);
      });

      test(
        'a partial failure is retried without duplicating what went in',
        () async {
          SharedPreferences.setMockInitialValues({});
          final failing = _FailingTargets(database, (id) => id == 'M31');
          await CatalogSeeder(
            failing,
            loadAsset: () async => assetJson,
          ).seedIfNeeded();
          expect(await repository.getAllTargets(), hasLength(163));
          expect(await storedVersion(), isNull);

          final retry = _FailingTargets(database, (_) => false);
          await CatalogSeeder(
            retry,
            loadAsset: () async => assetJson,
          ).seedIfNeeded();
          expect(retry.attempts, 1, reason: 'only the missing M31');
          final all = await repository.getAllTargets();
          expect(all, hasLength(164));
          expect(all.where((t) => t.catalogId == 'M31'), hasLength(1));
          expect(await storedVersion(), 2);
        },
      );

      test('a failed upgrade keeps the old version and is retried', () async {
        SharedPreferences.setMockInitialValues({CatalogSeeder.versionKey: 2});
        final data = jsonDecode(assetJson) as Map<String, dynamic>;
        data['version'] = 3;
        (data['objects'] as List).add({
          ...(data['objects'] as List).first as Map<String, dynamic>,
          'id': 'NEW 1',
          'since': 3,
        });
        final json = jsonEncode(data);
        await CatalogSeeder(
          _FailingTargets(database, (_) => true),
          loadAsset: () async => json,
        ).seedIfNeeded();
        expect(await storedVersion(), 2);

        await seeder(json: json).seedIfNeeded();
        expect((await repository.getAllTargets()).map((t) => t.catalogId), [
          'NEW 1',
        ]);
        expect(await storedVersion(), 3);
      });
    });

    test('without preferences, a non-empty table is left alone', () async {
      await repository.insertTarget(CatalogSeeder.legacySeeds.first);
      await CatalogSeeder(
        repository,
        loadAsset: () async => assetJson,
        preferences: () => Future.error(StateError('no prefs')),
      ).seedIfNeeded();
      expect(await repository.getAllTargets(), hasLength(1));
    });
  });
}

/// A real repository whose inserts fail with a [StorageFailure] (as a full
/// disk would) for the catalog ids [fails] selects.
class _FailingTargets extends DriftTargetRepository {
  _FailingTargets(super.db, this.fails);

  final bool Function(String catalogId) fails;
  int attempts = 0;

  @override
  Future<int> insertTarget(AstroTarget target) {
    attempts++;
    if (fails(target.catalogId)) {
      throw const StorageFailure('save a target', 'SQLITE_FULL');
    }
    return super.insertTarget(target);
  }
}
