import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Holds the user-selected ThemeMode and persists it across launches.
class ThemeProvider extends ChangeNotifier {
  static const _key = 'theme_mode';
  static const _storage = FlutterSecureStorage();

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  /// Read the persisted preference. Call once on app boot.
  Future<void> load() async {
    try {
      final raw = await _storage.read(key: _key);
      _mode = _decode(raw);
      notifyListeners();
    } catch (_) {
      // Fall back to system default silently.
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    try {
      await _storage.write(key: _key, value: _encode(mode));
    } catch (_) {}
  }

  static ThemeMode _decode(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
