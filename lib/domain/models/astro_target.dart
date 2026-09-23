/// A fixed-coordinate deep-sky target (TASK 8.1).
///
/// Coordinates are equatorial, in decimal degrees, for [epoch] — always
/// `J2000` (the calculators precess J2000 to the date, TASK 6.2). Moving
/// object types are not modelled (ADR-010 §3; see `target_types.dart`).
class AstroTarget {
  final int id;

  /// Catalog designation (e.g. `M42`), or the name a user gave a custom
  /// target. Edits never change it.
  final String catalogId;
  final String? commonName;

  /// Right ascension in degrees, [0, 360).
  final double rightAscension;

  /// Declination in degrees, [-90, 90].
  final double declination;
  final String type;

  /// Coordinate epoch/equinox. Only `J2000` is supported.
  final String epoch;

  /// Where the row came from (ADR-008 §6): `user`, `seed:catalog@1`,
  /// `catalog:<name>@<version>`; null for legacy rows (unknown, never
  /// guessed).
  final String? source;

  /// Apparent size (major axis), arcminutes; null when unknown.
  final double? angularSizeArcmin;

  /// Apparent (visual) magnitude; null when unknown.
  final double? magnitude;

  const AstroTarget({
    required this.id,
    required this.catalogId,
    this.commonName,
    required this.rightAscension,
    required this.declination,
    required this.type,
    this.epoch = 'J2000',
    this.source,
    this.angularSizeArcmin,
    this.magnitude,
  });

  /// The target an explicit user edit produces (TASK 8.1), from [original]
  /// (null for a new custom target).
  ///
  /// - A new target's catalog id is its [name] and its source is `user`.
  /// - An edit never changes the catalog id; [name] becomes the common name.
  /// - An edit that changes the coordinates, size or magnitude makes the
  ///   source `user` (the values are no longer the catalog's); a rename or
  ///   retype alone keeps the original source.
  static AstroTarget userEdit({
    AstroTarget? original,
    required String name,
    required String type,
    required double rightAscension,
    required double declination,
    double? angularSizeArcmin,
    double? magnitude,
  }) {
    if (original == null) {
      return AstroTarget(
        id: 0,
        catalogId: name,
        commonName: name,
        type: type,
        rightAscension: rightAscension,
        declination: declination,
        source: 'user',
        angularSizeArcmin: angularSizeArcmin,
        magnitude: magnitude,
      );
    }
    final dataChanged =
        rightAscension != original.rightAscension ||
        declination != original.declination ||
        angularSizeArcmin != original.angularSizeArcmin ||
        magnitude != original.magnitude;
    return AstroTarget(
      id: original.id,
      catalogId: original.catalogId,
      commonName: name,
      type: type,
      rightAscension: rightAscension,
      declination: declination,
      epoch: original.epoch,
      source: dataChanged ? 'user' : original.source,
      angularSizeArcmin: angularSizeArcmin,
      magnitude: magnitude,
    );
  }

  /// Whether this row is a catalog entry (unique per [catalogId]) rather than
  /// a user's own or a legacy row.
  bool get isCatalogEntry =>
      source != null &&
      (source!.startsWith('seed:') || source!.startsWith('catalog:'));
}
