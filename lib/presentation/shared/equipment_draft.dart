import '../../domain/equipment_import/equipment_candidate.dart';
import '../../domain/models/equipment_limits.dart';
import '../../domain/models/equipment_profile.dart';
import '../../domain/models/spec_confidence.dart';
import '../../domain/models/spec_provenance.dart';
import '../../domain/models/tracking_type.dart';
import 'equipment_form_input.dart';

/// The rig editor's text fields, as typed.
class EquipmentFormTexts {
  const EquipmentFormTexts({
    this.name = '',
    this.manufacturer = '',
    this.cameraModel = '',
    this.resolutionWidth = '',
    this.resolutionHeight = '',
    this.pixelPitch = '',
    this.sensorWidth = '',
    this.sensorHeight = '',
    this.focalLength = '',
    this.focalRatio = '',
    this.diameter = '',
    this.rawFileSize = '',
    this.rotation = '',
    this.maxExposure = '',
  });

  final String name;
  final String manufacturer;
  final String cameraModel;
  final String resolutionWidth;
  final String resolutionHeight;
  final String pixelPitch;
  final String sensorWidth;
  final String sensorHeight;
  final String focalLength;
  final String focalRatio;
  final String diameter;
  final String rawFileSize;
  final String rotation;
  final String maxExposure;

  /// The texts that hold [spec]'s value (two for a size).
  List<String> of(EquipmentSpec spec) => switch (spec) {
    EquipmentSpec.resolution => [resolutionWidth, resolutionHeight],
    EquipmentSpec.pixelPitch => [pixelPitch],
    EquipmentSpec.sensorSize => [sensorWidth, sensorHeight],
    EquipmentSpec.rawFileSize => [rawFileSize],
    EquipmentSpec.focalLength => [focalLength],
    EquipmentSpec.focalRatio => [focalRatio, diameter],
  };
}

/// A pre-filled value's origin, shown in the editor while its text is
/// unchanged (ADR-018 §4, §7).
class PrefilledSpec {
  const PrefilledSpec(this.provenance, this.texts, {this.fromSavedRig = false});

  final SpecProvenance provenance;

  /// Copied from a saved rig with the same camera, not read from the file.
  final bool fromSavedRig;

  /// The texts as pre-filled; any change makes the value the user's own.
  final List<String> texts;
}

/// The result of [EquipmentDraft.build]: a profile ready to save, or the
/// aperture problem to show.
class EquipmentDraftResult {
  const EquipmentDraftResult._(this.profile, this.apertureProblem);

  final EquipmentProfile? profile;
  final ApertureProblem? apertureProblem;
}

/// The rig editor's form model (S3.5): its initial texts, the provenance of
/// pre-filled values, and the one place a profile is built from the typed
/// texts. Pure; the widget keeps only controllers and layout. The same model
/// serves Add, Edit and a metadata import (ADR-018 §2).
class EquipmentDraft {
  const EquipmentDraft({
    required this.initial,
    this.existing,
    this.trackingType = TrackingType.unknown,
    this.prefilled = const {},
    this.metadataMake,
    this.metadataModel,
  });

  /// The editor for [existing] (null: a blank new rig), as before S3.5.
  factory EquipmentDraft.fromProfile(EquipmentProfile? existing) {
    final e = existing;
    return EquipmentDraft(
      existing: e,
      trackingType: e?.trackingType ?? TrackingType.unknown,
      initial: EquipmentFormTexts(
        name: e?.name ?? '',
        manufacturer: e?.manufacturer ?? '',
        cameraModel: e?.cameraModel ?? '',
        resolutionWidth: e?.resolutionWidthPx.toString() ?? '',
        resolutionHeight: e?.resolutionHeightPx.toString() ?? '',
        pixelPitch: numberText(e?.pixelPitchUm),
        // The sensor fields show 2 decimals; an untouched field keeps the
        // stored value exactly (TASK 8.5), see [build].
        sensorWidth: e?.sensorWidthMm.toStringAsFixed(2) ?? '',
        sensorHeight: e?.sensorHeightMm.toStringAsFixed(2) ?? '',
        focalLength: numberText(e?.focalLengthMm),
        focalRatio: numberText(e?.focalRatio),
        diameter: numberText(e?.apertureDiameterMm),
        rawFileSize: numberText(e?.averageRawFileSizeMB),
        rotation: numberText(e?.rotationDeg),
        maxExposure: numberText(e?.maxExposureS),
      ),
    );
  }

  /// A new rig pre-filled from a metadata candidate (ADR-018 §4). Unknown
  /// fields stay empty for the user to fill; the aperture diameter, rotation,
  /// tracking and maximum exposure are never pre-filled. [cameraFrom], a
  /// saved rig with the same camera (ADR-018 §6), fills the camera specs
  /// the file lacks, with that rig's provenance.
  factory EquipmentDraft.fromCandidate(
    EquipmentCandidate c, {
    EquipmentProfile? cameraFrom,
  }) {
    final prefilled = <EquipmentSpec, PrefilledSpec>{};
    String fill(
      EquipmentSpec spec,
      CandidateField<num> field,
      String Function(num) show, {
      num? fallback,
      SpecProvenance? fallbackProvenance,
    }) {
      if (field case ProposedField(
        :final value,
        :final source,
        :final confidence,
      )) {
        final text = show(value);
        _add(prefilled, spec, SpecProvenance(source, confidence), text);
        return text;
      }
      if (fallback != null) {
        final text = show(fallback);
        // A legacy rig's value has no provenance; it stays unknown.
        _add(
          prefilled,
          spec,
          fallbackProvenance ?? const SpecProvenance(null, null),
          text,
          fromSavedRig: true,
        );
        return text;
      }
      return '';
    }

    SpecProvenance? from(EquipmentSpec spec) => cameraFrom?.provenanceOf(spec);
    final rig = cameraFrom;

    final texts = EquipmentFormTexts(
      name: c.suggestedName ?? '',
      manufacturer: c.manufacturer.valueOrNull ?? '',
      cameraModel: c.cameraModel.valueOrNull ?? '',
      resolutionWidth: fill(
        EquipmentSpec.resolution,
        c.resolutionWidthPx,
        (v) => '$v',
        fallback: rig?.resolutionWidthPx,
        fallbackProvenance: from(EquipmentSpec.resolution),
      ),
      resolutionHeight: fill(
        EquipmentSpec.resolution,
        c.resolutionHeightPx,
        (v) => '$v',
        fallback: rig?.resolutionHeightPx,
        fallbackProvenance: from(EquipmentSpec.resolution),
      ),
      pixelPitch: fill(
        EquipmentSpec.pixelPitch,
        c.pixelPitchUm,
        (v) => _estimateText(v, 3),
        fallback: rig?.pixelPitchUm,
        fallbackProvenance: from(EquipmentSpec.pixelPitch),
      ),
      sensorWidth: fill(
        EquipmentSpec.sensorSize,
        c.sensorWidthMm,
        (v) => v.toStringAsFixed(2),
        fallback: rig?.sensorWidthMm,
        fallbackProvenance: from(EquipmentSpec.sensorSize),
      ),
      sensorHeight: fill(
        EquipmentSpec.sensorSize,
        c.sensorHeightMm,
        (v) => v.toStringAsFixed(2),
        fallback: rig?.sensorHeightMm,
        fallbackProvenance: from(EquipmentSpec.sensorSize),
      ),
      focalLength: fill(
        EquipmentSpec.focalLength,
        c.focalLengthMm,
        (v) => numberText(v.toDouble()),
      ),
      focalRatio: fill(
        EquipmentSpec.focalRatio,
        c.focalRatio,
        (v) => numberText(v.toDouble()),
      ),
      rawFileSize: fill(
        EquipmentSpec.rawFileSize,
        c.averageRawFileSizeMB,
        (v) => _estimateText(v, 1),
        fallback: rig?.averageRawFileSizeMB,
        fallbackProvenance: from(EquipmentSpec.rawFileSize),
      ),
    );
    // The focal ratio's texts include the (empty) diameter.
    if (prefilled[EquipmentSpec.focalRatio] case final p?) {
      prefilled[EquipmentSpec.focalRatio] = PrefilledSpec(p.provenance, [
        ...p.texts,
        '',
      ], fromSavedRig: p.fromSavedRig);
    }
    return EquipmentDraft(
      initial: texts,
      prefilled: prefilled,
      metadataMake: c.evidence.cameraMake,
      metadataModel: c.evidence.cameraModel,
    );
  }

  static void _add(
    Map<EquipmentSpec, PrefilledSpec> into,
    EquipmentSpec spec,
    SpecProvenance provenance,
    String text, {
    bool fromSavedRig = false,
  }) {
    final before = into[spec];
    into[spec] = PrefilledSpec(provenance, [
      ...?before?.texts,
      text,
    ], fromSavedRig: fromSavedRig);
  }

  /// The rig being edited; null for a new one.
  final EquipmentProfile? existing;
  final EquipmentFormTexts initial;
  final TrackingType trackingType;

  /// Pre-filled specs and their origin (empty for Add/Edit by hand).
  final Map<EquipmentSpec, PrefilledSpec> prefilled;

  /// The file's raw identity, stored for later matching (ADR-018 §5).
  final String? metadataMake;
  final String? metadataModel;

  /// [spec]'s pre-fill while [texts] still hold the pre-filled value; null
  /// once the user changed it (or it was not pre-filled).
  PrefilledSpec? unchangedPrefill(
    EquipmentSpec spec,
    EquipmentFormTexts texts,
  ) {
    final p = prefilled[spec];
    if (p == null) return null;
    final now = texts.of(spec);
    for (var i = 0; i < p.texts.length; i++) {
      if (now[i].trim() != p.texts[i].trim()) return null;
    }
    return p;
  }

  /// A number as the editor shows it: no trailing ".0".
  static String numberText(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble() ? value.toInt().toString() : '$value';
  }

  static String _estimateText(num v, int decimals) =>
      numberText(double.parse(v.toStringAsFixed(decimals)));

  /// The sensor size from resolution × pixel pitch, as the editor derives it
  /// (texts with 2 decimals), or null when an input is missing.
  static ({String width, String height})? sensorSizeText(
    String resolutionWidth,
    String resolutionHeight,
    String pixelPitch,
  ) {
    final resW = int.tryParse(resolutionWidth);
    final resH = int.tryParse(resolutionHeight);
    final pitch = EquipmentFormInput.parse(pixelPitch);
    if (resW == null || resH == null || pitch == null || !(pitch > 0)) {
      return null;
    }
    return (
      width: (resW * pitch / 1000).toStringAsFixed(2),
      height: (resH * pitch / 1000).toStringAsFixed(2),
    );
  }

  /// The profile the typed [texts] describe, with provenance (TASK 8.5,
  /// ADR-018 §5), or the aperture problem. The texts must already pass the
  /// form's validators.
  EquipmentDraftResult build(
    EquipmentFormTexts texts,
    TrackingType trackingType,
  ) {
    final focal = EquipmentFormInput.parse(texts.focalLength)!;
    final diameterText = texts.diameter.trim();
    final aperture = resolveAperture(
      focalLengthMm: focal,
      focalRatio: diameterText.isEmpty
          ? EquipmentFormInput.parse(texts.focalRatio)
          : null,
      diameterMm: diameterText.isEmpty
          ? null
          : EquipmentFormInput.parse(diameterText),
    );
    if (!aperture.isValid) {
      return EquipmentDraftResult._(null, aperture.problem);
    }

    final e = existing;
    String? optionalText(String s) => s.trim().isEmpty ? null : s.trim();
    final profile = EquipmentProfile(
      id: e?.id ?? 0,
      name: texts.name.trim(),
      manufacturer: optionalText(texts.manufacturer),
      cameraModel: optionalText(texts.cameraModel),
      resolutionWidthPx: int.parse(texts.resolutionWidth.trim()),
      resolutionHeightPx: int.parse(texts.resolutionHeight.trim()),
      pixelPitchUm: EquipmentFormInput.parse(texts.pixelPitch)!,
      // An untouched sensor field keeps the stored value exactly, so opening
      // and saving never alters verified specs (TASK 8.5).
      sensorWidthMm: e != null && texts.sensorWidth == initial.sensorWidth
          ? e.sensorWidthMm
          : EquipmentFormInput.parse(texts.sensorWidth)!,
      sensorHeightMm: e != null && texts.sensorHeight == initial.sensorHeight
          ? e.sensorHeightMm
          : EquipmentFormInput.parse(texts.sensorHeight)!,
      focalLengthMm: focal,
      focalRatio: aperture.focalRatio!,
      apertureDiameterMm: aperture.diameterMm,
      averageRawFileSizeMB: EquipmentFormInput.parse(texts.rawFileSize),
      rotationDeg: EquipmentFormInput.parse(texts.rotation),
      trackingType: trackingType,
      maxExposureS: EquipmentFormInput.parse(texts.maxExposure),
      // Only untouched pre-filled values keep their origin; a changed one
      // becomes the user's own through [EquipmentProfile.withEditProvenance].
      specProvenance: {
        for (final spec in EquipmentSpec.values)
          if (unchangedPrefill(spec, texts) case final p?)
            if (!p.provenance.isUnknown) spec: p.provenance,
      },
      metadataMake: metadataMake,
      metadataModel: metadataModel,
    );
    return EquipmentDraftResult._(profile.withEditProvenance(e), null);
  }
}

/// How a pre-filled value's origin reads under its field.
abstract final class PrefillText {
  static String note(PrefilledSpec p) {
    final source = p.provenance.source ?? '';
    if (p.fromSavedRig) {
      final confidence = switch (p.provenance.confidence) {
        SpecConfidence.verified => 'verified',
        SpecConfidence.reported => 'reported',
        SpecConfidence.estimated => 'estimated',
        null => 'source unknown',
      };
      return 'From your saved rig with this camera ($confidence)';
    }
    if (source.startsWith('derived:calc-40')) {
      return 'Estimated from the 35 mm equivalent — check it';
    }
    final format = source.startsWith('metadata:')
        ? source.substring('metadata:'.length).split(':').first.toUpperCase()
        : source;
    return 'From the file ($format)';
  }
}
