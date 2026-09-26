import 'spec_confidence.dart';

/// The equipment specs that carry their own provenance (ADR-018 §5): the
/// ones an import can mix with typed values in one group.
enum EquipmentSpec {
  resolution,
  pixelPitch,
  sensorSize,
  rawFileSize,
  focalLength,
  focalRatio;

  /// Whether the spec belongs to the camera group (else the optics group).
  bool get isCamera => switch (this) {
    resolution || pixelPitch || sensorSize || rawFileSize => true,
    focalLength || focalRatio => false,
  };
}

/// Where one stored value came from (ADR-008 §6): a namespaced source id and
/// a confidence. Either may be null (unknown); both null means no provenance.
class SpecProvenance {
  const SpecProvenance(this.source, this.confidence);

  /// The user's own entry: `user`, `reported` (TASK 8.5).
  static const user = SpecProvenance('user', SpecConfidence.reported);

  final String? source;
  final SpecConfidence? confidence;

  bool get isUnknown => source == null && confidence == null;

  @override
  bool operator ==(Object other) =>
      other is SpecProvenance &&
      other.source == source &&
      other.confidence == confidence;

  @override
  int get hashCode => Object.hash(source, confidence);

  @override
  String toString() => '${source ?? '?'} (${confidence?.name ?? '?'})';
}
