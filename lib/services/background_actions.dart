import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../utils/date_helpers.dart';
import 'local_storage_service.dart';
import 'notification_service.dart';
import 'task_mutations.dart';
import 'widget_sync_service.dart';

/// Port the UI isolate listens on, so background changes (widget taps,
/// notification actions) refresh the open app immediately.
const String mainIsolatePortName = 'mongez.main.refresh';

class BackgroundActions {
  BackgroundActions._();

  /// Toggles (or forces) a task completion from a background isolate and
  /// propagates it to storage, widgets, reminders and the running UI.
  static Future<void> toggleTask({
    required String taskId,
    required DateTime day,
    bool? forceValue,
    bool fallbackToToday = true,
  }) async {
    final storage = LocalStorageService();
    await storage.loadSettings(); // applies the week start setting

    final tasks = await storage.loadTasks();
    final history = await storage.loadHistory();

    var activeDay = dateOnly(day);
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index == -1) {
      return;
    }
    final today = todayDate();
    if (fallbackToToday &&
        !tasks[index].appearsOn(activeDay) &&
        tasks[index].appearsOn(today)) {
      activeDay = today;
    }

    final updated = TaskMutations.toggle(
      tasks: tasks,
      history: history,
      taskId: taskId,
      day: activeDay,
      forceValue: forceValue,
    );
    if (updated == null) {
      return;
    }

    await storage.saveTasks(tasks);
    await storage.saveHistory(history);
    notifyMainIsolate();

    try {
      await WidgetSyncService().syncTodayTasks(tasks);
    } catch (error) {
      debugPrint('[Mongez.Background] widget sync error: $error');
    }
    try {
      await NotificationService()
          .syncFromStorage(storage)
          .timeout(const Duration(seconds: 8));
    } catch (error) {
      debugPrint('[Mongez.Background] notification sync error: $error');
    }
  }

  /// Recomputes the widget data (e.g. after midnight) from storage.
  static Future<void> refreshWidgets() async {
    final storage = LocalStorageService();
    await storage.loadSettings();
    final tasks = await storage.loadTasks();
    await WidgetSyncService().syncTodayTasks(tasks);
  }

  static void notifyMainIsolate() {
    final SendPort? port = IsolateNameServer.lookupPortByName(
      mainIsolatePortName,
    );
    port?.send('refresh');
  }
}
