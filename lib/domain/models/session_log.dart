class SessionLog {
  final int id;
  final String targetName;
  final String equipmentName;
  final DateTime sessionDate;
  final int plannedLightFrames;
  final int? actualLightFrames;
  final int? rejectedFrames;
  final String? environmentalNotes;
  final String? processingNotes;

  const SessionLog({
    required this.id,
    required this.targetName,
    required this.equipmentName,
    required this.sessionDate,
    required this.plannedLightFrames,
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
    buffer.writeln('Equipment: $equipmentName');
    buffer.writeln('Planned Frames: $plannedLightFrames');
    if (actualLightFrames != null) {
      buffer.writeln('Actual Frames: $actualLightFrames');
    }
    if (rejectedFrames != null) {
      buffer.writeln('Rejected Frames: $rejectedFrames');
    }
    if (environmentalNotes != null && environmentalNotes!.isNotEmpty) {
      buffer.writeln('\nConditions: $environmentalNotes');
    }
    if (processingNotes != null && processingNotes!.isNotEmpty) {
      buffer.writeln('\nNotes: $processingNotes');
    }
    return buffer.toString();
  }
}
