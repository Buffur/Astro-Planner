import 'dart:io';
import 'package:exif/exif.dart';
import '../models/image_metadata.dart';

class MetadataExtractor {
  static Future<ImageMetadata?> extractFromFile(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final tags = await readExifFromBytes(bytes);

      if (tags.isEmpty) {
        return null;
      }

      return ImageMetadata(
        cameraMake: tags['Image Make']?.printable,
        cameraModel: tags['Image Model']?.printable,
        focalLength: tags['EXIF FocalLength']?.printable,
        aperture: tags['EXIF FNumber']?.printable,
        exposureTime: tags['EXIF ExposureTime']?.printable,
        iso: tags['EXIF ISOSpeedRatings']?.printable,
        dateTimeOriginal: tags['EXIF DateTimeOriginal']?.printable,
        rawTags: tags.map((k, v) => MapEntry(k, v.printable)),
      );
    } catch (e) {
      return null;
    }
  }
}
