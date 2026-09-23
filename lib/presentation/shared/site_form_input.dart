import 'coordinate_input.dart';

/// Parsing and validation for the site editor's non-coordinate fields
/// (TASK 7.3), usable as `TextFormField` validators. Ranges match
/// `LocationProfile`; coordinates use [CoordinateInput].
abstract final class SiteFormInput {
  static String? validateName(String? text) =>
      (text == null || text.trim().isEmpty) ? 'Name is required' : null;

  /// Metres above mean sea level, -500..9000. Required: the model has no
  /// "unknown" elevation.
  static String? validateElevation(String? text) {
    if (text == null || text.trim().isEmpty) return 'Elevation is required';
    final value = CoordinateInput.parse(text);
    if (value == null) return 'Enter metres, e.g. 295';
    if (value < -500 || value > 9000) {
      return 'Elevation must be between -500 and 9000 m';
    }
    return null;
  }

  /// Sky quality in mag/arcsec², 15..23; empty means unknown.
  static String? validateSqm(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    final value = CoordinateInput.parse(text);
    if (value == null) return 'Enter mag/arcsec², e.g. 21.2';
    if (value < 15 || value > 23) return 'SQM must be between 15 and 23';
    return null;
  }

  /// The trimmed text, or null when empty.
  static String? optionalText(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
