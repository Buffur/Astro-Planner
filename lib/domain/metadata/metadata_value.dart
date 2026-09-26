import 'metadata_format.dart';

/// Who put a value into the file (ADR-017 §5). Either way it is a reported
/// value, never a measurement the app made.
enum MetadataProvenance {
  /// Written by the capture device's firmware (a camera or a phone).
  captureDevice,

  /// Written by capture software from its user's settings, such as
  /// N.I.N.A.'s FOCALLEN "taken from equipment options" (RG-01 §3.3). Used
  /// from S2.6 (FITS).
  softwareSetting,
}

/// Where a value was read.
class MetadataOrigin {
  const MetadataOrigin({
    required this.format,
    required this.field,
    this.location,
    this.provenance = MetadataProvenance.captureDevice,
  });

  final MetadataFormat format;

  /// The tag or keyword, for example `ExposureTime (33434)` or `EXPTIME`.
  final String field;

  /// Where in the file, for example `IFD0` or `EXIF IFD`; null when the
  /// format has a single place.
  final String? location;

  final MetadataProvenance provenance;

  @override
  bool operator ==(Object other) =>
      other is MetadataOrigin &&
      other.format == format &&
      other.field == field &&
      other.location == location &&
      other.provenance == provenance;

  @override
  int get hashCode => Object.hash(format, field, location, provenance);

  @override
  String toString() =>
      '${format.name}:${location == null ? '' : '$location/'}$field';
}

/// One field of the metadata contract (ADR-017 §5). Unknown stays unknown:
/// there is no default, and nothing is ever filled in to make a field known.
sealed class MetadataValue<T> {
  const MetadataValue();

  /// The value when [KnownValue], otherwise null.
  T? get valueOrNull => switch (this) {
    KnownValue<T>(:final value) => value,
    _ => null,
  };

  /// One field found in several places (for example IFD0 and the EXIF IFD):
  /// absent places are ignored; equal known values agree; anything else
  /// (different values, or a value next to an unparseable one) is
  /// [AmbiguousValue], and stays unknown.
  static MetadataValue<T> combine<T>(Iterable<MetadataValue<T>> values) {
    final present = [
      for (final v in values)
        if (v is! AbsentValue<T>) v,
    ];
    if (present.isEmpty) return AbsentValue<T>();
    if (present.length == 1) return present.single;
    final first = present.first;
    if (first is KnownValue<T> &&
        present.every((v) => v is KnownValue<T> && v.value == first.value)) {
      return first;
    }
    return AmbiguousValue<T>([
      for (final v in present)
        ...switch (v) {
          KnownValue<T>(:final raw, :final origin) ||
          UnparseableValue<T>(
            :final raw,
            :final origin,
          ) => [(raw: raw, origin: origin)],
          AmbiguousValue<T>(:final candidates) => candidates,
          AbsentValue<T>() => const [],
        },
    ]);
  }
}

/// A value read and understood. [raw] is the value as stored in the file
/// (for example `3750000000/125000000`), kept for display and audit.
final class KnownValue<T> extends MetadataValue<T> {
  const KnownValue(this.value, {required this.raw, required this.origin});

  final T value;
  final String raw;
  final MetadataOrigin origin;

  @override
  bool operator ==(Object other) =>
      other is KnownValue<T> &&
      other.value == value &&
      other.raw == raw &&
      other.origin == origin;

  @override
  int get hashCode => Object.hash(value, raw, origin);

  @override
  String toString() => 'Known($value from $origin, raw "$raw")';
}

/// The file does not carry the value (or says it is unknown).
final class AbsentValue<T> extends MetadataValue<T> {
  const AbsentValue();

  @override
  bool operator ==(Object other) => other is AbsentValue<T>;

  @override
  int get hashCode => (AbsentValue<T>).hashCode;

  @override
  String toString() => 'Absent';
}

/// The file carries something that is not a valid value for the field.
final class UnparseableValue<T> extends MetadataValue<T> {
  const UnparseableValue({required this.raw, required this.origin});

  final String raw;
  final MetadataOrigin origin;

  @override
  bool operator ==(Object other) =>
      other is UnparseableValue<T> &&
      other.raw == raw &&
      other.origin == origin;

  @override
  int get hashCode => Object.hash(raw, origin);

  @override
  String toString() => 'Unparseable("$raw" from $origin)';
}

/// The file carries conflicting values for the field; all are kept.
final class AmbiguousValue<T> extends MetadataValue<T> {
  const AmbiguousValue(this.candidates);

  final List<({String raw, MetadataOrigin origin})> candidates;

  @override
  bool operator ==(Object other) =>
      other is AmbiguousValue<T> &&
      other.candidates.length == candidates.length &&
      [
        for (var i = 0; i < candidates.length; i++)
          other.candidates[i] == candidates[i],
      ].every((same) => same);

  @override
  int get hashCode => Object.hashAll(candidates);

  @override
  String toString() => 'Ambiguous($candidates)';
}
