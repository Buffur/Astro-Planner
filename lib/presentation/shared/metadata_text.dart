import '../../core/utils/quantity_text.dart';
import '../../domain/metadata/capture_metadata.dart';
import '../../domain/metadata/metadata_format.dart';
import '../../domain/metadata/metadata_value.dart';

/// How the metadata contract reads on screen (F-45, S2.5): units always, the
/// source of every value, and unknowns said as unknown, never as a number.
abstract final class MetadataText {
  static String format(MetadataFormat f) => switch (f) {
    MetadataFormat.dng => 'DNG',
    MetadataFormat.tiff => 'TIFF (not a DNG)',
    MetadataFormat.jpeg => 'JPEG',
    MetadataFormat.heif => 'HEIF/HEIC',
    MetadataFormat.png => 'PNG',
    MetadataFormat.fits => 'FITS',
    MetadataFormat.xisf => 'XISF',
    MetadataFormat.cr2 => 'Canon CR2',
    MetadataFormat.cr3 => 'Canon CR3',
    MetadataFormat.raf => 'Fujifilm RAF',
    MetadataFormat.rw2 => 'Panasonic RW2',
    MetadataFormat.orf => 'Olympus ORF',
    MetadataFormat.unknown => 'an unrecognised format',
  };

  /// Recognised without a reader, or not recognised at all (ADR-017 §13).
  static String unsupported(MetadataFormat f) => f == MetadataFormat.unknown
      ? "This file's format is not recognised."
      : "This file's format (${format(f)}) is not supported yet.";

  static String unreadable(MetadataUnreadableReason r) => switch (r) {
    MetadataUnreadableReason.truncated =>
      'The file ends before its metadata does.',
    MetadataUnreadableReason.corrupt => "The file's metadata is damaged.",
    MetadataUnreadableReason.overBudget =>
      'Its metadata is larger than the app reads from a file.',
    MetadataUnreadableReason.io => 'The file could not be read.',
  };

  /// The rows of a [CaptureMetadata], in reading order.
  static List<({String label, String value, String? source})> rows(
    CaptureMetadata m,
  ) => [
    _row('Exposure', m.exposureSeconds, QuantityText.exposure),
    _row('ISO', m.sensitivity, sensitivity),
    _row(
      'Focal length',
      m.focalLengthMm,
      (v) => '${QuantityText.number(v)} mm',
    ),
    _row(
      '35 mm equivalent',
      m.focalLength35mmEquivalentMm,
      (v) =>
          '${QuantityText.number(v)} mm (field of view, not the focal length)',
    ),
    _row('Aperture', m.fNumber, (v) => 'f/${QuantityText.number(v)}'),
    _row('Captured', m.captureTime, captureTime),
    _row('Camera make', m.cameraMake, (v) => v),
    _row('Camera model', m.cameraModel, (v) => v),
    _row('Unique camera model', m.uniqueCameraModel, (v) => v),
    _row('Lens make', m.lensMake, (v) => v),
    _row('Lens model', m.lensModel, (v) => v),
  ];

  static ({String label, String value, String? source}) _row<T>(
    String label,
    MetadataValue<T> value,
    String Function(T) show,
  ) => switch (value) {
    KnownValue<T>(:final value, :final origin) => (
      label: label,
      value: show(value),
      source: source(origin),
    ),
    AbsentValue<T>() => (label: label, value: 'Not in the file', source: null),
    UnparseableValue<T>(:final raw, :final origin) => (
      label: label,
      value: 'Unreadable value ("$raw")',
      source: source(origin),
    ),
    AmbiguousValue<T>(:final candidates) => (
      label: label,
      value:
          'Unknown: conflicting values '
          '${candidates.map((c) => '"${c.raw}"').join(' and ')}',
      source: candidates.map((c) => source(c.origin)).join('; '),
    ),
  };

  static String source(MetadataOrigin o) =>
      [format(o.format), ?o.location, o.field].join(' · ');

  static String sensitivity(Sensitivity s) {
    final value = QuantityText.number(s.value);
    return switch (s.kind) {
      SensitivityKind.isoUnspecified => 'ISO $value (standard not stated)',
      SensitivityKind.standardOutputSensitivity =>
        'ISO $value (standard output sensitivity)',
      SensitivityKind.recommendedExposureIndex =>
        'ISO $value (recommended exposure index)',
      SensitivityKind.isoSpeed => 'ISO $value (ISO speed)',
    };
  }

  /// The recorded wall-clock time; the zone only when the file records it.
  static String captureTime(CaptureTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    final local =
        '${t.year}-${two(t.month)}-${two(t.day)} '
        '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
    final offset = t.utcOffset;
    if (offset == null) return '$local (time zone not recorded)';
    final minutes = offset.inMinutes.abs();
    final sign = offset.isNegative ? '−' : '+';
    return '$local (UTC$sign${two(minutes ~/ 60)}:${two(minutes % 60)})';
  }
}
