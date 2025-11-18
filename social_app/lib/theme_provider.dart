// theme_provider.dart; Theme tracker
import 'package:flutter/material.dart';

// this guy just keeps track of whether the app is in light or dark mode
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode =
      ThemeMode.light; // default to light, easy on the eyes first

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // whenever the switch in settings is changed, we call this
  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // tells the whole app "yo, rebuild with new theme"
  }
}
