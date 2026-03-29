import 'dart:io';

import 'package:flutter_pulse/core/result.dart';
import 'package:flutter_pulse/models/project_model.dart';
import 'package:flutter_pulse/service/file_service.dart';
import 'package:path/path.dart' as p;

class ProjectService {
  static Future<Result<ProjectModel>> pickAndValidateProject() async {
    final dirResult = await FileService.getDirectoryPath();

    if (!dirResult.isSuccess) {
      return Result.failure("Directory selection failed: ${dirResult.error}");
    }

    final dirPath = dirResult.data!;
    final pubspec = File(p.join(dirPath, "pubspec.yaml"));
    final lib = Directory(p.join(dirPath, "lib"));
    final android = Directory(p.join(dirPath, "android"));
    final ios = Directory(p.join(dirPath, "ios"));


    final isValid =
        await pubspec.exists() && await lib.exists() &&  (await android.exists() || await ios.exists());

    if (!isValid) {
      return Result.failure("Not a Flutter project");
    }

    return Result.success(ProjectModel(path: dirPath, isValid: true));
  }
}
