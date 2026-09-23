import '../../core/utils/astro_math.dart';

/// `TextFormField` validators for the target editor (TASK 8.1). Parsing is
/// pure and lives in [AstroMath]; these only turn a failed parse into a
/// message.
abstract final class TargetFormInput {
  static String? validateRightAscension(String? text) {
    if (text == null || text.trim().isEmpty) return 'Required';
    return AstroMath.parseRightAscension(text) == null
        ? 'Use hours: 05h35m17s, 5:35:17 or 5.588 (or degrees: 83.82°)'
        : null;
  }

  static String? validateDeclination(String? text) {
    if (text == null || text.trim().isEmpty) return 'Required';
    return AstroMath.parseDeclination(text) == null
        ? 'Use −05°23′28″, -5:23:28 or -5.391 (within ±90°)'
        : null;
  }

  /// Parses an optional decimal; null when empty.
  static double? optionalNumber(String text) {
    final trimmed = text.trim().replaceAll(',', '.');
    return trimmed.isEmpty ? null : double.tryParse(trimmed);
  }

  /// Apparent size in arcminutes: optional, > 0 and at most 3000′ (50°).
  static String? validateAngularSize(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    final value = optionalNumber(text);
    if (value == null || !value.isFinite) return 'Enter arcminutes, e.g. 85';
    if (value <= 0 || value > 3000) return 'Must be above 0 and at most 3000′';
    return null;
  }

  /// Apparent magnitude: optional, −30..30.
  static String? validateMagnitude(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    final value = optionalNumber(text);
    if (value == null || !value.isFinite) return 'Enter a magnitude, e.g. 4.0';
    if (value < -30 || value > 30) return 'Must be between −30 and 30';
    return null;
  }
}
