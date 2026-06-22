import 'dart:convert';
import 'dart:io';

import 'package:flutter_pulse/models/build_history_model.dart';

class HistoryService {
  static File get _file {
    final home = Platform.environment['HOME'] ?? '';
    final dir = Directory('$home/.flutter_pulse');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return File('${dir.path}/history.json');
  }

  // load all records sorted by  newest first
  static Future<List<BuildHistoryRecord>> loadAll() async {
    try {
      final file = _file;
      if (!file.existsSync()) return [];

      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];

      final List<dynamic> raw = json.decode(content);
      final records = raw
          .map((e) => BuildHistoryRecord.fromJson(e as Map<String, dynamic>))
          .toList();

      // sort newest first
      records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return records;
    } catch (_) {
      return [];
    }
  }

  // Append a new record
  static Future<void> save(BuildHistoryRecord record) async {
    try {
      final existing = await loadAll();
      existing.insert(0, record); // prepend newest

      // Cap history at 100 records
      final capped = existing.take(100).toList();

      final file = _file;
      await file.writeAsString(
        const JsonEncoder.withIndent(
          '  ',
        ).convert(capped.map((r) => r.toJson()).toList()),
      );
    } catch (_) {
      // history save failure is non-fatal — build still succeeded/failed
    }
  }

  // delete a single record by id
  static Future<void> delete(String id) async {
    try {
      final existing = await loadAll();
      final filtered = existing.where((r) => r.id != id).toList();
      final file = _file;
      await file.writeAsString(
        const JsonEncoder.withIndent(
          '  ',
        ).convert(filtered.map((r) => r.toJson()).toList()),
      );
    } catch (_) {}
  }

  // clear all history
  static Future<void> clearAll() async {
    try {
      final file = _file;
      if (file.existsSync()) await file.writeAsString('[]');
    } catch (_) {}
  }
}
