import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pulse/service/build_service.dart';

class BuildViewModel extends ChangeNotifier {
  final _service = BuildService();

  bool _isRunning = false;
  String _logs = "";
  bool? _isSuccess;

  bool get isRunning => _isRunning;
  String get logs => _logs;
  bool? get isSuccess => _isSuccess;

  Future<void> startBuild(String projectPath) async {
    if (_isRunning) return;

    _isRunning = true;
    _logs = "";
    _isSuccess = null;
    notifyListeners();

    final process = await _service.startBuild(projectPath);

    process.stdout.transform(utf8.decoder).listen((data) {
      _logs += data;
      notifyListeners();
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      _logs += data;
      notifyListeners();
    });

    process.exitCode.then((code) {
      _isRunning = false;
      _isSuccess = code == 0;
      _logs += "\n\n>>> Build ${_isSuccess! ? "SUCCESS" : "FAILED"}";
      notifyListeners();
    });
  }
}