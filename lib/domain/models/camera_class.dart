/// What kind of camera a rig uses (ADR-020 §2; S7.2a). It decides which
/// capture settings a light block offers (ISO or gain, binning; S7.2b) and
/// feeds no calculation. Stored by [name] in `camera_modules.camera_class`;
/// anything unrecognised reads as [unknown]. Chosen by the user only: never
/// inferred from a name, a Make or Model string, or a file's format.
enum CameraClass {
  phone('Phone'),
  dslrMirrorless('DSLR or mirrorless'),
  astroColour('Astro camera (colour)'),
  astroMono('Astro camera (mono)'),
  unknown('Unknown');

  const CameraClass(this.label);

  final String label;

  static CameraClass fromStorage(String? value) => CameraClass.values
      .firstWhere((c) => c.name == value, orElse: () => CameraClass.unknown);

  /// Which sensitivity a light block records for this class (ADR-020 §3):
  /// ISO for phones and cameras, gain for astro cameras, the user's choice
  /// for Unknown. Never both on one block; never converted (SI-004).
  LightSensitivity get lightSensitivity => switch (this) {
    phone || dslrMirrorless => LightSensitivity.iso,
    astroColour || astroMono => LightSensitivity.gain,
    unknown => LightSensitivity.either,
  };

  /// Whether a light block offers binning (ADR-020 §3, B1): only where it is
  /// chosen per exposure (astro cameras) or the class is unknown. A phone's
  /// binning is its rig's mode; cameras offer none.
  bool get offersLightBinning =>
      this == astroColour || this == astroMono || this == unknown;
}

/// The sensitivity field a light block shows (ADR-020 §3).
enum LightSensitivity { iso, gain, either }
