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
  IntColumn get deviceId => integer().references(Devices, #id)();
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
  IntColumn get cameraModuleId => integer().references(CameraModules, #id)();
  RealColumn get focalLengthMm => real()();
  RealColumn get aperture => real()();
  TextColumn get trackingState =>
      text().withDefault(const Constant('unknown'))();
  RealColumn get rotationDegrees => real().nullable()();
}
