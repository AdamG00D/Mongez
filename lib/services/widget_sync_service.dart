import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../l10n/l10n.dart';
import '../models/task.dart';
import '../models/task_type.dart';
import '../utils/date_helpers.dart';
import '../utils/motivation.dart';
import 'task_mutations.dart';

class WidgetSyncService {
  static const String listProviderName = 'MongezWidgetProvider';
  static const String summaryProviderName = 'MongezSummaryWidgetProvider';

  Future<void> syncTodayTasks(List<Task> tasks) async {
    if (!_canUseAndroidWidget) {
      return;
    }

    final today = todayDate();
    final visibleTasks = TaskMutations.tasksForDay(tasks, today);
    final done = visibleTasks
        .where((Task task) => task.isCompletedOn(today))
        .length;
    final total = visibleTasks.length;
    final progress = total == 0 ? 0 : ((done / total) * 100).round();

    Task? next;
    for (final task in visibleTasks) {
      if (!task.isCompletedOn(today)) {
        next = task;
        break;
      }
    }

    final l10n = L10n.current;
    final data = <String, Object?>{
      // Texts are written in the app language so the widget follows it even
      // when it differs from the device language.
      'widget_rtl': L10n.isArabic ? 1 : 0,
      'widget_title': l10n.widgetTitle,
      'widget_subtitle': formatWeekdayDayMonth(today),
      'widget_date_key': dateKey(today),
      'widget_done_count': done,
      'widget_total_count': total,
      'widget_progress': progress,
      'widget_counter': total == 0 ? l10n.widgetNoTasks : '$done/$total',
      'widget_summary_counter': total == 0
          ? l10n.widgetNoTasksToday
          : l10n.widgetDoneOf(done, total),
      'widget_next_label': l10n.widgetNext,
      'widget_empty_text': l10n.widgetEmptyList,
      'widget_add_label': l10n.widgetAddTask,
      'widget_message': progressMessage(done, total),
      'widget_next_title':
          next?.title ??
          (total == 0 ? l10n.widgetEmptyDay : l10n.widgetAllDone),
      'widget_next_time': next?.timeInMinutes == null
          ? ''
          : formatMinutesOfDay(next!.timeInMinutes!),
      'widget_tasks_json': jsonEncode(
        visibleTasks
            .map(
              (Task task) => <String, dynamic>{
                'id': task.id,
                'title': task.title,
                'done': task.isCompletedOn(today),
                'time': task.timeInMinutes == null
                    ? ''
                    : formatMinutesOfDay(task.timeInMinutes!),
                'priority': task.priority.index,
                'type': task.type.storageValue,
              },
            )
            .toList(),
      ),
    };

    for (final entry in data.entries) {
      final value = entry.value;
      if (value is int) {
        await HomeWidget.saveWidgetData<int>(entry.key, value);
      } else {
        await HomeWidget.saveWidgetData<String>(entry.key, value as String?);
      }
    }

    await HomeWidget.updateWidget(androidName: listProviderName);
    await HomeWidget.updateWidget(androidName: summaryProviderName);
  }

  Future<bool> requestPinWidget({bool summary = false}) async {
    if (!_canUseAndroidWidget) {
      return false;
    }

    final supported = await HomeWidget.isRequestPinWidgetSupported() ?? false;
    if (!supported) {
      return false;
    }

    await HomeWidget.requestPinWidget(
      androidName: summary ? summaryProviderName : listProviderName,
    );
    return true;
  }

  bool get _canUseAndroidWidget => !kIsWeb && Platform.isAndroid;
}
