import '../../core/utils/quantity_text.dart';
import '../../domain/equipment_import/equipment_candidate.dart';
import '../../domain/equipment_import/equipment_matcher.dart';
import '../../domain/models/spec_confidence.dart';
import '../../domain/models/spec_provenance.dart';

/// How an equipment import reads on screen (S3.6, ADR-018 §6): the match
/// outcome in plain words, its reasons, and differing values with units and
/// sources. No calculation here; the domain decided everything.
abstract final class EquipmentImportText {
  static String headline(EquipmentCandidate c, EquipmentMatch m) {
    if (!c.hasEnoughEvidence) {
      return 'This file names no camera and gives no optics, so no rig can '
          'be proposed from it.';
    }
    String names() => m.rigs.map((r) => '"${r.rig.name}"').join(', ');
    return switch (m.outcome) {
      MatchKind.sameRig => 'You already have this rig: ${names()}.',
      MatchKind.likelySameRig =>
        'This is probably your rig ${names()}: the camera names differ '
            'slightly between file formats.',
      MatchKind.sameCameraOtherOptics =>
        'Same camera as ${names()}, with other optics.',
      MatchKind.croppedOrBinnedMode =>
        'Same camera and lens as ${names()}, but another field of view or '
            'pixel count (digital zoom, a crop or a binned mode).',
      MatchKind.ambiguous =>
        'Several saved rigs match this file: ${names()}. Choose one.',
      MatchKind.none => 'No saved rig has this camera.',
    };
  }

  static String reason(MatchReason r) => switch (r) {
    MatchReason.identityFromImport =>
      'camera identified from an earlier import',
    MatchReason.identityFromLabels => 'camera identified from the rig\'s names',
    MatchReason.sameMake => 'same make',
    MatchReason.sameModel => 'same model',
    MatchReason.modelByPrefix => 'model names match except for a suffix',
    MatchReason.sameFocalLength => 'same focal length',
    MatchReason.sameFocalRatio => 'same focal ratio',
    MatchReason.focalLengthDiffers => 'another focal length',
    MatchReason.focalRatioDiffers => 'another focal ratio',
    MatchReason.opticsUnknown => 'the file gives no focal length or f-number',
    MatchReason.pixelCountDiffers => 'another pixel count',
    MatchReason.fieldOfViewDiffers => 'another field of view',
  };

  static String reasons(List<MatchReason> rs) => rs.map(reason).join(' · ');

  static String spec(EquipmentSpec s) => switch (s) {
    EquipmentSpec.resolution => 'Resolution',
    EquipmentSpec.pixelPitch => 'Pixel size',
    EquipmentSpec.sensorSize => 'Sensor size',
    EquipmentSpec.rawFileSize => 'Average RAW file size',
    EquipmentSpec.focalLength => 'Focal length',
    EquipmentSpec.focalRatio => 'Focal ratio',
  };

  /// The switch that takes the file's value for [s] (off by default).
  static String useFileValue(EquipmentSpec s) =>
      "Use the file's ${spec(s).toLowerCase()}";

  /// A spec value with its unit; sizes as "width × height".
  static String value(EquipmentSpec s, Object v) {
    String n(Object x) => QuantityText.number(
      double.parse((x as num).toDouble().toStringAsFixed(3)),
    );
    String pair(String unit) {
      final sides = v as List;
      return '${n(sides[0])} × ${n(sides[1])} $unit';
    }

    return switch (s) {
      EquipmentSpec.resolution => pair('px'),
      EquipmentSpec.sensorSize => pair('mm'),
      EquipmentSpec.pixelPitch => '${n(v)} µm',
      EquipmentSpec.rawFileSize => '${n(v)} MB',
      EquipmentSpec.focalLength => '${n(v)} mm',
      EquipmentSpec.focalRatio => 'f/${n(v)}',
    };
  }

  static String provenance(SpecProvenance? p) {
    if (p == null) return 'source unknown';
    final confidence = switch (p.confidence) {
      SpecConfidence.verified => 'verified',
      SpecConfidence.reported => 'reported',
      SpecConfidence.estimated => 'estimated',
      null => 'confidence unknown',
    };
    final source = p.source;
    if (source == null) return confidence;
    if (source.startsWith('derived:calc-40')) {
      return 'estimated from the 35 mm equivalent';
    }
    if (source == EquipmentCandidate.rawFileSizeSource) {
      return "estimated from this one file's size";
    }
    if (source.startsWith('metadata:')) {
      return 'from the file, $confidence';
    }
    return '$confidence ($source)';
  }

  /// What the file can fill on a rig that lacks it (ADR-018 §6).
  static String fillable(EquipmentSpec s, EquipmentCandidate c) {
    final v = switch (s) {
      EquipmentSpec.rawFileSize => c.averageRawFileSizeMB.valueOrNull,
      _ => null,
    };
    return v == null
        ? ''
        : '${spec(s)} is unknown on this rig; the file suggests '
              '${value(s, v)} (estimated from one file). Open the rig to '
              'add it.';
  }

  /// One conflict's line: both values and their sources.
  static String conflict(FieldConflict c) =>
      'Saved: ${value(c.spec, c.saved)} (${provenance(c.savedProvenance)}). '
      'File: ${value(c.spec, c.imported)} '
      '(${provenance(c.importedProvenance)}).';
}
