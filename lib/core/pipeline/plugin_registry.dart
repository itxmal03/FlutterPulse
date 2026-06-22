import 'package:flutter_pulse/plugins/implementations/format_plugin.dart';
import 'package:flutter_pulse/plugins/implementations/lint_plugin.dart';
import 'package:flutter_pulse/plugins/implementations/notify_plugin.dart';
import 'package:flutter_pulse/plugins/implementations/test_plugin.dart';
import 'package:flutter_pulse/plugins/pipeline_plugin/pipeline_plugin.dart';

class PluginRegistry {
  static final Map<String, PipelinePlugin> available = {
    "test": TestPlugin(),
    "lint": LintPlugin(),
    "format": FormatPlugin(),
    "notify": NotifyPlugin(),
  };

  // helper to get all plugins
  static List<PipelinePlugin> get all => available.values.toList();
}