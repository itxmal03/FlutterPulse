import 'package:flutter_pulse/models/pipeline_step_model.dart';
import 'package:flutter_pulse/plugins/pipeline_plugin/pipeline_plugin.dart';

class LintPlugin extends PipelinePlugin {
  @override
  String get id => "lint";

  @override
  String get name => "Lint";

  @override
  String get description => "Run flutter analyze (warnings do not fail the build)";

  @override
  String get version => "1.0.0";

  @override
  String get author => "FlutterPulse";

  @override
  bool get isPreBuild => true;

  @override
  List<PipelineStep> buildSteps() {
    // '|| true' makes the step always succeed (exit code 0)
    return [
      PipelineStep("Analyze", "flutter analyze || true"),
    ];
  }
}