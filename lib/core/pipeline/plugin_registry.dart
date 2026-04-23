import 'package:flutter_pulse/plugins/implementations/test_plugin.dart';
import 'package:flutter_pulse/plugins/pipeline_plugin/pipeline_plugin.dart';

class PluginRegistry {
  static final Map<String, PipelinePlugin> available = {"test": TestPlugin()};

  // helper to get all plugins
  static List<PipelinePlugin> get all => available.values.toList();
}
