import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Gère les préférences utilisateur (thème et langue).
class SettingsProvider extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _themeModeKey = 'themeMode';
  static const String _localeKey = 'locale';

  late Box _box;
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('fr');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    final stored = _box.get(_themeModeKey, defaultValue: 'light') as String;
    _themeMode =
        stored == 'dark' ? ThemeMode.dark : ThemeMode.light;
    final storedLocale = _box.get(_localeKey, defaultValue: 'fr') as String;
    _locale = Locale(storedLocale);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _box.put(_themeModeKey, mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _box.put(_localeKey, locale.languageCode);
    notifyListeners();
  }

  void toggleTheme() {
    setThemeMode(
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
    );
  }

  void toggleLocale() {
    setLocale(
      _locale.languageCode == 'fr'
          ? const Locale('en')
          : const Locale('fr'),
    );
  }
}
