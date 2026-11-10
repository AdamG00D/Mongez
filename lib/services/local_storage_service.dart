import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/completion_record.dart';
import '../models/goal.dart';
import '../models/task.dart';
import '../utils/date_helpers.dart';

class LocalStorageService {
  static const String _tasksKey = 'mongez.tasks.v1';
  static const String _historyKey = 'mongez.history.v1';
  static const String _goalsKey = 'mongez.goals.v1';
  static const String _settingsKey = 'mongez.settings.v2';
  static const String _trackedAppsKey = 'mongez.tracked_apps.v1';
  static const String _legacyThemeModeKey = 'mongez.theme_mode.v1';
  static const String _demoSeededKey = 'mongez.demo_seeded.v1';
  static const String _taskDraftKey = 'mongez.task_draft.v1';

  Future<SharedPreferences> _prefs() async {
    final preferences = await SharedPreferences.getInstance();
    // Other isolates (home widget, notification actions) may have written.
    await preferences.reload();
    return preferences;
  }

  List<Map<String, dynamic>> _decodeList(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return const <Map<String, dynamic>>[];
    }
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        return const <Map<String, dynamic>>[];
      }
      return decoded
          .whereType<Map>()
          .map((Map map) => Map<String, dynamic>.from(map))
          .toList();
    } catch (_) {
      return const <Map<String, dynamic>>[];
    }
  }

  List<T> _parseEach<T>(
    List<Map<String, dynamic>> maps,
    T Function(Map<String, dynamic>) parse,
  ) {
    final result = <T>[];
    for (final map in maps) {
      try {
        result.add(parse(map));
      } catch (_) {
        // Skip a single corrupt entry rather than losing everything.
      }
    }
    return result;
  }

  Future<List<Task>> loadTasks() async {
    final preferences = await _prefs();
    return _parseEach(
      _decodeList(preferences.getString(_tasksKey)),
      Task.fromJson,
    );
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final preferences = await SharedPreferences.getInstance();
    final payload = tasks.map((Task task) => task.toJson()).toList();
    await preferences.setString(_tasksKey, jsonEncode(payload));
  }

  Future<List<CompletionRecord>> loadHistory() async {
    final preferences = await _prefs();
    return _parseEach(
      _decodeList(preferences.getString(_historyKey)),
      CompletionRecord.fromJson,
    );
  }

  Future<void> saveHistory(List<CompletionRecord> history) async {
    final preferences = await SharedPreferences.getInstance();
    final payload = history
        .map((CompletionRecord item) => item.toJson())
        .toList();
    await preferences.setString(_historyKey, jsonEncode(payload));
  }

  Future<List<Goal>> loadGoals() async {
    final preferences = await _prefs();
    return _parseEach(
      _decodeList(preferences.getString(_goalsKey)),
      Goal.fromJson,
    );
  }

  Future<void> saveGoals(List<Goal> goals) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _goalsKey,
      jsonEncode(goals.map((Goal goal) => goal.toJson()).toList()),
    );
  }

  Future<AppSettings> loadSettings() async {
    final preferences = await _prefs();
    final raw = preferences.getString(_settingsKey);
    AppSettings settings;
    if (raw != null && raw.isNotEmpty) {
      try {
        settings = AppSettings.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw) as Map),
        );
      } catch (_) {
        settings = const AppSettings();
      }
    } else {
      // Migrate the v1 theme-mode-only preference.
      final legacy = preferences.getString(_legacyThemeModeKey);
      settings = AppSettings(
        themeMode: switch (legacy) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          _ => ThemeMode.system,
        },
      );
    }
    WeekSettings.defaultStartDay = settings.weekStartDay;
    return settings;
  }

  Future<void> saveSettings(AppSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  /// Tracked apps for screen time: package name -> daily limit in minutes
  /// (0 = no limit).
  Future<Map<String, int>> loadTrackedApps() async {
    final preferences = await _prefs();
    final raw = preferences.getString(_trackedAppsKey);
    if (raw == null || raw.isEmpty) {
      return <String, int>{};
    }
    try {
      final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      return decoded.map(
        (String key, dynamic value) =>
            MapEntry<String, int>(key, (value as num?)?.toInt() ?? 0),
      );
    } catch (_) {
      return <String, int>{};
    }
  }

  Future<void> saveTrackedApps(Map<String, int> apps) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_trackedAppsKey, jsonEncode(apps));
  }

  /// The task being written when the app left for a system permission page.
  /// Lets the add/edit sheet come back if Android recreated the app meanwhile.
  Future<Map<String, dynamic>?> loadTaskDraft() async {
    final preferences = await _prefs();
    final raw = preferences.getString(_taskDraftKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveTaskDraft(Map<String, dynamic> draft) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_taskDraftKey, jsonEncode(draft));
  }

  Future<void> clearTaskDraft() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_taskDraftKey);
  }

  Future<bool> hasSeededDemoData() async {
    final preferences = await _prefs();
    return preferences.getBool(_demoSeededKey) ?? false;
  }

  Future<void> setDemoSeeded() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_demoSeededKey, true);
  }
}
