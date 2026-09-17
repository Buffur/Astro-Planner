import '../models/equipment_profile.dart';

abstract class EquipmentRepository {
  Future<List<EquipmentProfile>> getAllEquipment();
  Future<EquipmentProfile?> getEquipmentById(int id);
  Future<int> insertEquipment(EquipmentProfile profile);
  Future<void> deleteEquipment(int id);
  Future<void> updateEquipment(EquipmentProfile profile);
}
