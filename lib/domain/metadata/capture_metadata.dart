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
    this.imageDimensions = const AbsentValue(),
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

  /// The pixel dimensions of the captured image, as the file stores them
  /// (ADR-018 §3, amending ADR-017 §2). Orientation is not interpreted:
  /// a portrait capture may report width and height swapped, so equipment
  /// uses [ImageDimensions.longSidePx] and [ImageDimensions.shortSidePx].
  final MetadataValue<ImageDimensions> imageDimensions;

  /// Every field, in contract order.
  List<MetadataValue<Object>> get values => [
    exposureSeconds,
    sensitivity,
    focalLengthMm,
    focalLength35mmEquivalentMm,
    fNumber,
    captureTime,
    cameraMake,
    cameraModel,
    uniqueCameraModel,
    lensMake,
    lensModel,
    imageDimensions,
  ];
}

/// An image's pixel dimensions, as stored in the file (ADR-018 §3).
class ImageDimensions {
  const ImageDimensions(this.widthPx, this.heightPx);

  final int widthPx;
  final int heightPx;

  int get longSidePx => widthPx >= heightPx ? widthPx : heightPx;
  int get shortSidePx => widthPx >= heightPx ? heightPx : widthPx;

  @override
  bool operator ==(Object other) =>
      other is ImageDimensions &&
      other.widthPx == widthPx &&
      other.heightPx == heightPx;

  @override
  int get hashCode => Object.hash(widthPx, heightPx);

  @override
  String toString() => '${widthPx}x$heightPx';
}

/// The result of reading one file (ADR-017 §5, §13). Two of the three levels
/// are kept apart here: [format] is **recognition** (what the file is, from
/// its signature and, for DNG, its tags); the subclass is **extraction**
/// ([MetadataRead], [MetadataUnsupported], [MetadataUnreadable]). The third
/// level, whether the values are enough evidence for an EquipmentCandidate,
/// is Stage 3's (RG-02) and is never implied here.
sealed class MetadataReading {
  const MetadataReading(this.format);

  /// The recognised format; [MetadataFormat.unknown] when unrecognised.
  final MetadataFormat format;
}

/// Extraction ran; each field may still be unknown.
final class MetadataRead extends MetadataReading {
  const MetadataRead(super.format, this.metadata);

  final CaptureMetadata metadata;

  /// True when the file carries none of the contract's fields: the file
  /// was read, and there is simply nothing to report (never an error, and
  /// never filled in).
  bool get nothingFound => metadata.values.every((v) => v is AbsentValue);
}

/// No extraction: the format is recognised but has no reader (ADR-017
/// §13), or it is not recognised at all ([recognized] is false).
final class MetadataUnsupported extends MetadataReading {
  const MetadataUnsupported(super.format);

  bool get recognized => format != MetadataFormat.unknown;
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

/// Extraction failed: the file could not be read. [format] is what was
/// recognised before the failure (unknown when it failed before that).
final class MetadataUnreadable extends MetadataReading {
  const MetadataUnreadable(
    this.reason, [
    this.cause,
    MetadataFormat format = MetadataFormat.unknown,
  ]) : super(format);

  /// The reading for a failed read.
  factory MetadataUnreadable.fromReadFailure(
    MetadataReadException e, {
    MetadataFormat format = MetadataFormat.unknown,
  }) => MetadataUnreadable(
    switch (e.error) {
      MetadataReadError.outOfRange => MetadataUnreadableReason.truncated,
      MetadataReadError.readTooLarge => MetadataUnreadableReason.corrupt,
      MetadataReadError.overBudget => MetadataUnreadableReason.overBudget,
      MetadataReadError.io => MetadataUnreadableReason.io,
    },
    e,
    format,
  );

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
