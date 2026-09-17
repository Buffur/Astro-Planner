import 'package:flutter/material.dart';

class ThemeViewModel extends ChangeNotifier {
  bool _isFieldMode = false;

  bool get isFieldMode => _isFieldMode;

  void toggleFieldMode() {
    _isFieldMode = !_isFieldMode;
    notifyListeners();
  }
}
