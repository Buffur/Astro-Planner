import '../../domain/models/equipment_profile.dart';
import '../../domain/repositories/equipment_repository.dart';

class EquipmentSeeder {
  final EquipmentRepository _repository;

  EquipmentSeeder(this._repository);

  Future<void> seedIfNeeded() async {
    final existing = await _repository.getAllEquipment();
    if (existing.isNotEmpty) return;

    // Data Provenance:
    // Smartphone sensor specifications (sensor dimensions, focal lengths, pixel pitch, and apertures)
    // were sourced from manufacturer technical specifications and GSMArena device databases.
    // ZWO ASI2600MC specifications (sensor dimensions, resolution, pixel pitch, bit depth)
    // were sourced directly from official ZWO product documentation.
    final initialEquipment = [
      const EquipmentProfile(
        id: 0,
        name: 'iPhone 15 Pro Max (Main)',
        manufacturer: 'Apple',
        cameraModel: 'IMX903',
        sensorWidth: 9.8,
        sensorHeight: 7.3,
        pixelPitch: 1.22,
        resolutionWidth: 8064,
        resolutionHeight: 6048,
        focalLength: 6.86,
        aperture: 1.78,
        bitDepth: 14,
      ),
      const EquipmentProfile(
        id: 0,
        name: 'Pixel 8 Pro (Main)',
        manufacturer: 'Google / Samsung',
        cameraModel: 'GNK',
        sensorWidth: 9.6,
        sensorHeight: 7.2,
        pixelPitch: 1.2,
        resolutionWidth: 8160,
        resolutionHeight: 6144,
        focalLength: 6.9,
        aperture: 1.68,
        bitDepth: 14,
      ),
      const EquipmentProfile(
        id: 0,
        name: 'Xiaomi 14 Ultra (Main)',
        manufacturer: 'Sony',
        cameraModel: 'LYT-900',
        sensorWidth: 13.2,
        sensorHeight: 8.8,
        pixelPitch: 1.6,
        resolutionWidth: 8192,
        resolutionHeight: 6144,
        focalLength: 8.7,
        aperture: 1.63,
        bitDepth: 14,
      ),
      const EquipmentProfile(
        id: 0,
        name: 'Vivo X100 Pro (Main)',
        manufacturer: 'Sony',
        cameraModel: 'IMX989',
        sensorWidth: 13.2,
        sensorHeight: 8.8,
        pixelPitch: 1.6,
        resolutionWidth: 8192,
        resolutionHeight: 6144,
        focalLength: 8.7,
        aperture: 1.75,
        bitDepth: 14,
      ),
      const EquipmentProfile(
        id: 0,
        name: 'ZWO ASI2600MC + 400mm (Telescope Stub)',
        manufacturer: 'ZWO',
        cameraModel: 'ASI2600MC',
        sensorWidth: 23.5,
        sensorHeight: 15.7,
        pixelPitch: 3.76,
        resolutionWidth: 6248,
        resolutionHeight: 4176,
        focalLength: 400.0,
        aperture: 72.0,
        bitDepth: 16,
      ),
    ];

    for (final eq in initialEquipment) {
      await _repository.insertEquipment(eq);
    }
  }
}
