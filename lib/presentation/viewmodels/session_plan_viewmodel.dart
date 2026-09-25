import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/time/clock.dart';
import '../../domain/models/astro_target.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/capture_block.dart';
import '../../domain/models/equipment_profile.dart';
import '../../domain/models/session.dart';
import '../../domain/models/session_night.dart';
import '../../domain/models/session_snapshot.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/repositories/planner_state_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/repositories/storage_failure.dart';
import '../../domain/repositories/target_repository.dart';
import '../../domain/services/current_session.dart';
import '../../domain/services/example_capture_plan.dart';
import '../../domain/services/session_night_resolver.dart';
import '../../domain/services/session_reference_resolver.dart';
import 'site_viewmodel.dart';

/// The session the planner works on (ADR-014; TASKs 11.3–11.4; split out
/// of the planner ViewModel in TASK 12.3): its night, target, rig and
/// capture blocks. Every plan edit — a site change included — is autosaved
/// into the current session before the edit call returns.
class SessionPlanViewModel extends ChangeNotifier {
  SessionPlanViewModel({
    required this._site,
    required TargetRepository targetRepository,
    required EquipmentRepository equipmentRepository,
    required this._stateRepository,
    required this._clock,
    SessionRepository? sessionRepository,
  }) : _targets = targetRepository,
       _equipment = equipmentRepository,
       _current = sessionRepository == null
           ? null
           : CurrentSession(sessionRepository),
       _resolver = SessionReferenceResolver(
         targetRepository,
         equipmentRepository,
       ) {
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
  final SessionReferenceResolver _resolver;

  AstroTarget? _target;
  EquipmentProfile? _rig;
  List<CaptureBlock> _blocks = [];
  bool _isExample = true;
  CalendarDate? _pickedEveningDate;
  bool _loaded = false;
  Object? _siteKey;

  AstroTarget? get selectedTarget => _target;
  EquipmentProfile? get selectedEquipment => _rig;

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

  /// Restores the plan (call after the site has loaded): a plan still kept
  /// in preferences moves once into a new draft (ADR-014 §6); otherwise the
  /// most recent open session is resumed — a past night rolls forward to
  /// tonight (owner decision, TASK 11.4) — or a draft is created. An
  /// unreadable saved plan is logged by the repository and dropped.
  Future<void> load() async {
    final preferencesPlan = await _stateRepository
        .loadCaptureBlocks()
        .onError<StorageFailure>((_, _) => null);
    _blocks = List.of(preferencesPlan ?? const []);
    _isExample = _blocks.isEmpty;
    if (_blocks.isEmpty) _blocks = ExampleCapturePlan.blocks();
    final targetId = await _stateRepository.getSelectedTargetId();
    if (targetId != null) _target = await _targets.getTargetById(targetId);
    _target ??= (await _targets.searchTargets('M42')).firstOrNull;
    final rigId = await _stateRepository.getSelectedEquipmentId();
    if (rigId != null) _rig = await _equipment.getEquipmentById(rigId);
    _rig ??= (await _equipment.getAllEquipment()).firstOrNull;

    final current = _current;
    if (current != null) {
      final open = preferencesPlan == null ? await current.resume() : null;
      if (open == null) {
        await current.startNew(_plan());
        if (preferencesPlan != null) await _stateRepository.clearPlan();
      } else {
        await _apply(open);
        final stored = open.eveningDate;
        _pickedEveningDate =
            stored != null && stored.compareTo(_night.eveningDate) > 0
            ? stored
            : null;
        // A run in progress is tracked, never edited: plan on a copy
        // (owner decision, TASK 13.3; TD-055).
        if (!open.planEditable) await current.adopt(open, _plan);
      }
    }
    _loaded = true;
    _siteKey = _currentSiteKey();
    notifyListeners();
  }

  Future<void> _apply(Session session) async {
    _target = await _resolver.target(session) ?? _target;
    _rig = await _resolver.rig(session) ?? _rig;
    if (session.blocks.isNotEmpty) _blocks = List.of(session.blocks);
    _isExample = ExampleCapturePlan.matches(_blocks);
  }

  /// The plan as shown now (ADR-014 §2); without a site the night key is
  /// the picked date, else the default position's default night (S1.4).
  SessionPlan _plan() => SessionPlan(
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

  Object _currentSiteKey() => (
    _site.activeSite?.id,
    _site.latitude,
    _site.longitude,
    _site.displayZoneId,
  );

  /// The night key includes the site: a site change is a plan edit.
  void _onSiteChanged() {
    notifyListeners();
    final key = _currentSiteKey();
    if (!_loaded || key == _siteKey) return;
    _siteKey = key;
    unawaited(_current?.write(_plan, edit: false));
  }

  Future<void> _edited() async {
    notifyListeners();
    final current = _current;
    if (current != null) return current.write(_plan);
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

  /// Opens [session] (TASK 11.4): its site, night, target, rig and blocks.
  /// A draft or planned session becomes current; a frozen one is copied
  /// into a new draft on its night, never modified.
  Future<void> openSession(Session session) async {
    _loaded = false; // switching the site here is opening, not an edit
    if (session.siteId case final id?) await _site.selectSite(id);
    _pickedEveningDate =
        session.eveningDate ??
        CalendarDate.fromDateTimeFields(session.record.sessionDate.toLocal());
    await _apply(session);
    await _current?.adopt(session, _plan);
    _siteKey = _currentSiteKey();
    _loaded = true;
    notifyListeners();
  }

  /// A new draft for tonight with the example plan (owner decision).
  Future<void> newSession() async {
    _pickedEveningDate = null;
    _blocks = ExampleCapturePlan.blocks();
    _isExample = true;
    await _current?.startNew(_plan());
    notifyListeners();
  }

  /// A new draft with the current plan on [date]; the original stays.
  Future<void> duplicateForNight(CalendarDate date) async {
    _pickedEveningDate = date;
    await _current?.startNew(_plan());
    notifyListeners();
  }

  /// Save (ADR-014 §3): the current open session — or a new one — becomes
  /// planned with [snapshot]. Needs a repository, a night, target and rig.
  Future<Session> savePlan(SessionSnapshot snapshot) =>
      _commit((c) => c.save(_plan(), snapshot));

  /// Start (ADR-016; owner: same requirements as Save): the plan starts
  /// with [snapshot] and the planner continues on a fresh draft copy.
  Future<Session> startPlan(SessionSnapshot snapshot) =>
      _commit((c) => c.start(_plan(), snapshot));

  Future<Session> _commit(Future<Session> Function(CurrentSession) f) async {
    final current = _current;
    if (current == null ||
        sessionNight == null ||
        _target == null ||
        _rig == null) {
      throw StateError('Saving needs a site, a target and a rig.');
    }
    final result = await f(current);
    notifyListeners();
    return result;
  }

  @override
  void dispose() {
    _site.removeListener(_onSiteChanged);
    _current?.onWriteFailureChanged = null;
    super.dispose();
  }
}
