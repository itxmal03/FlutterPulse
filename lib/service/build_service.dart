import 'dart:io';

class BuildService {
  Future<Process> startBuild(String projectPath) async {
    final process = await Process.start(
      'bash',
      [
        '''
        set -e
   
        echo "=============================="
        echo ">>> Starting Flutter Build"
        echo "=============================="
        
        echo "🔹 Cleaning project..."
        
        flutter clean
        
        echo "🔹 Getting dependencies..."
        
        flutter pub get
        
        echo "🔹 Building APK..."
        
        flutter build apk --release
        
        echo "=============================="
        echo ">>>Build Completed Successfully"
        echo "=============================="   ''',
      ],
      workingDirectory: projectPath,
      runInShell: true,
    );

    return process;
  }
}
