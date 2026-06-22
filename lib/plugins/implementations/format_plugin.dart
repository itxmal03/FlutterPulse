import 'package:flutter_pulse/models/pipeline_step_model.dart';
import 'package:flutter_pulse/plugins/pipeline_plugin/pipeline_plugin.dart';

class FormatPlugin extends PipelinePlugin {
  @override
  String get id => "format";

  @override
  String get name => "Format";

  @override
  String get description => "Format Dart code using dart format";

  @override
  String get version => "1.0.0";

  @override
  String get author => "FlutterPulse";

  @override
  bool get isPreBuild => true;

  @override
  List<PipelineStep> buildSteps() {
    return [
      PipelineStep("Format", "dart format ."),
    ];
  }
}