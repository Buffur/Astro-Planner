/// Sun-altitude limit that defines "dark enough" for imaging windows.
///
/// These are preferences, not laws: −18° is astronomical darkness, and
/// −15° / −12° trade some sky background for longer windows (SI-006).
enum DarknessLimit {
  astronomical(-18.0),
  deepNautical(-15.0),
  nautical(-12.0);

  const DarknessLimit(this.degrees);

  /// Sun altitude in degrees.
  final double degrees;

  static DarknessLimit fromDegrees(double? degrees) => DarknessLimit.values
      .firstWhere((l) => l.degrees == degrees, orElse: () => astronomical);
}

/// The user's planning thresholds and capture-overhead defaults
/// (TASK 5.2, ADR-009 §4 and §6, SI-006, TD-043).
///
/// Every default below is a documented **assumption**, not a scientific
/// law, and every value is clamped to its valid range on construction.
///
/// An optional overhead that is `null` is **off** and must be shown as
/// "not included", never as a hidden zero (ADR-009 §4, SI-008).
class PlanningPreferences {
  factory PlanningPreferences({
    double minAltitudeDeg = defaultMinAltitudeDeg,
    DarknessLimit darknessLimit = DarknessLimit.astronomical,
    double feasibilityMarginPercent = defaultFeasibilityMarginPercent,
    double dewMarginC = defaultDewMarginC,
    double perFrameOverheadSeconds = defaultPerFrameOverheadSeconds,
    int? ditherEveryNFrames,
    double ditherSettleSeconds = defaultDitherSettleSeconds,
    double? refocusEveryMinutes,
    double refocusSeconds = defaultRefocusSeconds,
    double? filterChangeSeconds,
    double? meridianFlipSeconds,
    double? setupMinutes,
    double npfK = defaultNpfK,
  }) => PlanningPreferences._(
    minAltitudeDeg: _clamp(minAltitudeDeg, minAltitudeRange),
    darknessLimit: darknessLimit,
    feasibilityMarginPercent: _clamp(feasibilityMarginPercent, marginRange),
    dewMarginC: _clamp(dewMarginC, dewMarginRange),
    perFrameOverheadSeconds: _clamp(perFrameOverheadSeconds, perFrameRange),
    ditherEveryNFrames: ditherEveryNFrames?.clamp(1, 100),
    ditherSettleSeconds: _clamp(ditherSettleSeconds, overheadSecondsRange),
    refocusEveryMinutes: refocusEveryMinutes == null
        ? null
        : _clamp(refocusEveryMinutes, refocusIntervalRange),
    refocusSeconds: _clamp(refocusSeconds, overheadSecondsRange),
    filterChangeSeconds: filterChangeSeconds == null
        ? null
        : _clamp(filterChangeSeconds, overheadSecondsRange),
    meridianFlipSeconds: meridianFlipSeconds == null
        ? null
        : _clamp(meridianFlipSeconds, flipSecondsRange),
    setupMinutes: setupMinutes == null
        ? null
        : _clamp(setupMinutes, setupMinutesRange),
    npfK: _clamp(npfK, npfKRange),
  );

  const PlanningPreferences._({
    required this.minAltitudeDeg,
    required this.darknessLimit,
    required this.feasibilityMarginPercent,
    required this.dewMarginC,
    required this.perFrameOverheadSeconds,
    required this.ditherEveryNFrames,
    required this.ditherSettleSeconds,
    required this.refocusEveryMinutes,
    required this.refocusSeconds,
    required this.filterChangeSeconds,
    required this.meridianFlipSeconds,
    required this.setupMinutes,
    required this.npfK,
  });

  // Defaults (assumptions) ---------------------------------------------------

  /// 20°: below this, extinction and seeing usually hurt image quality; a
  /// common rule of thumb, not a sourced figure.
  static const double defaultMinAltitudeDeg = 20.0;

  /// 15 %: the margin the app has always used (the fixed 85 % threshold),
  /// kept so results don't shift silently (ADR-009 §6).
  static const double defaultFeasibilityMarginPercent = 15.0;

  /// 2 °C between air temperature and dew point before warning.
  static const double defaultDewMarginC = 2.0;

  /// 5 s per frame (download or interval gap): the value the app already
  /// used, kept by owner decision (ADR-009 §4). Measure your rig.
  static const double defaultPerFrameOverheadSeconds = 5.0;

  /// Values pre-filled when the user switches an optional overhead on.
  static const double defaultDitherSettleSeconds = 15.0;
  static const double defaultRefocusSeconds = 90.0;

  // Valid ranges (inclusive) -------------------------------------------------

  static const (double, double) minAltitudeRange = (5.0, 60.0);
  static const (double, double) marginRange = (0.0, 50.0);
  static const (double, double) dewMarginRange = (0.0, 10.0);
  static const (double, double) perFrameRange = (0.0, 120.0);
  static const (double, double) overheadSecondsRange = (0.0, 600.0);
  static const (double, double) refocusIntervalRange = (10.0, 600.0);
  static const (double, double) flipSecondsRange = (0.0, 1800.0);
  static const (double, double) setupMinutesRange = (0.0, 240.0);

  /// NPF k (Michaud): the accepted star trail in star radii — 1 = round
  /// stars (the source's default), up to 3 = slightly elongated (TASK 8.6,
  /// PD-11). The range is the source's.
  static const double defaultNpfK = 1.0;
  static const (double, double) npfKRange = (1.0, 3.0);

  // Fields -------------------------------------------------------------------

  /// Minimum target altitude for a usable window, degrees.
  final double minAltitudeDeg;

  /// Sun-altitude limit for a usable window.
  final DarknessLimit darknessLimit;

  /// Share of the available time kept free before a plan is "tight", percent.
  final double feasibilityMarginPercent;

  /// Temperature − dew point at or below which the dew warning shows, °C.
  final double dewMarginC;

  /// Overhead added to every acquired frame, seconds.
  final double perFrameOverheadSeconds;

  /// Dither after every N light frames; null = off ("not included").
  final int? ditherEveryNFrames;

  /// Dither plus settle time per dither, seconds.
  final double ditherSettleSeconds;

  /// Refocus every T minutes of capture; null = off ("not included").
  final double? refocusEveryMinutes;

  /// Time per refocus, seconds.
  final double refocusSeconds;

  /// Time per filter change, seconds; null = off ("not included").
  final double? filterChangeSeconds;

  /// Time for one meridian flip, seconds; null = off ("not included").
  final double? meridianFlipSeconds;

  /// Setup time before the first window, minutes; null = off
  /// ("not included").
  final double? setupMinutes;

  /// NPF k in use (see [defaultNpfK]).
  final double npfK;

  /// The margin as a fraction in [0, 0.5].
  double get feasibilityMarginFraction => feasibilityMarginPercent / 100.0;

  PlanningPreferences copyWith({
    double? minAltitudeDeg,
    DarknessLimit? darknessLimit,
    double? feasibilityMarginPercent,
    double? dewMarginC,
    double? perFrameOverheadSeconds,
    double? ditherSettleSeconds,
    double? refocusSeconds,
    double? npfK,
  }) => PlanningPreferences(
    minAltitudeDeg: minAltitudeDeg ?? this.minAltitudeDeg,
    darknessLimit: darknessLimit ?? this.darknessLimit,
    feasibilityMarginPercent:
        feasibilityMarginPercent ?? this.feasibilityMarginPercent,
    dewMarginC: dewMarginC ?? this.dewMarginC,
    perFrameOverheadSeconds:
        perFrameOverheadSeconds ?? this.perFrameOverheadSeconds,
    ditherEveryNFrames: ditherEveryNFrames,
    ditherSettleSeconds: ditherSettleSeconds ?? this.ditherSettleSeconds,
    refocusEveryMinutes: refocusEveryMinutes,
    refocusSeconds: refocusSeconds ?? this.refocusSeconds,
    filterChangeSeconds: filterChangeSeconds,
    meridianFlipSeconds: meridianFlipSeconds,
    setupMinutes: setupMinutes,
    npfK: npfK ?? this.npfK,
  );

  /// Copy with optional overheads switched on or off. Pass a value to switch
  /// one on, or `null` inside the record to switch it off; omit to keep it.
  PlanningPreferences withOptionalOverheads({
    (int?,)? ditherEveryNFrames,
    (double?,)? refocusEveryMinutes,
    (double?,)? filterChangeSeconds,
    (double?,)? meridianFlipSeconds,
    (double?,)? setupMinutes,
  }) => PlanningPreferences(
    minAltitudeDeg: minAltitudeDeg,
    darknessLimit: darknessLimit,
    feasibilityMarginPercent: feasibilityMarginPercent,
    dewMarginC: dewMarginC,
    perFrameOverheadSeconds: perFrameOverheadSeconds,
    ditherEveryNFrames: ditherEveryNFrames != null
        ? ditherEveryNFrames.$1
        : this.ditherEveryNFrames,
    ditherSettleSeconds: ditherSettleSeconds,
    refocusEveryMinutes: refocusEveryMinutes != null
        ? refocusEveryMinutes.$1
        : this.refocusEveryMinutes,
    refocusSeconds: refocusSeconds,
    filterChangeSeconds: filterChangeSeconds != null
        ? filterChangeSeconds.$1
        : this.filterChangeSeconds,
    meridianFlipSeconds: meridianFlipSeconds != null
        ? meridianFlipSeconds.$1
        : this.meridianFlipSeconds,
    setupMinutes: setupMinutes != null ? setupMinutes.$1 : this.setupMinutes,
    npfK: npfK,
  );

  static double _clamp(double value, (double, double) range) {
    if (!value.isFinite) return range.$1;
    return value.clamp(range.$1, range.$2).toDouble();
  }

  @override
  bool operator ==(Object other) =>
      other is PlanningPreferences &&
      minAltitudeDeg == other.minAltitudeDeg &&
      darknessLimit == other.darknessLimit &&
      feasibilityMarginPercent == other.feasibilityMarginPercent &&
      dewMarginC == other.dewMarginC &&
      perFrameOverheadSeconds == other.perFrameOverheadSeconds &&
      ditherEveryNFrames == other.ditherEveryNFrames &&
      ditherSettleSeconds == other.ditherSettleSeconds &&
      refocusEveryMinutes == other.refocusEveryMinutes &&
      refocusSeconds == other.refocusSeconds &&
      filterChangeSeconds == other.filterChangeSeconds &&
      meridianFlipSeconds == other.meridianFlipSeconds &&
      setupMinutes == other.setupMinutes &&
      npfK == other.npfK;

  @override
  int get hashCode => Object.hash(
    minAltitudeDeg,
    darknessLimit,
    feasibilityMarginPercent,
    dewMarginC,
    perFrameOverheadSeconds,
    ditherEveryNFrames,
    ditherSettleSeconds,
    refocusEveryMinutes,
    refocusSeconds,
    filterChangeSeconds,
    meridianFlipSeconds,
    setupMinutes,
    npfK,
  );
}
