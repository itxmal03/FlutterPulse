import 'package:flutter/material.dart';
import 'package:flutter_pulse/core/constants.dart';
import 'package:flutter_pulse/viewModels/theme_viewmodel.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ListTile(
            title: Text(
              "Theme",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            subtitle: Text(
              "Dark",
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            leading: Icon(Icons.dark_mode, color: AppColors.textSecondary),
            trailing: Switch.adaptive(
              value: context.watch<ThemeViewmodel>().isDark,
              onChanged: (value) {
                context.read<ThemeViewmodel>().updateTheme(val: value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
