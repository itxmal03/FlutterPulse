import 'package:flutter/material.dart';
import 'package:flutter_pulse/core/constants.dart';
import 'package:flutter_pulse/models/log_entry_model.dart';

class LogLine extends StatelessWidget {
  final LogEntry entry;
  final int lineNumber;

  const LogLine({super.key, required this.entry, required this.lineNumber});

  Color get _textColor {
    switch (entry.level) {
      case LogLevel.success:
        return AppColors.success;
      case LogLevel.error:
        return AppColors.error;
      case LogLevel.warning:
        return AppColors.warning;
      case LogLevel.info:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (entry.message.isEmpty) return const SizedBox(height: 6);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Text(
              lineNumber.toString().padLeft(3),
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11.5,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              entry.message,
              style: TextStyle(
                color: _textColor,
                fontSize: 12.5,
                fontFamily: 'monospace',
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
