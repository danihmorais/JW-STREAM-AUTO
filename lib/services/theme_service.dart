import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's light/dark preference across app restarts.
/// Exposed as a ValueNotifier so MaterialApp can rebuild via
/// ValueListenableBuilder without pulling in a state-management package.
class ThemeService {
  static const _prefsKey = 'theme_mode';

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    switch (stored) {
      case 'light':
        themeMode.value = ThemeMode.light;
        break;
      case 'dark':
        themeMode.value = ThemeMode.dark;
        break;
      default:
        themeMode.value = ThemeMode.system;
    }
  }

  Future<void> toggle() async {
    // Treat "system" as light for the purpose of the toggle: tapping it
    // always gives a definite light/dark choice rather than cycling
    // through a third state the user didn't ask for.
    final isCurrentlyDark = themeMode.value == ThemeMode.dark;
    final next = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    themeMode.value = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, next == ThemeMode.dark ? 'dark' : 'light');
  }
}
