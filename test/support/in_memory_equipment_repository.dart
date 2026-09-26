import 'package:astroplan/domain/models/equipment_profile.dart';
import 'package:astroplan/domain/repositories/equipment_repository.dart';

/// An [EquipmentRepository] in memory, for widget tests that must not wait on
/// Drift. Ids are assigned on insert; every write is recorded.
class InMemoryEquipmentRepository implements EquipmentRepository {
  InMemoryEquipmentRepository([List<EquipmentProfile> rigs = const []]) {
    for (final rig in rigs) {
      _rigs[rig.id] = rig;
      _next = rig.id >= _next ? rig.id + 1 : _next;
    }
  }

  final Map<int, EquipmentProfile> _rigs = {};
  int _next = 1;
  final inserted = <EquipmentProfile>[];
  final updated = <EquipmentProfile>[];

  @override
  Future<List<EquipmentProfile>> getAllEquipment() async => [..._rigs.values];

  @override
  Future<EquipmentProfile?> getEquipmentById(int id) async => _rigs[id];

  @override
  Future<int> insertEquipment(EquipmentProfile profile) async {
    final id = _next++;
    inserted.add(profile);
    _rigs[id] = _withId(profile, id);
    return id;
  }

  @override
  Future<void> updateEquipment(EquipmentProfile profile) async {
    updated.add(profile);
    _rigs[profile.id] = profile;
  }

  @override
  Future<void> deleteEquipment(int id) async => _rigs.remove(id);

  static EquipmentProfile _withId(EquipmentProfile p, int id) =>
      EquipmentProfile(
        id: id,
        name: p.name,
        manufacturer: p.manufacturer,
        cameraModel: p.cameraModel,
        sensorWidthMm: p.sensorWidthMm,
        sensorHeightMm: p.sensorHeightMm,
        pixelPitchUm: p.pixelPitchUm,
        resolutionWidthPx: p.resolutionWidthPx,
        resolutionHeightPx: p.resolutionHeightPx,
        focalLengthMm: p.focalLengthMm,
        focalRatio: p.focalRatio,
        apertureDiameterMm: p.apertureDiameterMm,
        averageRawFileSizeMB: p.averageRawFileSizeMB,
        rotationDeg: p.rotationDeg,
        trackingType: p.trackingType,
        maxExposureS: p.maxExposureS,
        cameraSource: p.cameraSource,
        cameraConfidence: p.cameraConfidence,
        opticsSource: p.opticsSource,
        opticsConfidence: p.opticsConfidence,
        specProvenance: p.specProvenance,
        metadataMake: p.metadataMake,
        metadataModel: p.metadataModel,
      );
}
