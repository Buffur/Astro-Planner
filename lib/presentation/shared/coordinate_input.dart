/// Parsing and validation of typed coordinates (TASK 7.2 manual entry),
/// usable as `TextFormField` validators. Decimal degrees, north/east positive;
/// ranges match `LocationProfile`.
abstract final class CoordinateInput {
  /// Parses decimal degrees, accepting a comma as the decimal separator.
  static double? parse(String? text) {
    if (text == null) return null;
    final value = double.tryParse(text.trim().replaceAll(',', '.'));
    return (value != null && value.isFinite) ? value : null;
  }

  static String? validateLatitude(String? text) =>
      _validate(text, min: -90, max: 90, name: 'Latitude');

  static String? validateLongitude(String? text) =>
      _validate(text, min: -180, max: 180, name: 'Longitude');

  static String? _validate(
    String? text, {
    required double min,
    required double max,
    required String name,
  }) {
    if (text == null || text.trim().isEmpty) return '$name is required';
    final value = parse(text);
    if (value == null) return 'Enter decimal degrees, e.g. 46.05';
    if (value < min || value > max) {
      return '$name must be between ${min.toInt()} and ${max.toInt()}';
    }
    return null;
  }
}
