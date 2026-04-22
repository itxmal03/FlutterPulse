import 'package:flutter_pulse/plugins/implementations/lint_plugin.dart';
import 'package:flutter_pulse/plugins/implementations/test_plugin.dart';
import 'package:flutter_pulse/plugins/pipeline_plugin/pipeline_plugin.dart';

class PluginRegistry {
  static final Map<String, PipelinePlugin> available = {
    "test": TestPlugin(),
    "lint": LintPlugin(),
  };
}
