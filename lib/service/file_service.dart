import 'package:file_picker/file_picker.dart';
import 'package:flutter_pulse/core/result.dart';

class FileService {
  static Future<Result<String>> getDirectoryPath() async {
    try {
      final path = await FilePicker.getDirectoryPath();

      if (path == null) {
        return Result.failure("User Cancelled");
      }
      return Result.success(path);
    } catch (e) {
      return Result.failure("Failed to pick directory");
    }
  }
}
