import '../models/equipment_profile.dart';
import 'storage_failure.dart';

/// Every method throws [StorageFailure] when the store cannot be read or
/// written (TASK 15.1).
abstract class EquipmentRepository {
  Future<List<EquipmentProfile>> getAllEquipment();
  Future<EquipmentProfile?> getEquipmentById(int id);
  Future<int> insertEquipment(EquipmentProfile profile);
  Future<void> deleteEquipment(int id);
  Future<void> updateEquipment(EquipmentProfile profile);
}
