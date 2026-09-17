import 'package:drift/drift.dart';

class AstroTargets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get catalogId => text()();
  TextColumn get commonName => text().nullable()();
  RealColumn get rightAscension => real()();
  RealColumn get declination => real()();
  TextColumn get type => text()();
}
