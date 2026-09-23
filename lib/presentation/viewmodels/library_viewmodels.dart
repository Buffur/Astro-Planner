import 'package:flutter/foundation.dart';

import '../../domain/models/astro_target.dart';
import '../../domain/models/equipment_profile.dart';
import '../../domain/models/session.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/repositories/target_repository.dart';

/// The Library's rigs (TASK 12.3): screens read and change equipment
/// through this, never through the repository.
class GearViewModel extends ChangeNotifier {
  GearViewModel(this._repository);

  final EquipmentRepository _repository;

  Future<List<EquipmentProfile>> all() => _repository.getAllEquipment();

  Future<int> add(EquipmentProfile rig) async {
    final id = await _repository.insertEquipment(rig);
    notifyListeners();
    return id;
  }

  Future<void> update(EquipmentProfile rig) async {
    await _repository.updateEquipment(rig);
    notifyListeners();
  }

  Future<void> delete(int id) async {
    await _repository.deleteEquipment(id);
    notifyListeners();
  }
}

/// The Library's targets (TASK 12.3).
class TargetsViewModel extends ChangeNotifier {
  TargetsViewModel(this._repository);

  final TargetRepository _repository;

  /// Catalog and user targets matching [query] (all when empty).
  Future<List<AstroTarget>> search(String query) =>
      _repository.searchTargets(query);

  Future<int> add(AstroTarget target) async {
    final id = await _repository.insertTarget(target);
    notifyListeners();
    return id;
  }

  Future<void> update(AstroTarget target) async {
    await _repository.updateTarget(target);
    notifyListeners();
  }

  Future<void> delete(int id) async {
    await _repository.deleteTarget(id);
    notifyListeners();
  }
}

/// The Sessions tab (TASKs 11.3–11.4; TASK 12.3): the saved sessions the
/// logbook lists — every non-draft session, a draft saved before
/// ("unsaved changes"), and the legacy logs (owner decisions).
class SessionsViewModel extends ChangeNotifier {
  SessionsViewModel(this._repository);

  final SessionRepository _repository;

  Future<List<Session>> saved() async => [
    for (final s in await _repository.list())
      if (s.legacy || s.status != SessionStatus.draft || s.plannedAtUtc != null)
        s,
  ];

  Future<Session?> get(int id) => _repository.get(id);

  Future<void> delete(int id) async {
    await _repository.delete(id);
    notifyListeners();
  }
}
