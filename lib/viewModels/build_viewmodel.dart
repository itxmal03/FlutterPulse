import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pulse/core/pipeline/plugin_registry.dart';
import 'package:flutter_pulse/models/log_entry_model.dart';
import 'package:flutter_pulse/models/pipeline_step_model.dart';
import 'package:flutter_pulse/service/build_service.dart';
import 'package:flutter_pulse/service/config_service.dart';

class BuildViewModel extends ChangeNotifier {
  final _service = BuildService();

  Process? _process;

  // base steps (always run)
  final List<PipelineStep> _baseSteps = [
    PipelineStep('Clean', 'flutter clean'),
    PipelineStep('Get', 'flutter pub get'),
    PipelineStep('Build', 'flutter build apk'),
  ];

  // final pipeline (base + plugins)
  final List<PipelineStep> _pipelineSteps = [];
  List<PipelineStep> get pipelineSteps => _pipelineSteps;

  // progress
  int _completedSteps = 0;
  double _progress = 0.0;
  double get progress => _progress;

  // run state
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  bool? _isSuccess;
  bool? get isSuccess => _isSuccess;

  // logs
  final List<LogEntry> _logs = [];
  List<LogEntry> get logs => _logs;

  // plugins
  final Set<String> _enabledPlugins = {};
  Set<String> get enabledPlugins => _enabledPlugins;

  // load config once (safe cache)
  bool _configLoaded = false;
  Map<String, dynamic> _config = {};
  Map<String, dynamic> get config => _config;

  BuildViewModel() {
    // base pipeline init
    _pipelineSteps.addAll(_baseSteps);
  }

  void togglePlugin(String id) {
    if (_enabledPlugins.contains(id)) {
      _enabledPlugins.remove(id);
    } else {
      _enabledPlugins.add(id);
    }
    notifyListeners();
  }

  // load config (ONLY ONCE)
  Future<void> loadConfig() async {
    if (_configLoaded) return;

    _config = await ConfigService.loadConfig();

    _enabledPlugins.clear();

    for (final entry in _config.entries) {
      if (entry.value == true) {
        _enabledPlugins.add(entry.key);
      }
    }

    _configLoaded = true;
    notifyListeners();
  }

  // start build
  Future<void> startBuild(String projectPath) async {
    if (_isRunning) return;

    await loadConfig(); // 🔥 FIX: ensure plugins loaded

    _resetState();

    _pipelineSteps
      ..clear()
      ..addAll(_buildPipelineSteps());

    notifyListeners();

    _process = await _service.runSteps(_pipelineSteps, projectPath);
    final process = _process!;

    process.stdout.transform(utf8.decoder).listen(_handleLog);

    process.stderr.transform(utf8.decoder).listen((data) {
      _addLog(data, LogLevel.error);
      _failCurrentStep();
      notifyListeners();
    });

    process.exitCode.then((code) {
      if (_process == null) return;

      _isRunning = false;
      _isSuccess = code == 0;

      _addLog(
        ">>> Build ${_isSuccess! ? "SUCCESS" : "FAILED"}",
        _isSuccess! ? LogLevel.success : LogLevel.error,
      );

      notifyListeners();
    });
  }

  // stop build
  void stopBuild() {
    if (!_isRunning) return;

    _process?.kill();
    _process = null;

    _isRunning = false;

    final i = _pipelineSteps.indexWhere(
      (s) => s.state == PipelineStepState.running,
    );

    if (i != -1) {
      _pipelineSteps[i].state = PipelineStepState.failed;
    }

    _addLog(">>> BUILD STOPPED BY USER", LogLevel.error);

    notifyListeners();
  }

  // pipeline builder
  List<PipelineStep> _buildPipelineSteps() {
    final steps = [..._baseSteps];

    for (final id in _enabledPlugins) {
      final plugin = PluginRegistry.available[id];
      if (plugin != null) {
        steps.addAll(plugin.buildSteps());
      }
    }

    return steps;
  }

  // log handler
  void _handleLog(String raw) {
    final lines = raw.split('\n');

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      _logs.add(LogEntry(line, _detectLogLevel(line)));

      _trackStep(line);
    }

    notifyListeners();
  }

  // STEP TRACKER (SAFE + PLUGIN FRIENDLY)
  void _trackStep(String line) {
    final match = RegExp(r'STEP::(\w+)::(\w+)').firstMatch(line);
    if (match == null) return;

    final name = match.group(1)!;
    final status = match.group(2)!;

    final step = _findStep(name);
    if (step == null) return;

    if (status == "start") {
      step.state = PipelineStepState.running;
    }

    if (status == "done") {
      if (step.state != PipelineStepState.done) {
        step.state = PipelineStepState.done;
        _completedSteps++;
        _updateProgress();
      }
    }
  }

  // SAFE FINDER (FIXED CRASH ISSUE)
  PipelineStep? _findStep(String name) {
    for (final s in _pipelineSteps) {
      if (s.label.toLowerCase() == name.toLowerCase()) {
        return s;
      }
    }
    return null;
  }

  void _addLog(String raw, LogLevel level) {
    for (final line in raw.split('\n')) {
      if (line.trim().isEmpty) continue;
      _logs.add(LogEntry(line, level));
    }
  }

  LogLevel _detectLogLevel(String line) {
    if (line.contains("ERROR")) return LogLevel.error;
    if (line.contains("SUCCESS")) return LogLevel.success;
    if (line.contains("WARNING")) return LogLevel.warning;
    return LogLevel.info;
  }

  void _failCurrentStep() {
    final i = _pipelineSteps.indexWhere(
      (s) => s.state == PipelineStepState.running,
    );

    if (i == -1) return;

    _pipelineSteps[i].state = PipelineStepState.failed;
    _updateProgress();
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
