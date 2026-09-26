// Synthetic metadata candidates for equipment-import tests (neutral strings;
// the optics are the committed RG-01 phone values).

import 'package:astroplan/domain/equipment_import/equipment_candidate.dart';
import 'package:astroplan/domain/metadata/capture_metadata.dart';
import 'package:astroplan/domain/metadata/metadata_format.dart';
import 'package:astroplan/domain/metadata/metadata_value.dart';

KnownValue<T> _k<T>(T v, String field) => KnownValue(
  v,
  raw: '$v',
  origin: MetadataOrigin(format: MetadataFormat.jpeg, field: field),
);

/// A phone main camera's JPEG (neutral strings, committed RG-01 optics).
EquipmentCandidate phoneCandidate({bool withDims = true, bool with35 = true}) =>
    EquipmentCandidate.fromReading(
      MetadataRead(
        MetadataFormat.jpeg,
        CaptureMetadata(
          cameraMake: _k('TestMake', 'Make'),
          cameraModel: _k('TestMake TestPhone', 'Model'),
          focalLengthMm: _k(6.57, 'FocalLength'),
          fNumber: _k(1.6, 'FNumber'),
          exposureSeconds: _k(30.0, 'ExposureTime'),
          focalLength35mmEquivalentMm: with35
              ? _k(23.0, 'FocalLengthIn35mmFilm')
              : const AbsentValue(),
          imageDimensions: withDims
              ? _k(const ImageDimensions(3072, 4096), 'dims')
              : const AbsentValue(),
        ),
      ),
    );
