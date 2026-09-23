import 'equipment_limits.dart';
import 'tracking_type.dart';

/// A flat equipment profile: one camera behind one optic (ADR-011 §2), stored
/// as a device → camera module → optical rig chain; [id] is the rig id.
/// Every number carries its unit in its name (ADR-011 §3).
class EquipmentProfile {
  final int id;
  final String name;
  final String? manufacturer;
  final String? cameraModel;

  /// Sensor size, mm. Dictates the field of view.
  final double sensorWidthMm;
  final double sensorHeightMm;

  /// Pixel pitch, µm (square pixels).
  final double pixelPitchUm;

  /// Resolution, px.
  final int resolutionWidthPx;
  final int resolutionHeightPx;

  /// Effective focal length, mm.
  final double focalLengthMm;

  /// Focal ratio N (f/N), dimensionless. What every formula uses.
  final double focalRatio;

  /// Aperture (entrance-pupil) diameter, mm, when known. When stored,
  /// [focalRatio] = [focalLengthMm] / this (ADR-011 §4).
  final double? apertureDiameterMm;

  /// Average RAW file size, MB, for storage estimates; null when unknown.
  final double? averageRawFileSizeMB;

  /// Camera rotation, degrees; null when unknown.
  final double? rotationDeg;

  final TrackingType trackingType;

  /// The user's maximum sub-exposure for this rig, s; null = no limit set.
  final double? maxExposureS;

  const EquipmentProfile({
    required this.id,
    required this.name,
    this.manufacturer,
    this.cameraModel,
    required this.sensorWidthMm,
    required this.sensorHeightMm,
    required this.pixelPitchUm,
    required this.resolutionWidthPx,
    required this.resolutionHeightPx,
    required this.focalLengthMm,
    required this.focalRatio,
    this.apertureDiameterMm,
    this.averageRawFileSizeMB,
    this.rotationDeg,
    this.trackingType = TrackingType.unknown,
    this.maxExposureS,
  });

  /// A stored focal ratio above f/32 is flagged for the user to review; it is
  /// never reinterpreted (ADR-011 §6).
  bool get needsApertureReview =>
      focalRatio > EquipmentLimits.reviewFocalRatioAbove;
}
