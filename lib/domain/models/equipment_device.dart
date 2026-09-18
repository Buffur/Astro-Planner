class EquipmentDevice {
  final int id;
  final String name;
  final String? manufacturer;
  final String? model;
  final String? notes;

  const EquipmentDevice({
    required this.id,
    required this.name,
    this.manufacturer,
    this.model,
    this.notes,
  });
}
