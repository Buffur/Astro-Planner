import 'package:drift/drift.dart';

class EquipmentProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get sensorWidth => real()();
  RealColumn get sensorHeight => real()();
  RealColumn get pixelPitch => real()();
  IntColumn get resolutionWidth => integer()();
  IntColumn get resolutionHeight => integer()();
  RealColumn get focalLength => real()();
  RealColumn get aperture => real()();
  RealColumn get opticalMultiplier => real().withDefault(const Constant(1.0))();
}
