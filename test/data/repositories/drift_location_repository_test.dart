import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/domain/models/location_profile.dart' as domain;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late DriftLocationRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftLocationRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('stores and updates saved locations through Drift', () async {
    final id = await repository.insertLocation(
      const domain.LocationProfile(
        id: 0,
        name: 'Dark Site',
        latitude: 50.12,
        longitude: 30.45,
        elevation: 180,
      ),
    );

    final inserted = await repository.getLocationById(id);
    expect(inserted?.name, 'Dark Site');

    await repository.updateLocation(
      domain.LocationProfile(
        id: id,
        name: 'Updated Dark Site',
        latitude: 50.12,
        longitude: 30.45,
        elevation: 181,
      ),
    );

    final updated = await repository.getLocationById(id);
    expect(updated?.name, 'Updated Dark Site');
    expect(updated?.elevation, 181);
  });
}
