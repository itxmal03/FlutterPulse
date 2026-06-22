import 'dart:io';
import 'package:flutter_pulse/models/pipeline_step_model.dart';
import 'package:flutter_pulse/plugins/pipeline_plugin/pipeline_plugin.dart';

class NotifyPlugin extends PipelinePlugin {
  @override
  String get id => "notify";

  @override
  String get name => "Notification";

  @override
  String get description => "Send a desktop notification when the build finishes";

  @override
  String get version => "1.0.0";

  @override
  String get author => "FlutterPulse";

  @override
  bool get isPreBuild => false; // post‑build

  @override
  List<PipelineStep> buildSteps() {
    String notifyCmd;
    if (Platform.isLinux) {
      notifyCmd = 'notify-send "FlutterPulse" "Build completed"';
    } else if (Platform.isMacOS) {
      notifyCmd =
          'osascript -e \'display notification "Build completed" with title "FlutterPulse"\'';
    } else if (Platform.isWindows) {
      // Simple fallback: just echo a message, since msg command requires user interaction
      notifyCmd = 'echo "Build completed (notification not supported on Windows)"';
    } else {
      notifyCmd = 'echo "Build completed"';
    }
    return [
      PipelineStep("Notify", notifyCmd),
    ];
  }
}