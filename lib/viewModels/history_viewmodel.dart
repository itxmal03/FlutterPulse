import 'package:flutter/material.dart';
import 'package:flutter_pulse/models/build_history_model.dart';
import 'package:flutter_pulse/service/history_service.dart';

class HistoryViewModel extends ChangeNotifier {
  List<BuildHistoryRecord> _records = [];
  List<BuildHistoryRecord> get records => _records;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Load history from disk
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _records = await HistoryService.loadAll();

    _isLoading = false;
    notifyListeners();
  }

  // Called by BuildViewModel after each build finishes — adds record and refreshes list
  Future<void> addRecord(BuildHistoryRecord record) async {
    await HistoryService.save(record);
    _records.insert(0, record);
    notifyListeners();
  }

  // Delete one record
  Future<void> deleteRecord(String id) async {
    await HistoryService.delete(id);
    _records.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // Clear all
  Future<void> clearAll() async {
    await HistoryService.clearAll();
    _records.clear();
    notifyListeners();
  }
}
