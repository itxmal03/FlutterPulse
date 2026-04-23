import 'package:flutter_pulse/models/pipeline_step_model.dart';
import 'package:flutter_pulse/plugins/pipeline_plugin/pipeline_plugin.dart';

class TestPlugin extends PipelinePlugin {
  @override
  String get id => "test";

  @override
  String get name => "Test Plugin";

  @override
  String get description => "Runs flutter tests before build";

  @override
  String get version => "1.0.0";

  @override
  String get author => "FlowForge";

  @override
  List<PipelineStep> buildSteps() {
    return [
      PipelineStep("Test", "flutter test"),
    ];
  }
}