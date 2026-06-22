import 'package:flutter_pulse/models/build_target.dart';

class BuildHistoryRecord {
  final String id;
  final String projectName;
  final String projectPath;
  final BuildTarget target;
  final bool success;
  final DateTime timestamp;
  final Duration duration;
  final String outputPath; // original flutter output
  final String? storedArtifactPath; // path to copied versioned artifact

  const BuildHistoryRecord({
    required this.id,
    required this.projectName,
    required this.projectPath,
    required this.target,
    required this.success,
    required this.timestamp,
    required this.duration,
    required this.outputPath,
    this.storedArtifactPath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectName': projectName,
    'projectPath': projectPath,
    'target': target.key,
    'success': success,
    'timestamp': timestamp.toIso8601String(),
    'durationMs': duration.inMilliseconds,
    'outputPath': outputPath,
    'storedArtifactPath': storedArtifactPath,
  };

  factory BuildHistoryRecord.fromJson(Map<String, dynamic> json) {
    return BuildHistoryRecord(
      id: json['id'] as String,
      projectName: json['projectName'] as String,
      projectPath: json['projectPath'] as String,
      target: BuildTarget.fromKey(json['target'] as String),
      success: json['success'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      duration: Duration(milliseconds: json['durationMs'] as int),
      outputPath: json['outputPath'] as String,
      storedArtifactPath: json['storedArtifactPath'] as String?,
    );
  }
}
