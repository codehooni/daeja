import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeDatabase {
  final Box _box = Hive.box('settings');

  ThemeMode getThemeMode() {
    if (_box.isEmpty) {
      return ThemeMode.system;
    }
    final themeIndex = _box.values.first as int;
    return ThemeMode.values[themeIndex];
  }

  void setThemeMode(ThemeMode themeMode) {
    _box.clear();
    _box.put('themeMode', themeMode.index);
  }
}
