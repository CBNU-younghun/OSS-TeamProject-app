// providers/CrabAnimationProvider.dart

import 'package:flutter/material.dart';

class CrabAnimationProvider extends ChangeNotifier {
  bool _isCrabVisible = false;

  bool get isCrabVisible => _isCrabVisible;

  void showCrab() {
    _isCrabVisible = true;
    notifyListeners();
  }

  void hideCrab() {
    _isCrabVisible = false;
    notifyListeners();
  }
}
