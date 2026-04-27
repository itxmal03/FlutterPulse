import 'package:flutter/material.dart' hide StepState;
import 'package:flutter_pulse/core/constants.dart';
import 'package:flutter_pulse/models/build_target.dart';
import 'package:flutter_pulse/models/pipeline_step_model.dart';
import 'package:flutter_pulse/ui/widgets/glow_button.dart';
import 'package:flutter_pulse/ui/widgets/log_line.dart';
import 'package:flutter_pulse/ui/widgets/pipeline/pipeline_step_chip.dart';
import 'package:flutter_pulse/viewModels/build_viewmodel.dart';
import 'package:flutter_pulse/viewModels/pick_directory_viewmodel.dart';
import 'package:provider/provider.dart';

class PipelineDashboard extends StatefulWidget {
  const PipelineDashboard({super.key});

  @override
  State<PipelineDashboard> createState() => _PipelineDashboardState();
}

class _PipelineDashboardState extends State<PipelineDashboard> {
  final ScrollController _logScrollController = ScrollController();
  int _lastLogCount = 0;

  void _scrollToBottomIfNeeded(int currentCount) {
    if (currentCount <= _lastLogCount) return;
    _lastLogCount = currentCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScrollController.hasClients) {
        _logScrollController.animateTo(
          _logScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _currentStepLabel(BuildViewModel vm) {
    if (!vm.isRunning || vm.pipelineSteps.isEmpty)
      return 'Idle — ready to build';
    final running = vm.pipelineSteps.firstWhere(
      (s) => s.state == PipelineStepState.running,
      orElse: () => vm.pipelineSteps.first,
    );
    return running.command;
  }

  @override
  void dispose() {
    _logScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildControlsSection(),
          _buildProgressSection(),
          Expanded(child: _buildLogsSection()),
        ],
      ),
    );
  }

  Widget _buildControlsSection() {
    final vm = context.watch<BuildViewModel>();
    final dirVm = context.watch<PickDirectoryViewmodel>();
    final projectPath = dirVm.path;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Project name + target selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pipeline Control',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    projectPath != null
                        ? projectPath.split('/').last
                        : 'No project selected',
                    style: TextStyle(
                      color: projectPath != null
                          ? AppColors.textSecondary
                          : AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 24),

              // Build target dropdown
              _TargetDropdown(
                selected: vm.selectedTarget,
                enabled: !vm.isRunning,
                onChanged: vm.setTarget,
              ),

              const Spacer(),

              if (!vm.isFinished)
                GlowButton(
                  label: 'Run Pipeline',
                  icon: Icons.play_arrow_rounded,
                  color: AppColors.accent,
                  onPressed: vm.isRunning || projectPath == null
                      ? null
                      : () => vm.startBuild(projectPath),
                ),

              if (vm.isFinished)
                GlowButton(
                  label: 'Reset',
                  icon: Icons.refresh_rounded,
                  color: AppColors.textSecondary,
                  onPressed: vm.resetBuild,
                ),

              const SizedBox(width: 10),

              GlowButton(
                label: 'Stop',
                icon: Icons.stop_rounded,
                color: AppColors.stopBtn,
                bgColor: AppColors.stopBtnBg,
                onPressed: vm.isRunning ? vm.stopBuild : null,
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (vm.pipelineSteps.isNotEmpty)
            Row(
              children: List.generate(vm.pipelineSteps.length * 2 - 1, (i) {
                if (i.isOdd) {
                  final left = i ~/ 2;
                  final right = left + 1;
                  final done =
                      right < vm.pipelineSteps.length &&
                      (vm.pipelineSteps[left].state == PipelineStepState.done ||
                          vm.pipelineSteps[right].state ==
                              PipelineStepState.done);
                  return _StepConnector(done: done);
                }
                final stepIdx = i ~/ 2;
                return PipelineStepChip(
                  step: vm.pipelineSteps[stepIdx],
                  index: stepIdx,
                );
              }),
            ),

          if (vm.isFinished) ...[
            const SizedBox(height: 14),
            _BuildResultBanner(success: vm.isSuccess == true),
          ],

          if (projectPath == null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 13,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  'Select a project folder from the top bar to run the pipeline.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final vm = context.watch<BuildViewModel>();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.terminal_rounded,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Current Step: ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        _currentStepLabel(vm),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 12.5,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(vm.progress * 100).toInt()}%',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: vm.progress,
                    minHeight: 5,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      vm.isRunning
                          ? AppColors.accent
                          : vm.isSuccess == true
                          ? AppColors.success
                          : vm.isSuccess == false
                          ? Colors.red.withValues(alpha: 0.8)
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsSection() {
    final vm = context.watch<BuildViewModel>();
    _scrollToBottomIfNeeded(vm.logs.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 7),
              Text(
                'Live Console',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${vm.logs.length} lines',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
              ),
              const SizedBox(width: 14),
              InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: vm.clearLogs,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  child: Text('Clear', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFF090B0F),
            padding: const EdgeInsets.all(16),
            child: vm.logs.isEmpty
                ? Center(
                    child: Text(
                      'No logs yet — press Run Pipeline to start.',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _logScrollController,
                    itemCount: vm.logs.length,
                    itemBuilder: (ctx, i) =>
                        LogLine(entry: vm.logs[i], lineNumber: i + 1),
                  ),
          ),
        ),
      ],
    );
  }
}

// ── Build target dropdown ─────────────────────────────────────────────────────

class _TargetDropdown extends StatelessWidget {
  final BuildTarget selected;
  final bool enabled;
  final ValueChanged<BuildTarget> onChanged;

  const _TargetDropdown({
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<BuildTarget>(
            value: selected,
            isDense: true,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              fontFamily: 'monospace',
            ),
            dropdownColor: AppColors.surface,
            icon: Icon(
              Icons.expand_more_rounded,
              size: 16,
              color: AppColors.textMuted,
            ),
            items: BuildTarget.values.map((t) {
              return DropdownMenuItem(
                value: t,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_targetIcon(t), size: 14, color: AppColors.accent),
                    const SizedBox(width: 7),
                    Text(t.label),
                  ],
                ),
              );
            }).toList(),
            onChanged: enabled
                ? (t) {
                    if (t != null) onChanged(t);
                  }
                : null,
          ),
        ),
      ),
    );
  }

  IconData _targetIcon(BuildTarget t) {
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

// ── Result banner ─────────────────────────────────────────────────────────────

class _BuildResultBanner extends StatelessWidget {
  final bool success;
  const _BuildResultBanner({required this.success});

  @override
  Widget build(BuildContext context) {
    final color = success ? AppColors.success : Colors.red;
    final icon = success ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final label = success ? 'Build completed successfully' : 'Build failed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            'Press Reset to run again',
            style: TextStyle(
              color: color.withValues(alpha: 0.6),
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step connector ────────────────────────────────────────────────────────────

class _StepConnector extends StatelessWidget {
  final bool done;
  const _StepConnector({required this.done});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: done
            ? AppColors.success.withValues(alpha: 0.4)
            : AppColors.border,
      ),
    );
  }
}
