import 'package:flutter_test/flutter_test.dart';
import 'package:astroplan/domain/models/session_log.dart';

void main() {
  test('SessionLog toShareableText formats correctly', () {
    final log = SessionLog(
      id: 1,
      targetName: 'Andromeda Galaxy',
      equipmentName: 'Pixel 8 Pro',
      sessionDate: DateTime(2026, 9, 17),
      plannedLightFrames: 120,
      actualLightFrames: 100,
      environmentalNotes: 'Clear sky, windy',
    );

    final text = log.toShareableText();

    expect(text.contains('AstroPlan Session Log'), isTrue);
    expect(text.contains('Target: Andromeda Galaxy'), isTrue);
    expect(text.contains('Date: 2026-09-17'), isTrue);
    expect(text.contains('Rig: Pixel 8 Pro'), isTrue);
    expect(text.contains('Lights: 120'), isTrue);
    expect(text.contains('Actual Lights: 100'), isTrue);
    expect(text.contains('Conditions Notes: Clear sky, windy'), isTrue);
  });

  test('SessionLog toShareableText formats expanded fields correctly', () {
    final log = SessionLog(
      id: 2,
      targetName: 'Orion Nebula',
      equipmentName: 'Deep Sky Rig',
      sessionDate: DateTime(2026, 12, 01),
      locationName: 'Backyard',
      bortleScale: 4.5,
      plannedLightFrames: 60,
      plannedDarkFrames: 20,
      plannedFlatFrames: 20,
      plannedBiasFrames: 50,
      integrationTimeSeconds: 3600.0,
      focalLength: 400,
      aperture: 5.6,
      temperature: -2.5,
      humidity: 85,
      cloudCover: 10,
    );

    final text = log.toShareableText();

    expect(text.contains('Location: Backyard'), isTrue);
    expect(text.contains('Focal Length: 400.0mm'), isTrue);
    expect(text.contains('Aperture: f/5.6'), isTrue);
    expect(text.contains('Lights: 60'), isTrue);
    expect(text.contains('Darks: 20'), isTrue);
    expect(text.contains('Flats: 20'), isTrue);
    expect(text.contains('Bias/Dark-Flats: 50'), isTrue);
    expect(text.contains('Planned Integration: 1.00 hrs'), isTrue);
    expect(text.contains('Temperature: -2.5°C'), isTrue);
    expect(text.contains('Humidity: 85.0%'), isTrue);
    expect(text.contains('Cloud Cover: 10%'), isTrue);
    expect(text.contains('Bortle Scale: 4.5'), isTrue);
  });

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
    expect(restored.sessionDate.toUtc().toIso8601String(), original.sessionDate.toUtc().toIso8601String());
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
}
