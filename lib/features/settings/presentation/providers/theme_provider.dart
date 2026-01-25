import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final _themeBoxProvider = FutureProvider<Box>((ref) async {
  return await Hive.openBox('settings');
});

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;
  Box? _box;

  ThemeModeNotifier(this._ref) : super(ThemeMode.system) {
    _initialize();
  }

  Future<void> _initialize() async {
    final boxAsync = _ref.read(_themeBoxProvider);
    boxAsync.whenData((box) {
      _box = box;
      final themeIndex = box.get('themeMode', defaultValue: 0) as int;
      state = ThemeMode.values[themeIndex];
    });
    
    // Also watch for when the box becomes available
    _ref.listen(_themeBoxProvider, (previous, next) {
      next.whenData((box) {
        if (_box == null) {
          _box = box;
          final themeIndex = box.get('themeMode', defaultValue: 0) as int;
          state = ThemeMode.values[themeIndex];
        }
      });
    });
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    if (_box != null) {
      await _box!.put('themeMode', mode.index);
    } else {
      // Wait for box to be available
      final boxAsync = _ref.read(_themeBoxProvider);
      boxAsync.whenData((box) async {
        _box = box;
        await box.put('themeMode', mode.index);
      });
    }
  }
}

