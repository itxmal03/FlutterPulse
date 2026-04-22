import 'package:flutter/material.dart';
import 'package:flutter_pulse/viewModels/build_viewmodel.dart';
import 'package:provider/provider.dart';

class PluginsScreen extends StatefulWidget {
  const PluginsScreen({super.key});

  @override
  State<PluginsScreen> createState() => _PluginsScreenState();
}

class _PluginsScreenState extends State<PluginsScreen> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BuildViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D10),

      // HEADER
      appBar: AppBar(
        title: const Text("Plugins"),
        backgroundColor: const Color(0xFF12151A),
      ),

      // BODY
      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          const Text(
            "Available Plugins",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          // FIX: simple plugin list (you can later make registry-driven UI)
          _pluginTile(
            vm: vm,
            id: "test",
            title: "Test Plugin",
            subtitle: "Runs test steps before build",
          ),

          // add more plugins here later
        ],
      ),
    );
  }

  // SINGLE PLUGIN TILE
  Widget _pluginTile({
    required BuildViewModel vm,
    required String id,
    required String title,
    required String subtitle,
  }) {
    final enabled = vm.enabledPlugins.contains(id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFF151922),
        borderRadius: BorderRadius.circular(10),
      ),

      child: Row(
        children: [
          // ICON
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: enabled
                  ? Colors.green.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.extension,
              color: enabled ? Colors.green : Colors.grey,
            ),
          ),

          const SizedBox(width: 12),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // TOGGLE SWITCH
          Switch(
            value: enabled,

            onChanged: (val) {
              // CORE LOGIC: enable/disable plugin
              vm.togglePlugin(id);
            },
          ),
        ],
      ),
    );
  }
}
