import '../../domain/models/calendar_date.dart';
import '../../domain/models/capture_block.dart';
import '../../domain/models/execution.dart';
import '../../domain/models/session.dart';
import '../../domain/models/session_log.dart';
import '../../domain/models/session_snapshot.dart';
import '../../domain/models/tracking_type.dart';
import '../../domain/services/execution_machine.dart';
import '../../domain/services/session_exporter.dart';

/// A decoded manifest: its version, the app and time that wrote it, and
/// the sessions.
class ManifestContents {
  const ManifestContents({
    required this.version,
    required this.sessions,
    this.appVersion,
    this.exportedAtUtc,
  });

  final int version;
  final List<ExportedSession> sessions;
  final String? appVersion;
  final DateTime? exportedAtUtc;
}

/// The export manifest, version 2 (TASK 14.3; schema in
/// `docs/EXPORT_MANIFEST.md`). Instants are UTC epoch milliseconds, keys
/// carry their units, unknown values are null (never 0, SI-008), and the
/// snapshots are embedded as stored. Reads v2 and the old v1 (one session,
/// read as a legacy log); anything else is refused.
abstract final class SessionManifestCodec {
  static const int version = 2;

  static Map<String, Object?> encode(
    List<ExportedSession> sessions, {
    required DateTime exportedAtUtc,
    required String appVersion,
  }) => {
    'manifest_version': version,
    'app': 'AstroPlan',
    'app_version': appVersion,
    'exported_at_utc_ms': exportedAtUtc.toUtc().millisecondsSinceEpoch,
    'sessions': [for (final e in sessions) _session(e)],
  };

  /// Throws [FormatException] for an unknown version or a malformed file.
  static ManifestContents decode(Map<String, Object?> json) {
    final v = json['manifest_version'];
    if (v == 1) {
      final log = SessionLog.fromJson(Map<String, dynamic>.from(json));
      final session = Session(
        record: log,
        status: SessionStatus.completed,
        legacy: true, // v1 carries no status, night key or references
      );
      return ManifestContents(
        version: 1,
        sessions: [ExportedSession(session, const [])],
      );
    }
    if (v != version) {
      throw FormatException('Unsupported manifest version: $v');
    }
    try {
      final list = json['sessions']! as List;
      return ManifestContents(
        version: version,
        appVersion: json['app_version'] as String?,
        exportedAtUtc: _instant(json['exported_at_utc_ms'] as int?),
        sessions: [
          for (final s in list)
            _readSession(Map<String, Object?>.from(s as Map)),
        ],
      );
    } on FormatException {
      rethrow;
    } catch (e) {
      throw FormatException('Malformed manifest: $e');
    }
  }

  // Encode ------------------------------------------------------------------

  static int? _ms(DateTime? t) => t?.toUtc().millisecondsSinceEpoch;

  static Map<String, Object?> _session(ExportedSession e) {
    final s = e.session;
    final log = s.record;
    ExecutionState? state;
    try {
      state = ExecutionMachine.fold({for (final b in s.blocks) b.id}, e.events);
    } on ExecutionError {
      state = null; // counts unknown rather than guessed
    }
    return {
      'id': s.id,
      'status': s.status.name,
      'legacy': s.legacy,
      'evening_date': s.eveningDate?.toIso8601String(),
      'time_zone_id': s.timeZoneId,
      'site_id': s.siteId,
      'target_id': s.targetId,
      'rig_id': s.rigId,
      // S7.1: the plan's tracking override; absent or null = the rig's.
      'tracking_override': s.trackingOverride?.name,
      'created_at_utc_ms': _ms(s.createdAtUtc),
      'updated_at_utc_ms': _ms(s.updatedAtUtc),
      'planned_at_utc_ms': _ms(s.plannedAtUtc),
      'started_at_utc_ms': _ms(s.startedAtUtc),
      'completed_at_utc_ms': _ms(s.completedAtUtc),
      'labels': {
        'target': log.targetName,
        'rig': log.equipmentName,
        'site': log.locationName,
        'session_date_utc_ms': _ms(log.sessionDate),
      },
      'blocks': [
        for (final b in s.blocks)
          {
            'id': b.id,
            'frame_type': b.frameType.name,
            'filter_name': b.filterName,
            'exposure_s': b.exposureTimeSeconds,
            'frame_count': b.frameCount,
            'binning': b.binning,
            'gain_kind': b.gain.kind.name,
            'gain_value': b.gain.value,
            'calibration_policy': b.calibrationPolicy?.name,
            'confirmed_frames': state?.completedFor(b.id),
            'rejected_frames': state?.rejectedFor(b.id),
          },
      ],
      'results': {
        'planned_light_frames': log.plannedLightFrames,
        'actual_light_frames': log.actualLightFrames,
        'rejected_frames': log.rejectedFrames,
        'environmental_notes': log.environmentalNotes,
        'processing_notes': log.processingNotes,
        'temperature_c': log.temperature,
        'humidity_pct': log.humidity,
        'cloud_cover_pct': log.cloudCover,
      },
      'legacy_values': {
        'bortle_scale': log.bortleScale,
        'focal_length_mm': log.focalLength,
        'aperture_f': log.aperture,
        'integration_time_s': log.integrationTimeSeconds,
        'planned_dark_frames': log.plannedDarkFrames,
        'planned_flat_frames': log.plannedFlatFrames,
        'planned_bias_frames': log.plannedBiasFrames,
      },
      'plan_snapshot': s.planSnapshot?.json,
      'execution_start_snapshot': s.executionStartSnapshot?.json,
      'events': [
        for (final ev in e.events)
          {
            'seq': ev.seq,
            'at_utc_ms': ev.atUtc.millisecondsSinceEpoch,
            'kind': ev.kind.name,
            'block_id': ev.blockId,
            'delta': ev.delta,
            'reason': ev.reason?.name,
            'clock_adjusted': ev.clockAdjusted,
          },
      ],
    };
  }

  // Decode ------------------------------------------------------------------

  static DateTime? _instant(int? ms) =>
      ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

  static double? _d(Object? v) => (v as num?)?.toDouble();

  static Map<String, Object?> _map(Object? v) =>
      v == null ? const {} : Map<String, Object?>.from(v as Map);

  static ExportedSession _readSession(Map<String, Object?> j) {
    final labels = _map(j['labels']);
    final results = _map(j['results']);
    final legacy = _map(j['legacy_values']);
    final id = j['id']! as int;
    final blocks = [
      for (final raw in (j['blocks'] as List? ?? const []))
        _readBlock(Map<String, Object?>.from(raw as Map), id),
    ];
    final events = [
      for (final raw in (j['events'] as List? ?? const []))
        _readEvent(Map<String, Object?>.from(raw as Map)),
    ];
    final evening = j['evening_date'] as String?;
    final plan = j['plan_snapshot'];
    final start = j['execution_start_snapshot'];
    final session = Session(
      record: SessionLog(
        id: id,
        targetName: labels['target']! as String,
        equipmentName: labels['rig']! as String,
        locationName: labels['site'] as String?,
        sessionDate: _instant(labels['session_date_utc_ms'] as int?)!,
        captureBlocks: blocks,
        plannedLightFrames: results['planned_light_frames'] as int? ?? 0,
        actualLightFrames: results['actual_light_frames'] as int?,
        rejectedFrames: results['rejected_frames'] as int?,
        environmentalNotes: results['environmental_notes'] as String?,
        processingNotes: results['processing_notes'] as String?,
        temperature: _d(results['temperature_c']),
        humidity: _d(results['humidity_pct']),
        cloudCover: results['cloud_cover_pct'] as int?,
        bortleScale: _d(legacy['bortle_scale']),
        focalLength: _d(legacy['focal_length_mm']),
        aperture: _d(legacy['aperture_f']),
        integrationTimeSeconds: _d(legacy['integration_time_s']),
        plannedDarkFrames: legacy['planned_dark_frames'] as int?,
        plannedFlatFrames: legacy['planned_flat_frames'] as int?,
        plannedBiasFrames: legacy['planned_bias_frames'] as int?,
      ),
      status: SessionStatus.parse(j['status']! as String),
      legacy: j['legacy']! as bool,
      eveningDate: evening == null ? null : CalendarDate.parse(evening),
      timeZoneId: j['time_zone_id'] as String?,
      siteId: j['site_id'] as int?,
      targetId: j['target_id'] as int?,
      rigId: j['rig_id'] as int?,
      trackingOverride: TrackingType.overrideFromStorage(
        j['tracking_override'] as String?,
      ),
      createdAtUtc: _instant(j['created_at_utc_ms'] as int?),
      updatedAtUtc: _instant(j['updated_at_utc_ms'] as int?),
      plannedAtUtc: _instant(j['planned_at_utc_ms'] as int?),
      startedAtUtc: _instant(j['started_at_utc_ms'] as int?),
      completedAtUtc: _instant(j['completed_at_utc_ms'] as int?),
      planSnapshot: plan == null
          ? null
          : SessionSnapshot.tryRead(Map<String, Object?>.from(plan as Map)),
      executionStartSnapshot: start == null
          ? null
          : SessionSnapshot.tryRead(Map<String, Object?>.from(start as Map)),
    );
    return ExportedSession(session, events);
  }

  static CaptureBlock _readBlock(Map<String, Object?> b, int sessionId) {
    final type = CaptureBlock.tryParseFrameType(b['frame_type'] as String?);
    if (type == null) {
      throw FormatException('Unknown frame type in block ${b['id']}');
    }
    return CaptureBlock(
      id: b['id']! as int,
      sessionLogId: sessionId,
      frameType: type,
      filterName: b['filter_name'] as String?,
      exposureTimeSeconds: _d(b['exposure_s'])!,
      frameCount: b['frame_count']! as int,
      binning: b['binning'] as int? ?? 1,
      gain: CaptureGain.fromStored(
        b['gain_kind'] as String? ?? 'unknown',
        _d(b['gain_value']),
      ),
      calibrationPolicy: type == FrameType.light
          ? null
          : CalibrationPolicy.tryParse(b['calibration_policy'] as String?),
    );
  }

  static ExecutionEvent _readEvent(Map<String, Object?> e) {
    final kind = ExecutionEventKind.tryParse(e['kind'] as String?);
    if (kind == null) {
      throw FormatException('Unknown event kind: ${e['kind']}');
    }
    return ExecutionEvent(
      seq: e['seq']! as int,
      atUtc: _instant(e['at_utc_ms']! as int)!,
      kind: kind,
      blockId: e['block_id'] as int?,
      delta: e['delta'] as int?,
      reason: InterruptionReason.tryParse(e['reason'] as String?),
      clockAdjusted: e['clock_adjusted'] as bool? ?? false,
    );
  }
}
