import 'dart:io';
import 'package:flutter_pulse/models/pipeline_step_model.dart';

class BuildService {
  Future<Process> runSteps(List<PipelineStep> steps, String projectPath) async {
    final buffer = StringBuffer();

    // safety mode :: stop on error
    buffer.writeln("set -e");

    buffer.writeln('echo "______________________________"');
    buffer.writeln('echo ">>> FlowForge Build Started"');
    buffer.writeln('echo "______________________________"');
    buffer.writeln("");

    // build dynamic pipeline from steps
    for (final step in steps) {
      buffer.writeln('echo "STEP:${step.label.toUpperCase()}"');
      buffer.writeln(step.command);
      buffer.writeln("");
    }

    buffer.writeln('echo "BUILD:SUCCESS"');

    final process = await Process.start(
      'bash',
      ['-c', buffer.toString()],
      workingDirectory: projectPath,
      runInShell: true,
    );

    return process;
  }
}
