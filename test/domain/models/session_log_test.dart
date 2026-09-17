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
    expect(text.contains('Equipment: Pixel 8 Pro'), isTrue);
    expect(text.contains('Planned Frames: 120'), isTrue);
    expect(text.contains('Actual Frames: 100'), isTrue);
    expect(text.contains('Conditions: Clear sky, windy'), isTrue);
  });
}
