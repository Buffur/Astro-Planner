import '../../domain/models/equipment_profile.dart';
import '../../domain/repositories/equipment_repository.dart';

class EquipmentSeeder {
  final EquipmentRepository _repository;

  EquipmentSeeder(this._repository);

  Future<void> seedIfNeeded() async {
    final existing = await _repository.getAllEquipment();
    if (existing.isNotEmpty) return;

    final initialEquipment = [
      const EquipmentProfile(
        id: 0,
        name: 'iPhone 15 Pro Max (Main)',
        sensorWidth: 9.8,
        sensorHeight: 7.3,
        pixelPitch: 1.22,
        resolutionWidth: 8064,
        resolutionHeight: 6048,
        focalLength: 6.86,
        aperture: 1.78,
      ),
      const EquipmentProfile(
        id: 0,
        name: 'Pixel 8 Pro (Main)',
        sensorWidth: 9.6,
        sensorHeight: 7.2,
        pixelPitch: 1.2,
        resolutionWidth: 8160,
        resolutionHeight: 6144,
        focalLength: 6.9,
        aperture: 1.68,
      ),
      const EquipmentProfile(
        id: 0,
        name: 'Xiaomi 14 Ultra (Main)',
        sensorWidth: 13.2,
        sensorHeight: 8.8,
        pixelPitch: 1.6,
        resolutionWidth: 8192,
        resolutionHeight: 6144,
        focalLength: 8.7,
        aperture: 1.63,
      ),
      const EquipmentProfile(
        id: 0,
        name: 'Vivo X100 Pro (Main)',
        sensorWidth: 13.2,
        sensorHeight: 8.8,
        pixelPitch: 1.6,
        resolutionWidth: 8192,
        resolutionHeight: 6144,
        focalLength: 8.7,
        aperture: 1.75,
      ),
      const EquipmentProfile(
        id: 0,
        name: 'ZWO ASI2600MC + 400mm (Telescope Stub)',
        sensorWidth: 23.5,
        sensorHeight: 15.7,
        pixelPitch: 3.76,
        resolutionWidth: 6248,
        resolutionHeight: 4176,
        focalLength: 400.0,
        aperture: 72.0,
      ),
    ];

    for (final eq in initialEquipment) {
      await _repository.insertEquipment(eq);
    }
  }
}
