class OpticalRig {
  final int id;
  final String name;
  final int cameraModuleId;
  final double focalLengthMm;
  final double aperture;
  final double opticalMultiplier;
  final String trackingState;
  final double? rotationDegrees;

  const OpticalRig({
    required this.id,
    required this.name,
    required this.cameraModuleId,
    required this.focalLengthMm,
    required this.aperture,
    this.opticalMultiplier = 1.0,
    this.trackingState = 'unknown',
    this.rotationDegrees,
  });
}
