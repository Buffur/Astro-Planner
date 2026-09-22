enum FrameType { light, dark, flat, bias }

/// Where a calibration block's time is spent (ADR-009 §3). Lights have none:
/// they are always taken inside the imaging window.
enum CalibrationPolicy {
  /// Counts against the imaging window (e.g. darks from an uncooled camera
  /// or a smartphone at ambient temperature).
  inWindow,

  /// Taken the same session but outside the window (twilight flats, darks
  /// and bias after dawn). Counts in the session budget only. The default.
  outsideWindow,

  /// Reused from a calibration library; consumes no time.
  library;

  /// The persisted name, or null for [name] values this app doesn't know.
  static CalibrationPolicy? tryParse(String? name) {
    for (final p in values) {
      if (p.name == name) return p;
    }
    return null;
  }
}

/// What the camera's sensitivity setting was expressed in.
enum GainKind { iso, gain, unknown }

/// The camera's sensitivity setting, recorded **descriptively only**.
///
/// ISO and gain change how the sensor's signal is amplified and digitized;
/// they do not collect more photons, and no calculation in this app uses
/// this value (SI-004, CLAUDE.md "SNR").
class CaptureGain {
  const CaptureGain._(this.kind, this.value);

  /// Nothing recorded, or a legacy value whose kind can't be told
  /// (ADR-008 §6 style: never guessed). [value], when present, is a
  /// non-negative finite number.
  factory CaptureGain.unknown([double? value]) {
    if (value != null && (!value.isFinite || value < 0)) {
      throw ArgumentError.value(value, 'value', 'must be finite and >= 0');
    }
    return CaptureGain._(GainKind.unknown, value);
  }

  /// A camera ISO setting, 1 to 1 000 000.
  factory CaptureGain.iso(int iso) {
    if (iso < 1 || iso > 1000000) {
      throw ArgumentError.value(iso, 'iso', 'must be in [1, 1000000]');
    }
    return CaptureGain._(GainKind.iso, iso.toDouble());
  }

  /// A dedicated-camera gain setting in the camera's own units, 0 to 10 000.
  factory CaptureGain.gain(double gain) {
    if (!gain.isFinite || gain < 0 || gain > 10000) {
      throw ArgumentError.value(gain, 'gain', 'must be in [0, 10000]');
    }
    return CaptureGain._(GainKind.gain, gain);
  }

  /// Rebuilds a stored value; an unrecognised kind reads as unknown.
  factory CaptureGain.fromStored(String? kind, double? value) {
    switch (kind) {
      case 'iso':
        return value == null
            ? CaptureGain.unknown()
            : CaptureGain.iso(value.round());
      case 'gain':
        return value == null ? CaptureGain.unknown() : CaptureGain.gain(value);
      default:
        return CaptureGain.unknown(value);
    }
  }

  /// No gain recorded.
  static const CaptureGain none = CaptureGain._(GainKind.unknown, null);

  final GainKind kind;
  final double? value;

  @override
  bool operator ==(Object other) =>
      other is CaptureGain && kind == other.kind && value == other.value;

  @override
  int get hashCode => Object.hash(kind, value);

  @override
  String toString() => 'CaptureGain(${kind.name}, $value)';
}

/// One block of identical frames in a capture plan (TASK 5.3).
///
/// Built only through the validating factory: an invalid block cannot exist
/// in the domain. Order within a plan is the list order; persistence stores
/// it as a `position`.
class CaptureBlock {
  /// Throws [ArgumentError] when a value is outside its valid range:
  /// - [exposureTimeSeconds] finite, > 0 and <= [maxExposureSeconds];
  /// - [frameCount] 1 to [maxFrameCount];
  /// - [binning] 1 to 4;
  /// - [filterName] at most 32 characters after trimming (blank = none);
  /// - [calibrationPolicy] must be null for lights; for calibration frames
  ///   it defaults to [CalibrationPolicy.outsideWindow] (ADR-009 §3).
  factory CaptureBlock({
    int id = 0,
    int sessionLogId = 0,
    required FrameType frameType,
    String? filterName,
    required double exposureTimeSeconds,
    required int frameCount,
    int binning = 1,
    CaptureGain gain = CaptureGain.none,
    CalibrationPolicy? calibrationPolicy,
  }) {
    if (!exposureTimeSeconds.isFinite ||
        exposureTimeSeconds <= 0 ||
        exposureTimeSeconds > maxExposureSeconds) {
      throw ArgumentError.value(
        exposureTimeSeconds,
        'exposureTimeSeconds',
        'must be > 0 and <= $maxExposureSeconds s',
      );
    }
    if (frameCount < 1 || frameCount > maxFrameCount) {
      throw ArgumentError.value(
        frameCount,
        'frameCount',
        'must be in [1, $maxFrameCount]',
      );
    }
    if (binning < 1 || binning > 4) {
      throw ArgumentError.value(binning, 'binning', 'must be in [1, 4]');
    }
    final filter = filterName?.trim();
    if (filter != null && filter.length > 32) {
      throw ArgumentError.value(filterName, 'filterName', 'too long');
    }
    if (frameType == FrameType.light && calibrationPolicy != null) {
      throw ArgumentError.value(
        calibrationPolicy,
        'calibrationPolicy',
        'lights have no calibration policy',
      );
    }
    return CaptureBlock._(
      id: id,
      sessionLogId: sessionLogId,
      frameType: frameType,
      filterName: (filter == null || filter.isEmpty) ? null : filter,
      exposureTimeSeconds: exposureTimeSeconds,
      frameCount: frameCount,
      binning: binning,
      gain: gain,
      calibrationPolicy: frameType == FrameType.light
          ? null
          : (calibrationPolicy ?? CalibrationPolicy.outsideWindow),
    );
  }

  const CaptureBlock._({
    required this.id,
    required this.sessionLogId,
    required this.frameType,
    required this.filterName,
    required this.exposureTimeSeconds,
    required this.frameCount,
    required this.binning,
    required this.gain,
    required this.calibrationPolicy,
  });

  /// Sanity bound for one sub-exposure, seconds (1 h). Not a physical limit.
  static const double maxExposureSeconds = 3600;

  /// Sanity bound for one block's frame count.
  static const int maxFrameCount = 100000;

  final int id;
  final int sessionLogId;
  final FrameType frameType;
  final String? filterName;

  /// Seconds per frame.
  final double exposureTimeSeconds;
  final int frameCount;
  final int binning;

  /// Descriptive only; never used in a calculation (SI-004).
  final CaptureGain gain;

  /// Null for lights; never null for calibration frames.
  final CalibrationPolicy? calibrationPolicy;

  /// A validated copy. Changing [frameType] to light drops the policy;
  /// changing it to a calibration type applies the default.
  CaptureBlock copyWith({
    int? id,
    int? sessionLogId,
    FrameType? frameType,
    String? filterName,
    double? exposureTimeSeconds,
    int? frameCount,
    int? binning,
    CaptureGain? gain,
    CalibrationPolicy? calibrationPolicy,
  }) {
    final type = frameType ?? this.frameType;
    return CaptureBlock(
      id: id ?? this.id,
      sessionLogId: sessionLogId ?? this.sessionLogId,
      frameType: type,
      filterName: filterName ?? this.filterName,
      exposureTimeSeconds: exposureTimeSeconds ?? this.exposureTimeSeconds,
      frameCount: frameCount ?? this.frameCount,
      binning: binning ?? this.binning,
      gain: gain ?? this.gain,
      calibrationPolicy: type == FrameType.light
          ? null
          : (calibrationPolicy ?? this.calibrationPolicy),
    );
  }

  /// Parses a stored frame type case-insensitively (older data and fixtures
  /// used upper case). Unknown text returns null — callers decide; it is
  /// never silently read as a light frame.
  static FrameType? tryParseFrameType(String? text) {
    final t = text?.trim().toLowerCase();
    for (final f in FrameType.values) {
      if (f.name == t) return f;
    }
    return null;
  }
}
