class FeatureScope {
  const FeatureScope._();

  /// Features implemented ahead of their approved roadmap phase stay disabled
  /// here until the phase is explicitly accepted.
  static bool get fieldMode => false;
  static bool get lightPollutionContext => false;
  static bool get metadataImport => true;
  static bool get logbook => true;
}
