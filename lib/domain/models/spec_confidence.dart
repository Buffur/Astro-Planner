/// How far a stored specification can be trusted (ADR-008 §6, TASK 8.5).
/// Null (not a value of this enum) means unknown — legacy rows are never
/// back-filled.
enum SpecConfidence {
  /// Checked against a cited primary source (e.g. the manufacturer's page).
  verified,

  /// Taken from a source that was not independently checked (a secondary
  /// site, or a user's own entry).
  reported,

  /// Derived or approximated (e.g. an example optic).
  estimated;

  /// The stored value, or null when [value] is null or unrecognised.
  static SpecConfidence? fromStorage(String? value) {
    for (final c in SpecConfidence.values) {
      if (c.name == value) return c;
    }
    return null;
  }
}
