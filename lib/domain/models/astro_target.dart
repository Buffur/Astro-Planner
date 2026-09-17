class AstroTarget {
  final int id;
  final String catalogId;
  final String? commonName;
  final double rightAscension;
  final double declination;
  final String type;

  const AstroTarget({
    required this.id,
    required this.catalogId,
    this.commonName,
    required this.rightAscension,
    required this.declination,
    required this.type,
  });
}
