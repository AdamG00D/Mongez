import 'package:flutter/foundation.dart';

import '../models/completion_record.dart';
import '../models/task.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';
import '../services/widget_sync_service.dart';
import '../utils/date_helpers.dart';

class WidgetBackgroundHandler {
  static Future<void> handle(Uri uri) async {
    final today = dateOnly(DateTime.now());
    final fallbackQuery = _extractRawQuery(uri);
    final action = _resolveAction(uri, fallbackQuery);

    var taskId = uri.queryParameters['taskId'] ?? fallbackQuery['taskId'];
    var date = uri.queryParameters['date'] ?? fallbackQuery['date'];
    taskId = _normalizeNullable(taskId);
    date = _normalizeNullable(date);

    if (taskId == null || date == null) {
      final nestedRaw = uri.queryParameters['uri'] ?? fallbackQuery['uri'];
      if (nestedRaw != null && nestedRaw.isNotEmpty) {
        final nestedQuery = _extractNestedQuery(nestedRaw);
        taskId ??= _normalizeNullable(nestedQuery['taskId']);
        date ??= _normalizeNullable(nestedQuery['date']);
      }
    }

    if (taskId == null || date == null) {
      final fromRegex = _extractByPattern(uri.toString());
      taskId ??= _normalizeNullable(fromRegex['taskId']);
      date ??= _normalizeNullable(fromRegex['date']);
    }

    final hasTogglePayload = taskId != null && date != null;
    if (action != 'toggle' && !hasTogglePayload) {
      return;
    }

    if (taskId == null) {
      return;
    }

    final selectedDay = _safeDateFromKey(date) ?? today;
    final storageService = LocalStorageService();
    final widgetSyncService = WidgetSyncService();
    final notificationService = NotificationService();

    final tasks = await storageService.loadTasks();
    final history = await storageService.loadHistory();

    final index = tasks.indexWhere((Task task) => task.id == taskId);
    if (index == -1) {
      return;
    }

    final task = tasks[index];
    var activeDay = selectedDay;
    if (!task.appearsOn(activeDay) && task.appearsOn(today)) {
      activeDay = today;
    }
    if (!task.appearsOn(activeDay)) {
      return;
    }

    final shouldComplete = !task.isCompletedOn(activeDay);
    final updatedTask = task.toggleCompletionForDay(activeDay, shouldComplete);
    tasks[index] = updatedTask;

    final recordId = _historyId(updatedTask, activeDay);
    if (shouldComplete) {
      final record = CompletionRecord(
        id: recordId,
        taskId: updatedTask.id,
        taskTitle: updatedTask.title,
        taskType: updatedTask.type,
        completedAt: DateTime.now(),
        completedForDate: updatedTask.isNormal
            ? dateOnly(updatedTask.scheduledDate)
            : dateOnly(activeDay),
        taskTimeInMinutes: updatedTask.timeInMinutes,
      );

      final oldIndex = history.indexWhere(
        (CompletionRecord item) => item.id == recordId,
      );
      if (oldIndex == -1) {
        history.add(record);
      } else {
        history[oldIndex] = record;
      }
    } else {
      history.removeWhere((CompletionRecord item) => item.id == recordId);
    }

    history.sort(
      (CompletionRecord first, CompletionRecord second) =>
          second.completedAt.compareTo(first.completedAt),
    );

    await storageService.saveTasks(tasks);
    await storageService.saveHistory(history);
    try {
      await widgetSyncService.syncTodayTasks(tasks);
    } catch (error, stackTrace) {
      debugPrint('[Mongez.Widget] widget sync error: $error');
      debugPrint(stackTrace.toString());
    }
    try {
      await notificationService
          .syncTaskNotificationsAfterWidgetToggle(updatedTask)
          .timeout(const Duration(seconds: 2));
    } catch (error, stackTrace) {
      debugPrint('[Mongez.Widget] notification sync error: $error');
      debugPrint(stackTrace.toString());
    }
  }

  static String _historyId(Task task, DateTime day) {
    if (task.isWeekly) {
      return '${task.id}-${weekKey(day)}';
    }
    if (task.isDaily) {
      return '${task.id}-${dateKey(day)}';
    }
    return '${task.id}-${dateKey(task.scheduledDate)}';
  }

  static Map<String, String> _extractRawQuery(Uri uri) {
    final uriString = uri.toString();
    final questionMarkIndex = uriString.indexOf('?');
    if (questionMarkIndex == -1 || questionMarkIndex == uriString.length - 1) {
      return const <String, String>{};
    }

    final query = uriString.substring(questionMarkIndex + 1);
    try {
      return Uri.splitQueryString(query);
    } catch (_) {
      return const <String, String>{};
    }
  }

  static String _resolveAction(Uri uri, Map<String, String> fallbackQuery) {
    final queryAction =
        uri.queryParameters['action'] ?? fallbackQuery['action'];
    if (queryAction != null && queryAction.isNotEmpty) {
      return queryAction;
    }

    if (uri.host.isNotEmpty) {
      return uri.host;
    }

    if (uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }

    return '';
  }

  static Map<String, String> _extractNestedQuery(String rawUri) {
    try {
      final nestedUri = Uri.parse(Uri.decodeComponent(rawUri));
      final query = <String, String>{
        ...nestedUri.queryParameters,
        ..._extractRawQuery(nestedUri),
      };
      return query;
    } catch (_) {
      return const <String, String>{};
    }
  }

  static Map<String, String> _extractByPattern(String raw) {
    final taskMatch = RegExp(r'taskId=([^&;]+)').firstMatch(raw);
    final dateMatch = RegExp(
      r'date=([0-9]{4}-[0-9]{2}-[0-9]{2})',
    ).firstMatch(raw);

    String? decode(String? value) {
      if (value == null || value.isEmpty) {
        return null;
      }
      try {
        return Uri.decodeComponent(value);
      } catch (_) {
        return value;
      }
    }

    final taskId = decode(taskMatch?.group(1));
    final date = decode(dateMatch?.group(1));
    if (taskId == null && date == null) {
      return const <String, String>{};
    }

    return <String, String>{
      ...?(taskId == null ? null : <String, String>{'taskId': taskId}),
      ...?(date == null ? null : <String, String>{'date': date}),
    };
  }

  static String? _normalizeNullable(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  static DateTime? _safeDateFromKey(String? value) {
    if (value == null) {
      return null;
    }
    try {
      return dateFromKey(value);
    } catch (_) {
      return null;
    }
  }
}
