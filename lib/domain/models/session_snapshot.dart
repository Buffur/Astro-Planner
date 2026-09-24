import 'astro_target.dart';
import 'calendar_date.dart';
import 'session_night.dart';

/// A frozen, versioned record of a session's context (ADR-014 §4): site,
/// target, rig, night, the preferences in force, the budget, the
/// opportunity and the weather, as JSON-ready data. History reads these,
/// never live rows. Built by `SessionSnapshotBuilder`.
///
/// Keys carry their units (`latitudeDeg`, `focalLengthMm`, `…UtcMs`);
/// unknown values are stored as null, never as zero (SI-008).
class SessionSnapshot {
  const SessionSnapshot._(this.json);

  /// The format version this app writes and reads.
  static const int currentVersion = 1;

  /// The data exactly as stored.
  final Map<String, Object?> json;

  /// Wraps [json] when it is a snapshot this app can read; null for no data,
  /// an unreadable value (an empty map) or an unknown version — then the
  /// snapshot is "unavailable", never partially guessed.
  static SessionSnapshot? tryRead(Map<String, Object?>? json) {
    if (json == null || json['v'] != currentVersion) return null;
    return SessionSnapshot._(Map.unmodifiable(json));
  }

  /// For the builder only: [json] must carry `v: currentVersion`.
  factory SessionSnapshot.fromBuilder(Map<String, Object?> json) {
    if (json['v'] != currentVersion) {
      throw ArgumentError('snapshot must be version $currentVersion');
    }
    return SessionSnapshot._(Map.unmodifiable(json));
  }

  Map<String, Object?>? _section(String key) =>
      (json[key] as Map?)?.cast<String, Object?>();

  DateTime get takenAtUtc => DateTime.fromMillisecondsSinceEpoch(
    json['takenAtUtcMs']! as int,
    isUtc: true,
  );

  CalendarDate? get eveningDate {
    final s = _section('night')?['eveningDate'] as String?;
    return s == null ? null : CalendarDate.parse(s);
  }

  /// The end of the snapshot's night (ADR-016 §5: a run past it is stale).
  DateTime? get nightEndUtc {
    final ms = _section('night')?['endUtcMs'] as int?;
    return ms == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  /// The snapshot's night, rebuilt from its stored values (never from the
  /// live site, ADR-014 §2); null when incomplete.
  SessionNight? get night {
    final n = _section('night');
    final date = n?['eveningDate'] as String?;
    final start = n?['startUtcMs'] as int?;
    final end = n?['endUtcMs'] as int?;
    final lat = (n?['latitudeDeg'] as num?)?.toDouble();
    final lon = (n?['longitudeDeg'] as num?)?.toDouble();
    if (date == null || start == null || end == null) return null;
    if (lat == null || lon == null) return null;
    try {
      return SessionNight(
        eveningDate: CalendarDate.parse(date),
        startUtc: DateTime.fromMillisecondsSinceEpoch(start, isUtc: true),
        endUtc: DateTime.fromMillisecondsSinceEpoch(end, isUtc: true),
        latitude: lat,
        longitude: lon,
        timeContextId: n?['timeContextId'] as String? ?? '',
      );
    } on ArgumentError {
      return null; // an inconsistent window reads as unavailable
    }
  }

  /// The IANA zone the night's times were shown in (null = device zone).
  String? get timeZoneId => _section('night')?['timeZoneId'] as String?;

  /// The target as it was (J2000 coordinates); null when none was chosen.
  AstroTarget? get target {
    final t = _section('target');
    final ra = (t?['raDegJ2000'] as num?)?.toDouble();
    final dec = (t?['decDegJ2000'] as num?)?.toDouble();
    if (t == null || ra == null || dec == null) return null;
    return AstroTarget(
      id: t['id'] as int? ?? 0,
      catalogId: t['catalogId'] as String? ?? '',
      commonName: t['commonName'] as String?,
      type: t['type'] as String? ?? '',
      rightAscension: ra,
      declination: dec,
    );
  }

  /// The minimum target altitude in force, degrees.
  double? get minAltitudeDeg =>
      (_section('preferences')?['minAltitudeDeg'] as num?)?.toDouble();

  /// The imaging windows planned for the night (UTC), in order; empty when
  /// there were none or no opportunity was recorded.
  List<(DateTime, DateTime)> get windows {
    final list = _section('opportunity')?['windows'] as List?;
    return [
      for (final w in list ?? const [])
        if (w is Map)
          (
            DateTime.fromMillisecondsSinceEpoch(
              w['startUtcMs'] as int,
              isUtc: true,
            ),
            DateTime.fromMillisecondsSinceEpoch(
              w['endUtcMs'] as int,
              isUtc: true,
            ),
          ),
    ];
  }

  /// The per-frame overhead in force when the snapshot was taken, seconds.
  double? get perFrameOverheadSeconds =>
      (_section('preferences')?['perFrameOverheadS'] as num?)?.toDouble();

  // Detail-page reads (TASK 14.1). Every value is null when absent —
  // never a default (SI-008).
  double? _num(String section, String key) =>
      (_section(section)?[key] as num?)?.toDouble();
  Duration? _ms(String section, String key) {
    final ms = _section(section)?[key] as int?;
    return ms == null ? null : Duration(milliseconds: ms);
  }

  double? get siteLatitudeDeg => _num('site', 'latitudeDeg');
  double? get siteLongitudeDeg => _num('site', 'longitudeDeg');
  double? get siteElevationM => _num('site', 'elevationM');
  int? get bortleClass => _section('skyDarkness')?['bortleClass'] as int?;
  double? get sqm => _num('skyDarkness', 'sqmMagArcsec2');
  double? get rigFocalRatio => _num('rig', 'focalRatio');
  double? get rigPixelPitchUm => _num('rig', 'pixelPitchUm');
  double? get darknessLimitDeg => _num('preferences', 'darknessLimitDeg');
  Duration? get integration => _ms('budget', 'integrationMs');
  Duration? get windowLoad => _ms('budget', 'windowLoadMs');
  Duration? get sessionBudget => _ms('budget', 'sessionBudgetMs');
  Duration? get usableTime => _ms('opportunity', 'usableMs');

  /// `available`, `outOfRange`, `unavailable` or `none`; null if absent.
  String? get weatherState => _section('weather')?['state'] as String?;
  String? get weatherSource {
    final w = _section('weather');
    final provider = w?['provider'] as String?, model = w?['model'] as String?;
    return provider == null ? null : '$provider / ${model ?? '?'}';
  }

  DateTime? get weatherFetchedAtUtc {
    final ms = _section('weather')?['fetchedAtUtcMs'] as int?;
    return ms == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  }

  String? get siteName => _section('site')?['name'] as String?;
  String? get targetName =>
      _section('target')?['commonName'] as String? ??
      _section('target')?['catalogId'] as String?;
  String? get rigName => _section('rig')?['name'] as String?;
  double? get rigFocalLengthMm =>
      (_section('rig')?['focalLengthMm'] as num?)?.toDouble();
}
