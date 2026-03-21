import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/completion_record.dart';
import '../models/task.dart';

class LocalStorageService {
  static const String _tasksKey = 'mongez.tasks.v1';
  static const String _historyKey = 'mongez.history.v1';
  static const String _themeModeKey = 'mongez.theme_mode.v1';
  static const String _demoSeededKey = 'mongez.demo_seeded.v1';

  Future<List<Task>> loadTasks() async {
    final preferences = await SharedPreferences.getInstance();
    final jsonString = preferences.getString(_tasksKey);
    if (jsonString == null || jsonString.isEmpty) {
      return <Task>[];
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        return <Task>[];
      }

      return decoded
          .whereType<Map>()
          .map((Map map) => Task.fromJson(Map<String, dynamic>.from(map)))
          .toList();
    } catch (_) {
      return <Task>[];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final preferences = await SharedPreferences.getInstance();
    final payload = tasks.map((Task task) => task.toJson()).toList();
    await preferences.setString(_tasksKey, jsonEncode(payload));
  }

  Future<List<CompletionRecord>> loadHistory() async {
    final preferences = await SharedPreferences.getInstance();
    final jsonString = preferences.getString(_historyKey);
    if (jsonString == null || jsonString.isEmpty) {
      return <CompletionRecord>[];
    }

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        return <CompletionRecord>[];
      }

      return decoded
          .whereType<Map>()
          .map(
            (Map map) =>
                CompletionRecord.fromJson(Map<String, dynamic>.from(map)),
          )
          .toList();
    } catch (_) {
      return <CompletionRecord>[];
    }
  }

  Future<void> saveHistory(List<CompletionRecord> history) async {
    final preferences = await SharedPreferences.getInstance();
    final payload = history
        .map((CompletionRecord item) => item.toJson())
        .toList();
    await preferences.setString(_historyKey, jsonEncode(payload));
  }

  Future<ThemeMode> loadThemeMode() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_themeModeKey);

    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await preferences.setString(_themeModeKey, value);
  }

  Future<bool> hasSeededDemoData() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_demoSeededKey) ?? false;
  }

  Future<void> setDemoSeeded() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_demoSeededKey, true);
  }
}
