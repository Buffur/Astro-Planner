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
}
