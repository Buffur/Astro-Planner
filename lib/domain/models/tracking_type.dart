/// How a rig follows the sky (ADR-011 §5). Stored by [name] in
/// `optical_rigs.tracking_state`; anything unrecognised reads as [unknown]
/// — a type is never inferred from a device name or focal length.
enum TrackingType {
  untracked('Untracked (fixed tripod)'),
  tracked('Tracked (unguided mount)'),
  guided('Guided'),
  unknown('Unknown');

  const TrackingType(this.label);

  final String label;

  static TrackingType fromStorage(String? value) => TrackingType.values
      .firstWhere((t) => t.name == value, orElse: () => TrackingType.unknown);
}
