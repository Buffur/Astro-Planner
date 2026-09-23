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
        sensorWidthMm: 9.8,
        sensorHeightMm: 7.3,
        pixelPitchUm: 1.22,
        resolutionWidthPx: 8064,
        resolutionHeightPx: 6048,
        focalLengthMm: 6.86,
        focalRatio: 1.78,
      ),
      const EquipmentProfile(
        id: 0,
        name: 'Pixel 8 Pro (Main)',
        manufacturer: 'Google / Samsung',
        cameraModel: 'GNK',
        sensorWidthMm: 9.6,
        sensorHeightMm: 7.2,
        pixelPitchUm: 1.2,
        resolutionWidthPx: 8160,
        resolutionHeightPx: 6144,
        focalLengthMm: 6.9,
        focalRatio: 1.68,
      ),
      const EquipmentProfile(
        id: 0,
        name: 'Xiaomi 14 Ultra (Main)',
        manufacturer: 'Sony',
        cameraModel: 'LYT-900',
        sensorWidthMm: 13.2,
        sensorHeightMm: 8.8,
        pixelPitchUm: 1.6,
        resolutionWidthPx: 8192,
        resolutionHeightPx: 6144,
        focalLengthMm: 8.7,
        focalRatio: 1.63,
      ),
      const EquipmentProfile(
        id: 0,
        name: 'Vivo X100 Pro (Main)',
        manufacturer: 'Sony',
        cameraModel: 'IMX989',
        sensorWidthMm: 13.2,
        sensorHeightMm: 8.8,
        pixelPitchUm: 1.6,
        resolutionWidthPx: 8192,
        resolutionHeightPx: 6144,
        focalLengthMm: 8.7,
        focalRatio: 1.75,
      ),
      const EquipmentProfile(
        id: 0,
        name: 'ZWO ASI2600MC + 400mm (Telescope Stub)',
        manufacturer: 'ZWO',
        cameraModel: 'ASI2600MC',
        sensorWidthMm: 23.5,
        sensorHeightMm: 15.7,
        pixelPitchUm: 3.76,
        resolutionWidthPx: 6248,
        resolutionHeightPx: 4176,
        focalLengthMm: 400.0,
        // A 72 mm aperture at 400 mm: N = f / D = f/5.56 (ADR-011 §4). The
        // pre-TASK 4.4 seed put the 72 mm diameter in the f/ field (SI-005).
        focalRatio: 400.0 / 72.0,
        apertureDiameterMm: 72.0,
      ),
    ];

    for (final eq in initialEquipment) {
      await _repository.insertEquipment(eq);
    }
  }
}
