import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../l10n/l10n.dart';
import '../models/app_settings.dart';
import '../services/local_storage_service.dart';
import '../utils/date_helpers.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._storage);

  final LocalStorageService _storage;

  AppSettings _settings = const AppSettings();
  bool _loaded = false;

  /// Called when a setting that affects scheduled reminders changes.
  VoidCallback? onRemindersChanged;

  /// Called when the week start changes (widget/progress must refresh).
  VoidCallback? onWeekStartChanged;

  /// Called when the shown language changes (widget and reminder texts must
  /// be rebuilt).
  VoidCallback? onLanguageChanged;

  AppSettings get settings => _settings;
  bool get isLoaded => _loaded;
  ThemeMode get themeMode => _settings.themeMode;

  Future<void> initialize() async {
    _settings = await _storage.loadSettings();
    if (_settings.backgroundId == 'custom' &&
        (_settings.customBackgroundPath == null ||
            !File(_settings.customBackgroundPath!).existsSync())) {
      _settings = _settings.copyWith(
        backgroundId: 'aurora',
        clearCustomBackground: true,
      );
    }
    L10n.apply(_settings.language);
    _loaded = true;
    notifyListeners();
  }

  Future<void> update(AppSettings Function(AppSettings current) change) async {
    final previous = _settings;
    final next = change(previous);
    _settings = next;
    WeekSettings.defaultStartDay = next.weekStartDay;
    final languageChanged =
        previous.language != next.language && L10n.apply(next.language);
    notifyListeners();
    await _storage.saveSettings(next);

    if (previous.weekStartDay != next.weekStartDay) {
      onWeekStartChanged?.call();
    }
    if (languageChanged) {
      onLanguageChanged?.call();
    }
    if (previous.followUpReminders != next.followUpReminders ||
        previous.followUpMinutes != next.followUpMinutes ||
        previous.planningReminder != next.planningReminder ||
        previous.planningReminderMinutes != next.planningReminderMinutes ||
        previous.goalsReminder != next.goalsReminder ||
        previous.weekStartDay != next.weekStartDay) {
      onRemindersChanged?.call();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      update((AppSettings s) => s.copyWith(themeMode: mode));

  Future<void> setLanguage(AppLanguage language) =>
      update((AppSettings s) => s.copyWith(language: language));

  /// Re-reads the device languages (when following the system). Returns true
  /// if the shown language changed; listeners are notified in that case.
  bool refreshDeviceLanguage() {
    if (_settings.language != AppLanguage.system || !L10n.refreshFromDevice()) {
      return false;
    }
    notifyListeners();
    onLanguageChanged?.call();
    return true;
  }

  /// Lets the user pick a photo and stores a private copy as the background.
  /// Returns false if the user cancelled.
  Future<bool> pickCustomBackground() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2160,
      imageQuality: 88,
    );
    if (picked == null) {
      return false;
    }

    final directory = await getApplicationDocumentsDirectory();
    final extension = picked.path.contains('.')
        ? picked.path.substring(picked.path.lastIndexOf('.'))
        : '.jpg';
    final target = File(
      '${directory.path}/background_${DateTime.now().millisecondsSinceEpoch}$extension',
    );
    await target.writeAsBytes(await picked.readAsBytes(), flush: true);

    final oldPath = _settings.customBackgroundPath;
    await update(
      (AppSettings s) =>
          s.copyWith(backgroundId: 'custom', customBackgroundPath: target.path),
    );
    if (oldPath != null && oldPath != target.path) {
      try {
        await File(oldPath).delete();
      } catch (_) {}
    }
    return true;
  }
}
