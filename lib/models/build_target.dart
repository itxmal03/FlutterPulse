enum BuildTarget {
  apk,
  linux,
  web,
  windows,
  deb;

  // Display label shown in dropdown
  String get label {
    switch (this) {
      case BuildTarget.apk:
        return 'Android APK';
      case BuildTarget.linux:
        return 'Linux (x64)';
      case BuildTarget.web:
        return 'Web';
      case BuildTarget.windows:
        return 'Windows';
      case BuildTarget.deb:
        return 'Linux DEB';
    }
  }

  // The actual flutter build command arg
  String get command {
    switch (this) {
      case BuildTarget.apk:
        return 'flutter build apk';
      case BuildTarget.linux:
        return 'flutter build linux';
      case BuildTarget.web:
        return 'flutter build web';
      case BuildTarget.windows:
        return 'flutter build windows';
      case BuildTarget.deb:
        return 'flutter build linux && dpkg-deb --build build/linux/x64/release/bundle';
    }
  }

  // Where Flutter outputs the build artifact for this target
  String outputPath(String projectPath) {
    switch (this) {
      case BuildTarget.apk:
        return '$projectPath/build/app/outputs/flutter-apk/app-release.apk';
      case BuildTarget.linux:
        return '$projectPath/build/linux/x64/release/bundle';
      case BuildTarget.web:
        return '$projectPath/build/web';
      case BuildTarget.windows:
        return '$projectPath/build/windows/x64/runner/Release';
      case BuildTarget.deb:
        return '$projectPath/build/linux/x64/release/bundle.deb';
    }
  }

  // Short tag stored in history JSON
  String get key => name;

  static BuildTarget fromKey(String key) {
    return BuildTarget.values.firstWhere(
      (t) => t.key == key,
      orElse: () => BuildTarget.apk,
    );
  }
}
