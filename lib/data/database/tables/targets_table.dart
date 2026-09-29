import 'package:drift/drift.dart';

/// Catalog entries (source `seed:…` or `catalog:…`) are unique per catalog
/// id; user and legacy rows are not constrained (TASK 8.1).
@TableIndex.sql(
  "CREATE UNIQUE INDEX astro_targets_catalog_id_unique ON astro_targets "
  "(catalog_id) WHERE source LIKE 'seed:%' OR source LIKE 'catalog:%'",
)
class AstroTargets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get catalogId => text()();
  TextColumn get commonName => text().nullable()();

  /// Degrees, [0, 360).
  RealColumn get rightAscension => real()();

  /// Degrees, [-90, 90].
  RealColumn get declination => real()();
  TextColumn get type => text()();

  /// Coordinate epoch (TASK 8.1, schema v13). Only `J2000` is supported.
  TextColumn get epoch => text().withDefault(const Constant('J2000'))();

  /// Provenance (ADR-008 §6); NULL = unknown (legacy rows).
  TextColumn get source => text().nullable()();

  /// Apparent size, arcminutes; NULL = unknown.
  RealColumn get angularSizeArcmin => real().nullable()();

  /// Apparent magnitude; NULL = unknown.
  RealColumn get magnitude => real().nullable()();
}

/// Other designations and names of the bundled catalog's objects (RG-07 =
/// T1, S7.4; schema v22), from the pinned OpenNGC release only. Keyed by the
/// catalog id, not by a row: an alias applies to the catalog row with that
/// id while one exists, so a deleted target's aliases are never shown, and
/// no target row is ever changed by them. Rebuilt whole from the asset when
/// the catalog version rises ([catalogVersion] records which one).
@DataClassName('TargetAliasRow')
class TargetAliases extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get catalogId => text()();
  TextColumn get alias => text()();

  /// `designation` or `name` (`TargetAliasKind`).
  TextColumn get kind => text()();

  /// The catalog asset's version these rows were built from.
  IntColumn get catalogVersion => integer()();
}
