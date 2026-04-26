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

  final List<PipelineStep> _baseSteps = [
    PipelineStep('Clean', 'flutter clean'),
    PipelineStep('Get', 'flutter pub get'),
    PipelineStep('Build', 'flutter build apk'),
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

  // True when build has finished (success or failure) — drives Reset button visibility
  bool get isFinished => !_isRunning && _isSuccess != null;

  final List<LogEntry> _logs = [];
  List<LogEntry> get logs => _logs;

  final Set<String> _enabledPlugins = {};
  Set<String> get enabledPlugins => _enabledPlugins;

  bool _configLoaded = false;
  bool _isConfigLoading = false;
  bool get isConfigLoading => _isConfigLoading;

  BuildViewModel() {
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
      // Config missing or malformed — no plugins enabled by default
    } finally {
      _isConfigLoading = false;
      notifyListeners();
    }
  }

  Future<void> startBuild(String projectPath) async {
    if (_isRunning) return;

    await loadConfig();
    _resetState();

    _pipelineSteps
      ..clear()
      ..addAll(_buildPipelineSteps());

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

    process.exitCode.then((code) {
      if (_process == null) return;
      _isRunning = false;
      _isSuccess = code == 0;
      _logs.add(
        LogEntry(
          '>>> Build ${_isSuccess! ? 'SUCCESS' : 'FAILED'}',
          _isSuccess! ? LogLevel.success : LogLevel.error,
        ),
      );
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
    if (i != -1) {
      _pipelineSteps[i].state = PipelineStepState.failed;
    }

    _logs.add(LogEntry('>>> BUILD STOPPED BY USER', LogLevel.error));
    notifyListeners();
  }

  // Resets everything back to initial idle state — called by Reset button in UI
  void resetBuild() {
    _process?.kill();
    _process = null;
    _isRunning = false;
    _isSuccess = null;
    _completedSteps = 0;
    _progress = 0.0;
    _logs.clear();

    // Reset steps back to base list with pending state
    _pipelineSteps
      ..clear()
      ..addAll(_baseSteps);

    for (final step in _pipelineSteps) {
      step.state = PipelineStepState.pending;
    }

    notifyListeners();
  }

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
        l.contains('FATAL'))
      return LogLevel.error;
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
