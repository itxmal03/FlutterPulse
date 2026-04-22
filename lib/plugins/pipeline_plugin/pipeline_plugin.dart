import 'package:flutter_pulse/models/pipeline_step_model.dart';

abstract class PipelinePlugin {
  String get id;     // unique key (e.g. "test")
  String get name;   // shown in UI

  List<PipelineStep> buildSteps();
}