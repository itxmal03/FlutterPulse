import 'dart:async';
import 'package:flutter/material.dart' hide StepState;
import 'package:flutter_pulse/core/constants.dart';
import 'package:flutter_pulse/models/log_entry_model.dart';
import 'package:flutter_pulse/models/pipeline_step_model.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Row(
        children: [
          Sidebar(
            items: _navItems,
            selected: _selectedNav,
            onSelect: (i) => setState(() => _selectedNav = i),
          ),
          const VerticalDivider(width: 1, color: AppColors.border),
          Expanded(
            child: Column(
              children: [
                const TopBar(),
                const Divider(height: 1, color: AppColors.border),
                Expanded(
                  child: _selectedNav == 0
                      ? const PipelineDashboard()
                      : _PlaceholderPanel(label: _navItems[_selectedNav].label),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



// ─── Placeholder Panel ────────────────────────────────────────────────────────

class _PlaceholderPanel extends StatelessWidget {
  final String label;
  const _PlaceholderPanel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.construction_rounded,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            '$label panel coming soon',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}



// ─── Pipeline Dashboard ───────────────────────────────────────────────────────

class PipelineDashboard extends StatefulWidget {
  const PipelineDashboard({super.key});

  @override
  State<PipelineDashboard> createState() => _PipelineDashboardState();
}

class _PipelineDashboardState extends State<PipelineDashboard> {
  bool _isRunning = false;
  int _currentStep = -1;
  double _progress = 0.0;
  Timer? _timer;
  final ScrollController _logScrollController = ScrollController();

  final List<PipelineStep> _steps = [
    PipelineStep('Clean', 'flutter clean'),
    PipelineStep('Get', 'flutter pub get'),
    PipelineStep('Analyze', 'flutter analyze'),
    PipelineStep('Test', 'flutter test'),
    PipelineStep('Build', 'flutter build apk'),
  ];

  final List<LogEntry> _logs = [
    LogEntry('[INFO]    FlutterPulse CI — Build initiated', LogLevel.info),
    LogEntry(
      '[INFO]    Working directory: /Users/dev/projects/my_flutter_app',
      LogLevel.info,
    ),
  ];

  static final List<List<LogEntry>> _stepLogs = [
    [
      LogEntry('[INFO]    Running flutter clean...', LogLevel.info),
      LogEntry('[SUCCESS] Deleted build/', LogLevel.success),
      LogEntry('[SUCCESS] Deleted .dart_tool/', LogLevel.success),
      LogEntry('[SUCCESS] flutter clean — completed in 0.8s', LogLevel.success),
    ],
    [
      LogEntry('[INFO]    Running flutter pub get...', LogLevel.info),
      LogEntry('[INFO]    Resolving dependencies...', LogLevel.info),
      LogEntry(
        '[WARNING] Package "http" has a newer version (1.2.1)',
        LogLevel.warning,
      ),
      LogEntry('[SUCCESS] Got 47 packages in 2.3s', LogLevel.success),
    ],
    [
      LogEntry('[INFO]    Running flutter analyze...', LogLevel.info),
      LogEntry('[INFO]    Analyzing 134 Dart files...', LogLevel.info),
      LogEntry(
        '[WARNING] lib/ui/widgets/card.dart:42 — prefer_const_constructors',
        LogLevel.warning,
      ),
      LogEntry('[SUCCESS] No critical issues found', LogLevel.success),
    ],
    [
      LogEntry('[INFO]    Running flutter test...', LogLevel.info),
      LogEntry('[INFO]    Loading test suite (18 tests)...', LogLevel.info),
      LogEntry('[SUCCESS] ✓ widget_test.dart — 18/18 passed', LogLevel.success),
      LogEntry('[SUCCESS] All tests passed in 4.1s', LogLevel.success),
    ],
    [
      LogEntry(
        '[INFO]    Running flutter build apk --release...',
        LogLevel.info,
      ),
      LogEntry('[INFO]    Compiling Dart to native ARM64...', LogLevel.info),
      LogEntry(
        '[INFO]    Running Gradle task assembleRelease...',
        LogLevel.info,
      ),
      LogEntry(
        '[SUCCESS] ✓ Built build/app/outputs/flutter-apk/app-release.apk (18.2 MB)',
        LogLevel.success,
      ),
    ],
  ];

  void _runPipeline() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
      _currentStep = 0;
      _progress = 0.0;
      for (var s in _steps) {
        s.state = StepState.pending;
      }
      _logs.add(LogEntry('', LogLevel.info));
      _logs.add(
        LogEntry(
          '[INFO]    ─── Pipeline started ───────────────────',
          LogLevel.info,
        ),
      );
    });
    _runStep(0);
  }

  void _runStep(int index) {
    if (index >= _steps.length) {
      setState(() {
        _isRunning = false;
        _currentStep = -1;
        _progress = 1.0;
        _logs.add(LogEntry('', LogLevel.info));
        _logs.add(
          LogEntry(
            '[SUCCESS] ─── Pipeline completed successfully ───',
            LogLevel.success,
          ),
        );
      });
      return;
    }

    setState(() {
      _currentStep = index;
      _steps[index].state = StepState.running;
    });

    int logIdx = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 520), (t) {
      if (!_isRunning) {
        t.cancel();
        return;
      }
      final stepLogs = _stepLogs[index];
      if (logIdx < stepLogs.length) {
        setState(() {
          _logs.add(stepLogs[logIdx]);
          _progress = (index + (logIdx + 1) / stepLogs.length) / _steps.length;
        });
        _scrollToBottom();
        logIdx++;
      } else {
        t.cancel();
        setState(() => _steps[index].state = StepState.done);
        _timer = Timer(
          const Duration(milliseconds: 300),
          () => _runStep(index + 1),
        );
      }
    });
  }

  void _stopPipeline() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      if (_currentStep >= 0 && _currentStep < _steps.length) {
        _steps[_currentStep].state = StepState.failed;
      }
      _logs.add(LogEntry('', LogLevel.info));
      _logs.add(
        LogEntry(
          '[ERROR]   ─── Pipeline stopped by user ──────────',
          LogLevel.error,
        ),
      );
      _currentStep = -1;
    });
  }

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

  String get _currentStepLabel {
    if (!_isRunning || _currentStep < 0) return 'Idle — ready to build';
    return _steps[_currentStep].command;
  }

  @override
  void dispose() {
    _timer?.cancel();
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
          // ── Controls ──
          _buildControlsSection(),
          // ── Progress ──
          _buildProgressSection(),
          // ── Logs ──
          Expanded(child: _buildLogsSection()),
        ],
      ),
    );
  }

  // ── Controls Section ────────────────────────────────────────────────────────

  Widget _buildControlsSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Section title
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pipeline Control',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'my_flutter_app  •  main branch',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Run button
              _GlowButton(
                label: 'Run Pipeline',
                icon: Icons.play_arrow_rounded,
                color: AppColors.accent,
                onPressed: _isRunning ? null : _runPipeline,
              ),
              const SizedBox(width: 10),
              // Stop button
              _GlowButton(
                label: 'Stop',
                icon: Icons.stop_rounded,
                color: AppColors.stopBtn,
                bgColor: AppColors.stopBtnBg,
                onPressed: _isRunning ? _stopPipeline : null,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Pipeline steps
          Row(
            children: List.generate(_steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                return _StepConnector(
                  done:
                      _steps[i ~/ 2].state == StepState.done ||
                      _steps[(i ~/ 2) + 1].state == StepState.done,
                );
              }
              final stepIdx = i ~/ 2;
              return _PipelineStepChip(step: _steps[stepIdx], index: stepIdx);
            }),
          ),
        ],
      ),
    );
  }

  // ── Progress Section ─────────────────────────────────────────────────────────

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
      decoration: const BoxDecoration(
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
                    const Icon(
                      Icons.terminal_rounded,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Current Step: ',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                    Text(
                      _currentStepLabel,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12.5,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: const TextStyle(
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
                    value: _progress,
                    minHeight: 5,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isRunning
                          ? AppColors.accent
                          : (_progress >= 1.0
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

  // ── Logs Section ─────────────────────────────────────────────────────────────

  Widget _buildLogsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.receipt_long_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 7),
              const Text(
                'Live Console',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              if (_isRunning)
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              const Spacer(),
              Text(
                '${_logs.length} lines',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11.5,
                ),
              ),
              const SizedBox(width: 14),
              InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => setState(() => _logs.clear()),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
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
              itemCount: _logs.length,
              itemBuilder: (ctx, i) =>
                  _LogLine(entry: _logs[i], lineNumber: i + 1),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Pipeline Step Chip ────────────────────────────────────────────────────────

class _PipelineStepChip extends StatelessWidget {
  final PipelineStep step;
  final int index;

  const _PipelineStepChip({required this.step, required this.index});

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
                valueColor: const AlwaysStoppedAnimation(AppColors.accent),
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

class _StepConnector extends StatelessWidget {
  final bool done;
  const _StepConnector({required this.done});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: done ? AppColors.success.withOpacity(0.4) : AppColors.border,
      ),
    );
  }
}

// ─── Glow Button ─────────────────────────────────────────────────────────────

class _GlowButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color? bgColor;
  final VoidCallback? onPressed;

  const _GlowButton({
    required this.label,
    required this.icon,
    required this.color,
    this.bgColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDisabled ? 0.4 : 1.0,
      child: Material(
        color: bgColor ?? color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              border: Border.all(color: color.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(8),
              boxShadow: isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Log Line ─────────────────────────────────────────────────────────────────

class _LogLine extends StatelessWidget {
  final LogEntry entry;
  final int lineNumber;

  const _LogLine({required this.entry, required this.lineNumber});

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
