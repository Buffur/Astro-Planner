class LocationProfile {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final double elevation;
  final int bortleClass;

  const LocationProfile({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.elevation,
    this.bortleClass = 4,
  });
}
