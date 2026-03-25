import 'package:flutter/material.dart' hide StepState;
import 'package:flutter_pulse/core/constants.dart';
import 'package:flutter_pulse/ui/screens/build_history_screen.dart';
import 'package:flutter_pulse/ui/screens/plugins_screen.dart';
import 'package:flutter_pulse/ui/screens/settings_screen.dart';
import 'package:flutter_pulse/ui/widgets/pipeline/pipeline_dashboard.dart';
import 'package:flutter_pulse/ui/widgets/sidebar.dart';
import 'package:flutter_pulse/ui/widgets/topbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNav = 0;
  final List<NavItem> _navItems = const [
    NavItem(Icons.folder_open_rounded, 'Projects'),
    NavItem(Icons.history_rounded, 'Build History'),
    NavItem(Icons.extension_rounded, 'Plugins'),
    NavItem(Icons.settings_rounded, 'Settings'),
  ];

  final List<Widget> _screens = const [
    PipelineDashboard(),
    BuildHistoryScreen(),
    PluginsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Row(
        children: [
          Sidebar(
            navItems: _navItems,
            selected: _selectedNav,
            onSelect: (i) => setState(() => _selectedNav = i),
          ),
          VerticalDivider(width: 1, color: AppColors.border),
          Expanded(
            child: Column(
              children: [
                const TopBar(),
                 Divider(height: 1, color: AppColors.border),
                Expanded(child: _screens[_selectedNav]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class _PlaceholderPanel extends StatelessWidget {
//   final String label;
//   const _PlaceholderPanel({required this.label});
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.construction_rounded,
//             size: 48,
//             color: AppColors.textMuted,
//           ),
//           const SizedBox(height: 12),
//           Text(
//             '$label panel coming soon',
//             style: const TextStyle(
//               color: AppColors.textSecondary,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
