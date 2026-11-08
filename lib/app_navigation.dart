import 'dart:async';

import 'package:flutter/material.dart';

/// Lightweight app-wide navigation signals (used by notifications and the
/// home-screen widget to steer the UI).
class AppNavigation {
  AppNavigation._();

  static const int tasksTab = 0;
  static const int goalsTab = 1;
  static const int statsTab = 2;
  static const int screenTimeTab = 3;
  static const int settingsTab = 4;

  static final ValueNotifier<int> currentTab = ValueNotifier<int>(tasksTab);

  static final StreamController<AppCommand> _commands =
      StreamController<AppCommand>.broadcast();

  static Stream<AppCommand> get commands => _commands.stream;

  static void send(AppCommand command) => _commands.add(command);
}

enum AppCommand { addTask }
