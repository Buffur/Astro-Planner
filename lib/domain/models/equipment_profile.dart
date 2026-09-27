import 'equipment_limits.dart';
import 'spec_confidence.dart';
import 'spec_provenance.dart';
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

  /// Per-field provenance (ADR-018 §5): only the specs with their own pair.
  /// A spec without one falls back to its group ([provenanceOf]).
  final Map<EquipmentSpec, SpecProvenance> specProvenance;

  /// The raw Make and Model of the file this rig was imported from, for
  /// matching later imports (ADR-018 §6); null for rigs entered by hand.
  final String? metadataMake;
  final String? metadataModel;

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
    this.specProvenance = const {},
    this.metadataMake,
    this.metadataModel,
  });

  /// Where [spec]'s value came from: its own pair, else its group's, else
  /// null (unknown; never guessed, ADR-008 §6). An own pair marked
  /// [SpecProvenance.unknown] is unknown, whatever the group says (S3.V2).
  SpecProvenance? provenanceOf(EquipmentSpec spec) {
    final own = specProvenance[spec];
    if (own != null && own.isExplicitlyUnknown) return null;
    if (own != null && !own.isUnknown) return own;
    final group = _groupProvenance(spec);
    return group.isUnknown ? null : group;
  }

  SpecProvenance _groupProvenance(EquipmentSpec spec) => spec.isCamera
      ? SpecProvenance(cameraSource, cameraConfidence)
      : SpecProvenance(opticsSource, opticsConfidence);

  bool _sameSpec(EquipmentSpec spec, EquipmentProfile o) => switch (spec) {
    EquipmentSpec.resolution =>
      resolutionWidthPx == o.resolutionWidthPx &&
          resolutionHeightPx == o.resolutionHeightPx,
    EquipmentSpec.pixelPitch => pixelPitchUm == o.pixelPitchUm,
    EquipmentSpec.sensorSize =>
      sensorWidthMm == o.sensorWidthMm && sensorHeightMm == o.sensorHeightMm,
    EquipmentSpec.rawFileSize => averageRawFileSizeMB == o.averageRawFileSizeMB,
    EquipmentSpec.focalLength => focalLengthMm == o.focalLengthMm,
    EquipmentSpec.focalRatio =>
      focalRatio == o.focalRatio && apertureDiameterMm == o.apertureDiameterMm,
  };

  bool _sameCamera(EquipmentProfile o) => EquipmentSpec.values
      .where((s) => s.isCamera)
      .every((s) => _sameSpec(s, o));

  bool _sameOptics(EquipmentProfile o) => EquipmentSpec.values
      .where((s) => !s.isCamera)
      .every((s) => _sameSpec(s, o));

  /// Per-field provenance after an edit of [original] (ADR-018 §5):
  /// - a pair given on this profile (an accepted import value) is kept;
  /// - a changed spec becomes the user's own;
  /// - an unchanged spec keeps its pair, and when its group changes it keeps
  ///   the group's old provenance as its own pair, so a verified value that
  ///   was not touched stays verified, and one of unknown origin stays
  ///   unknown ([SpecProvenance.unknown], S3.V2) instead of falling back to
  ///   the group's new `user`.
  Map<EquipmentSpec, SpecProvenance> _editedSpecProvenance(
    EquipmentProfile? original,
    bool keepCamera,
    bool keepOptics,
  ) {
    final result = <EquipmentSpec, SpecProvenance>{};
    for (final spec in EquipmentSpec.values) {
      final given = specProvenance[spec];
      if (given != null) {
        result[spec] = given;
        continue;
      }
      if (original == null) continue;
      if (!_sameSpec(spec, original)) {
        result[spec] = SpecProvenance.user;
        continue;
      }
      final kept = original.specProvenance[spec];
      final groupKept = spec.isCamera ? keepCamera : keepOptics;
      if (kept != null) {
        result[spec] = kept;
      } else if (!groupKept) {
        final group = original._groupProvenance(spec);
        result[spec] = group.isUnknown ? SpecProvenance.unknown : group;
      }
    }
    return result;
  }

  /// This profile as an explicit user edit of [original] (null for a new
  /// profile) records it (TASK 8.5): a new profile, or a changed group of
  /// specs, becomes source `user` with confidence `reported`; an unchanged
  /// group keeps its source and confidence. Per field (ADR-018 §5, S3.4):
  /// see [_editedSpecProvenance]. The metadata identity is kept.
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
      specProvenance: _editedSpecProvenance(original, keepCamera, keepOptics),
      metadataMake: metadataMake ?? original?.metadataMake,
      metadataModel: metadataModel ?? original?.metadataModel,
    );
  }

  /// A stored focal ratio above f/32 is flagged for the user to review; it is
  /// never reinterpreted (ADR-011 §6).
  bool get needsApertureReview =>
      focalRatio > EquipmentLimits.reviewFocalRatioAbove;
}
