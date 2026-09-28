import '../models/calendar_date.dart';
import '../models/capture_block.dart';
import '../models/session.dart';
import '../models/session_snapshot.dart';

/// The plan a saved snapshot records, read back for Discard on a Saved ·
/// changed plan (S4-DEF-04 = R; S6.3): the night key and zone, the site,
/// target and rig references, their display labels and every block, as
/// `SessionSnapshotBuilder` wrote them. Pure.
///
/// Returns null when any of it cannot be read — the snapshot is then
/// unavailable for a revert, never partly guessed (SI-008).
abstract final class SavedPlanReader {
  static SessionPlan? read(SessionSnapshot snapshot) {
    final json = snapshot.json;
    final night = _map(json['night']);
    final eveningDate = _date(night?['eveningDate']);
    final blocks = _blocks(json['blocks']);
    if (night == null || eveningDate == null || blocks == null) return null;
    final site = _map(json['site']);
    final target = _map(json['target']);
    final rig = _map(json['rig']);
    return SessionPlan(
      eveningDate: eveningDate,
      timeZoneId: night['timeZoneId'] as String?,
      siteId: site?['id'] as int?,
      targetId: target?['id'] as int?,
      rigId: rig?['id'] as int?,
      blocks: blocks,
      // The labels as the planner writes them (`SessionPlanViewModel`).
      targetLabel: target == null
          ? '(no target)'
          : (target['commonName'] as String?) ??
                (target['catalogId'] as String? ?? '(no target)'),
      rigLabel: rig?['name'] as String? ?? '(no rig)',
      siteLabel: site?['name'] as String?,
    );
  }

  static Map<String, Object?>? _map(Object? value) =>
      value is Map ? value.cast<String, Object?>() : null;

  static CalendarDate? _date(Object? value) {
    if (value is! String) return null;
    try {
      return CalendarDate.parse(value);
    } on FormatException {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  static List<CaptureBlock>? _blocks(Object? value) {
    if (value is! List) return null;
    final blocks = <CaptureBlock>[];
    for (final item in value) {
      final b = _map(item);
      final type = _byName(FrameType.values, b?['frameType']);
      final exposure = (b?['exposureS'] as num?)?.toDouble();
      final frames = b?['frameCount'];
      if (b == null || type == null || exposure == null || frames is! int) {
        return null;
      }
      final policyName = b['calibrationPolicy'];
      final policy = _byName(CalibrationPolicy.values, policyName);
      if (policyName != null && policy == null) return null;
      try {
        blocks.add(
          CaptureBlock(
            frameType: type,
            filterName: b['filterName'] as String?,
            exposureTimeSeconds: exposure,
            frameCount: frames,
            binning: b['binning'] as int? ?? 1,
            gain: CaptureGain.fromStored(
              b['gainKind'] as String?,
              (b['gainValue'] as num?)?.toDouble(),
            ),
            calibrationPolicy: policy,
          ),
        );
      } on ArgumentError {
        return null; // a value the domain would refuse today
      }
    }
    return blocks;
  }

  static T? _byName<T extends Enum>(List<T> values, Object? name) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }
}
