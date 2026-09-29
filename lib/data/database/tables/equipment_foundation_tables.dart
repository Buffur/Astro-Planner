import 'package:drift/drift.dart';

class Devices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get model => text().nullable()();
  TextColumn get notes => text().nullable()();
}

class CameraModules extends Table {
  IntColumn get id => integer().autoIncrement()();
  // ADR-008 §4: a device with camera modules still pointing to it cannot be
  // deleted (guarded in DriftEquipmentRepository before v10; enforced by
  // SQLite itself from v10 onward, once foreign keys are on).
  IntColumn get deviceId =>
      integer().references(Devices, #id, onDelete: KeyAction.restrict)();
  TextColumn get name => text()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get model => text().nullable()();
  RealColumn get sensorWidthMm => real()();
  RealColumn get sensorHeightMm => real()();
  IntColumn get resolutionWidthPx => integer()();
  IntColumn get resolutionHeightPx => integer()();
  RealColumn get pixelPitchUm => real()();
  RealColumn get averageRawFileSizeMB => real().nullable()();

  /// Provenance of the camera specs (ADR-008 §6, schema v15); NULL = unknown.
  TextColumn get source => text().nullable()();

  /// `verified` / `reported` / `estimated`; NULL = unknown.
  TextColumn get confidence => text().nullable()();

  // ADR-018 §5 (schema v18): per-field provenance for the specs an import
  // can mix with typed values. NULL = no own pair: the field falls back to
  // the group's [source]/[confidence] above, then unknown. Never back-filled.
  TextColumn get resolutionSource => text().nullable()();
  TextColumn get resolutionConfidence => text().nullable()();
  TextColumn get pixelPitchSource => text().nullable()();
  TextColumn get pixelPitchConfidence => text().nullable()();
  TextColumn get sensorSizeSource => text().nullable()();
  TextColumn get sensorSizeConfidence => text().nullable()();
  TextColumn get rawFileSizeSource => text().nullable()();
  TextColumn get rawFileSizeConfidence => text().nullable()();

  /// The raw Make and Model of the file a rig was imported from, kept for
  /// matching later imports (ADR-018 §5–§6). Never serials; NULL for rigs
  /// entered by hand.
  TextColumn get metadataMake => text().nullable()();
  TextColumn get metadataModel => text().nullable()();

  /// The camera's class (ADR-020 §2; S7.2a, v20): `phone`,
  /// `dslrMirrorless`, `astroColour`, `astroMono` or `unknown` (the
  /// default). Chosen by the user; never inferred.
  TextColumn get cameraClass => text().withDefault(const Constant('unknown'))();
}

class OpticalRigs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  // ADR-008 §4: a camera module with rigs still pointing to it cannot be
  // deleted — same RESTRICT reasoning as CameraModules.deviceId above.
  IntColumn get cameraModuleId =>
      integer().references(CameraModules, #id, onDelete: KeyAction.restrict)();
  RealColumn get focalLengthMm => real()();

  /// The focal ratio N (f/N), dimensionless (ADR-011 §4). The column keeps
  /// its historical name; stored values are never reinterpreted.
  RealColumn get aperture => real()();

  /// `untracked` / `tracked` / `guided` / `unknown` (ADR-011 §5).
  TextColumn get trackingState =>
      text().withDefault(const Constant('unknown'))();
  RealColumn get rotationDegrees => real().nullable()();

  /// Aperture diameter, mm; NULL = unknown (ADR-011 §4, schema v14).
  RealColumn get apertureDiameterMm => real().nullable()();

  /// The user's maximum sub-exposure, s; NULL = none (ADR-011 §5, v14).
  RealColumn get maxExposureS => real().nullable()();

  /// Provenance of the optics specs (ADR-008 §6, schema v15); NULL = unknown.
  TextColumn get source => text().nullable()();

  /// `verified` / `reported` / `estimated`; NULL = unknown.
  TextColumn get confidence => text().nullable()();

  // ADR-018 §5 (schema v18): per-field provenance; NULL falls back to the
  // group's [source]/[confidence].
  TextColumn get focalLengthSource => text().nullable()();
  TextColumn get focalLengthConfidence => text().nullable()();
  TextColumn get focalRatioSource => text().nullable()();
  TextColumn get focalRatioConfidence => text().nullable()();
}
