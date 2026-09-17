class ImageMetadata {
  final String? cameraMake;
  final String? cameraModel;
  final String? focalLength;
  final String? aperture;
  final String? exposureTime;
  final String? iso;
  final String? dateTimeOriginal;
  final Map<String, String> rawTags;

  const ImageMetadata({
    this.cameraMake,
    this.cameraModel,
    this.focalLength,
    this.aperture,
    this.exposureTime,
    this.iso,
    this.dateTimeOriginal,
    this.rawTags = const {},
  });
}
