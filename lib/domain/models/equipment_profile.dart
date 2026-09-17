class EquipmentProfile {
  final int id;
  final String name;
  // Stellarium-compatible camera sensor fields
  final String? manufacturer;
  final String? cameraModel;
  final double sensorWidth;
  final double sensorHeight;
  final double pixelPitch;
  final int resolutionWidth;
  final int resolutionHeight;
  // Optics
  final double focalLength;
  final double aperture;
  final double opticalMultiplier;
  // Optional rotation in degrees (Stellarium field)
  final double? rotation;

  const EquipmentProfile({
    required this.id,
    required this.name,
    this.manufacturer,
    this.cameraModel,
    required this.sensorWidth,
    required this.sensorHeight,
    required this.pixelPitch,
    required this.resolutionWidth,
    required this.resolutionHeight,
    required this.focalLength,
    required this.aperture,
    this.opticalMultiplier = 1.0,
    this.rotation,
  });
}
