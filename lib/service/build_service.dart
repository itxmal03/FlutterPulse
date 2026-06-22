import 'dart:io';
import 'package:flutter_pulse/models/pipeline_step_model.dart';

class BuildService {
  // use /bin/sh on Unix-like systems; for Windows needed cmd.exe, but Unix-only for now.
  static const String _shell = '/bin/sh';

  Future<Process> runSteps(List<PipelineStep> steps, String projectPath) async {
    final script = _generateScript(steps);

    return Process.start(
      _shell,
      ['-c', script],
      workingDirectory: projectPath,
      environment: Platform.environment, // inherit all environment variables (PATH, etc.)
      runInShell: false,
    );
  }

  String _generateScript(List<PipelineStep> steps) {
    final buffer = StringBuffer();

    buffer.writeln('echo "______________________________"');
    buffer.writeln('echo ">>> FlutterPulse Build Started"');
    buffer.writeln('echo "______________________________"');
    buffer.writeln('');

    for (final step in steps) {
      // use 'flutter' from PATH – no absolute path
      final cmd = step.command;

      buffer.writeln('echo "STEP::${step.label}::start"');
      buffer.writeln(cmd);
      buffer.writeln('if [ \$? -eq 0 ]; then');
      buffer.writeln('  echo "STEP::${step.label}::done"');
      buffer.writeln('else');
      buffer.writeln('  echo "STEP::${step.label}::failed"');
      buffer.writeln('  exit 1');
      buffer.writeln('fi');
      buffer.writeln('');
    }

    buffer.writeln('echo "BUILD::SUCCESS"');
    return buffer.toString();
  }
}