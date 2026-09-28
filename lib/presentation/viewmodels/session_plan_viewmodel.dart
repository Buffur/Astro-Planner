import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/time/clock.dart';
import '../../domain/models/astro_target.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/capture_block.dart';
import '../../domain/models/equipment_profile.dart';
import '../../domain/models/session.dart';
import '../../domain/models/session_night.dart';
import '../../domain/models/tracking_type.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/repositories/planner_state_repository.dart';
import '../../domain/repositories/target_repository.dart';
import '../../domain/services/current_session.dart';
import '../../domain/services/example_capture_plan.dart';
import '../../domain/services/session_night_resolver.dart';
import 'site_viewmodel.dart';

/// The plan the planner shows (ADR-014; TASKs 11.3–11.4; split out of the
/// planner ViewModel in TASK 12.3): its night, target, rig and capture
/// blocks, and their edits. Every plan edit — a site change included — is
/// autosaved into the current session before the edit call returns.
/// Restoring, opening, starting a new plan, copying, saving and starting a
/// run are `PlanLifecycleViewModel`'s (S6.1).
class SessionPlanViewModel extends ChangeNotifier {
  SessionPlanViewModel({
    required this._site,
    required TargetRepository targetRepository,
    required EquipmentRepository equipmentRepository,
    required this._stateRepository,
    required this._clock,
    CurrentSession? currentSession,
  }) : _targets = targetRepository,
       _equipment = equipmentRepository,
       _current = currentSession {
    _site.addListener(_onSiteChanged);
    _current?.onWriteFailureChanged = notifyListeners;
  }

  final SiteViewModel _site;
  final TargetRepository _targets;
  final EquipmentRepository _equipment;
  final PlannerStateRepository _stateRepository;
  final Clock _clock;

  /// Null only in tests without a session repository (plan in preferences).
  final CurrentSession? _current;

  AstroTarget? _target;
  EquipmentProfile? _rig;
  List<CaptureBlock> _blocks = [];
  bool _isExample = false;
  CalendarDate? _pickedEveningDate;
  bool _loaded = false;
  Object? _siteKey;

  AstroTarget? get selectedTarget => _target;
  EquipmentProfile? get selectedEquipment => _rig;

  /// The tracking this plan's guidance uses (RD-08 = T3): the rig's
  /// default, `unknown` without a rig. Stage 7 adds the plan's override.
  TrackingType get effectiveTracking =>
      _rig?.trackingType ?? TrackingType.unknown;

  /// The plan's blocks, read-only; change them through the methods below.
  List<CaptureBlock> get captureBlocks => List.unmodifiable(_blocks);

  /// True while the blocks are still the seeded example (TASK 4.4).
  bool get isExampleCapturePlan => _isExample;
  Session? get activeSession => _current?.session;
  int? get activeSessionId => activeSession?.id;
  Object? get autosaveFailure => _current?.writeFailure; // TASK 15.1
  bool get hasUnsavedChanges => _current?.hasUnsavedChanges ?? false; // S1.6

  /// Completes when every autosave started so far has reached the database.
  Future<void> get idle => _current?.idle ?? Future.value();

  /// The chosen night, or null without a site (ADR-007 §9).
  SessionNight? get sessionNight => _site.isDefaultLocation ? null : _night;

  /// The chosen night per ADR-007, never from a date's Y/M/D; without a site
  /// the default position's, used only as the draft's night key (S1.4).
  SessionNight get _night => SessionNightResolver.resolve(
    _pickedEveningDate,
    _clock.nowUtc(),
    latitude: _site.latitude,
    longitude: _site.longitude,
    timeContext: _site.timeContext,
  );

  CalendarDate? get eveningDate => sessionNight?.eveningDate;

  /// The plan's night key, with or without a site (S1.4).
  CalendarDate get nightKey => _night.eveningDate;

  /// Tonight's key, whatever night is picked (S6.4).
  CalendarDate get tonightKey => SessionNightResolver.resolve(
    null,
    _clock.nowUtc(),
    latitude: _site.latitude,
    longitude: _site.longitude,
    timeContext: _site.timeContext,
  ).eveningDate;

  /// The night the user picked, or null for tonight (S6.4).
  CalendarDate? get pickedNight => _pickedEveningDate;

  /// False while the plan is being restored or opened (S6.4).
  bool get isLoaded => _loaded;

  /// The plan as shown now (ADR-014 §2); its night key is [_night]'s (S1.4).
  SessionPlan currentPlan() => SessionPlan(
    eveningDate: _night.eveningDate,
    timeZoneId: _site.displayZoneId,
    siteId: _site.activeSite?.id,
    targetId: _target?.id,
    rigId: _rig?.id,
    blocks: List.of(_blocks),
    targetLabel: _target == null
        ? '(no target)'
        : _target!.commonName ?? _target!.catalogId,
    rigLabel: _rig?.name ?? '(no rig)',
    siteLabel: _site.locationName,
  );

  /// Sets the plan's contents with no autosave and no notification: the
  /// lifecycle's restore, open, new plan and copy (S6.1).
  void replaceContents({
    required AstroTarget? target,
    required EquipmentProfile? rig,
    required List<CaptureBlock> blocks,
    required bool isExample,
  }) {
    _target = target;
    _rig = rig;
    _blocks = List.of(blocks);
    _isExample = isExample;
  }

  /// Sets the picked night (null = tonight) with no autosave and no
  /// notification (S6.1).
  void replaceNight(CalendarDate? date) => _pickedEveningDate = date;

  /// Tells the listeners that the lifecycle changed the plan (S6.1).
  void markChanged() => notifyListeners();

  /// Runs a restore or an open (S6.1): a site change meanwhile is part of it,
  /// not a plan edit; afterwards the plan notifies once. A failure leaves the
  /// plan unloaded, as before the split.
  Future<void> restoring(Future<void> Function() body) async {
    _loaded = false;
    await body();
    _siteKey = _currentSiteKey();
    _loaded = true;
    notifyListeners();
  }

  Object _currentSiteKey() => (
    _site.activeSite?.id,
    _site.latitude,
    _site.longitude,
    _site.displayZoneId,
  );

  /// The night key includes the site: a site change is written into the
  /// plan. On a saved plan it is an unsaved change (V3, S6.3): leaving the
  /// plan then asks. On a never-saved draft it is not (S1.6).
  void _onSiteChanged() {
    notifyListeners();
    final key = _currentSiteKey();
    if (!_loaded || key == _siteKey) return;
    _siteKey = key;
    final saved = activeSession?.plannedAtUtc != null;
    unawaited(_current?.write(currentPlan, edit: saved));
  }

  Future<void> _edited() async {
    notifyListeners();
    final current = _current;
    if (current != null) return current.write(currentPlan);
    await _stateRepository.saveCaptureBlocks(_blocks);
    if (_target case final t?) await _stateRepository.setSelectedTargetId(t.id);
    if (_rig case final r?) await _stateRepository.setSelectedEquipmentId(r.id);
  }

  Future<void> setEveningDate(CalendarDate date) async {
    _pickedEveningDate = date;
    await _edited();
  }

  Future<void> setTarget(AstroTarget target) async {
    _target = target;
    await _edited();
  }

  Future<void> setEquipment(EquipmentProfile rig) async {
    _rig = rig;
    await _edited();
  }

  /// "Start from the example plan" (RD-04, S6.8): the example's blocks,
  /// shown as the example until the first block edit (TASK 4.4).
  Future<void> useExamplePlan() {
    _blocks = ExampleCapturePlan.blocks();
    _isExample = true;
    return _edited();
  }

  /// Any block edit ends the example plan (TASK 4.4).
  Future<void> _editBlocks(void Function(List<CaptureBlock> blocks) change) {
    change(_blocks);
    _isExample = false;
    return _edited();
  }

  bool _valid(int index) => index >= 0 && index < _blocks.length;

  Future<void> addCaptureBlock(CaptureBlock block) =>
      _editBlocks((b) => b.add(block));

  Future<void> updateCaptureBlock(int index, CaptureBlock block) async {
    if (_valid(index)) await _editBlocks((b) => b[index] = block);
  }

  Future<void> removeCaptureBlock(int index) async {
    if (_valid(index)) await _editBlocks((b) => b.removeAt(index));
  }

  /// Undo of a delete (RD-09, S6.9): [block] back at [index], and the
  /// example badge as it was, so the plan equals the one before the delete.
  Future<void> restoreCaptureBlock(
    int index,
    CaptureBlock block, {
    required bool wasExample,
  }) {
    _blocks.insert(index.clamp(0, _blocks.length), block);
    _isExample = wasExample;
    return _edited();
  }

  /// [newIndex] is already adjusted for the removal (the `onReorderItem`
  /// contract, TD-010) — do not re-adjust it.
  Future<void> reorderCaptureBlocks(int oldIndex, int newIndex) =>
      _editBlocks((b) => b.insert(newIndex, b.removeAt(oldIndex)));

  /// Re-reads the selection after an edit or delete (TASK 4.2, TD-028).
  Future<void> refreshSelectedTarget() async {
    if (_target case final t?) _target = await _targets.getTargetById(t.id);
    notifyListeners();
  }

  Future<void> refreshSelectedEquipment() async {
    if (_rig case final r?) _rig = await _equipment.getEquipmentById(r.id);
    notifyListeners();
  }

  @override
  void dispose() {
    _site.removeListener(_onSiteChanged);
    _current?.onWriteFailureChanged = null;
    super.dispose();
  }
}
