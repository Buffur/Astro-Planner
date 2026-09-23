import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
import 'package:astroplan/data/services/catalog_seeder.dart';
import 'package:astroplan/domain/models/astro_target.dart' as domain;

void main() {
  late AppDatabase database;
  late DriftTargetRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftTargetRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('can insert and search targets', () async {
    await repository.insertTarget(
      const domain.AstroTarget(
        id: 0,
        catalogId: 'M31',
        commonName: 'Andromeda',
        rightAscension: 10.0,
        declination: 41.0,
        type: 'Galaxy',
      ),
    );

    await repository.insertTarget(
      const domain.AstroTarget(
        id: 0,
        catalogId: 'M42',
        commonName: 'Orion Nebula',
        rightAscension: 83.0,
        declination: -5.0,
        type: 'Nebula',
      ),
    );

    final all = await repository.getAllTargets();
    expect(all.length, 2);

    final orionSearch = await repository.searchTargets('Orion');
    expect(orionSearch.length, 1);
    expect(orionSearch.first.catalogId, 'M42');

    final m31Search = await repository.searchTargets('M31');
    expect(m31Search.length, 1);
    expect(m31Search.first.commonName, 'Andromeda');
  });

  // TASK 8.1
  domain.AstroTarget target(
    String catalogId, {
    String? name,
    String? source,
    double ra = 10.0,
  }) => domain.AstroTarget(
    id: 0,
    catalogId: catalogId,
    commonName: name,
    rightAscension: ra,
    declination: 20.0,
    type: 'Galaxy',
    source: source,
  );

  test('the new fields round-trip; epoch defaults to J2000', () async {
    final id = await repository.insertTarget(
      const domain.AstroTarget(
        id: 0,
        catalogId: 'M42',
        rightAscension: 83.8221,
        declination: -5.3911,
        type: 'Nebula',
        source: 'seed:catalog@1',
        angularSizeArcmin: 85,
        magnitude: 4.0,
      ),
    );
    final back = (await repository.getTargetById(id))!;
    expect(back.epoch, 'J2000');
    expect(back.source, 'seed:catalog@1');
    expect(back.angularSizeArcmin, 85);
    expect(back.magnitude, 4.0);
  });

  test('an update never changes the catalog id', () async {
    final id = await repository.insertTarget(target('M42', name: 'Orion'));
    final original = (await repository.getTargetById(id))!;
    await repository.updateTarget(
      domain.AstroTarget(
        id: id,
        catalogId: 'SOMETHING ELSE',
        commonName: 'Renamed',
        rightAscension: original.rightAscension,
        declination: original.declination,
        type: original.type,
      ),
    );
    final back = (await repository.getTargetById(id))!;
    expect(back.catalogId, 'M42');
    expect(back.commonName, 'Renamed');
  });

  test('catalog entries are unique per catalog id', () async {
    await repository.insertTarget(target('M31', source: 'seed:catalog@1'));
    await expectLater(
      repository.insertTarget(target('M31', source: 'catalog:openngc@1')),
      throwsA(anything),
    );
    // A user's own "M31" is allowed next to the catalog one.
    await repository.insertTarget(target('M31', source: 'user'));
    expect(await repository.getAllTargets(), hasLength(2));
  });

  test('search treats % and _ literally', () async {
    await repository.insertTarget(target('NGC 7000', name: 'North America'));
    await repository.insertTarget(target('100%_done', name: 'Odd name'));

    expect(await repository.searchTargets('%'), hasLength(1));
    expect((await repository.searchTargets('%')).single.catalogId, '100%_done');
    expect(await repository.searchTargets('_'), hasLength(1));
    expect(await repository.searchTargets(r'\'), isEmpty);
    expect(await repository.searchTargets(''), hasLength(2));
    expect(DriftTargetRepository.escapeLike(r'a%b_c\d'), r'a\%b\_c\\d');
  });

  test('seeded targets carry seed provenance', () async {
    await CatalogSeeder(repository).seedIfNeeded();
    final all = await repository.getAllTargets();
    expect(all, isNotEmpty);
    expect(all.every((t) => t.source == 'seed:catalog@1'), isTrue);
    final m42 = all.firstWhere((t) => t.catalogId == 'M42');
    expect(m42.rightAscension, closeTo(83.8221, 1e-4));
    expect(m42.declination, closeTo(-5.3911, 1e-4));
  });
}
