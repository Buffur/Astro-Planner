import '../models/camera_class.dart';
import '../models/capture_block.dart';
import '../models/equipment_profile.dart';

/// Why a calibration block may not calibrate the plan's frames (ADR-020 §6;
/// RG-10 §4). Each is a warning in words; none blocks a plan.
enum CalibrationMismatch {
  /// A dark or bias block whose values match no light block.
  matchesNoLight,

  /// A flat whose filter no light block uses.
  filterUnused,

  /// A flat whose binning matches no light block.
  binningMatchesNoLight,

  /// A dark flat whose values match no flat block.
  matchesNoFlat,

  /// A dark that matches a light while the rig's in-camera noise reduction
  /// already takes a dark after each light (ADR-020 §6, §8; S7.3b).
  darksTwice;

  /// Whether "Match the lights" (or flats) fixes it; darks twice is kept or
  /// removed by the user.
  bool get fixable => this != darksTwice;
}

/// The calibration matrix's required matches (ADR-020 §6; RG-10 §4), pure.
/// What a calibration block inherits, whether it still matches the plan,
/// and the one-tap fix. Unknown never fails a check: an ISO or gain not
/// recorded on either side, or binning where the camera class does not
/// offer it. Exposures compare in ADR-009's integer milliseconds.
abstract final class CalibrationMatch {
  static int _ms(double seconds) => (seconds * 1000).round();

  static bool _known(CaptureGain g) =>
      g.kind != GainKind.unknown && g.value != null;

  /// Same ISO or gain, or not recorded on one side.
  static bool sameSensitivity(CaptureGain a, CaptureGain b) =>
      !_known(a) || !_known(b) || a == b;

  /// Same binning, where the class offers it (ADR-020 §3).
  static bool sameBinning(CaptureBlock a, CaptureBlock b, CameraClass c) =>
      !c.offersLightBinning || a.binning == b.binning;

  static bool _sameExposure(CaptureBlock a, CaptureBlock b) =>
      _ms(a.exposureTimeSeconds) == _ms(b.exposureTimeSeconds);

  /// Whether [block] (a dark, bias or dark flat) matches [source] (a light,
  /// or a flat for a dark flat) in every value it inherits.
  static bool matches(CaptureBlock block, CaptureBlock source, CameraClass c) {
    final common =
        sameSensitivity(block.gain, source.gain) &&
        sameBinning(block, source, c);
    return switch (block.frameType) {
      FrameType.dark ||
      FrameType.darkFlat => common && _sameExposure(block, source),
      FrameType.bias => common,
      FrameType.flat =>
        block.filterName == source.filterName && sameBinning(block, source, c),
      FrameType.light => true,
    };
  }

  /// Each block's mismatches with [blocks], the plan, for [rig] (its class,
  /// Unknown without one, and whether its noise reduction applies).
  static List<List<CalibrationMismatch>> ofPlan(
    List<CaptureBlock> blocks,
    EquipmentProfile? rig,
  ) => [
    for (final b in blocks)
      of(
        b,
        blocks,
        rig?.cameraClass ?? CameraClass.unknown,
        noiseReduction: rig?.noiseReductionApplies ?? false,
      ),
  ];

  /// [block]'s mismatches with [blocks], the plan, for a rig of class [c];
  /// empty for a light block or a block that matches. [noiseReduction]: the
  /// rig's in-camera noise reduction applies, so a dark that matches a light
  /// repeats it.
  static List<CalibrationMismatch> of(
    CaptureBlock block,
    List<CaptureBlock> blocks,
    CameraClass c, {
    bool noiseReduction = false,
  }) {
    final lights = blocks.where((b) => b.frameType == FrameType.light);
    final flats = blocks.where((b) => b.frameType == FrameType.flat);
    return switch (block.frameType) {
      FrameType.light => const [],
      FrameType.dark || FrameType.bias => [
        if (!lights.any((l) => matches(block, l, c)))
          CalibrationMismatch.matchesNoLight
        else if (noiseReduction && block.frameType == FrameType.dark)
          CalibrationMismatch.darksTwice,
      ],
      FrameType.flat => [
        if (!lights.any((l) => l.filterName == block.filterName))
          CalibrationMismatch.filterUnused,
        if (!lights.any((l) => sameBinning(block, l, c)))
          CalibrationMismatch.binningMatchesNoLight,
      ],
      FrameType.darkFlat => [
        if (!flats.any((f) => matches(block, f, c)))
          CalibrationMismatch.matchesNoFlat,
      ],
    };
  }

  /// The light filters no flat covers, when the plan has flats (a plan
  /// without flats says nothing: flats may come from a library). Null is
  /// "no filter".
  static List<String?> lightFiltersWithoutFlats(List<CaptureBlock> blocks) {
    final flatFilters = {
      for (final b in blocks)
        if (b.frameType == FrameType.flat) b.filterName,
    };
    if (flatFilters.isEmpty) return const [];
    return [
      for (final f in {
        for (final b in blocks)
          if (b.frameType == FrameType.light) b.filterName,
      })
        if (!flatFilters.contains(f)) f,
    ];
  }

  /// The blocks [type] may inherit from: the plan's lights, or its flats for
  /// a dark flat (ADR-020 §6).
  static List<CaptureBlock> sourcesFor(
    FrameType type,
    List<CaptureBlock> blocks,
  ) {
    final from = type == FrameType.darkFlat ? FrameType.flat : FrameType.light;
    return [
      for (final b in blocks)
        if (b.frameType == from) b,
    ];
  }

  /// The source "Match the lights" (or flats) copies from: for a flat, the
  /// first light whose filter has no flat yet, else the first light; for
  /// the others, the first source. Null when there is none.
  static CaptureBlock? defaultSource(
    CaptureBlock block,
    List<CaptureBlock> blocks,
  ) {
    final sources = sourcesFor(block.frameType, blocks);
    if (sources.isEmpty) return null;
    if (block.frameType == FrameType.flat) {
      final missing = lightFiltersWithoutFlats(blocks);
      for (final s in sources) {
        if (missing.contains(s.filterName)) return s;
      }
    }
    return sources.first;
  }

  /// Whether a calibration block of [type] takes its exposure from its
  /// source (ADR-020 §6): darks and dark flats; a flat's and a bias's
  /// exposure is their own.
  static bool takesExposure(FrameType type) =>
      type == FrameType.dark || type == FrameType.darkFlat;

  /// Whether a calibration block of [type] takes its ISO or gain from its
  /// source (ADR-020 §6): darks, dark flats and bias; a flat's is only
  /// proposed from it.
  static bool takesSensitivity(FrameType type) =>
      type == FrameType.dark ||
      type == FrameType.darkFlat ||
      type == FrameType.bias;

  /// [block] with what it inherits copied from [source] (ADR-020 §6, L1):
  /// darks and dark flats the exposure, ISO or gain and binning; bias the ISO
  /// or gain and binning; flats the filter and binning. Everything else (the
  /// count, the policy, a flat's or bias's own exposure) is kept.
  static CaptureBlock matched(CaptureBlock block, CaptureBlock source) {
    final type = block.frameType;
    if (type == FrameType.light) return block;
    return CaptureBlock(
      id: block.id,
      sessionLogId: block.sessionLogId,
      frameType: type,
      filterName: type == FrameType.flat ? source.filterName : null,
      exposureTimeSeconds: takesExposure(type)
          ? source.exposureTimeSeconds
          : block.exposureTimeSeconds,
      frameCount: block.frameCount,
      binning: source.binning,
      gain: takesSensitivity(type) ? source.gain : block.gain,
      calibrationPolicy: block.calibrationPolicy,
    );
  }
}
