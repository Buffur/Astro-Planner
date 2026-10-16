import 'package:astroplan/core/time/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/domain/models/session_log.dart';

void main() {
  // S8.7: toShareableText (every field, notes included) was retired with
  // its two tests; entry_share_text_test.dart covers the Share text now.
  test('SessionLog toJson and fromJson work correctly', () {
    final original = SessionLog(
      id: 3,
      targetName: 'Rosette Nebula',
      equipmentName: 'Widefield Rig',
      sessionDate: DateTime(2026, 12, 15, 22, 0).toUtc().toLocal(),
      locationName: 'Dark Site',
      bortleScale: 2.0,
      plannedLightFrames: 100,
      plannedDarkFrames: 30,
      plannedFlatFrames: 30,
      plannedBiasFrames: 100,
      integrationTimeSeconds: 18000.0,
      focalLength: 200,
      aperture: 2.8,
      temperature: -5.0,
      humidity: 70,
      cloudCover: 5,
      actualLightFrames: 95,
      rejectedFrames: 5,
      environmentalNotes: 'Excellent seeing',
      processingNotes: 'Stack in Siril',
    );

    final json = original.toJson();

    // Verify specific manifest structure
    expect(json['manifest_version'], 1);
    expect(json['app_name'], 'AstroPlan');
    expect(json['target_name'], 'Rosette Nebula');

    // Nested checks
    expect(json['location']['name'], 'Dark Site');
    expect(json['equipment_snapshot']['focal_length_mm'], 200.0);
    expect(json['capture_plan']['light_frames'], 100);
    expect(json['actual_results']['environmental_notes'], 'Excellent seeing');

    // Deserialize back
    final restored = SessionLog.fromJson(json);

    // Verify properties match
    expect(restored.id, original.id);
    expect(restored.targetName, original.targetName);
    expect(restored.equipmentName, original.equipmentName);
    expect(
      restored.sessionDate.toUtc().toIso8601String(),
      original.sessionDate.toUtc().toIso8601String(),
    );
    expect(restored.locationName, original.locationName);
    expect(restored.bortleScale, original.bortleScale);
    expect(restored.plannedLightFrames, original.plannedLightFrames);
    expect(restored.plannedDarkFrames, original.plannedDarkFrames);
    expect(restored.integrationTimeSeconds, original.integrationTimeSeconds);
    expect(restored.focalLength, original.focalLength);
    expect(restored.aperture, original.aperture);
    expect(restored.temperature, original.temperature);
    expect(restored.actualLightFrames, original.actualLightFrames);
    expect(restored.environmentalNotes, original.environmentalNotes);
  });

  test(
    'fromJson without session_date_utc falls back to the injected clock',
    () {
      final instant = DateTime.utc(2026, 9, 22, 1, 30);
      final restored = SessionLog.fromJson(
        const {},
        clock: FixedClock(instant),
      );
      expect(restored.sessionDate.toUtc(), instant);
    },
  );
}
