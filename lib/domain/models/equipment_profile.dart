import 'equipment_limits.dart';
import 'spec_confidence.dart';
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

  /// Provenance of the camera specs (sensor, pixels, RAW size) and of the
  /// optics (focal length, aperture), per ADR-008 §6: a namespaced source id
  /// (`user`, `seed:equipment@2`) and a confidence; null = unknown (legacy
  /// rows, never guessed). Tracking, maximum exposure and rotation are the
  /// user's own settings and carry no provenance.
  final String? cameraSource;
  final SpecConfidence? cameraConfidence;
  final String? opticsSource;
  final SpecConfidence? opticsConfidence;

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
    this.cameraSource,
    this.cameraConfidence,
    this.opticsSource,
    this.opticsConfidence,
  });

  bool _sameCamera(EquipmentProfile o) =>
      sensorWidthMm == o.sensorWidthMm &&
      sensorHeightMm == o.sensorHeightMm &&
      pixelPitchUm == o.pixelPitchUm &&
      resolutionWidthPx == o.resolutionWidthPx &&
      resolutionHeightPx == o.resolutionHeightPx &&
      averageRawFileSizeMB == o.averageRawFileSizeMB;

  bool _sameOptics(EquipmentProfile o) =>
      focalLengthMm == o.focalLengthMm &&
      focalRatio == o.focalRatio &&
      apertureDiameterMm == o.apertureDiameterMm;

  /// This profile as an explicit user edit of [original] (null for a new
  /// profile) records it (TASK 8.5): a new profile, or a changed group of
  /// specs, becomes source `user` with confidence `reported`; an unchanged
  /// group keeps its source and confidence.
  EquipmentProfile withEditProvenance(EquipmentProfile? original) {
    final keepCamera = original != null && _sameCamera(original);
    final keepOptics = original != null && _sameOptics(original);
    return EquipmentProfile(
      id: id,
      name: name,
      manufacturer: manufacturer,
      cameraModel: cameraModel,
      sensorWidthMm: sensorWidthMm,
      sensorHeightMm: sensorHeightMm,
      pixelPitchUm: pixelPitchUm,
      resolutionWidthPx: resolutionWidthPx,
      resolutionHeightPx: resolutionHeightPx,
      focalLengthMm: focalLengthMm,
      focalRatio: focalRatio,
      apertureDiameterMm: apertureDiameterMm,
      averageRawFileSizeMB: averageRawFileSizeMB,
      rotationDeg: rotationDeg,
      trackingType: trackingType,
      maxExposureS: maxExposureS,
      cameraSource: keepCamera ? original.cameraSource : 'user',
      cameraConfidence: keepCamera
          ? original.cameraConfidence
          : SpecConfidence.reported,
      opticsSource: keepOptics ? original.opticsSource : 'user',
      opticsConfidence: keepOptics
          ? original.opticsConfidence
          : SpecConfidence.reported,
    );
  }

  /// A stored focal ratio above f/32 is flagged for the user to review; it is
  /// never reinterpreted (ADR-011 §6).
  bool get needsApertureReview =>
      focalRatio > EquipmentLimits.reviewFocalRatioAbove;
}
