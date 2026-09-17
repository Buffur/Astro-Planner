class EquipmentProfile {
  final int id;
  final String name;
  final double sensorWidth;
  final double sensorHeight;
  final double pixelPitch;
  final int resolutionWidth;
  final int resolutionHeight;
  final double focalLength;
  final double aperture;
  final double opticalMultiplier;

  const EquipmentProfile({
    required this.id,
    required this.name,
    required this.sensorWidth,
    required this.sensorHeight,
    required this.pixelPitch,
    required this.resolutionWidth,
    required this.resolutionHeight,
    required this.focalLength,
    required this.aperture,
    this.opticalMultiplier = 1.0,
  });
}
