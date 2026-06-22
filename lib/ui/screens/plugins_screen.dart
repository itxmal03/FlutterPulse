import 'package:flutter/material.dart';
import 'package:flutter_pulse/core/pipeline/plugin_registry.dart';
import 'package:flutter_pulse/plugins/pipeline_plugin/pipeline_plugin.dart';
import 'package:flutter_pulse/viewModels/build_viewmodel.dart';
import 'package:provider/provider.dart';

class PluginsScreen extends StatefulWidget {
  const PluginsScreen({super.key});

  @override
  State<PluginsScreen> createState() => _PluginsScreenState();
}

class _PluginsScreenState extends State<PluginsScreen> {
  @override
  void initState() {
    super.initState();
    // Load config to seed which plugins are enabled — runs only once
    Future.microtask(() async {
      if (!mounted) return;
      await context.read<BuildViewModel>().loadConfig();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BuildViewModel>();

    // read plugin list from PluginRegistry — NOT from config.json
    // config.json only controls the enabled/disabled toggle state
    final plugins = PluginRegistry.all;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D10),
      appBar: AppBar(
        title: const Text('Plugins'),
        backgroundColor: const Color(0xFF12151A),
      ),
      body: _buildBody(vm, plugins),
    );
  }

  Widget _buildBody(BuildViewModel vm, List<PipelinePlugin> plugins) {
    // Show spinner only while config is being loaded
    if (vm.isConfigLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (plugins.isEmpty) {
      return const Center(
        child: Text(
          'No plugins registered.\nAdd plugins to PluginRegistry.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Available Plugins',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        // iterate PluginRegistry.all
        ...plugins.map((plugin) => _pluginTile(vm: vm, plugin: plugin)),
      ],
    );
  }

  Widget _pluginTile({
    required BuildViewModel vm,
    required PipelinePlugin plugin,
  }) {
    final isEnabled = vm.enabledPlugins.contains(plugin.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF151922),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isEnabled
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.extension,
              color: isEnabled ? Colors.green : Colors.grey,
            ),
          ),

          const SizedBox(width: 12),

          // Plugin info — from PipelinePlugin fields (name, description, version, author)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plugin.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  plugin.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  'v${plugin.version} · ${plugin.author}',
                  style: const TextStyle(
                    color: Color(0xFF555E6E),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Toggle — reads from vm.enabledPlugins (live set)
          Switch(
            value: isEnabled,
            onChanged: (_) => vm.togglePlugin(plugin.id),
          ),
        ],
      ),
    );
  }
}
