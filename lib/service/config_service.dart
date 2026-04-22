import 'dart:convert';
import 'package:flutter/services.dart';

class ConfigService {
  static Future<Map<String, dynamic>> loadConfig() async {
    final jsonString =
        await rootBundle.loadString('assets/config/pipeline_config.json');
    return json.decode(jsonString); 
  }
}