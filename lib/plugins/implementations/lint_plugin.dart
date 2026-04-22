import 'package:flutter_pulse/models/pipeline_step_model.dart';
import 'package:flutter_pulse/plugins/pipeline_plugin/pipeline_plugin.dart';

class LintPlugin implements PipelinePlugin {
  @override
  String get id => "lint";

  @override
  String get name => "Analyze Code";

  @override
  List<PipelineStep> buildSteps() {
    return [
      PipelineStep(
        "Analyze",
        "flutter analyze",
      ),
    ];
  }
}