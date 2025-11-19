import 'package:daeja/features/settings/database/theme_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeProvider);
  return themeMode == ThemeMode.dark;
});

class ThemeNotifier extends Notifier<ThemeMode> {
  final ThemeDatabase _themeDatabase = ThemeDatabase();

  @override
  ThemeMode build() {
    return _themeDatabase.getThemeMode();
  }

  void toggleTheme() {
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
    } else if (state == ThemeMode.dark) {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.dark;
    }
    _themeDatabase.setThemeMode(state);
  }

  void setThemeMode(ThemeMode themeMode) {
    state = themeMode;
    _themeDatabase.setThemeMode(state);
  }
}
