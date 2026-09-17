import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_target_repository.dart';
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
    await repository.insertTarget(const domain.AstroTarget(
      id: 0,
      catalogId: 'M31',
      commonName: 'Andromeda',
      rightAscension: 10.0,
      declination: 41.0,
      type: 'Galaxy',
    ));

    await repository.insertTarget(const domain.AstroTarget(
      id: 0,
      catalogId: 'M42',
      commonName: 'Orion Nebula',
      rightAscension: 83.0,
      declination: -5.0,
      type: 'Nebula',
    ));

    final all = await repository.getAllTargets();
    expect(all.length, 2);

    final orionSearch = await repository.searchTargets('Orion');
    expect(orionSearch.length, 1);
    expect(orionSearch.first.catalogId, 'M42');

    final m31Search = await repository.searchTargets('M31');
    expect(m31Search.length, 1);
    expect(m31Search.first.commonName, 'Andromeda');
  });
}
