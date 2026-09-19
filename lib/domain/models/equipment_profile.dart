class EquipmentProfile {
  final int id;
  final String name;
  // Stellarium-compatible camera sensor fields
  final String? manufacturer;
  final String? cameraModel;

  // Sensor dimensions in mm.
  // Semantics: These dictate the physical Field of View (FOV).
  // Note: These are mathematically derived from (resolution * pixelPitch / 1000)
  // but are currently stored independently.
  final double sensorWidth;
  final double sensorHeight;
  
  // Pixel size in microns (um)
  final double pixelPitch;
  // Resolution in pixels
  final int resolutionWidth;
  final int resolutionHeight;
  
  // Optics
  final double focalLength;
  final double aperture;

  // Average estimated RAW file size for storage calculations
  final double? averageRawFileSizeMB;

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
    this.averageRawFileSizeMB,
    this.rotation,
  });
}
