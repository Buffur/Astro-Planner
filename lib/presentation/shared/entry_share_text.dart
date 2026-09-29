import '../../core/config/app_identity.dart';
import '../../core/utils/quantity_text.dart';
import '../../domain/models/calendar_date.dart';
import '../../domain/models/capture_block.dart';
import '../../domain/models/session.dart';
import '../../domain/models/session_result.dart';
import '../../domain/services/session_reconciliation.dart';
import 'night_time_formatter.dart';
import 'opportunity_text.dart';
import 'plan_state.dart';

/// A Logbook entry as shared text (S8.7; D8-4, 08 §24): structured,
/// human-readable, with only the fields the entry holds. **Never the notes
/// and never the site's coordinates** (private by default); Export as file
/// is the complete record. Pure: the same entry gives the same text.
abstract final class EntryShareText {
  static String of(Session s, {SessionReconciliation? reconciliation}) {
    final log = s.record;
    final snap = s.executionStartSnapshot ?? s.planSnapshot;
    final night =
        s.eveningDate ??
        CalendarDate.fromDateTimeFields(log.sessionDate.toLocal());
    final target = snap?.targetName ?? log.targetName;
    final lines = <String>[
      ?s.name,
      '$target · ${NightTimeFormatter.eveningDate(night)}',
      '',
      if (s.legacy)
        'Night of ${NightTimeFormatter.eveningDate(night)}'
      else
        'Night of ${NightTimeFormatter.eveningDate(night)} '
            '(${s.timeZoneId ?? snap?.timeZoneId ?? 'device zone'})',
      if (snap?.siteName ?? log.locationName case final site?) 'Site: $site',
      'Rig: ${snap?.rigName ?? log.equipmentName}',
      'Result: ${result(s)}',
      ..._counts(s, reconciliation),
      if (_conditions(s) case final c?) 'Conditions: $c',
      '',
      '— ${AppIdentity.appName}',
    ];
    return lines.join('\n');
  }

  /// The entry's result in words: its state, and how it was reported.
  static String result(Session s) {
    final state = PlanState.of(s).word;
    if (s.legacy) return state;
    return switch (s.status) {
      SessionStatus.completed => switch (s.resultKind) {
        ResultKind.asPlanned => '$state, reported as planned',
        ResultKind.partly => state,
        null => '$state, counted during a live run',
      },
      SessionStatus.abandoned => switch (s.notDoneReason) {
        final r? => '$state (${r.name})',
        null => state,
      },
      SessionStatus.inProgress => '$state, no result yet',
      SessionStatus.planned || SessionStatus.draft => '$state, no result yet',
    };
  }

  static List<String> _counts(Session s, SessionReconciliation? r) {
    if (s.legacy) {
      final taken = s.record.actualLightFrames;
      return [
        'Light frames: ${s.record.plannedLightFrames} planned'
            '${taken == null ? '' : ', $taken taken'}',
      ];
    }
    final counted =
        s.status == SessionStatus.completed ||
        s.status == SessionStatus.inProgress ||
        s.startedAtUtc != null;
    if (r == null) return const [];
    return [
      if (counted)
        'Integration: ${OpportunityText.duration(r.actualIntegration)} of '
            '${OpportunityText.duration(r.plannedIntegration)} planned'
      else
        'Integration planned: ${OpportunityText.duration(r.plannedIntegration)}',
      for (final b in r.blocks)
        if (b.block.frameType == FrameType.light)
          '  ${b.block.filterName ?? 'Light'} · '
              '${QuantityText.exposure(b.block.exposureTimeSeconds)}: '
              '${counted ? '${b.confirmed} of ${b.planned}' : '${b.planned} planned'}',
    ];
  }

  static String? _conditions(Session s) {
    final log = s.record;
    final parts = [
      if (log.temperature case final t?)
        '${QuantityText.signed(t, digits: 1)} °C',
      if (log.humidity case final h?) '${h.round()} % humidity',
      if (log.cloudCover case final c?) '$c % cloud',
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }
}
