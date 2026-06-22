import 'package:flutter/foundation.dart';
import 'package:flutter_pulse/service/project_service.dart';

class PickDirectoryViewmodel extends ChangeNotifier {
  String? _error;
  String? _projectPath;
  bool _isLoading = false;
  String? get error => _error;
  bool get isLoading => _isLoading;
  String? get path => _projectPath;

  Future<bool> pickDirectory() async {
    if (_isLoading) return false;

    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ProjectService.pickAndValidateProject();

      if (result.isSuccess) {
        _projectPath = result.data!.path;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result.error;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Unexpected error: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
