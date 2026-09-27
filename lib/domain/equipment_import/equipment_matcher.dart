import 'dart:math' as math;

import '../metadata/capture_metadata.dart';
import '../models/equipment_profile.dart';
import '../models/spec_confidence.dart';
import '../models/spec_provenance.dart';
import 'equipment_candidate.dart';
import 'sensor_geometry_estimate.dart';

/// How a candidate relates to the saved rigs (ADR-018 §6). Decided by
/// stated rules, never a score.
enum MatchKind {
  /// Same camera identity, same optics, same capture mode: no new rig.
  sameRig,

  /// As [sameRig], but the models match only by the prefix rule (for
  /// example a DNG's `Model/Code` against a JPEG's `Model`).
  likelySameRig,

  /// Same camera identity, other or unknown optics: a new rig, which may take
  /// the saved rig's camera specs.
  sameCameraOtherOptics,

  /// Same camera and optics, but another field of view or pixel count
  /// (digital zoom, a crop or a binned mode): never merged silently.
  croppedOrBinnedMode,

  /// Several saved rigs qualify as the same rig: the user chooses.
  ambiguous,

  /// No saved rig has this camera.
  none,
}

/// Why a rig matched as it did (shown to the user in plain words).
enum MatchReason {
  /// The identity came from the rig's stored import metadata.
  identityFromImport,

  /// The identity came from the rig's user-editable labels.
  identityFromLabels,
  sameMake,
  sameModel,
  modelByPrefix,
  sameFocalLength,
  sameFocalRatio,
  focalLengthDiffers,
  focalRatioDiffers,

  /// The file gives no focal length or focal ratio.
  opticsUnknown,
  pixelCountDiffers,
  fieldOfViewDiffers,
}

/// A saved value that differs from the file's proposal (ADR-018 §6). The
/// saved value is kept unless the user explicitly takes the imported one.
class FieldConflict {
  const FieldConflict({
    required this.spec,
    required this.saved,
    required this.imported,
    required this.savedProvenance,
    required this.importedProvenance,
  });

  final EquipmentSpec spec;

  /// The values as numbers, or `[width, height]` for size specs.
  final Object saved;
  final Object imported;

  /// Null = unknown provenance (a legacy row), treated like the user's own.
  final SpecProvenance? savedProvenance;
  final SpecProvenance importedProvenance;

  /// A verified saved value is never replaced by default.
  bool get savedIsVerified =>
      savedProvenance?.confidence == SpecConfidence.verified;
}

/// One saved rig's relation to the candidate.
class RigMatch {
  const RigMatch({
    required this.rig,
    required this.kind,
    required this.reasons,
    this.conflicts = const [],
    this.fillable = const [],
  });

  final EquipmentProfile rig;
  final MatchKind kind;
  final List<MatchReason> reasons;

  /// For [MatchKind.sameRig] and [MatchKind.likelySameRig]: saved values
  /// that differ from the file's.
  final List<FieldConflict> conflicts;

  /// For the same kinds: specs the rig lacks (unknown) that the file
  /// proposes, offered for filling through the editor.
  final List<EquipmentSpec> fillable;
}

/// The overall result: an [outcome] and every rig that relates to it.
class EquipmentMatch {
  const EquipmentMatch(this.outcome, this.rigs);

  final MatchKind outcome;

  /// The rigs behind [outcome] (several for [MatchKind.ambiguous], or for
  /// several cameras' specs to choose from); empty for [MatchKind.none].
  final List<RigMatch> rigs;
}

/// Matches an [EquipmentCandidate] against the saved rigs (ADR-018 §6).
/// Pure; nothing is merged or written here.
abstract final class EquipmentMatcher {
  /// f and N agree when they differ by at most this fraction of the larger
  /// value: enough for a user's rounded "6.6" against a file's 6.57. An
  /// assumption for matching, not a physical law (ADR-018 §6).
  static const opticsTolerance = 0.01;

  /// The file's 35 mm equivalent and the one implied by a saved rig's sensor
  /// diagonal and focal length agree within this fraction. Wider than
  /// CALC-40's own uncertainty (about ±2 % from rounding and 4 % from the
  /// diagonal/width convention), so only a real change of field of view
  /// (a 1.2× crop or more) counts as another mode (S3.3 choice).
  static const fieldOfViewTolerance = 0.10;

  static EquipmentMatch match(
    EquipmentCandidate candidate,
    List<EquipmentProfile> rigs,
  ) {
    final related = [for (final rig in rigs) ?_matchRig(candidate, rig)];
    List<RigMatch> of(Set<MatchKind> kinds) =>
        related.where((m) => kinds.contains(m.kind)).toList();

    final same = of({MatchKind.sameRig, MatchKind.likelySameRig});
    if (same.length > 1) return EquipmentMatch(MatchKind.ambiguous, same);
    if (same.length == 1) return EquipmentMatch(same.single.kind, same);
    final modes = of({MatchKind.croppedOrBinnedMode});
    if (modes.isNotEmpty) {
      return EquipmentMatch(MatchKind.croppedOrBinnedMode, modes);
    }
    final cameras = of({MatchKind.sameCameraOtherOptics});
    if (cameras.isNotEmpty) {
      return EquipmentMatch(MatchKind.sameCameraOtherOptics, cameras);
    }
    return const EquipmentMatch(MatchKind.none, []);
  }

  /// Trim, collapse whitespace, case-fold. For comparison only.
  static String normalize(String s) =>
      s.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

  /// One model is the other plus a separator (`/`, space, `-`, `_`) and a
  /// non-empty suffix (normalised).
  static bool modelByPrefix(String a, String b) {
    final (short, long) = a.length <= b.length ? (a, b) : (b, a);
    if (short.isEmpty || long.length <= short.length + 1) return false;
    if (!long.startsWith(short)) return false;
    return const {'/', ' ', '-', '_'}.contains(long[short.length]);
  }

  /// Whether a file's pixel dimensions are the rig's resolution, in either
  /// orientation (the file's orientation is not interpreted, ADR-018 §3).
  static bool samePixelCount(ImageDimensions dims, EquipmentProfile rig) =>
      dims.longSidePx ==
          math.max(rig.resolutionWidthPx, rig.resolutionHeightPx) &&
      dims.shortSidePx ==
          math.min(rig.resolutionWidthPx, rig.resolutionHeightPx);

  static bool _close(double a, double b, double tolerance) =>
      (a - b).abs() <= tolerance * math.max(a.abs(), b.abs());

  static RigMatch? _matchRig(EquipmentCandidate c, EquipmentProfile rig) {
    final reasons = <MatchReason>[];

    // Camera identity: the stored import metadata first, else the labels.
    final fromImport = rig.metadataModel != null;
    final rigMake = fromImport ? rig.metadataMake : rig.manufacturer;
    final rigModel = fromImport ? rig.metadataModel : rig.cameraModel;
    final fileMake = c.evidence.cameraMake;
    final fileModel = c.evidence.cameraModel;
    if (rigModel == null || fileModel == null) return null;
    if (rigMake != null && fileMake != null) {
      if (normalize(rigMake) != normalize(fileMake)) return null;
      reasons.add(MatchReason.sameMake);
    }
    final bool byPrefix;
    if (normalize(rigModel) == normalize(fileModel)) {
      byPrefix = false;
      reasons.add(MatchReason.sameModel);
    } else if (modelByPrefix(normalize(rigModel), normalize(fileModel))) {
      byPrefix = true;
      reasons.add(MatchReason.modelByPrefix);
    } else {
      return null;
    }
    reasons.insert(
      0,
      fromImport
          ? MatchReason.identityFromImport
          : MatchReason.identityFromLabels,
    );

    // Optics.
    final f = c.focalLengthMm.valueOrNull;
    final n = c.focalRatio.valueOrNull;
    if (f == null || n == null) {
      return RigMatch(
        rig: rig,
        kind: MatchKind.sameCameraOtherOptics,
        reasons: [...reasons, MatchReason.opticsUnknown],
      );
    }
    final sameF = _close(f, rig.focalLengthMm, opticsTolerance);
    final sameN = _close(n, rig.focalRatio, opticsTolerance);
    reasons.add(
      sameF ? MatchReason.sameFocalLength : MatchReason.focalLengthDiffers,
    );
    reasons.add(
      sameN ? MatchReason.sameFocalRatio : MatchReason.focalRatioDiffers,
    );
    if (!sameF || !sameN) {
      return RigMatch(
        rig: rig,
        kind: MatchKind.sameCameraOtherOptics,
        reasons: reasons,
      );
    }

    // Capture mode: pixel count, and the field of view the file implies.
    final dims = c.evidence.imageDimensions;
    final modeReasons = <MatchReason>[
      if (dims != null && !samePixelCount(dims, rig))
        MatchReason.pixelCountDiffers,
      if (c.evidence.focalLength35mmEquivalentMm case final f35?
          when !_close(f35, _implied35mm(rig), fieldOfViewTolerance))
        MatchReason.fieldOfViewDiffers,
    ];
    if (modeReasons.isNotEmpty) {
      return RigMatch(
        rig: rig,
        kind: MatchKind.croppedOrBinnedMode,
        reasons: [...reasons, ...modeReasons],
      );
    }

    return RigMatch(
      rig: rig,
      kind: byPrefix ? MatchKind.likelySameRig : MatchKind.sameRig,
      reasons: reasons,
      conflicts: _conflicts(c, rig),
      fillable: [
        if (rig.averageRawFileSizeMB == null &&
            c.averageRawFileSizeMB is ProposedField)
          EquipmentSpec.rawFileSize,
      ],
    );
  }

  /// The 35 mm equivalent a saved rig implies: f × (36 × 24 mm diagonal ÷
  /// the rig's sensor diagonal).
  static double _implied35mm(EquipmentProfile rig) =>
      rig.focalLengthMm *
      SensorGeometryEstimate.fullFrameDiagonalMm /
      math.sqrt(
        rig.sensorWidthMm * rig.sensorWidthMm +
            rig.sensorHeightMm * rig.sensorHeightMm,
      );

  static List<FieldConflict> _conflicts(
    EquipmentCandidate c,
    EquipmentProfile rig,
  ) {
    final result = <FieldConflict>[];
    void compare(
      EquipmentSpec spec,
      Object saved,
      List<CandidateField<num>> proposed,
    ) {
      if (!proposed.every((p) => p is ProposedField)) return;
      final values = [for (final p in proposed) p.valueOrNull!];
      final imported = values.length == 1 ? values.single : values;
      final same = saved is List
          ? _listEquals(saved, values)
          : saved == values.single;
      if (same) return;
      final first = proposed.first as ProposedField<num>;
      result.add(
        FieldConflict(
          spec: spec,
          saved: saved,
          imported: imported,
          savedProvenance: rig.provenanceOf(spec),
          importedProvenance: SpecProvenance(first.source, first.confidence),
        ),
      );
    }

    compare(
      EquipmentSpec.resolution,
      [rig.resolutionWidthPx, rig.resolutionHeightPx],
      [c.resolutionWidthPx, c.resolutionHeightPx],
    );
    compare(
      EquipmentSpec.sensorSize,
      [rig.sensorWidthMm, rig.sensorHeightMm],
      [c.sensorWidthMm, c.sensorHeightMm],
    );
    compare(EquipmentSpec.pixelPitch, rig.pixelPitchUm, [c.pixelPitchUm]);
    compare(EquipmentSpec.focalLength, rig.focalLengthMm, [c.focalLengthMm]);
    compare(EquipmentSpec.focalRatio, rig.focalRatio, [c.focalRatio]);
    if (rig.averageRawFileSizeMB case final saved?) {
      compare(EquipmentSpec.rawFileSize, saved, [c.averageRawFileSizeMB]);
    }
    return result;
  }

  static bool _listEquals(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
