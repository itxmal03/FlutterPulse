import 'package:flutter/material.dart' hide StepState;
import 'package:flutter_pulse/core/constants.dart';
import 'package:flutter_pulse/models/pipeline_step_model.dart';

class PipelineStepChip extends StatelessWidget {
  final PipelineStep step;
  final int index;

  const PipelineStepChip({super.key, required this.step, required this.index});

  @override
  Widget build(BuildContext context) {
    Color bg, border, textColor;
    IconData? icon;

    switch (step.state) {
      case StepState.running:
        bg = AppColors.accentGlow;
        border = AppColors.accent;
        textColor = AppColors.accent;
        icon = null;
        break;
      case StepState.done:
        bg = AppColors.success.withOpacity(0.12);
        border = AppColors.success.withOpacity(0.4);
        textColor = AppColors.success;
        icon = Icons.check_rounded;
        break;
      case StepState.failed:
        bg = AppColors.error.withOpacity(0.12);
        border = AppColors.error.withOpacity(0.4);
        textColor = AppColors.error;
        icon = Icons.close_rounded;
        break;
      default:
        bg = Colors.transparent;
        border = AppColors.border;
        textColor = AppColors.textSecondary;
        icon = null;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (step.state == StepState.running) ...[
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.8,
                valueColor:  AlwaysStoppedAnimation(AppColors.accent),
              ),
            ),
            const SizedBox(width: 7),
          ] else if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 5),
          ],
          Text(
            step.label,
            style: TextStyle(
              color: textColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
