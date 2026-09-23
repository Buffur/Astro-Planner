import '../../domain/models/equipment_profile.dart';
import '../../domain/models/spec_confidence.dart';
import '../../domain/repositories/equipment_repository.dart';

/// Seeds the default equipment on an empty table (TASK 8.5).
///
/// "Fewer correct seeds beat many unverified ones" (roadmap TASK 8.5; owner
/// decision): only one profile ships.
///
/// - **Camera — verified.** ZWO ASI2600MC (Sony IMX571): 23.5 × 15.7 mm,
///   6248 × 4176 px, 3.76 µm pixels, per ZWO's product page
///   (https://www.zwoastro.com/product/asi2600mc-duo/, specification table
///   "ASI2600MC Pro", checked 2026-09-23). Resolution × pitch = 23.49 ×
///   15.70 mm, consistent with the stated size.
/// - **Optics — estimated.** A generic 72 mm f/5.6 refractor (400 mm), an
///   illustrative example rather than a specific product.
/// - No RAW file size: it depends on the capture format, and an estimate
///   would carry a different confidence than the verified camera specs.
///
/// The four phone profiles shipped before TASK 8.5 were dropped: their makers
/// publish only megapixels, f-number and a 35 mm-equivalent focal length, so
/// sensor size, pixel pitch and real focal length were unverified. Existing
/// installs keep their rows (never deleted or reinterpreted).
class EquipmentSeeder {
  final EquipmentRepository _repository;

  EquipmentSeeder(this._repository);

  /// The provenance id stored on seeded rows (ADR-008 §6).
  static const String source = 'seed:equipment@2';

  static const List<EquipmentProfile> defaults = [
    EquipmentProfile(
      id: 0,
      name: 'ZWO ASI2600MC + example 72 mm f/5.6 refractor',
      manufacturer: 'ZWO',
      cameraModel: 'ASI2600MC',
      sensorWidthMm: 23.5,
      sensorHeightMm: 15.7,
      pixelPitchUm: 3.76,
      resolutionWidthPx: 6248,
      resolutionHeightPx: 4176,
      focalLengthMm: 400.0,
      // N = f / D = 400 / 72 = f/5.56 (ADR-011 §4).
      focalRatio: 400.0 / 72.0,
      apertureDiameterMm: 72.0,
      cameraSource: source,
      cameraConfidence: SpecConfidence.verified,
      opticsSource: source,
      opticsConfidence: SpecConfidence.estimated,
    ),
  ];

  Future<void> seedIfNeeded() async {
    final existing = await _repository.getAllEquipment();
    if (existing.isNotEmpty) return;
    for (final eq in defaults) {
      await _repository.insertEquipment(eq);
    }
  }
}
