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
    _error = null;
    _isLoading = true;

    final result = await ProjectService.pickAndValidateProject();
    if (result.isSuccess) {
      _projectPath = result.data!.path;
      _isLoading = false;
      notifyListeners();
      return true;
    }
    _error = result.error;
    notifyListeners();
    return false;
  }
}
