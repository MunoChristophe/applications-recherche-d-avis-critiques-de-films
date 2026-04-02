import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  final List<String> _history = ['/search'];
  int _index = 0;

  String get current => _history[_index];

  bool get canGoBack => _index > 0;

  bool get canGoForward => _index < _history.length - 1;

  void navigate(String route) {
    if (_index < _history.length - 1) {
      _history.removeRange(_index + 1, _history.length);
    }
    _history.add(route);
    _index++;
    notifyListeners();
  }

  void goBack() {
    if (canGoBack) {
      _index--;
      notifyListeners();
    }
  }

  void goForward() {
    if (canGoForward) {
      _index++;
      notifyListeners();
    }
  }
}
