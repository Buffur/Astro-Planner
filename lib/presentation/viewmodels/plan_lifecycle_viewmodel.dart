import '../../domain/models/astro_target.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/capture_block.dart';
import '../../domain/models/equipment_profile.dart';
import '../../domain/models/session.dart';
import '../../domain/models/session_snapshot.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../../domain/repositories/planner_state_repository.dart';
import '../../domain/repositories/storage_failure.dart';
import '../../domain/repositories/target_repository.dart';
import '../../domain/services/current_session.dart';
import '../../domain/services/example_capture_plan.dart';
import '../../domain/services/session_reference_resolver.dart';
import 'session_plan_viewmodel.dart';
import 'site_viewmodel.dart';

/// Which plan the planner works on (ADR-014 §3; TASKs 11.3–11.4, 13.3;
/// split out of [SessionPlanViewModel] in S6.1): restoring it at startup,
/// opening a stored one, starting a new one, copying it to another night,
/// saving it and starting a run. The plan's contents, their edits and the
/// autosave stay in [SessionPlanViewModel], which notifies for both.
class PlanLifecycleViewModel {
  PlanLifecycleViewModel({
    required this._plan,
    required this._site,
    required TargetRepository targetRepository,
    required EquipmentRepository equipmentRepository,
    required this._stateRepository,
    CurrentSession? currentSession,
  }) : _targets = targetRepository,
       _equipment = equipmentRepository,
       _current = currentSession,
       _resolver = SessionReferenceResolver(
         targetRepository,
         equipmentRepository,
       );

  final SessionPlanViewModel _plan;
  final SiteViewModel _site;
  final TargetRepository _targets;
  final EquipmentRepository _equipment;
  final PlannerStateRepository _stateRepository;

  /// Null only in tests without a session repository (plan in preferences).
  final CurrentSession? _current;
  final SessionReferenceResolver _resolver;

  /// Restores the plan (call after the site has loaded): a plan still kept
  /// in preferences moves once into a new draft (ADR-014 §6); otherwise the
  /// most recent open session is resumed — a past night rolls forward to
  /// tonight (owner decision, TASK 11.4) — or a draft is created. An
  /// unreadable saved plan is logged by the repository and dropped.
  Future<void> load() => _plan
      .restoring(() async {
        final preferencesPlan = await _stateRepository
            .loadCaptureBlocks()
            .onError<StorageFailure>((_, _) => null);
        final blocks = List.of(preferencesPlan ?? const <CaptureBlock>[]);
        final isExample = blocks.isEmpty;
        if (blocks.isEmpty) blocks.addAll(ExampleCapturePlan.blocks());
        AstroTarget? target = _plan.selectedTarget;
        final targetId = await _stateRepository.getSelectedTargetId();
        if (targetId != null) target = await _targets.getTargetById(targetId);
        target ??= (await _targets.searchTargets('M42')).firstOrNull;
        EquipmentProfile? rig = _plan.selectedEquipment;
        final rigId = await _stateRepository.getSelectedEquipmentId();
        if (rigId != null) rig = await _equipment.getEquipmentById(rigId);
        rig ??= (await _equipment.getAllEquipment()).firstOrNull;
        _plan.replaceContents(
          target: target,
          rig: rig,
          blocks: blocks,
          isExample: isExample,
        );

        final current = _current;
        if (current == null) return;
        final open = preferencesPlan == null ? await current.resume() : null;
        if (open == null) {
          await current.startNew(_plan.currentPlan());
          if (preferencesPlan != null) await _stateRepository.clearPlan();
          return;
        }
        await _apply(open);
        _plan.replaceNight(_keptNight(open.eveningDate));
        // S6.4 (TD-057): a never-saved draft's rolled-forward night is stored
        // now, not at its next edit. A saved plan is not written (D1).
        if (_neverSaved(open) && open.eveningDate != _plan.nightKey) {
          await current.write(_plan.currentPlan, edit: false);
        }
        // A run in progress is tracked, never edited: plan on a copy
        // (owner decision, TASK 13.3; TD-055).
        if (!open.planEditable) await current.adopt(open, _plan.currentPlan);
      })
      .then((_) {
        _tonight = _plan.tonightKey;
      });

  /// The only plan a new night moves (ADR-019 §3.1, D1): one never saved.
  static bool _neverSaved(Session s) =>
      s.status == SessionStatus.draft && s.plannedAtUtc == null;

  /// The night a plan keeps when tonight moves on: a picked night still
  /// ahead, else tonight (null) — TASK 11.4's roll-forward.
  CalendarDate? _keptNight(CalendarDate? night) =>
      night != null && night.compareTo(_plan.tonightKey) > 0 ? night : null;

  CalendarDate? _followedNight;

  /// Tonight as of the last restore or rollover check (S6.4).
  CalendarDate? _tonight;

  /// Follows a new night while the app runs (S6.4; TD-057), before the
  /// forecast's check (`NightClock`, every minute and on resume). Only a
  /// never-saved draft moves. When tonight has moved on since the last check,
  /// a picked night that is no longer ahead rolls forward to tonight, as at
  /// a restart; a night picked in the past meanwhile stays until then. Its
  /// night key is written through the autosave chain, not as a user edit. A
  /// saved plan keeps today's behaviour until Stage 8 (D1): nothing of it is
  /// written. Screens that show the plan's night are told when it changes.
  Future<void> followNight() async {
    if (!_plan.isLoaded) return;
    final tonight = _plan.tonightKey;
    final rolledOver = _tonight != null && tonight != _tonight;
    _tonight = tonight;
    final current = _current;
    final session = current?.session;
    if (current != null && session != null && _neverSaved(session)) {
      final picked = _plan.pickedNight;
      final kept = rolledOver ? _keptNight(picked) : picked;
      if (kept != picked) _plan.replaceNight(kept);
      if (session.eveningDate != _plan.nightKey) {
        await current.write(_plan.currentPlan, edit: false);
      }
    }
    final night = _plan.nightKey;
    if (night == _followedNight) return;
    _followedNight = night;
    _plan.markChanged();
  }

  /// [session]'s references and blocks into the plan; what it lacks stays.
  Future<void> _apply(Session session) async {
    final blocks = session.blocks.isNotEmpty
        ? session.blocks
        : _plan.captureBlocks;
    _plan.replaceContents(
      target: await _resolver.target(session) ?? _plan.selectedTarget,
      rig: await _resolver.rig(session) ?? _plan.selectedEquipment,
      blocks: blocks,
      isExample: ExampleCapturePlan.matches(blocks),
    );
  }

  /// Opens [session] (TASK 11.4): a draft or planned one becomes current, a
  /// frozen one is copied into a new draft; the current, editable one is left
  /// as it is live — a caller's copy may be stale (S1.V4, TD-062).
  Future<void> openSession(Session session) async {
    if (session.id == _plan.activeSessionId && session.planEditable) return;
    // Switching the site here is opening, not an edit.
    await _plan.restoring(() async {
      if (session.siteId case final id?) await _site.selectSite(id);
      _plan.replaceNight(
        session.eveningDate ??
            CalendarDate.fromDateTimeFields(
              session.record.sessionDate.toLocal(),
            ),
      );
      await _apply(session);
      await _current?.adopt(session, _plan.currentPlan);
    });
  }

  /// A new draft for tonight with the example plan (owner decision).
  Future<void> newSession() async {
    _plan.replaceNight(null);
    _plan.replaceContents(
      target: _plan.selectedTarget,
      rig: _plan.selectedEquipment,
      blocks: ExampleCapturePlan.blocks(),
      isExample: true,
    );
    await _current?.startNew(_plan.currentPlan());
    _plan.markChanged();
  }

  /// A new draft with the current plan on [date]; the original stays.
  Future<void> duplicateForNight(CalendarDate date) async {
    _plan.replaceNight(date);
    await _current?.startNew(_plan.currentPlan());
    _plan.markChanged();
  }

  /// Save (ADR-014 §3): the current open session — or a new one — becomes
  /// planned with [snapshot]. Needs a repository, a night, target and rig.
  Future<Session> savePlan(SessionSnapshot snapshot) =>
      _commit((c) => c.save(_plan.currentPlan(), snapshot));

  /// Start (ADR-016; owner: same requirements as Save): the plan starts
  /// with [snapshot] and the planner continues on a fresh draft copy.
  Future<Session> startPlan(SessionSnapshot snapshot) =>
      _commit((c) => c.start(_plan.currentPlan(), snapshot));

  Future<Session> _commit(Future<Session> Function(CurrentSession) f) async {
    final current = _current;
    if (current == null ||
        _plan.sessionNight == null ||
        _plan.selectedTarget == null ||
        _plan.selectedEquipment == null) {
      throw StateError('Saving needs a site, a target and a rig.');
    }
    final result = await f(current);
    _plan.markChanged();
    return result;
  }
}
