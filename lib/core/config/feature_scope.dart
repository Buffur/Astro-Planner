/// The single source every entry point (buttons, cards, routes) reads to
/// decide whether a feature built ahead of its approved roadmap phase is
/// visible (TASK 4.3, TD-014; policy decided in `docs/DECISIONS.md` PD-06
/// E.1). Flip a flag here — never gate the same feature a second way at
/// the call site.
class FeatureScope {
  const FeatureScope._();

  /// Visible since TASK 12.4 (PD-06 E.1): tokens are red-only and the
  /// whole app goes through the red filter; the mode is persisted.
  static bool get fieldMode => true;

  /// Visible since TASK 7.4 (PD-06 E.1): manual Bortle/SQM with a source,
  /// and the external map at the site's coordinates. No scraping.
  static bool get lightPollutionContext => true;

  /// Visible since S3.7 (ADR-018 §7, RD-16): "Add from a photo" on the
  /// equipment screen. Earlier: a debug-build viewer under Settings
  /// (owner, `23b962c`), hidden before that (Stage 2).
  static bool get metadataImport => true;

  /// Stays visible — on the core path (PD-06 E.1). Text sharing stays
  /// visible for the same reason; it has no gate of its own because it
  /// only appears inside the logbook screen this already gates.
  static bool get logbook => true;
}
