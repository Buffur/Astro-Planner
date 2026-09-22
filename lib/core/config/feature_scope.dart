/// The single source every entry point (buttons, cards, routes) reads to
/// decide whether a feature built ahead of its approved roadmap phase is
/// visible (TASK 4.3, TD-014; policy decided in `docs/DECISIONS.md` PD-06
/// E.1). Flip a flag here — never gate the same feature a second way at
/// the call site.
class FeatureScope {
  const FeatureScope._();

  /// Hidden until TASK 12.4 (PD-06 E.1).
  static bool get fieldMode => false;

  /// Hidden until TASK 7.4 (PD-06 E.1).
  static bool get lightPollutionContext => false;

  /// Hidden until G17 / v1.1 (PD-06 E.1).
  static bool get metadataImport => false;

  /// Stays visible — on the core path (PD-06 E.1). Text sharing stays
  /// visible for the same reason; it has no gate of its own because it
  /// only appears inside the logbook screen this already gates.
  static bool get logbook => true;
}
