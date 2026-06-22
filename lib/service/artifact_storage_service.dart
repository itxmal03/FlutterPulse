import 'dart:io';
import 'package:path/path.dart' as p;

class ArtifactStorageService {
  /// Copies the built artifact from [sourcePath] to a versioned folder under
  /// ~/.flutter_pulse/artifacts/{projectName}/{timestamp}/ and returns the new path.
  static Future<String> storeArtifact(
    String projectPath,
    String sourcePath,
  ) async {
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null) {
      throw Exception('Could not determine user home directory');
    }
    final projectName = p.basename(projectPath);
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final destDir = p.join(
      home,
      '.flutter_pulse',
      'artifacts',
      projectName,
      timestamp,
    );

    await Directory(destDir).create(recursive: true);

    final source = FileSystemEntity.typeSync(sourcePath);
    final destPath = p.join(destDir, p.basename(sourcePath));

    if (source == FileSystemEntityType.directory) {
      await _copyDirectory(Directory(sourcePath), Directory(destPath));
    } else if (source == FileSystemEntityType.file) {
      await File(sourcePath).copy(destPath);
    } else {
      throw Exception('Source artifact not found: $sourcePath');
    }

    return destPath;
  }

  static Future<void> _copyDirectory(
    Directory source,
    Directory destination,
  ) async {
    await destination.create(recursive: true);

    await for (final entity in source.list(recursive: false)) {
      final relative = p.relative(entity.path, from: source.path);
      final dest = p.join(destination.path, relative);

      if (entity is File) {
        await entity.copy(dest);
      } else if (entity is Directory) {
        await _copyDirectory(entity, Directory(dest));
      }
    }
  }
}
