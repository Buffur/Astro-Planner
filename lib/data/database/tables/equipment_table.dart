import 'package:drift/drift.dart';

class EquipmentProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  // Stellarium-compatible camera sensor fields
  TextColumn get manufacturer => text().nullable()();
  TextColumn get cameraModel => text().nullable()();
  RealColumn get sensorWidth => real()();
  RealColumn get sensorHeight => real()();
  RealColumn get pixelPitch => real()();
  IntColumn get resolutionWidth => integer()();
  IntColumn get resolutionHeight => integer()();
  // Optics
  RealColumn get focalLength => real()();
  RealColumn get aperture => real()();
  RealColumn get averageRawFileSizeMB => real().nullable()();
  // Optional rotation in degrees (Stellarium field)
  RealColumn get rotation => real().nullable()();
}
