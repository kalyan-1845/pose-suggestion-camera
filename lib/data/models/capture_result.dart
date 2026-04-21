/// Metadata for a captured photo
class CaptureResult {
  final String filePath;
  final DateTime timestamp;
  final String templateId;
  final String templateName;
  final double matchScore;
  final double brightness;
  final double contrast;

  CaptureResult({
    required this.filePath,
    required this.timestamp,
    required this.templateId,
    required this.templateName,
    required this.matchScore,
    this.brightness = 0.0,
    this.contrast = 1.0,
  });

  CaptureResult copyWith({
    double? brightness,
    double? contrast,
  }) {
    return CaptureResult(
      filePath: filePath,
      timestamp: timestamp,
      templateId: templateId,
      templateName: templateName,
      matchScore: matchScore,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
    );
  }
}
