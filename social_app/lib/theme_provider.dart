// lib/theme_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark; // default to Discord-style dark

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Discord-inspired palette
  static const discordBlurple = Color(0xFF5865F2);
  static const discordDark = Color(0xFF1E1F22);
  static const discordDarker = Color(0xFF2B2D31);
  static const discordTextLight = Color(0xFFDBDEE1);
  static const discordTextMuted = Color(0xFF949BA4);
  static const discordTextDark = Color(0xFF1A1A1D);

  // Gradients
  static const LinearGradient darkGradient = LinearGradient(
    colors: [
      Color(0xFF1B0A39), // deep purple
      Color(0xFF1E1F54), // indigo
      Color(0xFF0A1A42), // navy-ish
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightGradient = LinearGradient(
    colors: [
      Color(0xFFE6D9FF), // soft lavender
      Color(0xFFC8D7FF), // light blue
      Color(0xFFD9F3FF), // pale teal
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
