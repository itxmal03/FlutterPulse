import 'package:flutter_pulse/models/pipeline_step_model.dart';

abstract class PipelinePlugin {
  String get id;
  String get name;
  String get description;
  String get version;
  String get author;

  /// whether this plugin's steps should run before the build step.
  /// defaults to false (post‑build).
  bool get isPreBuild => false;

  List<PipelineStep> buildSteps(); 
}
