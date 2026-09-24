import '../../core/time/clock.dart';
import 'capture_block.dart';
import '../../core/config/app_identity.dart';

class SessionLog {
  final int id;

  // Basic Info
  final String targetName;
  final String equipmentName;
  final DateTime sessionDate;
  final String? locationName;
  final double? bortleScale;

  // Capture Plan
  final List<CaptureBlock> captureBlocks;
  final int plannedLightFrames;
  final int? plannedDarkFrames;
  final int? plannedFlatFrames;
  final int? plannedBiasFrames;
  final double? integrationTimeSeconds;

  // Equipment Snapshot
  final double? focalLength;
  final double? aperture;

  // Environmental / Weather Snapshot
  final double? temperature;
  final double? humidity;
  final int? cloudCover;

  // Actual Results
  final int? actualLightFrames;
  final int? rejectedFrames;
  final String? environmentalNotes;
  final String? processingNotes;

  const SessionLog({
    required this.id,
    required this.targetName,
    required this.equipmentName,
    required this.sessionDate,
    this.captureBlocks = const [],
    this.plannedLightFrames = 0,
    this.locationName,
    this.bortleScale,
    this.plannedDarkFrames,
    this.plannedFlatFrames,
    this.plannedBiasFrames,
    this.integrationTimeSeconds,
    this.focalLength,
    this.aperture,
    this.temperature,
    this.humidity,
    this.cloudCover,
    this.actualLightFrames,
    this.rejectedFrames,
    this.environmentalNotes,
    this.processingNotes,
  });

  String toShareableText() {
    final buffer = StringBuffer();
    buffer.writeln('${AppIdentity.appName} Session Log');
    buffer.writeln('----------------------');
    buffer.writeln('Target: $targetName');
    buffer.writeln('Date: ${sessionDate.toLocal().toString().split(' ')[0]}');
    if (locationName != null) buffer.writeln('Location: $locationName');

    buffer.writeln('\n--- Equipment ---');
    buffer.writeln('Rig: $equipmentName');
    if (focalLength != null) buffer.writeln('Focal Length: ${focalLength}mm');
    if (aperture != null) buffer.writeln('Aperture: f/$aperture');

    buffer.writeln('\n--- Capture Plan ---');
    buffer.writeln('Lights: $plannedLightFrames');
    if (plannedDarkFrames != null) buffer.writeln('Darks: $plannedDarkFrames');
    if (plannedFlatFrames != null) buffer.writeln('Flats: $plannedFlatFrames');
    if (plannedBiasFrames != null) {
      buffer.writeln('Bias/Dark-Flats: $plannedBiasFrames');
    }
    if (integrationTimeSeconds != null) {
      buffer.writeln(
        'Planned Integration: ${(integrationTimeSeconds! / 3600).toStringAsFixed(2)} hrs',
      );
    }

    buffer.writeln('\n--- Environment ---');
    if (temperature != null) buffer.writeln('Temperature: $temperature°C');
    if (humidity != null) buffer.writeln('Humidity: $humidity%');
    if (cloudCover != null) buffer.writeln('Cloud Cover: $cloudCover%');
    if (bortleScale != null) buffer.writeln('Bortle Scale: $bortleScale');
    if (environmentalNotes != null && environmentalNotes!.isNotEmpty) {
      buffer.writeln('Conditions Notes: $environmentalNotes');
    }

    buffer.writeln('\n--- Results & Notes ---');
    if (actualLightFrames != null) {
      buffer.writeln('Actual Lights: $actualLightFrames');
    }
    if (rejectedFrames != null) buffer.writeln('Rejected: $rejectedFrames');
    if (processingNotes != null && processingNotes!.isNotEmpty) {
      buffer.writeln('Processing: $processingNotes');
    }
    return buffer.toString();
  }

  // Serialization methods for Export/Interoperability
  Map<String, dynamic> toJson() {
    return {
      'manifest_version': 1,
      'app_name': 'AstroPlan',
      'session_id': id,
      'target_name': targetName,
      'equipment_name': equipmentName,
      'session_date_utc': sessionDate.toUtc().toIso8601String(),
      'location': {'name': locationName, 'bortle_scale': bortleScale},
      'equipment_snapshot': {
        'focal_length_mm': focalLength,
        'aperture_f': aperture,
      },
      'environment_snapshot': {
        'temperature_c': temperature,
        'humidity_percent': humidity,
        'cloud_cover_percent': cloudCover,
      },
      'capture_plan': {
        'blocks': captureBlocks
            .map(
              (b) => {
                'id': b.id,
                'frame_type': b.frameType.name,
                'filter_name': b.filterName,
                'exposure_seconds': b.exposureTimeSeconds,
                'frame_count': b.frameCount,
                'binning': b.binning,
                // TASK 5.3: typed, descriptive-only gain and the
                // calibration policy (replaced the free-text gain_iso).
                'gain_kind': b.gain.kind.name,
                'gain_value': b.gain.value,
                'calibration_policy': b.calibrationPolicy?.name,
              },
            )
            .toList(),
        'light_frames': plannedLightFrames,
        'dark_frames': plannedDarkFrames,
        'flat_frames': plannedFlatFrames,
        'bias_frames': plannedBiasFrames,
        'integration_time_seconds': integrationTimeSeconds,
      },
      'actual_results': {
        'light_frames': actualLightFrames,
        'rejected_frames': rejectedFrames,
        'environmental_notes': environmentalNotes,
        'processing_notes': processingNotes,
      },
    };
  }

  SessionLog copyWith({
    int? id,
    String? targetName,
    String? equipmentName,
    DateTime? sessionDate,
    String? locationName,
    double? bortleScale,
    List<CaptureBlock>? captureBlocks,
    int? plannedLightFrames,
    int? plannedDarkFrames,
    int? plannedFlatFrames,
    int? plannedBiasFrames,
    double? integrationTimeSeconds,
    double? focalLength,
    double? aperture,
    double? temperature,
    double? humidity,
    int? cloudCover,
    int? actualLightFrames,
    int? rejectedFrames,
    String? environmentalNotes,
    String? processingNotes,
  }) {
    return SessionLog(
      id: id ?? this.id,
      targetName: targetName ?? this.targetName,
      equipmentName: equipmentName ?? this.equipmentName,
      sessionDate: sessionDate ?? this.sessionDate,
      locationName: locationName ?? this.locationName,
      bortleScale: bortleScale ?? this.bortleScale,
      captureBlocks: captureBlocks ?? this.captureBlocks,
      plannedLightFrames: plannedLightFrames ?? this.plannedLightFrames,
      plannedDarkFrames: plannedDarkFrames ?? this.plannedDarkFrames,
      plannedFlatFrames: plannedFlatFrames ?? this.plannedFlatFrames,
      plannedBiasFrames: plannedBiasFrames ?? this.plannedBiasFrames,
      integrationTimeSeconds:
          integrationTimeSeconds ?? this.integrationTimeSeconds,
      focalLength: focalLength ?? this.focalLength,
      aperture: aperture ?? this.aperture,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      cloudCover: cloudCover ?? this.cloudCover,
      actualLightFrames: actualLightFrames ?? this.actualLightFrames,
      rejectedFrames: rejectedFrames ?? this.rejectedFrames,
      environmentalNotes: environmentalNotes ?? this.environmentalNotes,
      processingNotes: processingNotes ?? this.processingNotes,
    );
  }

  /// [clock] supplies the fallback `sessionDate` when the manifest has no
  /// `session_date_utc` (unchanged behavior: "now", as a local `DateTime`).
  factory SessionLog.fromJson(
    Map<String, dynamic> json, {
    Clock clock = const SystemClock(),
  }) {
    final location = json['location'] as Map<String, dynamic>? ?? {};
    final equipment = json['equipment_snapshot'] as Map<String, dynamic>? ?? {};
    final env = json['environment_snapshot'] as Map<String, dynamic>? ?? {};
    final plan = json['capture_plan'] as Map<String, dynamic>? ?? {};
    final results = json['actual_results'] as Map<String, dynamic>? ?? {};

    return SessionLog(
      id: json['session_id'] as int? ?? 0,
      targetName: json['target_name'] as String? ?? 'Unknown Target',
      equipmentName: json['equipment_name'] as String? ?? 'Unknown Equipment',
      sessionDate: json['session_date_utc'] != null
          ? DateTime.parse(json['session_date_utc'] as String).toLocal()
          : clock.nowUtc().toLocal(),
      locationName: location['name'] as String?,
      bortleScale: (location['bortle_scale'] as num?)?.toDouble(),
      focalLength: (equipment['focal_length_mm'] as num?)?.toDouble(),
      aperture: (equipment['aperture_f'] as num?)?.toDouble(),
      temperature: (env['temperature_c'] as num?)?.toDouble(),
      humidity: (env['humidity_percent'] as num?)?.toDouble(),
      cloudCover: env['cloud_cover_percent'] as int?,
      captureBlocks: (plan['blocks'] as List<dynamic>? ?? [])
          .map((b) => _blockFromManifest(b as Map<String, dynamic>))
          .whereType<CaptureBlock>()
          .toList(),
      plannedLightFrames: plan['light_frames'] as int? ?? 0,
      plannedDarkFrames: plan['dark_frames'] as int?,
      plannedFlatFrames: plan['flat_frames'] as int?,
      plannedBiasFrames: plan['bias_frames'] as int?,
      integrationTimeSeconds: (plan['integration_time_seconds'] as num?)
          ?.toDouble(),
      actualLightFrames: results['light_frames'] as int?,
      rejectedFrames: results['rejected_frames'] as int?,
      environmentalNotes: results['environmental_notes'] as String?,
      processingNotes: results['processing_notes'] as String?,
    );
  }

  /// One manifest block, or null when it is invalid (TASK 5.3: an invalid
  /// block cannot exist in the domain). Reads the pre-5.3 free-text
  /// `gain_iso` as an unknown-kind value, never guessing ISO vs gain.
  static CaptureBlock? _blockFromManifest(Map<String, dynamic> b) {
    final type = CaptureBlock.tryParseFrameType(b['frame_type'] as String?);
    if (type == null) return null;
    try {
      final CaptureGain gain;
      if (b.containsKey('gain_kind')) {
        gain = CaptureGain.fromStored(
          b['gain_kind'] as String?,
          (b['gain_value'] as num?)?.toDouble(),
        );
      } else {
        final legacy = double.tryParse('${b['gain_iso'] ?? ''}'.trim());
        gain = legacy != null && legacy.isFinite && legacy >= 0
            ? CaptureGain.unknown(legacy)
            : CaptureGain.none;
      }
      return CaptureBlock(
        id: b['id'] as int? ?? 0,
        frameType: type,
        filterName: b['filter_name'] as String?,
        exposureTimeSeconds: (b['exposure_seconds'] as num?)?.toDouble() ?? 0,
        frameCount: b['frame_count'] as int? ?? 0,
        binning: b['binning'] as int? ?? 1,
        gain: gain,
        calibrationPolicy: type == FrameType.light
            ? null
            : CalibrationPolicy.tryParse(b['calibration_policy'] as String?),
      );
    } on ArgumentError {
      return null;
    }
  }
}
