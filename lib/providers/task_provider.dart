import 'dart:convert';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/completion_record.dart';
import '../models/task.dart';
import '../models/task_type.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';
import '../services/widget_sync_service.dart';
import '../utils/date_helpers.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider({
    required this.storageService,
    required this.widgetSyncService,
    required this.notificationService,
  });

  final LocalStorageService storageService;
  final WidgetSyncService widgetSyncService;
  final NotificationService notificationService;

  final List<Task> _tasks = <Task>[];
  final List<CompletionRecord> _history = <CompletionRecord>[];

  bool _isLoading = true;
  DateTime _selectedDate = tomorrowDate();

  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;
  bool get isTomorrowSelected => isSameDate(_selectedDate, tomorrowDate());

  UnmodifiableListView<CompletionRecord> get history =>
      UnmodifiableListView<CompletionRecord>(_history);

  List<Task> get tasksForSelectedDate {
    final day = dateOnly(_selectedDate);

    final visibleTasks =
        _tasks.where((Task task) => task.appearsOn(day)).toList()
          ..sort((Task first, Task second) {
            final firstTime = first.timeInMinutes ?? 24 * 60 + 1;
            final secondTime = second.timeInMinutes ?? 24 * 60 + 1;
            if (firstTime != secondTime) {
              return firstTime.compareTo(secondTime);
            }

            return first.createdAt.compareTo(second.createdAt);
          });

    return visibleTasks;
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final loadedTasks = await storageService.loadTasks();
    final loadedHistory = await storageService.loadHistory();

    _tasks
      ..clear()
      ..addAll(loadedTasks);
    _history
      ..clear()
      ..addAll(loadedHistory);

    await _seedDemoDataIfNeeded();

    _sortHistoryDescending();
    _isLoading = false;
    _selectedDate = tomorrowDate();
    notifyListeners();

    await widgetSyncService.syncTodayTasks(_tasks);
    await notificationService.syncTaskNotifications(_tasks);
  }

  void goToPreviousDay() {
    _selectedDate = dateOnly(_selectedDate.subtract(const Duration(days: 1)));
    notifyListeners();
  }

  void goToNextDay() {
    _selectedDate = dateOnly(_selectedDate.add(const Duration(days: 1)));
    notifyListeners();
  }

  void goToTomorrow() {
    _selectedDate = tomorrowDate();
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = dateOnly(date);
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    required DateTime date,
    required TaskType type,
    int? timeInMinutes,
    bool weeklyAnyDay = true,
    Set<int>? weeklyDays,
  }) async {
    final now = DateTime.now();
    final task = Task(
      id: _generateId('task'),
      title: title.trim(),
      type: type,
      scheduledDate: dateOnly(date),
      timeInMinutes: timeInMinutes,
      createdAt: now,
      weeklyAnyDay: type == TaskType.weekly ? weeklyAnyDay : true,
      weeklyDays: type == TaskType.weekly && !weeklyAnyDay
          ? (weeklyDays ?? <int>{})
          : <int>{},
    );

    _tasks.add(task);
    await _saveChanges(syncWidget: true);
  }

  Future<void> updateTask({
    required String taskId,
    required String title,
    required DateTime date,
    required TaskType type,
    int? timeInMinutes,
    bool weeklyAnyDay = true,
    Set<int>? weeklyDays,
  }) async {
    final index = _tasks.indexWhere((Task task) => task.id == taskId);
    if (index == -1) {
      return;
    }

    final current = _tasks[index];
    var updated = current.copyWith(
      title: title.trim(),
      type: type,
      scheduledDate: dateOnly(date),
      timeInMinutes: timeInMinutes,
      removeTime: timeInMinutes == null,
      weeklyAnyDay: type == TaskType.weekly ? weeklyAnyDay : true,
      weeklyDays: type == TaskType.weekly && !weeklyAnyDay
          ? (weeklyDays ?? <int>{})
          : <int>{},
    );

    if (current.type != type) {
      updated = updated.copyWith(
        clearCompletedAt: true,
        completedDays: <String>{},
        completedWeeks: <String>{},
      );
      _history.removeWhere((CompletionRecord item) => item.taskId == taskId);
    }

    _tasks[index] = updated;
    _sortHistoryDescending();
    await _saveChanges(syncWidget: true);
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((Task task) => task.id == taskId);
    _history.removeWhere((CompletionRecord item) => item.taskId == taskId);
    await _saveChanges(syncWidget: true);
  }

  Future<void> toggleTask(Task task, bool isCompleted) async {
    await _toggleTaskForDate(
      taskId: task.id,
      day: _selectedDate,
      forceValue: isCompleted,
    );
  }

  Future<void> toggleTaskByIdForDate({
    required String taskId,
    required DateTime day,
    bool? forceValue,
  }) async {
    await _toggleTaskForDate(taskId: taskId, day: day, forceValue: forceValue);
  }

  Future<void> _toggleTaskForDate({
    required String taskId,
    required DateTime day,
    bool? forceValue,
  }) async {
    final taskIndex = _tasks.indexWhere((Task element) => element.id == taskId);
    if (taskIndex == -1) {
      return;
    }

    final activeDay = dateOnly(day);
    final currentTask = _tasks[taskIndex];
    if (!currentTask.appearsOn(activeDay)) {
      return;
    }

    final isCompleted = forceValue ?? !currentTask.isCompletedOn(activeDay);
    final updatedTask = currentTask.toggleCompletionForDay(
      activeDay,
      isCompleted,
    );
    _tasks[taskIndex] = updatedTask;

    final completionDay = updatedTask.isNormal
        ? dateOnly(updatedTask.scheduledDate)
        : activeDay;
    final recordId = _historyId(updatedTask, activeDay);

    if (isCompleted) {
      final record = CompletionRecord(
        id: recordId,
        taskId: updatedTask.id,
        taskTitle: updatedTask.title,
        taskType: updatedTask.type,
        completedAt: DateTime.now(),
        completedForDate: completionDay,
        taskTimeInMinutes: updatedTask.timeInMinutes,
      );

      final recordIndex = _history.indexWhere(
        (CompletionRecord item) => item.id == recordId,
      );
      if (recordIndex == -1) {
        _history.add(record);
      } else {
        _history[recordIndex] = record;
      }
    } else {
      _history.removeWhere((CompletionRecord item) => item.id == recordId);
    }

    _sortHistoryDescending();
    await _saveChanges(syncWidget: true);
  }

  Future<void> refreshWidget() async {
    await widgetSyncService.syncTodayTasks(_tasks);
  }

  Future<void> reloadFromStorageIfChanged() async {
    final loadedTasks = await storageService.loadTasks();
    final loadedHistory = await storageService.loadHistory();

    final tasksChanged =
        _fingerprintTasks(loadedTasks) != _fingerprintTasks(_tasks);
    final historyChanged =
        _fingerprintHistory(loadedHistory) != _fingerprintHistory(_history);
    if (!tasksChanged && !historyChanged) {
      return;
    }

    _tasks
      ..clear()
      ..addAll(loadedTasks);
    _history
      ..clear()
      ..addAll(loadedHistory);
    _sortHistoryDescending();
    notifyListeners();
  }

  Future<void> requestNotificationPermissions() async {
    await notificationService.requestPermissions();
    await notificationService.syncTaskNotifications(_tasks);
  }

  Future<bool> requestPinWidget() {
    return widgetSyncService.requestPinWidget();
  }

  Future<void> _saveChanges({required bool syncWidget}) async {
    notifyListeners();
    await storageService.saveTasks(_tasks);
    await storageService.saveHistory(_history);
    await notificationService.syncTaskNotifications(_tasks);
    if (syncWidget) {
      await widgetSyncService.syncTodayTasks(_tasks);
    }
  }

  Future<void> _seedDemoDataIfNeeded() async {
    final hasSeeded = await storageService.hasSeededDemoData();
    if (hasSeeded || _tasks.isNotEmpty || _history.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    final today = dateOnly(now);
    final tomorrow = tomorrowDate();

    _tasks.addAll(<Task>[
      Task(
        id: _generateId('task'),
        title: 'تخطيط أولويات الغد',
        type: TaskType.normal,
        scheduledDate: tomorrow,
        timeInMinutes: 21 * 60 + 30,
        createdAt: now,
      ),
      Task(
        id: _generateId('task'),
        title: 'شرب الماء 8 أكواب',
        type: TaskType.daily,
        scheduledDate: today,
        createdAt: now,
      ),
      Task(
        id: _generateId('task'),
        title: 'تمارين خفيفة',
        type: TaskType.weekly,
        scheduledDate: today,
        weeklyAnyDay: false,
        weeklyDays: <int>{
          DateTime.saturday,
          DateTime.monday,
          DateTime.wednesday,
        },
        createdAt: now,
      ),
    ]);

    await storageService.setDemoSeeded();
    await storageService.saveTasks(_tasks);
    await notificationService.syncTaskNotifications(_tasks);
  }

  void _sortHistoryDescending() {
    _history.sort(
      (CompletionRecord first, CompletionRecord second) =>
          second.completedAt.compareTo(first.completedAt),
    );
  }

  String _historyId(Task task, DateTime day) {
    if (task.isWeekly) {
      return '${task.id}-${weekKey(day)}';
    }
    if (task.isDaily) {
      return '${task.id}-${dateKey(day)}';
    }
    return '${task.id}-${dateKey(task.scheduledDate)}';
  }

  String _generateId(String prefix) {
    final stamp = DateTime.now().microsecondsSinceEpoch;
    return '$prefix-$stamp-${_tasks.length + _history.length}';
  }

  String _fingerprintTasks(List<Task> tasks) {
    return tasks.map((Task task) => jsonEncode(task.toJson())).join('||');
  }

  String _fingerprintHistory(List<CompletionRecord> history) {
    return history
        .map((CompletionRecord item) => jsonEncode(item.toJson()))
        .join('||');
  }
}
