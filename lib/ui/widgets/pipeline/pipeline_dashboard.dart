import 'package:flutter/material.dart' hide StepState;
import 'package:flutter_pulse/core/constants.dart';
import 'package:flutter_pulse/models/pipeline_step_model.dart';
import 'package:flutter_pulse/ui/widgets/glow_button.dart';
import 'package:flutter_pulse/ui/widgets/log_line.dart';
import 'package:flutter_pulse/ui/widgets/pipeline/pipeline_step_chip.dart';
import 'package:flutter_pulse/viewModels/build_viewmodel.dart';
import 'package:provider/provider.dart';

class PipelineDashboard extends StatefulWidget {
  const PipelineDashboard({super.key});

  @override
  State<PipelineDashboard> createState() => _PipelineDashboardState();
}

class _PipelineDashboardState extends State<PipelineDashboard> {
  final ScrollController _logScrollController = ScrollController();

  void _scrollToBottom() {
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

  // FIX: safe current step label (no empty list crash)
  String _currentStepLabel(BuildContext context) {
    final vm = context.watch<BuildViewModel>();

    if (!vm.isRunning || vm.pipelineSteps.isEmpty) {
      return 'Idle — ready to build';
    }

    final runningStep = vm.pipelineSteps.firstWhere(
      (s) => s.state == PipelineStepState.running,
      orElse: () => vm.pipelineSteps.first,
    );

    return runningStep.command;
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
                    'my_flutter_app • main branch',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              GlowButton(
                label: 'Run Pipeline',
                icon: Icons.play_arrow_rounded,
                color: AppColors.accent,
                onPressed: vm.isRunning
                    ? null
                    : () => vm.startBuild("your/project/path"),
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

          // FIX: prevent crash when pipeline is empty
          if (vm.pipelineSteps.isEmpty)
            const SizedBox()
          else
            Row(
              children: List.generate(vm.pipelineSteps.length * 2 - 1, (i) {
                // FIX: connector safety check
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

                    Text(
                      _currentStepLabel(context),
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12.5,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

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
                          : (vm.progress >= 1.0
                                ? AppColors.success
                                : AppColors.textMuted),
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

    // FIX: auto scroll safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

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
            child: ListView.builder(
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
