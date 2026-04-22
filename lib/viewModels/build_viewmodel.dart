import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pulse/core/pipeline/plugin_registry.dart';
import 'package:flutter_pulse/models/log_entry_model.dart';
import 'package:flutter_pulse/models/pipeline_step_model.dart';
import 'package:flutter_pulse/service/build_service.dart';

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

  // progress
  int _completedSteps = 0;
  double _progress = 0.0;

  double get progress => _progress;

  //running state control
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  bool? _isSuccess;
  bool? get isSuccess => _isSuccess;

  // handles logs
  final List<LogEntry> _logs = [];
  List<LogEntry> get logs => _logs;

  //handles plugins
  final Set<String> _enabledPlugins = {};

  Set<String> get enabledPlugins => _enabledPlugins;

  void togglePlugin(String id) {
    // Enable/disable plugin from UI
    if (_enabledPlugins.contains(id)) {
      _enabledPlugins.remove(id);
    } else {
      _enabledPlugins.add(id);
    }
    notifyListeners();
  }

  //build handler
  Future<void> startBuild(String projectPath) async {
    if (_isRunning) return;

    _resetState();

    // build final pipeline (base + plugins + build step)
    _pipelineSteps
      ..clear()
      ..addAll(_buildPipelineSteps());

    notifyListeners();

    _process = await _service.startBuild(projectPath);
    final process = _process!;

    // stdout logs :: normal output
    process.stdout.transform(utf8.decoder).listen(_handleLog);

    // stderr logs :: errors
    process.stderr.transform(utf8.decoder).listen((data) {
      _addLog(data, LogLevel.error);
      _failCurrentStep();
      notifyListeners();
    });

    // process exit
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

  // stop build hanlder
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

  // pipeline builder :: core
  List<PipelineStep> _buildPipelineSteps() {
    // base steps always run
    final steps = [..._baseSteps];

    // inject plugin steps dynamically
    for (final id in _enabledPlugins) {
      final plugin = PluginRegistry.available[id];
      if (plugin != null) {
        steps.addAll(plugin.buildSteps());
      }
    }

    return steps;
  }

  // log handling engine
  void _handleLog(String raw) {
    final lines = raw.split('\n');

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      _logs.add(LogEntry(line, _detectLogLevel(line)));

      // step tracking simple pattern matching
      if (line.contains("STEP:CLEAN")) _setRunning(0);

      if (line.contains("STEP:GET")) {
        _complete(0);
        _setRunning(1);
      }

      if (line.contains("STEP:BUILD")) {
        _complete(1);
        _setRunning(2);
      }

      if (line.contains("BUILD:SUCCESS")) {
        _complete(2);
      }
    }

    notifyListeners();
  }

  void _addLog(String raw, LogLevel level) {
    for (final line in raw.split('\n')) {
      if (line.trim().isEmpty) continue;
      _logs.add(LogEntry(line, level));
    }
  }

  LogLevel _detectLogLevel(String line) {
    if (line.contains("ERROR")) {
      return LogLevel.error;
    }
    if (line.contains("SUCCESS")) {
      return LogLevel.success;
    }
    if (line.contains("WARNING")) {
      return LogLevel.warning;
    }
    return LogLevel.info;
  }

  //step control
  void _setRunning(int index) {
    _pipelineSteps[index].state = PipelineStepState.running;
  }

  void _complete(int index) {
    if (_pipelineSteps[index].state != PipelineStepState.done) {
      _pipelineSteps[index].state = PipelineStepState.done;
      _completedSteps++;
      _updateProgress();
    }
  }

  void _failCurrentStep() {
    final i = _pipelineSteps.indexWhere(
      (s) => s.state == PipelineStepState.running,
    );

    if (i != -1) {
      _pipelineSteps[i].state = PipelineStepState.failed;
      _updateProgress();
    }
  }

  void _updateProgress() {
    _progress = (_completedSteps / _pipelineSteps.length).clamp(0.0, 1.0);
  }

  // reset state
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
