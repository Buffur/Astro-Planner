import '../../core/utils/quantity_text.dart';
import '../metadata/capture_metadata.dart';
import '../metadata/metadata_format.dart';
import '../metadata/metadata_value.dart';
import '../models/equipment_limits.dart';
import '../models/spec_confidence.dart';
import 'sensor_geometry_estimate.dart';

/// Why a candidate field has no proposed value (ADR-018 §4).
enum CandidateGap {
  /// The file does not carry it.
  notInFile,

  /// The file carries a value that cannot be read.
  unreadable,

  /// The file carries conflicting values.
  conflicting,

  /// The file's value is outside the plausible equipment range
  /// ([EquipmentLimits]).
  outOfRange,

  /// An estimate (CALC-40) needs inputs the file does not give, or its
  /// result is implausible.
  notEstimable,

  /// Never taken from metadata: the aperture diameter (ADR-011 §4), rotation,
  /// tracking (ADR-011 §5) and the maximum exposure.
  neverFromMetadata,
}

/// One proposed [EquipmentCandidate] field (ADR-018 §4): a value with its
/// source and confidence, or unknown with a reason. Nothing here is stored;
/// the user confirms or changes every value before a rig is saved.
sealed class CandidateField<T> {
  const CandidateField();

  T? get valueOrNull => switch (this) {
    ProposedField<T>(:final value) => value,
    UnknownField<T>() => null,
  };
}

/// A value proposed from the file.
final class ProposedField<T> extends CandidateField<T> {
  const ProposedField(
    this.value, {
    required this.source,
    required this.confidence,
    required this.origins,
  });

  final T value;

  /// A namespaced source id (ADR-008 §6): `metadata:<format>` for a value
  /// read from the file, `derived:calc-40/metadata:<format>` for the
  /// estimate.
  final String source;

  /// `reported` for a file value, `estimated` for a derivation; never
  /// `verified`.
  final SpecConfidence confidence;

  /// The tags it came from (several for a derivation).
  final List<MetadataOrigin> origins;

  @override
  String toString() => 'Proposed($value, $source, ${confidence.name})';
}

/// No value proposed, and why.
final class UnknownField<T> extends CandidateField<T> {
  const UnknownField(this.gap);

  final CandidateGap gap;

  @override
  String toString() => 'Unknown(${gap.name})';
}

/// What a capture file says about the equipment that made it (level 3 of
/// ADR-017 §13; ADR-018 §4): a proposed value per `EquipmentProfile` field,
/// plus the identity evidence matching needs (S3.3). Pure and in memory.
class EquipmentCandidate {
  const EquipmentCandidate({
    required this.format,
    required this.suggestedName,
    required this.manufacturer,
    required this.cameraModel,
    required this.resolutionWidthPx,
    required this.resolutionHeightPx,
    required this.focalLengthMm,
    required this.focalRatio,
    required this.sensorWidthMm,
    required this.sensorHeightMm,
    required this.pixelPitchUm,
    required this.averageRawFileSizeMB,
    required this.evidence,
  });

  final MetadataFormat format;

  /// A suggested rig name (a label, always editable), or null without any
  /// identity or focal length.
  final String? suggestedName;

  /// Labels, as the file writes them (trimmed).
  final CandidateField<String> manufacturer;
  final CandidateField<String> cameraModel;

  /// The output mode's pixel counts: the long side as the width.
  final CandidateField<int> resolutionWidthPx;
  final CandidateField<int> resolutionHeightPx;

  final CandidateField<double> focalLengthMm;
  final CandidateField<double> focalRatio;

  /// CALC-40 estimates, `estimated` (offered, never applied silently).
  final CandidateField<double> sensorWidthMm;
  final CandidateField<double> sensorHeightMm;
  final CandidateField<double> pixelPitchUm;

  /// Not proposed yet (S3.8 proposes it from a DNG's file length).
  final CandidateField<double> averageRawFileSizeMB;

  /// The raw metadata behind the candidate, for matching (S3.3).
  final EquipmentEvidence evidence;

  /// Never taken from metadata (ADR-011 §4, §5; ADR-018 §4).
  CandidateField<double> get apertureDiameterMm =>
      const UnknownField(CandidateGap.neverFromMetadata);
  CandidateField<double> get rotationDeg =>
      const UnknownField(CandidateGap.neverFromMetadata);
  CandidateField<double> get maxExposureS =>
      const UnknownField(CandidateGap.neverFromMetadata);

  /// True when the file names a camera or gives its optics; false means
  /// there is nothing to propose a rig from.
  bool get hasEnoughEvidence =>
      manufacturer is ProposedField ||
      cameraModel is ProposedField ||
      focalLengthMm is ProposedField ||
      focalRatio is ProposedField;

  /// Builds the candidate from a reading (ADR-018 §4). Exposure,
  /// sensitivity and capture time are ignored: they describe one frame,
  /// not the equipment.
  factory EquipmentCandidate.fromReading(MetadataRead reading) {
    final m = reading.metadata;
    final source = 'metadata:${reading.format.name}';

    CandidateField<T> field<T>(
      MetadataValue<T> value, [
      bool Function(T)? plausible,
    ]) => switch (value) {
      KnownValue<T>(:final value, :final origin) =>
        plausible != null && !plausible(value)
            ? UnknownField<T>(CandidateGap.outOfRange)
            : ProposedField<T>(
                value,
                source: source,
                confidence: SpecConfidence.reported,
                origins: [origin],
              ),
      AbsentValue<T>() => UnknownField<T>(CandidateGap.notInFile),
      UnparseableValue<T>() => UnknownField<T>(CandidateGap.unreadable),
      AmbiguousValue<T>() => UnknownField<T>(CandidateGap.conflicting),
    };

    final focal = field(
      m.focalLengthMm,
      EquipmentLimits.focalLengthMm.contains,
    );
    final ratio = field(m.fNumber, EquipmentLimits.focalRatio.contains);
    final dims = field(
      m.imageDimensions,
      (d) =>
          EquipmentLimits.resolutionPx.contains(d.longSidePx.toDouble()) &&
          EquipmentLimits.resolutionPx.contains(d.shortSidePx.toDouble()),
    );
    CandidateField<int> side(int Function(ImageDimensions) of) =>
        switch (dims) {
          ProposedField(:final value, :final source, :final origins) =>
            ProposedField(
              of(value),
              source: source,
              confidence: SpecConfidence.reported,
              origins: origins,
            ),
          UnknownField(:final gap) => UnknownField(gap),
        };

    final estimate = _estimate(m, focal, dims, source);
    final make = field(m.cameraMake);
    final model = field(m.cameraModel);

    return EquipmentCandidate(
      format: reading.format,
      suggestedName: _name(
        make.valueOrNull,
        model.valueOrNull,
        m.lensModel.valueOrNull,
        focal.valueOrNull,
      ),
      manufacturer: make,
      cameraModel: model,
      resolutionWidthPx: side((d) => d.longSidePx),
      resolutionHeightPx: side((d) => d.shortSidePx),
      focalLengthMm: focal,
      focalRatio: ratio,
      sensorWidthMm: estimate.width,
      sensorHeightMm: estimate.height,
      pixelPitchUm: estimate.pitch,
      averageRawFileSizeMB: const UnknownField(CandidateGap.notInFile),
      evidence: EquipmentEvidence(
        cameraMake: m.cameraMake.valueOrNull,
        cameraModel: m.cameraModel.valueOrNull,
        uniqueCameraModel: m.uniqueCameraModel.valueOrNull,
        lensMake: m.lensMake.valueOrNull,
        lensModel: m.lensModel.valueOrNull,
        focalLength35mmEquivalentMm: m.focalLength35mmEquivalentMm.valueOrNull,
        imageDimensions: m.imageDimensions.valueOrNull,
      ),
    );
  }

  static ({
    CandidateField<double> width,
    CandidateField<double> height,
    CandidateField<double> pitch,
  })
  _estimate(
    CaptureMetadata m,
    CandidateField<double> focal,
    CandidateField<ImageDimensions> dims,
    String source,
  ) {
    const none = UnknownField<double>(CandidateGap.notEstimable);
    final f35 = m.focalLength35mmEquivalentMm;
    if (focal is! ProposedField<double> ||
        dims is! ProposedField<ImageDimensions> ||
        f35 is! KnownValue<double>) {
      return (width: none, height: none, pitch: none);
    }
    final e = SensorGeometryEstimate.of(
      focalLengthMm: focal.value,
      focalLength35mmEquivalentMm: f35.value,
      longSidePx: dims.value.longSidePx,
      shortSidePx: dims.value.shortSidePx,
    );
    if (e == null) return (width: none, height: none, pitch: none);
    ProposedField<double> proposed(double v) => ProposedField(
      v,
      source: 'derived:calc-40/$source',
      confidence: SpecConfidence.estimated,
      origins: [...focal.origins, f35.origin, ...dims.origins],
    );
    return (
      width: proposed(e.widthMm),
      height: proposed(e.heightMm),
      pitch: proposed(e.pixelPitchUm),
    );
  }

  /// "Make Model · lens" or "Make Model · 6.57 mm"; the make is not
  /// repeated when the model already starts with it.
  static String? _name(
    String? make,
    String? model,
    String? lens,
    double? focalLengthMm,
  ) {
    final camera = switch ((make, model)) {
      (final mk?, final md?)
          when md.toLowerCase().startsWith(mk.toLowerCase()) =>
        md,
      (final mk?, final md?) => '$mk $md',
      (final mk?, null) => mk,
      (null, final md?) => md,
      (null, null) => null,
    };
    final optics =
        lens ??
        (focalLengthMm == null
            ? null
            : '${QuantityText.number(focalLengthMm)} mm');
    return switch ((camera, optics)) {
      (final c?, final o?) => '$c · $o',
      (final c?, null) => c,
      (null, final o?) => o,
      (null, null) => null,
    };
  }
}

/// The raw identity and optics evidence behind a candidate, kept for
/// matching (ADR-018 §6). Never serials or location (ADR-017 §3).
class EquipmentEvidence {
  const EquipmentEvidence({
    this.cameraMake,
    this.cameraModel,
    this.uniqueCameraModel,
    this.lensMake,
    this.lensModel,
    this.focalLength35mmEquivalentMm,
    this.imageDimensions,
  });

  final String? cameraMake;
  final String? cameraModel;
  final String? uniqueCameraModel;
  final String? lensMake;
  final String? lensModel;
  final double? focalLength35mmEquivalentMm;
  final ImageDimensions? imageDimensions;
}
