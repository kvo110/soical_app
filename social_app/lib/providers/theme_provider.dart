// lib/providers/theme_provider.dart
// central theme controller for the app.
//
// Provides:
// - dark/light mode toggle
// - Discord color palette
// - gradient background used globally
// - glass UI helpers for login/register cards

import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  // Discord “blurple”
  static const Color discordBlurple = Color(0xFF5865F2);

  // sidebar + panels
  static const Color discordDarkest = Color(0xFF1E1F22);
  static const Color discordDarker = Color(0xFF2B2D31);

  // Muted text
  static const Color discordTextMuted = Color(0xFFB9BBBE);

  // Light theme gradients
  static const LinearGradient lightGradient = LinearGradient(
    colors: [
      Color(0xFFB07CFF),
      Color(0xFF7BA2FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark theme gradients
  static const LinearGradient darkGradient = LinearGradient(
    colors: [
      Color(0xFF3A0CA3),
      Color(0xFF4361EE),
      Color(0xFF7209B7),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass background for login/register forms
  static Color glassBackground(BuildContext context) {
    return Colors.white.withOpacity(isDark(context) ? 0.06 : 0.3);
  }

  // Thin border for glass effect
  static Color glassBorder(BuildContext context) {
    return Colors.white.withOpacity(isDark(context) ? 0.08 : 0.4);
  }

  // Drop shadows matching Discord blurple glow
  static List<BoxShadow> glassShadow(BuildContext context) {
    return [
      BoxShadow(
        blurRadius: 20,
        offset: const Offset(0, 10),
        color: Colors.black.withOpacity(isDark(context) ? 0.4 : 0.15),
      ),
    ];
  }

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
