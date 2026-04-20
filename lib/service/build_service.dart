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
        
         echo "STEP:CLEAN"
         flutter clean
   
         echo "STEP:GET"
         flutter pub get
   
         echo "STEP:BUILD"
         flutter build apk --release
   
         echo "BUILD:SUCCESS"
        
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
