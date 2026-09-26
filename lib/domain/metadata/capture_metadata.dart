import 'metadata_format.dart';
import 'metadata_source.dart';
import 'metadata_value.dart';

/// The metadata contract (ADR-017 §2): the only fields Stage 2 extracts from
/// a capture file. Location, serial numbers and observer identity are not
/// part of it and are never read (ADR-017 §3). Units are in the names.
class CaptureMetadata {
  const CaptureMetadata({
    this.exposureSeconds = const AbsentValue(),
    this.sensitivity = const AbsentValue(),
    this.focalLengthMm = const AbsentValue(),
    this.focalLength35mmEquivalentMm = const AbsentValue(),
    this.fNumber = const AbsentValue(),
    this.captureTime = const AbsentValue(),
    this.cameraMake = const AbsentValue(),
    this.cameraModel = const AbsentValue(),
    this.uniqueCameraModel = const AbsentValue(),
    this.lensMake = const AbsentValue(),
    this.lensModel = const AbsentValue(),
  });

  final MetadataValue<double> exposureSeconds;
  final MetadataValue<Sensitivity> sensitivity;

  /// The real focal length of the optics that made the image.
  final MetadataValue<double> focalLengthMm;

  /// The 35 mm-film equivalent: a field-of-view comparison, never the focal
  /// length itself (ADR-017 §2). Kept apart so nothing mistakes one for the
  /// other.
  final MetadataValue<double> focalLength35mmEquivalentMm;

  final MetadataValue<double> fNumber;
  final MetadataValue<CaptureTime> captureTime;

  /// Identity strings, raw, for Stage 3. Neither is a reliable identifier
  /// on its own: two cameras of one phone can share all three (DECISIONS
  /// E.1, "Stage 2 decisions").
  final MetadataValue<String> cameraMake;
  final MetadataValue<String> cameraModel;
  final MetadataValue<String> uniqueCameraModel;
  final MetadataValue<String> lensMake;
  final MetadataValue<String> lensModel;
}

/// The result of reading one file (ADR-017 §5).
sealed class MetadataReading {
  const MetadataReading();
}

/// The file was read; each field may still be unknown.
final class MetadataRead extends MetadataReading {
  const MetadataRead(this.format, this.metadata);

  final MetadataFormat format;
  final CaptureMetadata metadata;
}

/// The format was recognised (or not) but has no reader (ADR-017 §8).
final class MetadataUnsupported extends MetadataReading {
  const MetadataUnsupported(this.format);

  final MetadataFormat format;
}

/// Why a file could not be read.
enum MetadataUnreadableReason {
  /// A structure points past the end of the file.
  truncated,

  /// A structure is invalid (a loop, an impossible count or size).
  corrupt,

  /// Reading it would take more than the byte budget (ADR-017 §4).
  overBudget,

  /// The file could not be opened or read.
  io,
}

/// The file's format is supported, but the file cannot be read.
final class MetadataUnreadable extends MetadataReading {
  const MetadataUnreadable(this.reason, [this.cause]);

  /// The reading for a failed read.
  factory MetadataUnreadable.fromReadFailure(MetadataReadException e) =>
      MetadataUnreadable(switch (e.error) {
        MetadataReadError.outOfRange => MetadataUnreadableReason.truncated,
        MetadataReadError.readTooLarge => MetadataUnreadableReason.corrupt,
        MetadataReadError.overBudget => MetadataUnreadableReason.overBudget,
        MetadataReadError.io => MetadataUnreadableReason.io,
      }, e);

  final MetadataUnreadableReason reason;

  /// The underlying error, for the log.
  final Object? cause;
}

/// What a sensitivity value means. ISO and gain are different quantities
/// and are never converted into each other (SI-004).
enum SensitivityKind {
  /// An ISO-type value whose standard the file does not name (EXIF
  /// PhotographicSensitivity without SensitivityType, or type 0).
  isoUnspecified,

  /// Standard output sensitivity (EXIF SensitivityType 1).
  standardOutputSensitivity,

  /// Recommended exposure index (EXIF SensitivityType 2).
  recommendedExposureIndex,

  /// ISO speed (EXIF SensitivityType 3).
  isoSpeed,
}

/// A sensitivity value with its kind (ADR-017 §2).
class Sensitivity {
  const Sensitivity(this.kind, this.value);

  final SensitivityKind kind;
  final double value;

  @override
  bool operator ==(Object other) =>
      other is Sensitivity && other.kind == kind && other.value == value;

  @override
  int get hashCode => Object.hash(kind, value);

  @override
  String toString() => '${kind.name} $value';
}

/// When a capture happened, as the file records it (ADR-017 §2–§3): the local
/// wall-clock time, plus the UTC offset only when the file records one. No
/// zone is ever inferred; without an offset the zone is unknown, and there
/// is no UTC instant.
class CaptureTime {
  const CaptureTime({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    required this.second,
    this.utcOffset,
  });

  final int year, month, day, hour, minute, second;

  /// The recorded offset from UTC, or null: zone unknown.
  final Duration? utcOffset;

  bool get isZoneKnown => utcOffset != null;

  /// The instant, only when the offset is recorded.
  DateTime? get utc => switch (utcOffset) {
    final offset? => DateTime.utc(
      year,
      month,
      day,
      hour,
      minute,
      second,
    ).subtract(offset),
    null => null,
  };

  @override
  bool operator ==(Object other) =>
      other is CaptureTime &&
      other.year == year &&
      other.month == month &&
      other.day == day &&
      other.hour == hour &&
      other.minute == minute &&
      other.second == second &&
      other.utcOffset == utcOffset;

  @override
  int get hashCode =>
      Object.hash(year, month, day, hour, minute, second, utcOffset);

  @override
  String toString() {
    String two(int n) => n.toString().padLeft(2, '0');
    final local =
        '$year-${two(month)}-${two(day)}T${two(hour)}:${two(minute)}:${two(second)}';
    final offset = utcOffset;
    if (offset == null) return '$local (zone unknown)';
    final sign = offset.isNegative ? '-' : '+';
    final minutes = offset.inMinutes.abs();
    return '$local$sign${two(minutes ~/ 60)}:${two(minutes % 60)}';
  }
}

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
