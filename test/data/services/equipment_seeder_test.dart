import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/models/spec_confidence.dart';
import 'package:astroplan/domain/repositories/equipment_repository.dart';

class _FakeEquipmentRepository implements EquipmentRepository {
  final List<EquipmentProfile> _items = [];

  @override
  Future<List<EquipmentProfile>> getAllEquipment() async => _items;

  @override
  Future<EquipmentProfile?> getEquipmentById(int id) async {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<int> insertEquipment(EquipmentProfile profile) async {
    final id = _items.length + 1;
    _items.add(
      EquipmentProfile(
        id: id,
        name: profile.name,
        manufacturer: profile.manufacturer,
        cameraModel: profile.cameraModel,
        sensorWidthMm: profile.sensorWidthMm,
        sensorHeightMm: profile.sensorHeightMm,
        pixelPitchUm: profile.pixelPitchUm,
        resolutionWidthPx: profile.resolutionWidthPx,
        resolutionHeightPx: profile.resolutionHeightPx,
        focalLengthMm: profile.focalLengthMm,
        focalRatio: profile.focalRatio,
        averageRawFileSizeMB: profile.averageRawFileSizeMB,
        rotationDeg: profile.rotationDeg,
      ),
    );
    return id;
  }

  @override
  Future<void> deleteEquipment(int id) async {
    _items.removeWhere((e) => e.id == id);
  }

  @override
  Future<void> updateEquipment(EquipmentProfile profile) async {
    final index = _items.indexWhere((e) => e.id == profile.id);
    if (index != -1) _items[index] = profile;
  }
}

void main() {
  // TASK 8.5 (owner decision) dropped the four unverified phone seeds and
  // renamed the telescope profile; this test used to find it by "400mm" in
  // the name, and now checks the single verified seed with its provenance.
  test('one seed: the verified ZWO camera with example optics', () async {
    final repo = _FakeEquipmentRepository();
    await EquipmentSeeder(repo).seedIfNeeded();
    final all = await repo.getAllEquipment();
    expect(all, hasLength(1));
    final seed = EquipmentSeeder.defaults.single;

    // ZWO product page: 23.5 x 15.7 mm, 6248 x 4176 px, 3.76 um.
    expect(seed.sensorWidthMm, 23.5);
    expect(seed.sensorHeightMm, 15.7);
    expect(seed.resolutionWidthPx, 6248);
    expect(seed.resolutionHeightPx, 4176);
    expect(seed.pixelPitchUm, 3.76);
    expect(seed.cameraConfidence, SpecConfidence.verified);
    expect(seed.opticsConfidence, SpecConfidence.estimated);
    expect(seed.cameraSource, 'seed:equipment@2');
    // SI-005: N = f / D, not the 72 mm diameter.
    expect(seed.focalRatio, closeTo(400.0 / 72.0, 1e-9));
    expect(seed.apertureDiameterMm, 72.0);
    expect(seed.averageRawFileSizeMB, isNull, reason: 'unknown, not guessed');
  });

  // Roadmap TASK 8.5: stored sensor size matches resolution x pitch within
  // 2 % unless documented.
  test('every seed: sensor size = resolution x pitch within 2 %', () {
    for (final s in EquipmentSeeder.defaults) {
      final w = s.resolutionWidthPx * s.pixelPitchUm / 1000;
      final h = s.resolutionHeightPx * s.pixelPitchUm / 1000;
      expect((w - s.sensorWidthMm).abs() / s.sensorWidthMm, lessThan(0.02));
      expect((h - s.sensorHeightMm).abs() / s.sensorHeightMm, lessThan(0.02));
    }
  });

  test('an existing table is left alone', () async {
    final repo = _FakeEquipmentRepository();
    await repo.insertEquipment(EquipmentSeeder.defaults.single);
    await EquipmentSeeder(repo).seedIfNeeded();
    expect(await repo.getAllEquipment(), hasLength(1));
  });
}
