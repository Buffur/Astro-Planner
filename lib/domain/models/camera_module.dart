class CameraModule {
  final int id;
  final int deviceId;
  final String name;
  final String? manufacturer;
  final String? model;
  final double sensorWidthMm;
  final double sensorHeightMm;
  final int resolutionWidthPx;
  final int resolutionHeightPx;
  final double pixelPitchUm;
  final int bitDepth;

  const CameraModule({
    required this.id,
    required this.deviceId,
    required this.name,
    this.manufacturer,
    this.model,
    required this.sensorWidthMm,
    required this.sensorHeightMm,
    required this.resolutionWidthPx,
    required this.resolutionHeightPx,
    required this.pixelPitchUm,
    this.bitDepth = 14,
  });
}
