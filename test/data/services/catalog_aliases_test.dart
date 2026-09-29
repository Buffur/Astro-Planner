// S7.4 (RG-07 = T1): the bundled catalog's aliases, end to end — the
// asset written by tool/build_catalog.dart, seeded into SQLite, searched
// offline through the repository. RG-07 §6's examples as tests; the aliases
// are rebuilt when the catalog version rises, change no row (a user's edit
// stays), and are never shown for a deleted target.

import 'dart:convert';
import 'dart:io';

import 'package:astroplan/data/database/app_database.dart' show AppDatabase;
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/domain/models/astro_target.dart';
import 'package:astroplan/domain/models/target_alias.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

AstroTarget _with(
  AstroTarget t, {
  int? id,
  String? catalogId,
  String? name,
  String? source,
}) => AstroTarget(
  id: id ?? t.id,
  catalogId: catalogId ?? t.catalogId,
  commonName: name ?? t.commonName,
  rightAscension: t.rightAscension,
  declination: t.declination,
  type: t.type,
  source: source ?? t.source,
  angularSizeArcmin: t.angularSizeArcmin,
  magnitude: t.magnitude,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final assetJson = File(CatalogSeeder.assetPath).readAsStringSync();
  final catalog = TargetCatalog.parse(assetJson);

  group('the asset (catalog version 3)', () {
    test('adds aliases and no object; every object keeps its version', () {
      expect(catalog.version, 3);
      expect(catalog.entries, hasLength(164));
      expect(catalog.entries.every((e) => e.since == 2), isTrue);
    });

    test('the decided aliases, from OpenNGC only', () {
      CatalogEntry e(String id) =>
          catalog.entries.firstWhere((x) => x.id == id);
      expect(e('M31').aliasIds, ['NGC 224']);
      expect(e('M8').aliasIds, containsAll(['NGC 6523', 'LBN 25']));
      expect(e('NGC 7000').aliasIds, ['C 20', 'LBN 373']);
      expect(e('M45').aliasIds, isEmpty, reason: 'Mel 22: not NGC/IC');
      // Every OpenNGC common name, the first one included.
      expect(e('M17').aliasNames, contains('Swan Nebula'));
      expect(e('M44').aliasNames, ['Beehive', 'Praesepe Cluster']);
      expect(
        catalog.entries.where((x) => x.aliasNames.length > 1),
        hasLength(16),
      );
    });

    test('no alias is another object\'s id, and none repeats the own id', () {
      final ids = {for (final x in catalog.entries) x.id};
      for (final x in catalog.entries) {
        for (final a in x.aliasIds) {
          expect(ids.contains(a), isFalse, reason: '$a on ${x.id}');
        }
      }
    });
  });

  group('search (real SQLite, offline)', () {
    late AppDatabase db;
    late DriftTargetRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase(NativeDatabase.memory());
      repo = DriftTargetRepository(db);
      await CatalogSeeder(
        repo,
        loadAsset: () async => assetJson,
      ).seedIfNeeded();
    });
    tearDown(() => db.close());

    Future<String?> first(String query) async =>
        (await repo.searchTargets(query)).firstOrNull?.catalogId;

    test('RG-07 §6: each typed form finds its object first', () async {
      for (final (typed, id) in [
        ('M31', 'M31'),
        ('M 31', 'M31'),
        ('m31', 'M31'),
        ('Messier 31', 'M31'),
        ('NGC 224', 'M31'),
        ('NGC224', 'M31'),
        ('NGC 0224', 'M31'),
        ('Andromeda', 'M31'),
        ('NGC7000', 'NGC 7000'),
        ('ngc 7000', 'NGC 7000'),
        ('C 20', 'NGC 7000'),
        ('C020', 'NGC 7000'),
        ('Caldwell 20', 'NGC 7000'),
        ('LBN 25', 'M8'),
        ('Swan Nebula', 'M17'),
        ('Praesepe', 'M44'),
      ]) {
        expect(await first(typed), id, reason: typed);
      }
      expect(await repo.searchTargets('Sh2-129'), isEmpty);
    });

    test(
      'ordered by match kind, then the id: "M3" is M3, then M30-M39',
      () async {
        final found = [
          for (final t in await repo.searchTargets('M3')) t.catalogId,
        ];
        expect(found.take(11), [
          'M3', 'M30', 'M31', 'M32', 'M33', 'M34', 'M35', 'M36', 'M37', //
          'M38', 'M39',
        ]);
      },
    );

    test('a deleted target\'s aliases are never shown', () async {
      final m31 = (await repo.searchTargets('M31')).first;
      await repo.deleteTarget(m31.id);
      expect(await repo.searchTargets('NGC 224'), isEmpty);
      expect(await repo.searchTargets('Andromeda'), isEmpty);
    });

    test('aliases change no row: a renamed target keeps the user\'s name and '
        'is still found by its OpenNGC names', () async {
      final m42 = (await repo.searchTargets('M42')).first;
      await repo.updateTarget(_with(m42, name: 'My first target'));
      final found = (await repo.searchTargets('Orion Nebula')).first;
      expect(found.id, m42.id);
      expect(found.commonName, 'My first target');
      expect(found.catalogId, 'M42');
    });

    test('rebuilt when the catalog version rises, and only then; the '
        'targets are untouched', () async {
      expect(await repo.aliasCatalogVersion(), 3);
      final before = await repo.getAllTargets();

      final data = jsonDecode(assetJson) as Map<String, dynamic>;
      data['version'] = 4;
      for (final o in data['objects'] as List) {
        final m = o as Map<String, dynamic>;
        if (m['id'] == 'M31') m['aliasIds'] = ['NGC 224', 'UGC 454'];
      }
      await CatalogSeeder(
        repo,
        loadAsset: () async => jsonEncode(data),
      ).seedIfNeeded();
      expect(await repo.aliasCatalogVersion(), 4);
      expect(await first('UGC 454'), 'M31');
      final after = await repo.getAllTargets();
      expect(
        [for (final t in after) (t.id, t.catalogId, t.commonName)],
        [for (final t in before) (t.id, t.catalogId, t.commonName)],
      );
    });

    test('a database without aliases (restored, or just upgraded) gets them '
        'at the next launch, even with the version already applied', () async {
      await repo.replaceAliases(3, const []);
      await db.delete(db.targetAliases).go();
      expect(await repo.aliasCatalogVersion(), isNull);
      expect(
        (await SharedPreferences.getInstance()).getInt(
          CatalogSeeder.versionKey,
        ),
        3,
      );
      await CatalogSeeder(
        repo,
        loadAsset: () async => assetJson,
      ).seedIfNeeded();
      expect(await first('NGC 224'), 'M31');
    });

    test('custom targets are found by their name as before, and take no '
        'alias', () async {
      final m31 = (await repo.searchTargets('M31')).first;
      await repo.insertTarget(
        _with(m31, id: 0, catalogId: 'Backyard field', source: 'user'),
      );
      expect(await first('backyard'), 'Backyard field');
      expect(
        [for (final t in await repo.searchTargets('NGC 224')) t.catalogId],
        ['M31'],
      );
    });

    test('the stored kinds', () async {
      final rows = await db.select(db.targetAliases).get();
      expect(rows.map((r) => r.kind).toSet(), {
        TargetAliasKind.designation.name,
        TargetAliasKind.name.name,
      });
      expect(rows.every((r) => r.catalogVersion == 3), isTrue);
    });
  });
}
