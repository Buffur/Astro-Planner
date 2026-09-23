/// Target object types (TASK 8.1, ADR-010 §3).
abstract final class TargetTypes {
  /// Types a new target can have: objects with fixed coordinates.
  static const List<String> selectable = [
    'Galaxy',
    'Nebula',
    'Globular Cluster',
    'Open Cluster',
    'Star',
    'Other',
  ];

  /// Solar-system types. Hidden for new targets in 1.0 (no ephemerides);
  /// existing targets of these types stay usable, with [movingWarning], and
  /// are never deleted or retyped silently.
  static const Set<String> moving = {'Planet', 'Moon', 'Comet', 'Asteroid'};

  static bool isMoving(String type) => moving.contains(type);

  /// The ADR-010 §3 label for a moving-type target.
  static const String movingWarning =
      'Fixed coordinates — this object moves; positions are not tracked.';
}
