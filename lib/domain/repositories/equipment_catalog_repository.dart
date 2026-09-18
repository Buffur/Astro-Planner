import '../models/camera_module.dart';
import '../models/equipment_device.dart';
import '../models/optical_rig.dart';

abstract class EquipmentCatalogRepository {
  Future<int> insertDevice(EquipmentDevice device);
  Future<List<EquipmentDevice>> getDevices();
  Future<EquipmentDevice?> getDeviceById(int id);

  Future<int> insertCameraModule(CameraModule module);
  Future<List<CameraModule>> getCameraModulesForDevice(int deviceId);

  Future<int> insertOpticalRig(OpticalRig rig);
  Future<List<OpticalRig>> getOpticalRigsForCameraModule(int cameraModuleId);
}
