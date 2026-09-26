import 'capture_metadata.dart';
import 'metadata_value.dart';

// EXIF/TIFF value conversions, shared by every container that carries an
// EXIF structure (DNG/TIFF, and later JPEG, HEIF, PNG; ADR-017 §13).

/// An EXIF/TIFF RATIONAL or SRATIONAL, kept exact until converted.
class ExifRational {
  const ExifRational(this.numerator, this.denominator);

  final int numerator;
  final int denominator;

  @override
  String toString() => '$numerator/$denominator';
}

/// Conversions from EXIF/TIFF values to contract values (ADR-017 §2, §5;
/// CALC-39). Pure; the reader (S2.3) supplies the raw values it found.
abstract final class ExifValues {
  /// A positive quantity from a rational: exposure in seconds (EXIF stores
  /// seconds), f-number, or focal length in mm (EXIF stores mm). A zero
  /// denominator, or a value that is not positive, is unparseable.
  static MetadataValue<double> positive(
    ExifRational? rational,
    MetadataOrigin origin,
  ) {
    if (rational == null) return const AbsentValue();
    final raw = rational.toString();
    if (rational.denominator == 0) {
      return UnparseableValue(raw: raw, origin: origin);
    }
    final value = rational.numerator / rational.denominator;
    if (!(value > 0) || !value.isFinite) {
      return UnparseableValue(raw: raw, origin: origin);
    }
    return KnownValue(value, raw: raw, origin: origin);
  }

  /// FocalLengthIn35mmFilm (a SHORT, mm): 0 means unknown (EXIF 2.3).
  static MetadataValue<double> focalLength35mm(
    int? value,
    MetadataOrigin origin,
  ) {
    if (value == null || value == 0) return const AbsentValue();
    return KnownValue(value.toDouble(), raw: '$value', origin: origin);
  }

  /// PhotographicSensitivity (ISOSpeedRatings) with SensitivityType. The
  /// kind is unspecified unless the type names exactly one standard (1, 2
  /// or 3); a combination (4–7) does not say which one the value is. 0 is
  /// not a sensitivity; 65535 means "65535 or more" (the real value is in a
  /// tag outside the contract), so both are unparseable.
  static MetadataValue<Sensitivity> sensitivity(
    int? photographicSensitivity,
    int? sensitivityType,
    MetadataOrigin origin,
  ) {
    final value = photographicSensitivity;
    if (value == null) return const AbsentValue();
    final raw = sensitivityType == null
        ? '$value'
        : '$value (type $sensitivityType)';
    if (value <= 0 || value >= 65535) {
      return UnparseableValue(raw: raw, origin: origin);
    }
    final kind = switch (sensitivityType) {
      1 => SensitivityKind.standardOutputSensitivity,
      2 => SensitivityKind.recommendedExposureIndex,
      3 => SensitivityKind.isoSpeed,
      _ => SensitivityKind.isoUnspecified,
    };
    return KnownValue(
      Sensitivity(kind, value.toDouble()),
      raw: raw,
      origin: origin,
    );
  }

  static final _dateTime = RegExp(
    r'^(\d{4}):(\d{2}):(\d{2}) (\d{2}):(\d{2}):(\d{2})$',
  );
  static final _offset = RegExp(r'^([+-])(\d{2}):(\d{2})$');

  /// DateTimeOriginal (`YYYY:MM:DD HH:MM:SS`, local) with
  /// OffsetTimeOriginal (`±HH:MM`) when present. A time the file marks as
  /// unknown (blank, or all zeros) is absent. An offset that cannot be
  /// parsed leaves the zone unknown; its text stays in the raw value.
  static MetadataValue<CaptureTime> captureTime(
    String? dateTime,
    String? offset,
    MetadataOrigin origin,
  ) {
    final text = dateTime == null ? null : cleanText(dateTime);
    if (text == null ||
        text.replaceAll(RegExp(r'[\s:]'), '').isEmpty ||
        text.replaceAll(RegExp(r'[\s:0]'), '').isEmpty) {
      return const AbsentValue();
    }
    final offsetText = offset == null ? null : cleanText(offset);
    final raw = offsetText == null ? text : '$text $offsetText';
    final m = _dateTime.firstMatch(text);
    if (m == null) return UnparseableValue(raw: raw, origin: origin);
    final [year, month, day, hour, minute, second] = [
      for (var i = 1; i <= 6; i++) int.parse(m.group(i)!),
    ];
    final valid =
        month >= 1 &&
        month <= 12 &&
        day >= 1 &&
        day <= _daysIn(year, month) &&
        hour <= 23 &&
        minute <= 59 &&
        second <= 59;
    if (!valid) return UnparseableValue(raw: raw, origin: origin);
    return KnownValue(
      CaptureTime(
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second,
        utcOffset: offsetText == null ? null : _parseOffset(offsetText),
      ),
      raw: raw,
      origin: origin,
    );
  }

  static Duration? _parseOffset(String text) {
    final m = _offset.firstMatch(text);
    if (m == null) return null;
    final hours = int.parse(m.group(2)!);
    final minutes = int.parse(m.group(3)!);
    if (hours > 14 || minutes > 59 || (hours == 14 && minutes > 0)) return null;
    final offset = Duration(hours: hours, minutes: minutes);
    return m.group(1) == '-' ? -offset : offset;
  }

  static int _daysIn(int year, int month) => switch (month) {
    2 => (year % 4 == 0 && year % 100 != 0) || year % 400 == 0 ? 29 : 28,
    4 || 6 || 9 || 11 => 30,
    _ => 31,
  };

  /// An ASCII value without its NUL terminator and surrounding spaces, or
  /// null when nothing is left.
  static String? cleanText(String text) {
    final nul = text.indexOf('\u0000');
    final cleaned = (nul < 0 ? text : text.substring(0, nul)).trim();
    return cleaned.isEmpty ? null : cleaned;
  }

  /// A text field (make, model, lens): absent when empty.
  static MetadataValue<String> text(String? value, MetadataOrigin origin) {
    final cleaned = value == null ? null : cleanText(value);
    if (cleaned == null) return const AbsentValue();
    return KnownValue(cleaned, raw: cleaned, origin: origin);
  }
}
