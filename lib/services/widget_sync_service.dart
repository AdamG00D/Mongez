import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../utils/date_helpers.dart';

class WidgetSyncService {
  static const String _androidProviderName = 'MongezWidgetProvider';

  static const String _titleKey = 'widget_title';
  static const String _subtitleKey = 'widget_subtitle';
  static const String _dateKey = 'widget_date_key';
  static const String _tasksJsonKey = 'widget_tasks_json';

  static String _taskTitleKey(int index) => 'widget_task_${index}_title';
  static String _taskIdKey(int index) => 'widget_task_${index}_id';
  static String _taskDoneKey(int index) => 'widget_task_${index}_done';

  Future<void> syncTodayTasks(List<Task> tasks) async {
    if (!_canUseAndroidWidget) {
      return;
    }

    final today = dateOnly(DateTime.now());
    final visibleTasks =
        tasks.where((Task task) => task.appearsOn(today)).toList()
          ..sort((Task first, Task second) {
            final firstTime = first.timeInMinutes ?? 24 * 60 + 1;
            final secondTime = second.timeInMinutes ?? 24 * 60 + 1;
            if (firstTime != secondTime) {
              return firstTime.compareTo(secondTime);
            }

            return first.createdAt.compareTo(second.createdAt);
          });

    await HomeWidget.saveWidgetData<String>(
      _titleKey,
      '\u0645\u0647\u0627\u0645 \u0627\u0644\u064a\u0648\u0645',
    );
    await HomeWidget.saveWidgetData<String>(
      _subtitleKey,
      '${_formatWidgetDate(today)} \u2022 ${visibleTasks.length} \u0645\u0647\u0645\u0629',
    );
    await HomeWidget.saveWidgetData<String>(_dateKey, dateKey(today));
    await HomeWidget.saveWidgetData<String>(
      _tasksJsonKey,
      jsonEncode(
        visibleTasks
            .map(
              (Task task) => <String, dynamic>{
                'id': task.id,
                'title': task.title,
                'done': task.isCompletedOn(today),
              },
            )
            .toList(),
      ),
    );

    final topThree = visibleTasks.take(3).toList();
    for (var i = 0; i < 3; i++) {
      final keyIndex = i + 1;
      if (i < topThree.length) {
        final task = topThree[i];
        await HomeWidget.saveWidgetData<String>(
          _taskTitleKey(keyIndex),
          task.title,
        );
        await HomeWidget.saveWidgetData<String>(_taskIdKey(keyIndex), task.id);
        await HomeWidget.saveWidgetData<bool>(
          _taskDoneKey(keyIndex),
          task.isCompletedOn(today),
        );
      } else {
        await HomeWidget.saveWidgetData<String>(_taskTitleKey(keyIndex), null);
        await HomeWidget.saveWidgetData<String>(_taskIdKey(keyIndex), null);
        await HomeWidget.saveWidgetData<bool>(_taskDoneKey(keyIndex), null);
      }
    }

    await HomeWidget.updateWidget(androidName: _androidProviderName);
  }

  String _formatWidgetDate(DateTime date) {
    try {
      return DateFormat('d MMMM', 'ar').format(date);
    } catch (_) {
      return DateFormat('yyyy/MM/dd').format(date);
    }
  }

  Future<bool> requestPinWidget() async {
    if (!_canUseAndroidWidget) {
      return false;
    }

    final supported = await HomeWidget.isRequestPinWidgetSupported() ?? false;
    if (!supported) {
      return false;
    }

    await HomeWidget.requestPinWidget(androidName: _androidProviderName);
    return true;
  }

  bool get _canUseAndroidWidget => !kIsWeb && Platform.isAndroid;
}
