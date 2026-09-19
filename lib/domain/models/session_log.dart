import 'capture_block.dart';

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
    buffer.writeln('AstroPlan Session Log');
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
    if (plannedBiasFrames != null) buffer.writeln('Bias/Dark-Flats: $plannedBiasFrames');
    if (integrationTimeSeconds != null) {
      buffer.writeln('Planned Integration: ${(integrationTimeSeconds! / 3600).toStringAsFixed(2)} hrs');
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
    if (actualLightFrames != null) buffer.writeln('Actual Lights: $actualLightFrames');
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
      'location': {
        'name': locationName,
        'bortle_scale': bortleScale,
      },
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
        'blocks': captureBlocks.map((b) => {
          'id': b.id,
          'frame_type': b.frameType.name,
          'filter_name': b.filterName,
          'exposure_seconds': b.exposureTimeSeconds,
          'frame_count': b.frameCount,
          'binning': b.binning,
          'gain_iso': b.gainIso,
        }).toList(),
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
      integrationTimeSeconds: integrationTimeSeconds ?? this.integrationTimeSeconds,
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

  factory SessionLog.fromJson(Map<String, dynamic> json) {
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
          : DateTime.now(),
      locationName: location['name'] as String?,
      bortleScale: (location['bortle_scale'] as num?)?.toDouble(),
      focalLength: (equipment['focal_length_mm'] as num?)?.toDouble(),
      aperture: (equipment['aperture_f'] as num?)?.toDouble(),
      temperature: (env['temperature_c'] as num?)?.toDouble(),
      humidity: (env['humidity_percent'] as num?)?.toDouble(),
      cloudCover: env['cloud_cover_percent'] as int?,
      captureBlocks: (plan['blocks'] as List<dynamic>? ?? []).map((b) {
        final bMap = b as Map<String, dynamic>;
        return CaptureBlock(
          id: bMap['id'] as int? ?? 0,
          frameType: FrameType.values.firstWhere((e) => e.name == bMap['frame_type'], orElse: () => FrameType.light),
          filterName: bMap['filter_name'] as String?,
          exposureTimeSeconds: (bMap['exposure_seconds'] as num?)?.toDouble() ?? 0.0,
          frameCount: bMap['frame_count'] as int? ?? 0,
          binning: bMap['binning'] as int? ?? 1,
          gainIso: bMap['gain_iso'] as String?,
        );
      }).toList(),
      plannedLightFrames: plan['light_frames'] as int? ?? 0,
      plannedDarkFrames: plan['dark_frames'] as int?,
      plannedFlatFrames: plan['flat_frames'] as int?,
      plannedBiasFrames: plan['bias_frames'] as int?,
      integrationTimeSeconds: (plan['integration_time_seconds'] as num?)?.toDouble(),
      actualLightFrames: results['light_frames'] as int?,
      rejectedFrames: results['rejected_frames'] as int?,
      environmentalNotes: results['environmental_notes'] as String?,
      processingNotes: results['processing_notes'] as String?,
    );
  }
}
