import 'package:drift/drift.dart';

/// Saved sites (TASK 7.1 semantics since schema v12).
class LocationProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// Degrees, north positive.
  RealColumn get latitude => real()();

  /// Degrees, east positive.
  RealColumn get longitude => real()();

  /// Metres above mean sea level. Rows created before v12 by the old
  /// "current location" path hold 0, which may mean "not measured".
  RealColumn get elevation => real()();

  /// Bortle class 1–9, or NULL when unknown (SI-007). Nullable since v12:
  /// the old default 4 was cleared by the v11→v12 migration (owner).
  IntColumn get bortleClass => integer().nullable()();

  /// Provenance of [bortleClass] (ADR-008 §6): `user`, `legacy`, …
  TextColumn get bortleSource => text().nullable()();

  /// When [bortleClass] was determined, ISO `YYYY-MM-DD`.
  TextColumn get bortleDate => text().nullable()();

  /// Sky quality, mag/arcsec² (SQM), or NULL when unknown.
  RealColumn get sqm => real().nullable()();
  TextColumn get sqmSource => text().nullable()();
  TextColumn get sqmDate => text().nullable()();

  /// IANA time zone id (e.g. `Europe/London`), or NULL when unknown — the
  /// night then falls back to mean solar time (ADR-007 §6, L1).
  TextColumn get timeZone => text().nullable()();

  TextColumn get notes => text().nullable()();
}
