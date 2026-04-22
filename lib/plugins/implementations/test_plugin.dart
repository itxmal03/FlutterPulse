import 'package:flutter_pulse/models/pipeline_step_model.dart';
import 'package:flutter_pulse/plugins/pipeline_plugin/pipeline_plugin.dart';

class TestPlugin implements PipelinePlugin { 
  @override
  String get id => "test";

  @override
  String get name => "Run Tests";

  @override
  List<PipelineStep> buildSteps() {
    return [
      PipelineStep(
        "Test",
        "flutter test",
      ),
    ];
  }
}