import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  static const _prefKey = 'theme_mode';

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefKey);
      if (stored != null) {
        final mode = ThemeMode.values.firstWhere(
          (mode) => mode.name == stored,
          orElse: () => ThemeMode.light,
        );
        emit(mode);
      }
    } catch (e) {
      debugPrint('Failed to load theme mode: $e');
    }
  }

  Future<void> toggleDarkMode(bool enableDarkMode) async {
    await setTheme(enableDarkMode ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, mode.name);
    } catch (e) {
      debugPrint('Failed to persist theme mode: $e');
    }
  }
}
