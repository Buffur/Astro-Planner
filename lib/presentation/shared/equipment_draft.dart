import '../../domain/equipment_import/equipment_candidate.dart';
import '../../domain/equipment_import/equipment_matcher.dart';
import '../../domain/metadata/capture_metadata.dart';
import '../../domain/models/camera_class.dart';
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
  const PrefilledSpec(
    this.provenance,
    this.texts, {
    this.values = const [],
    this.fromSavedRig = false,
  });

  final SpecProvenance provenance;

  /// Copied from a saved rig with the same camera, not read from the file.
  final bool fromSavedRig;

  /// The texts as pre-filled; any change makes the value the user's own.
  final List<String> texts;

  /// The exact values behind [texts], one per text (null where a text has
  /// none, such as the empty diameter). While the texts are unchanged these
  /// are what is saved, so display rounding never alters a saved, verified
  /// or chosen value (S3.V3).
  final List<num?> values;
}

/// Camera specs of a saved rig that were not copied into a new rig because
/// the file's pixel count differs from that rig's (S3.V8, S3S-02): binning,
/// a crop, resampling or another sensor mode could explain it, and metadata
/// cannot tell which, so the values stay unknown for the user to provide.
class WithheldCameraSpecs {
  const WithheldCameraSpecs({
    required this.rigName,
    required this.specs,
    required this.file,
    required this.rig,
  });

  /// The saved rig the specs were not copied from.
  final String rigName;

  /// The specs left empty (pixel size, sensor size).
  final Set<EquipmentSpec> specs;

  /// The file's pixel dimensions, and the saved rig's resolution.
  final ImageDimensions file;
  final ImageDimensions rig;
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
    this.cameraClass = CameraClass.unknown,
    this.prefilled = const {},
    this.metadataMake,
    this.metadataModel,
    this.withheldFromSavedRig,
  });

  /// The editor for [existing] (null: a blank new rig), as before S3.5.
  factory EquipmentDraft.fromProfile(EquipmentProfile? existing) {
    final e = existing;
    return EquipmentDraft(
      existing: e,
      trackingType: e?.trackingType ?? TrackingType.unknown,
      cameraClass: e?.cameraClass ?? CameraClass.unknown,
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
  /// the file lacks, with that rig's provenance, except its pixel size and
  /// sensor size when the file's pixel count differs from that rig's (S3.V8:
  /// they belong to another output mode; see [withheldFromSavedRig]).
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
      String Function(num)? showSaved,
    }) {
      if (field case ProposedField(
        :final value,
        :final source,
        :final confidence,
      )) {
        final text = show(value);
        _add(
          prefilled,
          spec,
          SpecProvenance(source, confidence),
          text,
          value: value,
        );
        return text;
      }
      if (fallback != null) {
        // A saved value is shown in full (only estimates are rounded), and
        // saved exactly (S3.V3).
        final text = (showSaved ?? show)(fallback);
        // A legacy rig's value has no provenance; it stays unknown, never
        // the new rig's `user` (S3.V2).
        _add(
          prefilled,
          spec,
          fallbackProvenance ?? SpecProvenance.unknown,
          text,
          value: fallback,
          fromSavedRig: true,
        );
        return text;
      }
      return '';
    }

    SpecProvenance? from(EquipmentSpec spec) => cameraFrom?.provenanceOf(spec);
    final rig = cameraFrom;
    // S3.V8 (S3S-02): a pixel size describes one output mode. When the file
    // has another pixel count than the saved rig, its pitch and sensor size
    // are not copied; the relationship is not inferred.
    final fileDims = c.evidence.imageDimensions;
    final otherPixelCount =
        rig != null &&
        fileDims != null &&
        !EquipmentMatcher.samePixelCount(fileDims, rig);
    final geometryFrom = otherPixelCount ? null : rig;

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
        (v) => _estimateText(v, EquipmentCandidate.pixelPitchDecimals),
        fallback: geometryFrom?.pixelPitchUm,
        fallbackProvenance: from(EquipmentSpec.pixelPitch),
        showSaved: (v) => numberText(v.toDouble()),
      ),
      sensorWidth: fill(
        EquipmentSpec.sensorSize,
        c.sensorWidthMm,
        (v) => v.toStringAsFixed(EquipmentCandidate.sensorDecimals),
        fallback: geometryFrom?.sensorWidthMm,
        fallbackProvenance: from(EquipmentSpec.sensorSize),
      ),
      sensorHeight: fill(
        EquipmentSpec.sensorSize,
        c.sensorHeightMm,
        (v) => v.toStringAsFixed(EquipmentCandidate.sensorDecimals),
        fallback: geometryFrom?.sensorHeightMm,
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
        (v) => _estimateText(v, EquipmentCandidate.rawSizeDecimals),
        fallback: rig?.averageRawFileSizeMB,
        fallbackProvenance: from(EquipmentSpec.rawFileSize),
        showSaved: (v) => numberText(v.toDouble()),
      ),
    );
    // The focal ratio's texts include the (empty) diameter.
    if (prefilled[EquipmentSpec.focalRatio] case final p?) {
      prefilled[EquipmentSpec.focalRatio] = PrefilledSpec(
        p.provenance,
        [...p.texts, ''],
        values: [...p.values, null],
        fromSavedRig: p.fromSavedRig,
      );
    }
    final withheld = {
      if (otherPixelCount && c.pixelPitchUm is! ProposedField)
        EquipmentSpec.pixelPitch,
      if (otherPixelCount && c.sensorWidthMm is! ProposedField)
        EquipmentSpec.sensorSize,
    };
    return EquipmentDraft(
      initial: texts,
      prefilled: prefilled,
      metadataMake: c.evidence.cameraMake,
      metadataModel: c.evidence.cameraModel,
      withheldFromSavedRig: withheld.isEmpty
          ? null
          : WithheldCameraSpecs(
              rigName: rig!.name,
              specs: withheld,
              file: fileDims!,
              rig: ImageDimensions(
                rig.resolutionWidthPx,
                rig.resolutionHeightPx,
              ),
            ),
    );
  }

  /// A saved rig opened for editing with the file's values taken for
  /// [taken] (ADR-018 §6: only by the user's explicit choice, per field).
  /// Each taken value carries the file's provenance while untouched. Taking
  /// the file's focal ratio clears the diameter field, since the ratio is
  /// derived from a diameter otherwise (ADR-011 §4); D is never back-filled.
  factory EquipmentDraft.forRig(
    EquipmentProfile rig,
    Map<EquipmentSpec, ({Object value, SpecProvenance provenance})> taken,
  ) {
    final base = EquipmentDraft.fromProfile(rig);
    if (taken.isEmpty) return base;
    final t = base.initial;
    final prefilled = <EquipmentSpec, PrefilledSpec>{};
    String num1(Object v) => numberText((v as num).toDouble());
    List<String> texts(EquipmentSpec spec, Object v) => switch (spec) {
      EquipmentSpec.resolution => [for (final side in v as List) '$side'],
      EquipmentSpec.sensorSize => [
        for (final side in v as List) _sensorText((side as num).toDouble()),
      ],
      EquipmentSpec.pixelPitch => [
        _estimateText(v as num, EquipmentCandidate.pixelPitchDecimals),
      ],
      EquipmentSpec.rawFileSize => [
        _estimateText(v as num, EquipmentCandidate.rawSizeDecimals),
      ],
      EquipmentSpec.focalLength => [num1(v)],
      EquipmentSpec.focalRatio => [num1(v), ''],
    };
    List<num?> values(EquipmentSpec spec, Object v) => switch (spec) {
      EquipmentSpec.resolution ||
      EquipmentSpec.sensorSize => [for (final side in v as List) side as num],
      EquipmentSpec.focalRatio => [v as num, null],
      _ => [v as num],
    };
    for (final MapEntry(key: spec, value: choice) in taken.entries) {
      prefilled[spec] = PrefilledSpec(
        choice.provenance,
        texts(spec, choice.value),
        values: values(spec, choice.value),
      );
    }
    List<String>? of(EquipmentSpec s) => prefilled[s]?.texts;
    return EquipmentDraft(
      existing: rig,
      trackingType: rig.trackingType,
      cameraClass: rig.cameraClass,
      prefilled: prefilled,
      metadataMake: rig.metadataMake,
      metadataModel: rig.metadataModel,
      initial: EquipmentFormTexts(
        name: t.name,
        manufacturer: t.manufacturer,
        cameraModel: t.cameraModel,
        resolutionWidth: of(EquipmentSpec.resolution)?[0] ?? t.resolutionWidth,
        resolutionHeight:
            of(EquipmentSpec.resolution)?[1] ?? t.resolutionHeight,
        pixelPitch: of(EquipmentSpec.pixelPitch)?[0] ?? t.pixelPitch,
        sensorWidth: of(EquipmentSpec.sensorSize)?[0] ?? t.sensorWidth,
        sensorHeight: of(EquipmentSpec.sensorSize)?[1] ?? t.sensorHeight,
        focalLength: of(EquipmentSpec.focalLength)?[0] ?? t.focalLength,
        focalRatio: of(EquipmentSpec.focalRatio)?[0] ?? t.focalRatio,
        diameter: of(EquipmentSpec.focalRatio)?[1] ?? t.diameter,
        rawFileSize: of(EquipmentSpec.rawFileSize)?[0] ?? t.rawFileSize,
        rotation: t.rotation,
        maxExposure: t.maxExposure,
      ),
    );
  }

  static String _sensorText(double mm) =>
      mm.toStringAsFixed(EquipmentCandidate.sensorDecimals);

  static void _add(
    Map<EquipmentSpec, PrefilledSpec> into,
    EquipmentSpec spec,
    SpecProvenance provenance,
    String text, {
    required num value,
    bool fromSavedRig = false,
  }) {
    final before = into[spec];
    into[spec] = PrefilledSpec(
      provenance,
      [...?before?.texts, text],
      values: [...?before?.values, value],
      fromSavedRig: fromSavedRig,
    );
  }

  /// The rig being edited; null for a new one.
  final EquipmentProfile? existing;
  final EquipmentFormTexts initial;
  final TrackingType trackingType;

  /// The camera's class (ADR-020 §2): the rig's own when editing; always
  /// [CameraClass.unknown] for an import, which never proposes one.
  final CameraClass cameraClass;

  /// Pre-filled specs and their origin (empty for Add/Edit by hand).
  final Map<EquipmentSpec, PrefilledSpec> prefilled;

  /// The file's raw identity, stored for later matching (ADR-018 §5).
  final String? metadataMake;
  final String? metadataModel;

  /// A saved rig's camera specs not copied (S3.V8); null when none were.
  final WithheldCameraSpecs? withheldFromSavedRig;

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
    TrackingType trackingType, {
    CameraClass? cameraClass,
  }) {
    // S3.V3: while a pre-filled value's texts are unchanged, its exact value
    // is saved, never the (possibly rounded) text.
    num? exact(EquipmentSpec spec, int index) {
      final p = unchangedPrefill(spec, texts);
      return p == null || index >= p.values.length ? null : p.values[index];
    }

    final focal =
        exact(EquipmentSpec.focalLength, 0)?.toDouble() ??
        EquipmentFormInput.parse(texts.focalLength)!;
    final diameterText = texts.diameter.trim();
    final aperture = resolveAperture(
      focalLengthMm: focal,
      focalRatio: diameterText.isEmpty
          ? exact(EquipmentSpec.focalRatio, 0)?.toDouble() ??
                EquipmentFormInput.parse(texts.focalRatio)
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
      cameraClass: cameraClass ?? this.cameraClass,
      resolutionWidthPx:
          exact(EquipmentSpec.resolution, 0)?.toInt() ??
          int.parse(texts.resolutionWidth.trim()),
      resolutionHeightPx:
          exact(EquipmentSpec.resolution, 1)?.toInt() ??
          int.parse(texts.resolutionHeight.trim()),
      pixelPitchUm:
          exact(EquipmentSpec.pixelPitch, 0)?.toDouble() ??
          EquipmentFormInput.parse(texts.pixelPitch)!,
      // A chosen or copied sensor size is saved exactly (S3.V3); otherwise
      // an untouched sensor field keeps the stored value exactly, so opening
      // and saving never alters verified specs (TASK 8.5).
      sensorWidthMm:
          exact(EquipmentSpec.sensorSize, 0)?.toDouble() ??
          (e != null && texts.sensorWidth == _sensorText(e.sensorWidthMm)
              ? e.sensorWidthMm
              : EquipmentFormInput.parse(texts.sensorWidth)!),
      sensorHeightMm:
          exact(EquipmentSpec.sensorSize, 1)?.toDouble() ??
          (e != null && texts.sensorHeight == _sensorText(e.sensorHeightMm)
              ? e.sensorHeightMm
              : EquipmentFormInput.parse(texts.sensorHeight)!),
      focalLengthMm: focal,
      focalRatio: aperture.focalRatio!,
      apertureDiameterMm: aperture.diameterMm,
      averageRawFileSizeMB:
          exact(EquipmentSpec.rawFileSize, 0)?.toDouble() ??
          EquipmentFormInput.parse(texts.rawFileSize),
      rotationDeg: EquipmentFormInput.parse(texts.rotation),
      trackingType: trackingType,
      maxExposureS: EquipmentFormInput.parse(texts.maxExposure),
      // Only untouched pre-filled values keep their origin; a changed one
      // becomes the user's own through [EquipmentProfile.withEditProvenance].
      specProvenance: {
        for (final spec in EquipmentSpec.values)
          if (unchangedPrefill(spec, texts) case final p?) spec: p.provenance,
      },
      metadataMake: metadataMake,
      metadataModel: metadataModel,
    );
    return EquipmentDraftResult._(profile.withEditProvenance(e), null);
  }
}

/// How a pre-filled value's origin reads under its field.
abstract final class PrefillText {
  /// Why a saved rig's pixel size was not copied (S3.V8).
  static String withheld(WithheldCameraSpecs w) {
    String px(ImageDimensions d) => '${d.longSidePx} × ${d.shortSidePx} px';
    return 'Pixel size not copied from "${w.rigName}": this file is '
        '${px(w.file)}, that rig ${px(w.rig)}. Binning, a crop or another '
        'mode could explain the difference, so enter the pixel size for this '
        'one.';
  }

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
    if (source == EquipmentCandidate.rawFileSizeSource) {
      return "Estimated from this one file's size (DNG)";
    }
    final format = source.startsWith('metadata:')
        ? source.substring('metadata:'.length).split(':').first.toUpperCase()
        : source;
    return 'From the file ($format)';
  }
}
