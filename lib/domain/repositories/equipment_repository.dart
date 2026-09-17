import '../models/equipment_profile.dart';

abstract class EquipmentRepository {
  Future<List<EquipmentProfile>> getAllEquipment();
  Future<EquipmentProfile?> getEquipmentById(int id);
  Future<int> insertEquipment(EquipmentProfile profile);
}
