import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pulse/core/pipeline/plugin_registry.dart';
import 'package:flutter_pulse/models/build_history_model.dart';
import 'package:flutter_pulse/models/build_target.dart';
import 'package:flutter_pulse/models/log_entry_model.dart';
import 'package:flutter_pulse/models/pipeline_step_model.dart';
import 'package:flutter_pulse/service/artifact_storage_service.dart';
import 'package:flutter_pulse/service/build_service.dart';
import 'package:flutter_pulse/service/config_service.dart';
import 'package:flutter_pulse/viewModels/history_viewmodel.dart';

class BuildViewModel extends ChangeNotifier {
  final _service = BuildService();

  // historyViewModel reference  injected so we can push records after build
  final HistoryViewModel historyViewModel;

  BuildViewModel({required this.historyViewModel});

  Process? _process;
  DateTime? _buildStartTime;

  // selected build target default is set APK
  BuildTarget _selectedTarget = BuildTarget.apk;
  BuildTarget get selectedTarget => _selectedTarget;

  void setTarget(BuildTarget target) {
    if (_isRunning) return;
    _selectedTarget = target;
    notifyListeners();
  }

  // Base steps clean and get always run
  // Build step is dynamically set from selectedTarget in _buildPipelineSteps()
  final List<PipelineStep> _baseSteps = [
    PipelineStep('Clean', 'flutter clean'),
    PipelineStep('Get', 'flutter pub get'),
  ];

  final List<PipelineStep> _pipelineSteps = [];
  List<PipelineStep> get pipelineSteps => _pipelineSteps;

  int _completedSteps = 0;
  double _progress = 0.0;
  double get progress => _progress;

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  bool? _isSuccess;
  bool? get isSuccess => _isSuccess;

  bool get isFinished => !_isRunning && _isSuccess != null;

  final List<LogEntry> _logs = [];
  List<LogEntry> get logs => _logs;

  final Set<String> _enabledPlugins = {};
  Set<String> get enabledPlugins => _enabledPlugins;

  bool _configLoaded = false;
  bool _isConfigLoading = false;
  bool get isConfigLoading => _isConfigLoading;

  void togglePlugin(String id) {
    if (_enabledPlugins.contains(id)) {
      _enabledPlugins.remove(id);
    } else {
      _enabledPlugins.add(id);
    }
    notifyListeners();
  }

  Future<void> loadConfig() async {
    if (_configLoaded) return;

    _isConfigLoading = true;
    notifyListeners();

    try {
      final config = await ConfigService.loadConfig();
      _enabledPlugins.clear();

      for (final entry in config.entries) {
        final value = entry.value;
        if (value is Map &&
            value['enabled'] == true &&
            PluginRegistry.available.containsKey(entry.key)) {
          _enabledPlugins.add(entry.key);
        }
      }
      _configLoaded = true;
    } catch (_) {
      // config missing or malformed means no plugins enabled by default
    } finally {
      _isConfigLoading = false;
      notifyListeners();
    }
  }

  Future<void> startBuild(String projectPath) async {
    if (_isRunning) return;

    // Validate that the selected build target is supported on this OS
    if (!_selectedTarget.isSupportedOnCurrentPlatform) {
      _logs.add(
        LogEntry(
          'ERROR: Building for "${_selectedTarget.label}" is not supported on ${Platform.operatingSystem}.',
          LogLevel.error,
        ),
      );
      _logs.add(
        LogEntry(
          'Please choose a target that works on this OS (e.g., APK, Web, Linux).',
          LogLevel.warning,
        ),
      );
      notifyListeners(); // show the error logs in UI
      return; // prevent the build from starting
    }

    await loadConfig();
    _resetState();
    _buildStartTime = DateTime.now();

    _pipelineSteps
      ..clear()
      ..addAll(_buildPipelineSteps(projectPath));

    notifyListeners();

    _process = await _service.runSteps(_pipelineSteps, projectPath);
    final process = _process!;

    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          if (line.trim().isEmpty) return;
          _logs.add(LogEntry(line, _detectLogLevel(line)));
          _trackStep(line);
          notifyListeners();
        });

    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          if (line.trim().isEmpty) return;
          _logs.add(LogEntry(line, _detectLogLevel(line)));
          notifyListeners();
        });

    process.exitCode.then((code) async {
      if (_process == null) return;

      _isRunning = false;
      _isSuccess = code == 0;

      _logs.add(
        LogEntry(
          '>>> Build ${_isSuccess! ? 'SUCCESS' : 'FAILED'}',
          _isSuccess! ? LogLevel.success : LogLevel.error,
        ),
      );

      // save to history with artifact storage
      await _saveHistory(projectPath);

      notifyListeners();
    });
  }

  void stopBuild() {
    if (!_isRunning) return;

    _process?.kill();
    _process = null;
    _isRunning = false;
    _isSuccess = false;

    final i = _pipelineSteps.indexWhere(
      (s) => s.state == PipelineStepState.running,
    );
    if (i != -1) _pipelineSteps[i].state = PipelineStepState.failed;

    _logs.add(LogEntry('>>> BUILD STOPPED BY USER', LogLevel.error));
    notifyListeners();
  }

  void resetBuild() {
    _process?.kill();
    _process = null;
    _isRunning = false;
    _isSuccess = null;
    _completedSteps = 0;
    _progress = 0.0;
    _logs.clear();
    _buildStartTime = null;

    _pipelineSteps
      ..clear()
      ..addAll(_baseSteps);

    for (final step in _pipelineSteps) {
      step.state = PipelineStepState.pending;
    }

    notifyListeners();
  }

  // Clean → Get → [Test plugin if enabled] → Build (target) → [other plugins]
  List<PipelineStep> _buildPipelineSteps(String projectPath) {
    final steps = <PipelineStep>[];

    // always start with Clean and Get
    steps.addAll(_baseSteps);

    // collect pre‑build plugin steps they run after Get, before Build
    final preBuildSteps = <PipelineStep>[];
    // collect post‑build plugin steps they run after Build
    final postBuildSteps = <PipelineStep>[];

    // Iterate enabled plugins in the order they appear in PluginRegistry.available
    for (final id in _enabledPlugins) {
      final plugin = PluginRegistry.available[id];
      if (plugin == null) continue;
      if (plugin.isPreBuild) {
        preBuildSteps.addAll(plugin.buildSteps());
      } else {
        postBuildSteps.addAll(plugin.buildSteps());
      }
    }

    // Add pre‑build steps e.g., lint, format, backup
    steps.addAll(preBuildSteps);

    // Then the main build step using selected target
    steps.add(PipelineStep('Build', _selectedTarget.command));

    // finally post‑build steps e.g. notify
    steps.addAll(postBuildSteps);

    return steps;
  }

  Future<void> _saveHistory(String projectPath) async {
    final duration = _buildStartTime != null
        ? DateTime.now().difference(_buildStartTime!)
        : Duration.zero;

    String outputPath = _selectedTarget.outputPath(projectPath);
    String? storedArtifactPath;

    // Only store artifact if build succeeded
    if (_isSuccess == true) {
      try {
        storedArtifactPath = await ArtifactStorageService.storeArtifact(
          projectPath,
          outputPath,
        );
      } catch (e) {
        _logs.add(
          LogEntry('Warning: Could not store artifact: $e', LogLevel.warning),
        );
        // Still save record without stored path
      }
    }

    final record = BuildHistoryRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      projectName: projectPath.split('/').last,
      projectPath: projectPath,
      target: _selectedTarget,
      success: _isSuccess ?? false,
      timestamp: DateTime.now(),
      duration: duration,
      outputPath: outputPath,
      storedArtifactPath: storedArtifactPath,
    );

    await historyViewModel.addRecord(record);
  }

  void _trackStep(String line) {
    final match = RegExp(r'STEP::(.+?)::(\w+)').firstMatch(line);
    if (match == null) return;

    final name = match.group(1)!;
    final status = match.group(2)!;
    final step = _findStep(name);
    if (step == null) return;

    switch (status) {
      case 'start':
        step.state = PipelineStepState.running;
        break;
      case 'done':
        if (step.state != PipelineStepState.done) {
          step.state = PipelineStepState.done;
          _completedSteps++;
          _updateProgress();
        }
        break;
      case 'failed':
        step.state = PipelineStepState.failed;
        _updateProgress();
        break;
    }
  }

  PipelineStep? _findStep(String name) {
    for (final s in _pipelineSteps) {
      if (s.label.toLowerCase() == name.toLowerCase()) return s;
    }
    return null;
  }

  LogLevel _detectLogLevel(String line) {
    final l = line.toUpperCase();
    if (l.contains('STEP::') && l.contains('::FAILED')) return LogLevel.error;
    if (l.contains('BUILD::SUCCESS')) return LogLevel.success;
    if (l.startsWith('ERROR:') ||
        l.contains('EXCEPTION') ||
        l.contains('FATAL')) {
      return LogLevel.error;
    }
    if (l.contains('WARNING:') || l.contains('WARN:')) return LogLevel.warning;
    if (l.contains('SUCCESS') || l.contains('::DONE')) return LogLevel.success;
    return LogLevel.info;
  }

  void _updateProgress() {
    if (_pipelineSteps.isEmpty) {
      _progress = 0;
      return;
    }
    _progress = (_completedSteps / _pipelineSteps.length).clamp(0.0, 1.0);
  }

  void _resetState() {
    _isRunning = true;
    _logs.clear();
    _isSuccess = null;
    _process = null;
    _completedSteps = 0;
    _progress = 0.0;
    for (final step in _pipelineSteps) {
      step.state = PipelineStepState.pending;
    }
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }
}
