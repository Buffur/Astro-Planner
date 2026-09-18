import 'dart:io';
import 'package:exif/exif.dart';
import '../models/image_metadata.dart';

class MetadataExtractor {
  static Future<ImageMetadata?> extractFromFile(File file) async {
    try {
      final bytes = await file.readAsBytes();

      if (bytes.length >= 80) {
        final headerStart = String.fromCharCodes(bytes.sublist(0, 80));
        if (headerStart.startsWith('SIMPLE  =')) {
          return _parseFits(bytes);
        }
      }

      final tags = await readExifFromBytes(bytes);

      if (tags.isEmpty) {
        return null;
      }

      return ImageMetadata(
        cameraMake: tags['Image Make']?.printable ?? tags['Image Make']?.toString(),
        cameraModel: tags['Image Model']?.printable ?? tags['Image Model']?.toString(),
        focalLength: tags['EXIF FocalLength']?.printable ?? tags['EXIF FocalLength']?.toString(),
        aperture: tags['EXIF FNumber']?.printable ?? tags['EXIF FNumber']?.toString(),
        exposureTime: tags['EXIF ExposureTime']?.printable ?? tags['EXIF ExposureTime']?.toString(),
        iso: tags['EXIF ISOSpeedRatings']?.printable ?? tags['EXIF ISOSpeedRatings']?.toString(),
        dateTimeOriginal: tags['EXIF DateTimeOriginal']?.printable ?? tags['EXIF DateTimeOriginal']?.toString(),
        rawTags: tags.map((k, v) => MapEntry(k, v.printable)),
      );
    } catch (e) {
      return null;
    }
  }

  static ImageMetadata? _parseFits(List<int> bytes) {
    String? cameraModel;
    String? exposureTime;
    String? focalLength;
    String? dateTimeOriginal;
    Map<String, String> rawTags = {};

    try {
      // FITS header uses ASCII.
      final headerStr = String.fromCharCodes(bytes);
      for (int i = 0; i < headerStr.length; i += 80) {
        if (i + 80 > headerStr.length) break;
        final card = headerStr.substring(i, i + 80);
        if (card.startsWith('END ')) break;

        if (card.contains('=')) {
          final parts = card.split('=');
          final key = parts[0].trim();
          var valueStr = parts.skip(1).join('=').split('/')[0].trim();
          if (valueStr.startsWith("'") && valueStr.endsWith("'")) {
            valueStr = valueStr.substring(1, valueStr.length - 1).trim();
          }

          rawTags[key] = valueStr;
          if (key == 'INSTRUME' || key == 'CAMERAMOD') cameraModel = valueStr;
          if (key == 'EXPTIME' || key == 'EXPOSURE') exposureTime = valueStr;
          if (key == 'FOCALLEN') focalLength = valueStr;
          if (key == 'DATE-OBS') dateTimeOriginal = valueStr;
        }
      }

      if (rawTags.isEmpty) return null;

      return ImageMetadata(
        cameraMake: null,
        cameraModel: cameraModel,
        focalLength: focalLength,
        aperture: rawTags['APERTURE'] ?? rawTags['FOCALRATIO'],
        exposureTime: exposureTime,
        iso: rawTags['GAIN'] ?? rawTags['ISOSPEED'],
        dateTimeOriginal: dateTimeOriginal,
        rawTags: rawTags,
      );
    } catch (e) {
      return null;
    }
  }
}
