import 'calendar_date.dart';
import 'location_profile.dart';

/// What is known about the sky darkness at the current position (TASK 7.4,
/// PD-05 option A/B): a Bortle class and/or an SQM reading, each with its
/// source and date, or nothing (SI-007, SI-008: unknown is never shown as a
/// default).
///
/// The two scales are kept separate: there is no Bortle↔SQM conversion,
/// because none is sourced for this app (roadmap TASK 7.4 direction).
class SkyDarkness {
  const SkyDarkness({
    this.bortleClass,
    this.bortleSource,
    this.bortleDate,
    this.sqm,
    this.sqmSource,
    this.sqmDate,
    this.isSaved = true,
  });

  /// Nothing known.
  static const SkyDarkness unknown = SkyDarkness();

  /// The values stored on a saved [site].
  factory SkyDarkness.fromSite(LocationProfile site) => SkyDarkness(
    bortleClass: site.bortleClass,
    bortleSource: site.bortleSource,
    bortleDate: site.bortleDate,
    sqm: site.sqm,
    sqmSource: site.sqmSource,
    sqmDate: site.sqmDate,
  );

  /// Bortle class 1–9, or null when unknown.
  final int? bortleClass;
  final String? bortleSource;
  final CalendarDate? bortleDate;

  /// Sky quality in mag/arcsec², or null when unknown.
  final double? sqm;
  final String? sqmSource;
  final CalendarDate? sqmDate;

  /// False for a value entered for a transient position: it is held in
  /// memory only and is lost with the position.
  final bool isSaved;

  bool get hasBortle => bortleClass != null;
  bool get hasSqm => sqm != null;

  /// True when neither a Bortle class nor an SQM reading is known.
  bool get isUnknown => !hasBortle && !hasSqm;
}
