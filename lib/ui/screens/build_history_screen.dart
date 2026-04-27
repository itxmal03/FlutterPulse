import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pulse/core/constants.dart';
import 'package:flutter_pulse/models/build_history_model.dart';
import 'package:flutter_pulse/models/build_target.dart';
import 'package:flutter_pulse/viewModels/history_viewmodel.dart';
import 'package:provider/provider.dart';

class BuildHistoryScreen extends StatefulWidget {
  const BuildHistoryScreen({super.key});

  @override
  State<BuildHistoryScreen> createState() => _BuildHistoryScreenState();
}

class _BuildHistoryScreenState extends State<BuildHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<HistoryViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewModel>();

    return Container(
      color: AppColors.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(vm),
          Expanded(child: _buildBody(vm)),
        ],
      ),
    );
  }

  Widget _buildHeader(HistoryViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Build History',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${vm.records.length} builds recorded',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          if (vm.records.isNotEmpty)
            TextButton.icon(
              onPressed: () => _confirmClearAll(context, vm),
              icon: Icon(
                Icons.delete_sweep_rounded,
                size: 15,
                color: AppColors.textMuted,
              ),
              label: Text(
                'Clear all',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(HistoryViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.records.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'No builds yet',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Run your first pipeline to see history here.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: vm.records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) => _HistoryTile(
        record: vm.records[i],
        onDelete: () => vm.deleteRecord(vm.records[i].id),
      ),
    );
  }

  Future<void> _confirmClearAll(
    BuildContext context,
    HistoryViewModel vm,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Clear all history?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'This will permanently delete all build records.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear all', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) vm.clearAll();
  }
}

// ── Single history tile ───────────────────────────────────────────────────────

class _HistoryTile extends StatelessWidget {
  final BuildHistoryRecord record;
  final VoidCallback onDelete;

  const _HistoryTile({required this.record, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = record.success ? AppColors.success : Colors.red;
    final icon = record.success
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status icon
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),

          // Main info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project + target
                Row(
                  children: [
                    Text(
                      record.projectName,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _TargetChip(target: record.target),
                  ],
                ),
                const SizedBox(height: 4),

                // Timestamp + duration
                Text(
                  '${_formatDate(record.timestamp)}  ·  ${_formatDuration(record.duration)}',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
                ),
                const SizedBox(height: 6),

                // Output path
                GestureDetector(
                  onTap: () => _openFolder(record.outputPath),
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        size: 12,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          record.outputPath,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 11,
                            fontFamily: 'monospace',
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Delete button
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.close_rounded,
              size: 15,
              color: AppColors.textMuted,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            tooltip: 'Remove from history',
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds < 60) return '${d.inSeconds}s';
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m}m ${s}s';
  }

  void _openFolder(String path) {
    // Open the folder in the system file manager
    final dir = Directory(path);
    final target = dir.existsSync() ? path : File(path).parent.path;
    Process.run('xdg-open', [target]);
  }
}

// ── Target chip ───────────────────────────────────────────────────────────────

class _TargetChip extends StatelessWidget {
  final BuildTarget target;
  const _TargetChip({required this.target});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(target), size: 11, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(
            target.label,
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 10.5,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon(BuildTarget t) {
    switch (t) {
      case BuildTarget.apk:
        return Icons.android_rounded;
      case BuildTarget.linux:
        return Icons.computer_rounded;
      case BuildTarget.web:
        return Icons.language_rounded;
      case BuildTarget.windows:
        return Icons.window_rounded;
      case BuildTarget.deb:
        return Icons.archive_rounded;
    }
  }
}
