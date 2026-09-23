import '../../domain/models/equipment_limits.dart';

/// Parsing and validation for the equipment editor (TASK 8.4). Bounds come
/// from [EquipmentLimits] (ADR-011 §4); every message names the unit. A
/// value that does not parse is an error — never a silent `0`.
abstract final class EquipmentFormInput {
  /// Parses a decimal (accepting a comma), or null.
  static double? parse(String? text) {
    if (text == null) return null;
    final value = double.tryParse(text.trim().replaceAll(',', '.'));
    return (value != null && value.isFinite) ? value : null;
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : '$v';

  static String _rangeMessage(Range r, String unit) =>
      'Must be ${_fmt(r.min)}–${_fmt(r.max)}${unit.isEmpty ? '' : ' $unit'}';

  static String? Function(String?) required(Range range, String unit) =>
      (text) {
        if (text == null || text.trim().isEmpty) return 'Required';
        final value = parse(text);
        if (value == null) return 'Invalid';
        return range.contains(value) ? null : _rangeMessage(range, unit);
      };

  static String? Function(String?) optional(Range range, String unit) =>
      (text) {
        if (text == null || text.trim().isEmpty) return null;
        final value = parse(text);
        if (value == null) return 'Invalid';
        return range.contains(value) ? null : _rangeMessage(range, unit);
      };

  /// Whole pixels.
  static String? validateResolution(String? text) {
    if (text == null || text.trim().isEmpty) return 'Required';
    final value = int.tryParse(text.trim());
    if (value == null) return 'Invalid';
    return EquipmentLimits.resolutionPx.contains(value.toDouble())
        ? null
        : _rangeMessage(EquipmentLimits.resolutionPx, 'px');
  }

  /// The message for an aperture that could not be resolved.
  static String apertureMessage(ApertureProblem problem) => switch (problem) {
    ApertureProblem.missing =>
      'Enter the focal ratio (f/) or the diameter (mm)',
    ApertureProblem.focalRatioOutOfRange =>
      'Focal ratio must be f/0.5–f/32 — check the focal length and diameter',
    ApertureProblem.diameterOutOfRange => 'Diameter must be 1–2000 mm',
    ApertureProblem.disagree =>
      'Focal length ÷ diameter does not match the focal ratio (within 1 %)',
  };
}
