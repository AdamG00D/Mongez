import 'dart:async';

import '../services/notification_service.dart';
import 'goals_provider.dart';
import 'settings_provider.dart';
import 'task_provider.dart';

/// Collects tasks, goals and settings and reschedules reminders. Changes are
/// debounced so a burst of edits results in a single reschedule.
class ReminderCoordinator {
  ReminderCoordinator({
    required this.notifications,
    required this.tasks,
    required this.goals,
    required this.settings,
  });

  final NotificationService notifications;
  final TaskProvider tasks;
  final GoalsProvider goals;
  final SettingsProvider settings;

  Timer? _debounce;

  void schedule({Duration delay = const Duration(milliseconds: 400)}) {
    _debounce?.cancel();
    _debounce = Timer(delay, syncNow);
  }

  Future<void> syncNow() {
    _debounce?.cancel();
    if (tasks.isLoading || !settings.isLoaded) {
      return Future<void>.value();
    }
    return notifications.sync(
      tasks: tasks.allTasks,
      settings: settings.settings,
      goals: goals.goals,
    );
  }
}
