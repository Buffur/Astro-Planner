import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/data/services/equipment_seeder.dart';
import 'package:astroplan/domain/models/equipment_profile.dart';
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
  test('seeded telescope stub has a plausible focal ratio, not f/72', () async {
    final repo = _FakeEquipmentRepository();
    await EquipmentSeeder(repo).seedIfNeeded();

    final telescopeStub = (await repo.getAllEquipment()).firstWhere(
      (e) => e.name.contains('400mm'),
    );

    // aperture stores the f-number (SI-005); a plausible amateur telescope
    // sits well under f/72 — the seed used to store the 72mm diameter here.
    expect(telescopeStub.focalRatio, closeTo(400.0 / 72.0, 0.01));
    expect(telescopeStub.focalRatio, lessThan(20.0));
  });
}
