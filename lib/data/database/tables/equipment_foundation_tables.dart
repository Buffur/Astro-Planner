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
}
