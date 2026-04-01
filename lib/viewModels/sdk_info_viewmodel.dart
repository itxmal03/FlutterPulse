import 'package:flutter/material.dart';
import 'package:flutter_pulse/service/sdk_service.dart';

class SdkInfoViewmodel extends ChangeNotifier {
  List<String> _info = [];
  String? _error;
  bool _isLoading = false;
  String? get error => _error;
  bool get isLoading => _isLoading;

  List<String> get info => _info;

  final _service = SdkService();

  Future<bool> getSdkInfo() async {
    if (_isLoading) {
      return false;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.getInfo();
    if (result.isSuccess) {
      _info = result.data!;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    _error = result.error;
    notifyListeners();
    return false;
  }
}
