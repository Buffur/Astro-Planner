import 'dart:math' as math;

/// Mathematical constants and utilities for astronomical calculations.
class AstroMath {
  /// Converts degrees to radians.
  /// Formula: radians = degrees * (pi / 180)
  static double degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  /// Converts radians to degrees.
  /// Formula: degrees = radians * (180 / pi)
  static double radiansToDegrees(double radians) {
    return radians * (180.0 / math.pi);
  }

  /// Converts Right Ascension (hours, minutes, seconds) to decimal degrees.
  /// Purpose: Internal coordinate representation.
  /// Inputs: hours (0-24), minutes (0-60), seconds (0-60)
  /// Formula: (h + m/60 + s/3600) * 15
  static double raToDecimalDegrees(int hours, int minutes, double seconds) {
    final decimalHours = hours + (minutes / 60.0) + (seconds / 3600.0);
    return decimalHours * 15.0;
  }

  /// Converts Declination (degrees, minutes, seconds) to decimal degrees.
  /// Purpose: Internal coordinate representation.
  /// Inputs: degrees (-90 to 90), minutes (0-60), seconds (0-60), isNegative (bool)
  /// Formula: (abs(d) + m/60 + s/3600) * sign
  static double decToDecimalDegrees(
    int degrees,
    int minutes,
    double seconds, {
    bool isNegative = false,
  }) {
    final absDegrees = degrees.abs();
    final decimal = absDegrees + (minutes / 60.0) + (seconds / 3600.0);
    return isNegative || degrees < 0 ? -decimal : decimal;
  }

  static final RegExp _number = RegExp(r'^\d+(\.\d+)?$');
  static final RegExp _integer = RegExp(r'^\d+$');

  /// Splits sexagesimal text into 1–3 numeric fields after turning every
  /// accepted separator into a space; null if anything else is left.
  static List<String>? _fields(String text, RegExp separators) {
    final parts = text
        .replaceAll(separators, ' ')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty || parts.length > 3) return null;
    if (!parts.every(_number.hasMatch)) return null;
    // Only the last field may have a fractional part.
    for (var i = 0; i < parts.length - 1; i++) {
      if (!_integer.hasMatch(parts[i])) return null;
    }
    return parts;
  }

  /// Sum of sexagesimal [fields] (whole unit, minutes, seconds), or null if
  /// minutes or seconds are 60 or more.
  static double? _sexagesimal(List<String> fields) {
    final values = fields.map(double.parse).toList();
    for (var i = 1; i < values.length; i++) {
      if (values[i] >= 60) return null;
    }
    var total = values[0];
    if (values.length > 1) total += values[1] / 60.0;
    if (values.length > 2) total += values[2] / 3600.0;
    return total;
  }

  /// Parses a right ascension typed by a user (TASK 8.1) into decimal
  /// degrees in [0, 360), or null if it is not valid.
  ///
  /// Accepted: hours as `h:m:s`, `h m s`, `05h35m17.3s` (also `ʰᵐˢ`), `h m`
  /// or a single number of **hours** (`5.588`); or explicit degrees with a
  /// `°`/`d`/`deg` suffix (`83.82°`). A bare number is hours, never degrees.
  static double? parseRightAscension(String input) {
    final text = input.trim().toLowerCase();
    if (text.isEmpty) return null;
    final degrees = RegExp(r'^(\d+(?:\.\d+)?)\s*(?:°|deg|d)$').firstMatch(text);
    if (degrees != null) {
      final value = double.parse(degrees.group(1)!);
      return value < 360 ? value : null;
    }
    final fields = _fields(
      text.replaceFirst(RegExp(r'[sˢ]$'), ''),
      RegExp(r'[hʰmᵐ:\s]'),
    );
    if (fields == null) return null;
    final hours = _sexagesimal(fields);
    if (hours == null || hours >= 24) return null;
    return hours * 15.0;
  }

  /// Parses a declination typed by a user (TASK 8.1) into decimal degrees in
  /// [-90, 90], or null if it is not valid.
  ///
  /// Accepted: `d:m:s`, `d m s`, `−05°23′28″`, `-5d23m28s`, `d m`, or
  /// decimal degrees. The sign applies to the whole value, so `-0 30`
  /// is −0.5°. ASCII `-` and the minus sign `−` (U+2212) are both accepted.
  static double? parseDeclination(String input) {
    var text = input.trim().toLowerCase();
    if (text.isEmpty) return null;
    var negative = false;
    if (text.startsWith('-') || text.startsWith('\u2212')) {
      negative = true;
      text = text.substring(1);
    } else if (text.startsWith('+')) {
      text = text.substring(1);
    }
    final fields = _fields(
      text.replaceFirst(RegExp('[s"\u2033]\$'), ''),
      RegExp("[°d'\u2032m:\\s]"),
    );
    if (fields == null) return null;
    final degrees = _sexagesimal(fields);
    if (degrees == null || degrees > 90) return null;
    return negative ? -degrees : degrees;
  }

  /// Formats right ascension degrees as `05h35m17.3s` (0.1 s resolution).
  static String formatRightAscension(double degrees) {
    var tenths = (normalizeDegrees(degrees) / 15.0 * 36000).round();
    if (tenths >= 24 * 36000) tenths -= 24 * 36000;
    final h = tenths ~/ 36000;
    final m = (tenths % 36000) ~/ 600;
    final s = (tenths % 600) / 10.0;
    return '${_two(h)}h${_two(m)}m${s < 10 ? '0' : ''}${s.toStringAsFixed(1)}s';
  }

  /// Formats declination degrees as `−05°23′28″` (1″ resolution, with the
  /// minus sign U+2212 or `+`).
  static String formatDeclination(double degrees) {
    final seconds = (degrees.abs() * 3600).round();
    final sign = degrees < 0 && seconds > 0 ? '\u2212' : '+';
    final d = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '$sign${_two(d)}°${_two(m)}\u2032${_two(s)}\u2033';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  /// Normalizes an angle in degrees to the range [0, 360).
  static double normalizeDegrees(double degrees) {
    var result = degrees % 360.0;
    if (result < 0) result += 360.0;
    return result;
  }
}
