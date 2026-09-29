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

  /// The types a plan may choose as its override (RD-08 = T3; S7.1):
  /// unknown comes only from a rig's default.
  static const List<TrackingType> overrides = [untracked, tracked, guided];

  /// A stored plan override, or null (the rig's default) for anything that
  /// is not one of [overrides].
  static TrackingType? overrideFromStorage(String? value) {
    for (final t in overrides) {
      if (t.name == value) return t;
    }
    return null;
  }
}

/// Where a plan's effective tracking comes from (RD-08 = T3).
enum TrackingSource { rig, plan }

/// The tracking a plan's calculations use (RD-08 = T3; S7.1): the plan's
/// override when it has one, else its rig's default, else unknown (no rig).
/// Pure; the planner, the capability guidance and the snapshot share it.
class EffectiveTracking {
  const EffectiveTracking(this.type, this.source);

  factory EffectiveTracking.of({
    TrackingType? override,
    TrackingType? rigDefault,
  }) => override != null && override != TrackingType.unknown
      ? EffectiveTracking(override, TrackingSource.plan)
      : EffectiveTracking(
          rigDefault ?? TrackingType.unknown,
          TrackingSource.rig,
        );

  final TrackingType type;
  final TrackingSource source;

  @override
  bool operator ==(Object other) =>
      other is EffectiveTracking &&
      type == other.type &&
      source == other.source;

  @override
  int get hashCode => Object.hash(type, source);

  @override
  String toString() => 'EffectiveTracking(${type.name}, ${source.name})';
}
