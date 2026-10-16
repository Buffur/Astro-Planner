import '../../domain/models/night_timeline.dart';

/// One stretch of the night at one depth of darkness (S9.6): 1 civil
/// twilight, 2 nautical, 3 astronomical, 4 dark (the Sun below −18°).
class TwilightBand {
  const TwilightBand(this.startUtc, this.endUtc, this.depth);

  final DateTime startUtc;
  final DateTime endUtc;
  final int depth;

  Duration get length => endUtc.difference(startUtc);

  @override
  bool operator ==(Object other) =>
      other is TwilightBand &&
      other.startUtc == startUtc &&
      other.endUtc == endUtc &&
      other.depth == depth;

  @override
  int get hashCode => Object.hash(startUtc, endUtc, depth);

  @override
  String toString() => 'TwilightBand($startUtc – $endUtc, $depth)';
}

/// The night from sunset to sunrise as bands of the standard twilights,
/// for the Night & Moon detail's bar (S9.6). Only the domain's crossings
/// ([NightTimeline], CALC-10/CALC-23) are used: nothing is computed from
/// the Sun here, only which crossings enclose which stretch. Pure.
abstract final class TwilightBands {
  /// The bands in time order, or null when there is no night to draw (the
  /// Sun never sets in the window).
  static List<TwilightBand>? of(NightTimeline t) {
    final window = (t.night.startUtc, t.night.endUtc);
    final span = _below(t.sunriseSunset, window);
    if (span == null) return null;
    final levels = [
      for (final r in [
        t.civilTwilight,
        t.nauticalTwilight,
        t.astronomicalTwilight,
      ])
        ?_below(r, window),
    ];
    DateTime clip(DateTime x) => x.isBefore(span.$1)
        ? span.$1
        : x.isAfter(span.$2)
        ? span.$2
        : x;
    final edges = {
      span.$1,
      span.$2,
      for (final (a, b) in levels) ...[clip(a), clip(b)],
    }.toList()..sort();
    final bands = <TwilightBand>[];
    for (var i = 0; i + 1 < edges.length; i++) {
      final a = edges[i], b = edges[i + 1];
      if (!b.isAfter(a)) continue;
      final mid = a.add(b.difference(a) ~/ 2);
      final depth =
          1 +
          levels.where((l) => !mid.isBefore(l.$1) && mid.isBefore(l.$2)).length;
      if (bands.isNotEmpty && bands.last.depth == depth) {
        bands[bands.length - 1] = TwilightBand(bands.last.startUtc, b, depth);
      } else {
        bands.add(TwilightBand(a, b, depth));
      }
    }
    return bands;
  }

  /// When the Sun is below [r]'s threshold inside [window], or null when it
  /// never is.
  static (DateTime, DateTime)? _below(
    SunThresholdResult r,
    (DateTime, DateTime) window,
  ) => switch (r) {
    SunCrossing(:final duskUtc, :final dawnUtc) => (
      duskUtc ?? window.$1,
      dawnUtc ?? window.$2,
    ),
    SunAlwaysBelow() => window,
    SunNeverBelow() => null,
  };
}
