import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/domain/services/metadata_extractor.dart';

void main() {
  test('FITS header parsing', () async {
    final file = File('test_dummy.fit');
    final header = "SIMPLE  =                    T / file does conform to FITS standard             BITPIX  =                   16 / number of bits per data pixel                  NAXIS   =                    2 / number of data axes                            NAXIS1  =                 6248 / length of data axis 1                          NAXIS2  =                 4176 / length of data axis 2                          INSTRUME= 'ZWO ASI2600MC Pro'  / instrument name                                EXPTIME =                 60.0 / exposure time (s)                              FOCALLEN=                400.0 / focal length (mm)                              DATE-OBS= '2026-01-01T23:00:00' / UTC date that FITS file was created           END                                                                             ";
    final padded = header.padRight(2880, ' ');
    await file.writeAsString(padded);
    
    final metadata = await MetadataExtractor.extractFromFile(file);
    expect(metadata, isNotNull);
    expect(metadata?.cameraModel, 'ZWO ASI2600MC Pro');
    expect(metadata?.exposureTime, '60.0');
    if (file.existsSync()) {
      await file.delete();
    }
  });

  test('EXIF FocalLength rational parsing', () {
    expect(MetadataExtractor.parseRational('4000/10'), 400.0);
    expect(MetadataExtractor.parseRational('400/1'), 400.0);
    expect(MetadataExtractor.parseRational('50'), 50.0);
    expect(MetadataExtractor.parseRational('0'), isNull);
    expect(MetadataExtractor.parseRational('0/10'), isNull);
    expect(MetadataExtractor.parseRational(''), isNull);
    expect(MetadataExtractor.parseRational(null), isNull);
  });
}
