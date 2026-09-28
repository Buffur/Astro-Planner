// S6.8 (RD-04): the shipped rig is recognised as the example while its
// optics are still the seed's; an edit of the optics makes it the user's
// own, and any other rig is never an example.

import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final seeded = EquipmentSeeder.defaults.single;

  test('the seeded rig is the example', () {
    expect(seeded.isExample, isTrue);
  });

  test(
    'renaming it, or changing only its camera, keeps the example optics',
    () {
      final renamed = EquipmentProfile(
        id: seeded.id,
        name: 'My test rig',
        sensorWidthMm: seeded.sensorWidthMm,
        sensorHeightMm: seeded.sensorHeightMm,
        pixelPitchUm: 4.0,
        resolutionWidthPx: seeded.resolutionWidthPx,
        resolutionHeightPx: seeded.resolutionHeightPx,
        focalLengthMm: seeded.focalLengthMm,
        focalRatio: seeded.focalRatio,
        apertureDiameterMm: seeded.apertureDiameterMm,
      ).withEditProvenance(seeded);
      expect(renamed.isExample, isTrue);
    },
  );

  test('editing its optics makes it the user\'s own rig', () {
    final edited = EquipmentProfile(
      id: seeded.id,
      name: seeded.name,
      sensorWidthMm: seeded.sensorWidthMm,
      sensorHeightMm: seeded.sensorHeightMm,
      pixelPitchUm: seeded.pixelPitchUm,
      resolutionWidthPx: seeded.resolutionWidthPx,
      resolutionHeightPx: seeded.resolutionHeightPx,
      focalLengthMm: 530,
      focalRatio: seeded.focalRatio,
      apertureDiameterMm: seeded.apertureDiameterMm,
    ).withEditProvenance(seeded);
    expect(edited.isExample, isFalse);
  });

  test('a rig of the user\'s, or of unknown origin, is not an example', () {
    const own = EquipmentProfile(
      id: 2,
      name: 'Refractor 400',
      sensorWidthMm: 23.5,
      sensorHeightMm: 15.6,
      pixelPitchUm: 3.76,
      resolutionWidthPx: 6000,
      resolutionHeightPx: 4000,
      focalLengthMm: 400,
      focalRatio: 5,
    );
    expect(own.isExample, isFalse);
    expect(own.withEditProvenance(null).isExample, isFalse);
  });
}
