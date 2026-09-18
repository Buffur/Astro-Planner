import 'package:drift/drift.dart';

class LocationProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get elevation => real()();
  IntColumn get bortleClass => integer().withDefault(const Constant(4))();
}
