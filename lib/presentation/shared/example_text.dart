import '../../domain/models/equipment_profile.dart';

/// How the shipped examples are named (TASK 4.4; RD-04, S6.8): the example
/// capture plan and the example rig never look like the user's own.
abstract final class ExampleText {
  static const plan = 'Example plan';
  static const startFromExample = 'Start from the example plan';
  static const rig = 'Example rig';

  /// Said where the example rig is chosen: what is real and what is not.
  static const rigNote =
      'An example: the camera is real, the optics are illustrative. Add your '
      'own rig to plan with it.';

  /// [rig]'s name, marked when it is the example (S6.8).
  static String rigName(EquipmentProfile rig) =>
      rig.isExample ? '${rig.name} (example rig)' : rig.name;
}
