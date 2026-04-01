import 'package:flutter/material.dart';
import 'package:flutter_pulse/core/constants.dart';
import 'package:flutter_pulse/viewModels/pick_directory_viewmodel.dart';
import 'package:flutter_pulse/viewModels/sdk_info_viewmodel.dart';
import 'package:provider/provider.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<SdkInfoViewmodel>().getSdkInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sdk = context.watch<SdkInfoViewmodel>();

    return Container(
      height: 52,
      color: AppColors.sidebar,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Consumer<PickDirectoryViewmodel>(
        builder: (ctx, val, child) {
          if (val.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: ctx,
                builder: (context) => AlertDialog(
                  title: const Text("Error"),
                  content: Text(val.error!),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        val.clearError();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            });
          }

          return Row(
            children: [
              if (val.isLoading)
                const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                InkWell(
                  onTap: val.isLoading
                      ? null
                      : () async {
                          await val.pickDirectory();
                        },
                  child: Row(
                    children: [
                      val.path == null
                          ? Icon(
                              Icons.add,
                              color: AppColors.textMuted,
                              size: 22,
                            )
                          : Icon(
                              Icons.folder_rounded,
                              color: AppColors.textSecondary,
                              size: 22,
                            ),
                      const SizedBox(width: 6),
                      Text(
                        val.path ?? 'Add Project',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              sdk.isLoading
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : _StatusChip(
                      label: sdk.error != null
                          ? "Error"
                          : sdk.info.length > 1
                          ? "Dart ${sdk.info[1]}"
                          : "Loading...",
                      icon: Icons.code_rounded,
                    ),

              const SizedBox(width: 8),

              sdk.isLoading
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : _StatusChip(
                      label: sdk.error != null
                          ? "Error"
                          : sdk.info.isNotEmpty
                          ? "Flutter ${sdk.info[0]}"
                          : "Loading...",
                      icon: Icons.flutter_dash_rounded,
                      color: AppColors.accentSecondary,
                    ),

              const SizedBox(width: 8),

              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: sdk.error != null ? Colors.red : AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 6),

              Text(
                sdk.error != null ? 'SDK Error' : 'SDK OK',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;

  const _StatusChip({required this.label, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: chipColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: chipColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: chipColor,
              fontSize: 11.5,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
