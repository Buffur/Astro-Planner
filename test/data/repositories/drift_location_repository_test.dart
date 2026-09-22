import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_location_repository.dart';
import 'package:astroplan/domain/models/calendar_date.dart';
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
      domain.LocationProfile(
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

  test(
    'TASK 7.1: sky data with provenance, zone and notes round trip',
    () async {
      final id = await repository.insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Dark Site',
          latitude: 44.1,
          longitude: 7.2,
          elevation: 1850,
          bortleClass: 2,
          bortleSource: 'user',
          bortleDate: CalendarDate(2026, 9, 1),
          sqm: 21.6,
          sqmSource: 'user',
          sqmDate: CalendarDate(2026, 9, 2),
          timeZoneId: 'Europe/Rome',
          notes: 'Gate closes at 22:00',
        ),
      );
      final s = (await repository.getLocationById(id))!;
      expect(s.bortleClass, 2);
      expect(s.bortleSource, 'user');
      expect(s.bortleDate, CalendarDate(2026, 9, 1));
      expect(s.sqm, 21.6);
      expect(s.sqmDate, CalendarDate(2026, 9, 2));
      expect(s.timeZoneId, 'Europe/Rome');
      expect(s.notes, 'Gate closes at 22:00');

      // Unknown stays unknown (SI-008): nothing defaults to 4.
      final plain = await repository.insertLocation(
        domain.LocationProfile(
          id: 0,
          name: 'Unknown sky',
          latitude: 0,
          longitude: 0,
          elevation: 0,
        ),
      );
      final u = (await repository.getLocationById(plain))!;
      expect(u.bortleClass, isNull);
      expect(u.sqm, isNull);
      expect(u.timeZoneId, isNull);
    },
  );

  test('LocationProfile rejects values out of range', () {
    domain.LocationProfile make({
      double lat = 0,
      double lon = 0,
      double elev = 0,
      int? bortle,
      double? sqm,
    }) => domain.LocationProfile(
      id: 0,
      name: 'x',
      latitude: lat,
      longitude: lon,
      elevation: elev,
      bortleClass: bortle,
      sqm: sqm,
    );
    expect(() => make(lat: 91), throwsArgumentError);
    expect(() => make(lon: -181), throwsArgumentError);
    expect(() => make(elev: 10000), throwsArgumentError);
    expect(() => make(bortle: 0), throwsArgumentError);
    expect(() => make(bortle: 10), throwsArgumentError);
    expect(() => make(sqm: 30), throwsArgumentError);
    expect(make(bortle: 9, sqm: 22).bortleClass, 9);
  });
}
