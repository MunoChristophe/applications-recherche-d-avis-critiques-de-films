import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('fr');

  Locale get locale => _locale;

  bool get isFrench => _locale.languageCode == 'fr';

  void toggle() {
    _locale = isFrench ? const Locale('en') : const Locale('fr');
    notifyListeners();
  }
}
