import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/data/database/app_database.dart';
import 'package:astroplan/data/repositories/drift_equipment_repository.dart';
import 'package:astroplan/domain/models/equipment_profile.dart' as domain;
import 'package:astroplan/domain/models/tracking_type.dart';

void main() {
  late AppDatabase database;
  late DriftEquipmentRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriftEquipmentRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('can insert and retrieve equipment profiles', () async {
    await repository.insertEquipment(
      const domain.EquipmentProfile(
        id: 0,
        name: 'Pixel 8 Pro (Main)',
        sensorWidthMm: 9.6,
        sensorHeightMm: 7.2,
        pixelPitchUm: 1.2,
        resolutionWidthPx: 8160,
        resolutionHeightPx: 6144,
        focalLengthMm: 6.9,
        focalRatio: 1.68,
      ),
    );

    final all = await repository.getAllEquipment();
    expect(all.length, 1);
    expect(all.first.name, 'Pixel 8 Pro (Main)');
    expect(all.first.focalLengthMm, 6.9);
  });

  // TASK 8.4 (ADR-011): the new fields map to the existing and new columns.
  test('diameter, tracking type and maximum exposure round-trip', () async {
    const profile = domain.EquipmentProfile(
      id: 0,
      name: 'Refractor',
      sensorWidthMm: 23.5,
      sensorHeightMm: 15.7,
      pixelPitchUm: 3.76,
      resolutionWidthPx: 6248,
      resolutionHeightPx: 4176,
      focalLengthMm: 400,
      focalRatio: 400 / 72,
      apertureDiameterMm: 72,
      rotationDeg: 90,
      trackingType: TrackingType.guided,
      maxExposureS: 300,
    );
    final id = await repository.insertEquipment(profile);
    final back = (await repository.getEquipmentById(id))!;
    expect(back.focalRatio, closeTo(5.5556, 1e-4));
    expect(back.apertureDiameterMm, 72);
    expect(back.trackingType, TrackingType.guided);
    expect(back.maxExposureS, 300);
    expect(back.rotationDeg, 90);

    final rig = await database.select(database.opticalRigs).getSingle();
    expect(rig.aperture, closeTo(5.5556, 1e-4), reason: 'N in `aperture`');
    expect(rig.trackingState, 'guided');

    await repository.updateEquipment(
      domain.EquipmentProfile(
        id: id,
        name: 'Refractor',
        sensorWidthMm: 23.5,
        sensorHeightMm: 15.7,
        pixelPitchUm: 3.76,
        resolutionWidthPx: 6248,
        resolutionHeightPx: 4176,
        focalLengthMm: 400,
        focalRatio: 5.6,
        trackingType: TrackingType.untracked,
      ),
    );
    final updated = (await repository.getEquipmentById(id))!;
    expect(updated.focalRatio, 5.6);
    expect(updated.apertureDiameterMm, isNull);
    expect(updated.maxExposureS, isNull);
    expect(updated.trackingType, TrackingType.untracked);
  });

  test('a new profile without a tracking type is unknown', () async {
    final id = await repository.insertEquipment(
      const domain.EquipmentProfile(
        id: 0,
        name: 'Phone',
        sensorWidthMm: 9.8,
        sensorHeightMm: 7.3,
        pixelPitchUm: 1.22,
        resolutionWidthPx: 8064,
        resolutionHeightPx: 6048,
        focalLengthMm: 6.86,
        focalRatio: 1.78,
      ),
    );
    expect(
      (await repository.getEquipmentById(id))!.trackingType,
      TrackingType.unknown,
    );
  });
}
