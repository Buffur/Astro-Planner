import '../models/astro_target.dart';
import '../models/equipment_profile.dart';
import '../models/imaging_opportunity.dart';
import '../models/session_night.dart';
import '../models/sky_darkness.dart';
import 'astronomical_engine.dart';
import 'capability_calculator.dart';
import 'imaging_opportunity_calculator.dart';
import 'moon_calculator.dart';
import 'visibility_calculator.dart';

/// The Moon on one night's grid, computed once and shared by every target
/// (TASK 10.4): topocentric RA/Dec of date and altitude per instant, and
/// the night's illumination. Separations then cost only a precession and
/// an angle per target and instant — the same arithmetic as
/// [MoonCalculator.conditionsForNight], so results are identical.
class MoonTrack {
  const MoonTrack._(
    this.night,
    this.raDeg,
    this.decDeg,
    this.altitudesDeg,
    this.illumination,
  );

  factory MoonTrack.forNight(SessionNight night) {
    final ra = <double>[];
    final dec = <double>[];
    final alt = <double>[];
    for (var i = 0; i < ImagingOpportunityCalculator.gridCount; i++) {
      final t = ImagingOpportunityCalculator.instantAt(night, i);
      final topo = MoonCalculator.topocentric(
        t,
        night.latitude,
        night.longitude,
      );
      ra.add(topo.raDeg);
      dec.add(topo.decDeg);
      alt.add(
        VisibilityCalculator.calculateAltitude(
          lha: topo.hourAngleDeg,
          declination: topo.decDeg,
          latitude: night.latitude,
        ),
      );
    }
    return MoonTrack._(
      night,
      ra,
      dec,
      alt,
      MoonCalculator.illuminatedFraction(
        night.startUtc.add(const Duration(hours: 12)),
      ),
    );
  }

  final SessionNight night;
  final List<double> raDeg;
  final List<double> decDeg;
  final List<double> altitudesDeg;
  final double illumination;

  /// The calculator's Moon input for [target].
  OpportunityMoon forTarget(AstroTarget target) => OpportunityMoon(
    altitudesDeg: altitudesDeg,
    separationsDeg: [
      for (var i = 0; i < raDeg.length; i++) _separation(target, i),
    ],
    illumination: illumination,
  );

  double _separation(AstroTarget target, int i) {
    final (ra, dec) = AstronomicalEngine.precessJ2000ToDate(
      target.rightAscension,
      target.declination,
      AstronomicalEngine.calculateJulianDate(
        ImagingOpportunityCalculator.instantAt(night, i),
      ),
    );
    return MoonCalculator.angularSeparationDeg(raDeg[i], decDeg[i], ra, dec);
  }
}

/// One row of "Tonight's candidates" (TASK 10.4): measured facts, no score.
class TonightCandidate {
  const TonightCandidate({
    required this.target,
    required this.usableTime,
    required this.firstWindowStartUtc,
    required this.lastWindowEndUtc,
    required this.maxAltitudeDeg,
    required this.minMoonSeparationDeg,
    required this.frameFillFraction,
    required this.noWindowReason,
  });

  final AstroTarget target;

  /// The sum of tonight's imaging windows (ADR-013 §5, the ranking quantity).
  final Duration usableTime;

  /// Start of the first and end of the last window; null without a window.
  final DateTime? firstWindowStartUtc;
  final DateTime? lastWindowEndUtc;

  /// Highest altitude inside the windows, degrees; null without a window.
  final double? maxAltitudeDeg;

  /// Smallest Moon–target separation while the Moon is up inside the
  /// windows, degrees; null without a window or with the Moon down.
  final double? minMoonSeparationDeg;

  /// Target size ÷ the frame's short side (CALC-31); null without equipment
  /// or a known size.
  final double? frameFillFraction;

  /// Why there is no window; null when there is one.
  final NoWindowReason? noWindowReason;

  bool get hasWindow => noWindowReason == null;
}

/// Evaluates many targets for one night (TASK 10.4) with the single-target
/// [ImagingOpportunityCalculator], sharing the Sun and Moon samples.
abstract final class CandidateEvaluator {
  static List<TonightCandidate> evaluate({
    required SessionNight night,
    required List<AstroTarget> targets,
    required double darknessLimitDeg,
    required double minAltitudeDeg,
    OptionalGates gates = OptionalGates.none,
    OpportunityWeather? weather,
    SkyDarkness? skyDarkness,
    EquipmentProfile? equipment,
    double npfK = 1.0,
    SunTrack? sunTrack,
    MoonTrack? moonTrack,
  }) {
    final sun = sunTrack ?? SunTrack.forNight(night);
    final moon = moonTrack ?? MoonTrack.forNight(night);
    return [
      for (final target in targets)
        candidateOf(
          target,
          ImagingOpportunityCalculator.fromSamples(
            night: night,
            sunAltitudesDeg: sun.altitudesDeg,
            targetAltitudesDeg: [
              for (var i = 0; i < ImagingOpportunityCalculator.gridCount; i++)
                VisibilityCalculator.calculateTargetAltitude(
                  target,
                  ImagingOpportunityCalculator.instantAt(night, i),
                  night.latitude,
                  night.longitude,
                ),
            ],
            darknessLimitDeg: darknessLimitDeg,
            minAltitudeDeg: minAltitudeDeg,
            gates: gates,
            moon: moon.forTarget(target),
            weather: weather,
            skyDarkness: skyDarkness,
          ),
          equipment: equipment,
          npfK: npfK,
        ),
    ];
  }

  /// A row from one target's opportunity — also how the single-target view
  /// is compared with the batch.
  static TonightCandidate candidateOf(
    AstroTarget target,
    ImagingOpportunity o, {
    EquipmentProfile? equipment,
    double npfK = 1.0,
  }) {
    double? minSep;
    for (final w in o.windows) {
      final s = w.moon?.minSeparationDeg;
      if (s != null && (minSep == null || s < minSep)) minSep = s;
    }
    return TonightCandidate(
      target: target,
      usableTime: o.usableTime,
      firstWindowStartUtc: o.windows.isEmpty ? null : o.windows.first.startUtc,
      lastWindowEndUtc: o.windows.isEmpty ? null : o.windows.last.endUtc,
      maxAltitudeDeg: o.maxAltitudeInWindowsDeg,
      minMoonSeparationDeg: minSep,
      frameFillFraction: equipment == null
          ? null
          : CapabilityCalculator.evaluate(
              equipment,
              target: target,
              npfK: npfK,
            ).frameFillFraction,
      noWindowReason: o.noWindowReason,
    );
  }
}

/// The columns the candidates list can be sorted by (TASK 10.4: sorting
/// only, no score).
enum CandidateSort {
  usableTime,
  windowStart,
  maxAltitude,
  moonSeparation,
  frameFill,
  name,
}

/// Pure sorting and filtering for the candidates list.
abstract final class CandidateList {
  /// Sorts by [by]: usable time, max altitude, Moon separation and frame
  /// fill descending; window start ascending; name A–Z. Unknown values
  /// always sort last; ties fall back to the name.
  static List<TonightCandidate> sort(
    List<TonightCandidate> rows,
    CandidateSort by,
  ) {
    int byName(TonightCandidate a, TonightCandidate b) =>
        _name(a).toLowerCase().compareTo(_name(b).toLowerCase());
    int nullsLast<T extends Comparable<Object>>(
      T? a,
      T? b, {
      required bool descending,
    }) {
      if (a == null && b == null) return 0;
      if (a == null) return 1;
      if (b == null) return -1;
      return descending ? b.compareTo(a) : a.compareTo(b);
    }

    final out = [...rows];
    out.sort((a, b) {
      final c = switch (by) {
        CandidateSort.usableTime => b.usableTime.compareTo(a.usableTime),
        CandidateSort.windowStart => nullsLast(
          a.firstWindowStartUtc,
          b.firstWindowStartUtc,
          descending: false,
        ),
        CandidateSort.maxAltitude => nullsLast(
          a.maxAltitudeDeg,
          b.maxAltitudeDeg,
          descending: true,
        ),
        CandidateSort.moonSeparation => nullsLast(
          a.minMoonSeparationDeg,
          b.minMoonSeparationDeg,
          descending: true,
        ),
        CandidateSort.frameFill => nullsLast(
          a.frameFillFraction,
          b.frameFillFraction,
          descending: true,
        ),
        CandidateSort.name => 0,
      };
      return c != 0 ? c : byName(a, b);
    });
    return out;
  }

  /// Keeps rows matching every given filter: [withWindowOnly], [type]
  /// (exact), [ownOnly] (not a catalog entry: the user's own targets).
  static List<TonightCandidate> filter(
    List<TonightCandidate> rows, {
    bool withWindowOnly = true,
    String? type,
    bool ownOnly = false,
  }) => [
    for (final r in rows)
      if ((!withWindowOnly || r.hasWindow) &&
          (type == null || r.target.type == type) &&
          (!ownOnly || !r.target.isCatalogEntry))
        r,
  ];

  static String _name(TonightCandidate c) =>
      c.target.commonName ?? c.target.catalogId;
}
