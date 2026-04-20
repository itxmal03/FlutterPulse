import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pulse/models/log_entry_model.dart';
import 'package:flutter_pulse/models/pipeline_step_model.dart';
import 'package:flutter_pulse/service/build_service.dart';

class BuildViewModel extends ChangeNotifier {
  final _service = BuildService();

  final List<PipelineStep> _pipelineSteps = [
    PipelineStep('Clean', 'flutter clean'),
    PipelineStep('Get', 'flutter pub get'),
    PipelineStep('Build', 'flutter build apk'),
  ];

  Process? _process;

  int _completedSteps = 0;
  double _progress = 0.0;

  double get progress => _progress;

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  final List<LogEntry> _logs = [];
  List<LogEntry> get logs => _logs;

  bool? _isSuccess;
  bool? get isSuccess => _isSuccess;

  List<PipelineStep> get pipelineSteps => _pipelineSteps;

  Future<void> startBuild(String projectPath) async {
    if (_isRunning) return;

    // reset state
    _isRunning = true;
    _logs.clear();
    _isSuccess = null;
    _process = null;
    _completedSteps = 0;
    _progress = 0.0;

    for (var step in _pipelineSteps) {
      step.state = PipelineStepState.pending;
    }

    notifyListeners();

    _process = await _service.startBuild(projectPath);
    final process = _process!;

    process.stdout.transform(utf8.decoder).listen((data) {
      _handleLog(data);
    });

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

  // 🔥 CORE LOG ENGINE
  void _handleLog(String raw) {
    final lines = raw.split('\n');

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      _logs.add(LogEntry(line, _detectLogLevel(line)));

      // STEP DETECTION
      if (line.contains("STEP:CLEAN")) {
        _setRunning(0);
      }

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
    final lines = raw.split('\n');

    for (var line in lines) {
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

  void _updateProgress() {
    _progress = (_completedSteps / _pipelineSteps.length).clamp(0.0, 1.0);
  }

  void _complete(int index) {
    if (_pipelineSteps[index].state != PipelineStepState.done) {
      _pipelineSteps[index].state = PipelineStepState.done;
      _completedSteps++;
      _updateProgress();
    }
  }

  void _setRunning(int index) {
    _pipelineSteps[index].state = PipelineStepState.running;
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

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }
}
