import 'package:flutter/material.dart';
import 'package:flutter_pulse/core/constants.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: AppColors.sidebar,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Row(
            children: [
              Icon(Icons.folder_rounded, color: AppColors.textMuted, size: 14),
              const SizedBox(width: 6),
              Text(
                '/Users/dev/projects/my_flutter_app',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const Spacer(),
          _StatusChip(label: 'dart 3.3.0', icon: Icons.code_rounded),
          const SizedBox(width: 8),
          _StatusChip(
            label: 'flutter 3.19.0',
            icon: Icons.flutter_dash_rounded,
            color: AppColors.accentSecondary,
          ),
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'SDK OK',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
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
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
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
