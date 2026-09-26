/// One written form for each quantity the app shows (S1.7; audit ENG-06,
/// UX-19), shared by the domain's reason texts and the presentation, so the
/// same value reads the same everywhere. Formatting only.
abstract final class QuantityText {
  /// A duration rounded to the nearest minute: "5 h 35 min", "45 min",
  /// "3 h", "0 min"; under a minute (but not zero) in seconds: "30 s".
  /// A negative duration gets a minus sign.
  static String duration(Duration d) {
    if (d.isNegative) return '−${duration(-d)}';
    if (d > Duration.zero && d < const Duration(minutes: 1)) {
      final s = (d.inMilliseconds / 1000).round();
      return s == 60 ? '1 min' : '${s < 1 ? 1 : s} s';
    }
    final minutes = (d.inMilliseconds / 60000).round();
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '$m min';
    return m == 0 ? '$h h' : '$h h $m min';
  }

  /// Exposure: "60 s", "2.5 s", "1/50 s". Sub-second values within 0.5%
  /// of an integer reciprocal use that fraction; non-exact equivalents
  /// carry an approximation sign. This is display rounding only: metadata,
  /// raw rationals and calculations retain the original value. A 1e-12
  /// relative tolerance ignores floating-point division noise.
  static String exposure(double seconds) {
    if (seconds > 0 && seconds < 1) {
      final reciprocal = 1 / seconds;
      if (reciprocal.isFinite) {
        final denominator = reciprocal.round();
        final relativeDifference = (seconds * denominator - 1).abs();
        if (denominator >= 2 && relativeDifference <= 0.005) {
          final approximation = relativeDifference <= 1e-12 ? '' : '≈';
          return '${approximation}1/$denominator s';
        }
      }
    }
    return '${number(seconds)} s';
  }

  /// Degrees with the typographic minus (U+2212): "−18°", "46.050°".
  static String degrees(double value, {int digits = 0}) =>
      '${signed(value, digits: digits)}°';

  /// [value] to [digits] decimals with the typographic minus (U+2212):
  /// "−3.0"; never "−0".
  static String signed(double value, {int digits = 0}) {
    final text = value.abs().toStringAsFixed(digits);
    final zero = double.parse(text) == 0;
    return '${value < 0 && !zero ? '−' : ''}$text';
  }

  /// A percentage with a space before the sign: "3 %".
  static String percent(num value) => '${value.round()} %';

  /// [value] without a trailing ".0": "60", "2.5", "0.25".
  static String number(double value) =>
      value == value.roundToDouble() ? '${value.round()}' : '$value';
}
