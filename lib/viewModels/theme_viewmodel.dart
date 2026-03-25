import 'package:flutter/material.dart';
import 'package:flutter_pulse/core/constants.dart';

class ThemeViewmodel extends ChangeNotifier {
  bool _isDark = true;
  bool get isDark => _isDark;

  void updateTheme({required bool val}) {
    _isDark = val;
    AppColors.isDark = val;
    notifyListeners();
  }
}
