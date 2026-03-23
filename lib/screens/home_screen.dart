
import 'dart:async';

import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0D0F14);
  static const sidebar = Color(0xFF111318);
  static const surface = Color(0xFF161A23);
  static const surfaceElevated = Color(0xFF1C2130);
  static const border = Color(0xFF252B3B);
  static const accent = Color(0xFF4D9EFF);
  static const accentGlow = Color(0x334D9EFF);
  static const accentSecondary = Color(0xFF7C6EFF);
  static const textPrimary = Color(0xFFE2E8F4);
  static const textSecondary = Color(0xFF6B7A99);
  static const textMuted = Color(0xFF3D4A61);
  static const success = Color(0xFF2ECC71);
  static const error = Color(0xFFFF4E4E);
  static const warning = Color(0xFFFFB347);
  static const info = Color(0xFFB0BED4);
  static const stepActive = Color(0xFF4D9EFF);
  static const stepDone = Color(0xFF2ECC71);
  static const stepPending = Color(0xFF252B3B);
  static const stopBtn = Color(0xFFFF4E4E);
  static const stopBtnBg = Color(0x22FF4E4E);
}

// ─── Data Models ──────────────────────────────────────────────────────────────

enum LogLevel { info, success, error, warning }

class LogEntry {
  final String message;
  final LogLevel level;
  LogEntry(this.message, this.level);
}

enum StepState { pending, running, done, failed }

class PipelineStep {
  final String label;
  final String command;
  StepState state;
  PipelineStep(this.label, this.command, {this.state = StepState.pending});
}

// ─── Root App ─────────────────────────────────────────────────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterPulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.surface,
          background: AppColors.bg,
        ),
        useMaterial3: true,
        fontFamily: 'monospace',
        scaffoldBackgroundColor: AppColors.bg,
      ),
      home: const AppShell(),
    );
  }
}

// ─── App Shell ────────────────────────────────────────────────────────────────

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedNav = 0;
  final List<_NavItem> _navItems = const [
    _NavItem(Icons.folder_open_rounded, 'Projects'),
    _NavItem(Icons.history_rounded, 'Build History'),
    _NavItem(Icons.extension_rounded, 'Plugins'),
    _NavItem(Icons.settings_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Row(
        children: [
          _Sidebar(
            items: _navItems,
            selected: _selectedNav,
            onSelect: (i) => setState(() => _selectedNav = i),
          ),
          const VerticalDivider(width: 1, color: AppColors.border),
          Expanded(
            child: Column(
              children: [
                const _TopBar(),
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

// ─── Sidebar ──────────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

class _Sidebar extends StatelessWidget {
  final List<_NavItem> items;
  final int selected;
  final ValueChanged<int> onSelect;

  const _Sidebar({
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppColors.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo area
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentSecondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'FlutterPulse',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'NAVIGATION',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 6),

          ...List.generate(items.length, (i) {
            final isSelected = i == selected;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => onSelect(i),
                  hoverColor: AppColors.border.withOpacity(0.5),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accentGlow : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: AppColors.accent.withOpacity(0.2), width: 1)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          items[i].icon,
                          size: 17,
                          color: isSelected ? AppColors.accent : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            color: isSelected ? AppColors.accent : AppColors.textSecondary,
                            fontSize: 13.5,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        if (i == 0) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '3',
                              style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          const Spacer(),
          const Divider(color: AppColors.border, height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.accentSecondary.withOpacity(0.3),
                  child: const Text('D', style: TextStyle(color: AppColors.accentSecondary, fontSize: 13, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('dev@flutter.io', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500)),
                    Text('Pro Plan', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

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
              const Icon(Icons.folder_rounded, color: AppColors.textMuted, size: 14),
              const SizedBox(width: 6),
              Text(
                '/Users/dev/projects/my_flutter_app',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5, fontFamily: 'monospace'),
              ),
            ],
          ),
          const Spacer(),
          _StatusChip(label: 'dart 3.3.0', icon: Icons.code_rounded),
          const SizedBox(width: 8),
          _StatusChip(label: 'flutter 3.19.0', icon: Icons.flutter_dash_rounded, color: AppColors.accentSecondary),
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text('SDK OK', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatusChip({required this.label, required this.icon, this.color = AppColors.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontSize: 11.5, fontFamily: 'monospace', fontWeight: FontWeight.w500)),
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
          Icon(Icons.construction_rounded, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('$label panel coming soon', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
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
    LogEntry('[INFO]    Working directory: /Users/dev/projects/my_flutter_app', LogLevel.info),
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
      LogEntry('[WARNING] Package "http" has a newer version (1.2.1)', LogLevel.warning),
      LogEntry('[SUCCESS] Got 47 packages in 2.3s', LogLevel.success),
    ],
    [
      LogEntry('[INFO]    Running flutter analyze...', LogLevel.info),
      LogEntry('[INFO]    Analyzing 134 Dart files...', LogLevel.info),
      LogEntry('[WARNING] lib/ui/widgets/card.dart:42 — prefer_const_constructors', LogLevel.warning),
      LogEntry('[SUCCESS] No critical issues found', LogLevel.success),
    ],
    [
      LogEntry('[INFO]    Running flutter test...', LogLevel.info),
      LogEntry('[INFO]    Loading test suite (18 tests)...', LogLevel.info),
      LogEntry('[SUCCESS] ✓ widget_test.dart — 18/18 passed', LogLevel.success),
      LogEntry('[SUCCESS] All tests passed in 4.1s', LogLevel.success),
    ],
    [
      LogEntry('[INFO]    Running flutter build apk --release...', LogLevel.info),
      LogEntry('[INFO]    Compiling Dart to native ARM64...', LogLevel.info),
      LogEntry('[INFO]    Running Gradle task assembleRelease...', LogLevel.info),
      LogEntry('[SUCCESS] ✓ Built build/app/outputs/flutter-apk/app-release.apk (18.2 MB)', LogLevel.success),
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
      _logs.add(LogEntry('[INFO]    ─── Pipeline started ───────────────────', LogLevel.info));
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
        _logs.add(LogEntry('[SUCCESS] ─── Pipeline completed successfully ───', LogLevel.success));
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
        _timer = Timer(const Duration(milliseconds: 300), () => _runStep(index + 1));
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
      _logs.add(LogEntry('[ERROR]   ─── Pipeline stopped by user ──────────', LogLevel.error));
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
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.2),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'my_flutter_app  •  main branch',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
                return _StepConnector(done: _steps[i ~/ 2].state == StepState.done || _steps[(i ~/ 2) + 1].state == StepState.done);
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
                    const Icon(Icons.terminal_rounded, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'Current Step: ',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
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
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'monospace'),
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
                      _isRunning ? AppColors.accent : (_progress >= 1.0 ? AppColors.success : AppColors.textMuted),
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
              const Icon(Icons.receipt_long_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 7),
              const Text('Live Console', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(width: 10),
              if (_isRunning)
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    const Text('LIVE', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                  ],
                ),
              const Spacer(),
              Text('${_logs.length} lines', style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
              const SizedBox(width: 14),
              InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => setState(() => _logs.clear()),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  child: Text('Clear', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
              itemBuilder: (ctx, i) => _LogLine(entry: _logs[i], lineNumber: i + 1),
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
            style: TextStyle(color: textColor, fontSize: 12.5, fontWeight: FontWeight.w600),
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
                  : [BoxShadow(color: color.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 3))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
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