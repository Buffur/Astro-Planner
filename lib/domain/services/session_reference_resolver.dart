import '../models/astro_target.dart';
import '../models/equipment_profile.dart';
import '../models/session.dart';
import '../repositories/equipment_repository.dart';
import '../repositories/target_repository.dart';

/// Finds a session's target and rig (TASK 11.3; moved out of the planner
/// ViewModel in TASK 12.3): by reference id; a legacy session, which has no
/// references, falls back to matching its stored labels (ADR-014 §7). A
/// null result means "keep the current selection".
class SessionReferenceResolver {
  const SessionReferenceResolver(this._targets, this._equipment);

  final TargetRepository _targets;
  final EquipmentRepository _equipment;

  Future<AstroTarget?> target(Session session) async {
    final id = session.targetId;
    final byId = id == null ? null : await _targets.getTargetById(id);
    if (byId != null || !session.legacy) return byId;
    final label = session.record.targetName;
    final matches = await _targets.searchTargets(label);
    if (matches.isEmpty) return null;
    return matches.firstWhere(
      (t) => (t.commonName ?? t.catalogId).toLowerCase() == label.toLowerCase(),
      orElse: () => matches.first,
    );
  }

  Future<EquipmentProfile?> rig(Session session) async {
    final id = session.rigId;
    final byId = id == null ? null : await _equipment.getEquipmentById(id);
    if (byId != null || !session.legacy) return byId;
    final label = session.record.equipmentName.toLowerCase();
    for (final e in await _equipment.getAllEquipment()) {
      if (e.name.toLowerCase() == label) return e;
    }
    return null;
  }
}
