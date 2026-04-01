import 'dart:convert';
import 'dart:io';
import 'package:flutter_pulse/core/result.dart';

class SdkService {
  Future<Result<List<String>>> getInfo() async {
    try {
      final result = await Process.run("flutter", ["--version", "--machine"]);

      if (result.exitCode == 0) {
        final Map<String, dynamic> jsonData = jsonDecode(result.stdout);

        final flutterVersion = jsonData['flutterVersion'] as String;
        final dartVersion = jsonData['dartSdkVersion'] as String;

        return Result.success([flutterVersion, dartVersion]);
      } else {
        return Result.failure("Failed to fetch SDK info");
      }
    } catch (e) {
      return Result.failure("Exception: $e");
    }
  }
}
