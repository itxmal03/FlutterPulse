import 'dart:io';

import 'package:flutter_pulse/models/pipeline_step_model.dart';

class BuildService {
  static const String _bash = '/usr/bin/bash';
  static const String _flutter =
      '/home/itxmal03/development/flutter/bin/flutter';
  static const String _path =
      '/home/itxmal03/Android/Sdk/cmdline-tools/latest/bin'
      ':/home/itxmal03/Android/Sdk/platform-tools'
      ':/usr/lib/jvm/java-21-openjdk-amd64/bin'
      ':/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
      ':/usr/games:/usr/local/games:/snap/bin'
      ':/home/itxmal03/development/flutter/bin'
      ':/home/itxmal03/.pub-cache/bin';

  Future<Process> runSteps(List<PipelineStep> steps, String projectPath) async {
    final buffer = StringBuffer();

    buffer.writeln('echo "______________________________"');
    buffer.writeln('echo ">>> FlowForge Build Started"');
    buffer.writeln('echo "______________________________"');
    buffer.writeln('');

    for (final step in steps) {
      // Replace 'flutter' with absolute path so it works without login shell
      final cmd = step.command.replaceFirst('flutter', _flutter);

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

    final process = await Process.start(
      _bash,
      ['-c', buffer.toString()],
      workingDirectory: projectPath,
      runInShell: false,
      environment: {
        'PATH': _path,
        'HOME': Platform.environment['HOME'] ?? '/home/itxmal03',
        'USER': Platform.environment['USER'] ?? 'itxmal03',
        'ANDROID_HOME': '/home/itxmal03/Android/Sdk',
        'ANDROID_SDK_ROOT': '/home/itxmal03/Android/Sdk',
        'JAVA_HOME': '/usr/lib/jvm/java-21-openjdk-amd64',
        'CI': 'true',
        'TERM': 'dumb',
      },
    );

    return process;
  }
}
