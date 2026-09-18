enum FrameType {
  light,
  dark,
  flat,
  bias
}

class CaptureBlock {
  final int id;
  final int sessionLogId;
  final FrameType frameType;
  final String? filterName;
  final double exposureTimeSeconds;
  final int frameCount;
  final int binning;
  final String? gainIso;

  const CaptureBlock({
    this.id = 0,
    this.sessionLogId = 0,
    required this.frameType,
    this.filterName,
    required this.exposureTimeSeconds,
    required this.frameCount,
    this.binning = 1,
    this.gainIso,
  });

  CaptureBlock copyWith({
    int? id,
    int? sessionLogId,
    FrameType? frameType,
    String? filterName,
    double? exposureTimeSeconds,
    int? frameCount,
    int? binning,
    String? gainIso,
  }) {
    return CaptureBlock(
      id: id ?? this.id,
      sessionLogId: sessionLogId ?? this.sessionLogId,
      frameType: frameType ?? this.frameType,
      filterName: filterName ?? this.filterName,
      exposureTimeSeconds: exposureTimeSeconds ?? this.exposureTimeSeconds,
      frameCount: frameCount ?? this.frameCount,
      binning: binning ?? this.binning,
      gainIso: gainIso ?? this.gainIso,
    );
  }
}
