import 'package:flutter_pulse/models/pipeline_step_model.dart';

abstract class PipelinePlugin {
  String get id;
  String get name;
  String get description;
  String get version;
  String get author;

  List<PipelineStep> buildSteps();
}