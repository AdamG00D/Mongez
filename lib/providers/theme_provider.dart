import 'package:flutter/material.dart';

import '../services/local_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._storageService);

  final LocalStorageService _storageService;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> initialize() async {
    _themeMode = await _storageService.loadThemeMode();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) {
      return;
    }

    _themeMode = mode;
    notifyListeners();
    await _storageService.saveThemeMode(mode);
  }
}
