import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/app_settings.dart';
import '../models/completion_record.dart';
import '../models/goal.dart';
import '../models/task.dart';
import '../models/task_type.dart';
import '../services/backup_service.dart';
import '../services/local_storage_service.dart';
import '../services/task_mutations.dart';
import '../services/widget_sync_service.dart';
import '../utils/date_helpers.dart';

class TypeCounts {
  const TypeCounts({
    required this.normal,
    required this.daily,
    required this.weekly,
  });

  final int normal;
  final int daily;
  final int weekly;

  int get total => normal + daily + weekly;

  int of(TaskType type) => switch (type) {
    TaskType.normal => normal,
    TaskType.daily => daily,
    TaskType.weekly => weekly,
  };
}

class TaskStat {
  const TaskStat(this.title, this.type, this.count);

  final String title;
  final TaskType type;
  final int count;
}

class TaskProvider extends ChangeNotifier {
  TaskProvider({required this.storageService, required this.widgetSyncService});

  final LocalStorageService storageService;
  final WidgetSyncService widgetSyncService;

  /// Fired after any change that affects reminders.
  VoidCallback? onDataChanged;

  final List<Task> _tasks = <Task>[];
  final List<CompletionRecord> _history = <CompletionRecord>[];

  bool _isLoading = true;
  DateTime _selectedDate = todayDate();

  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;
  bool get isTodaySelected => isSameDate(_selectedDate, todayDate());
  bool get isTomorrowSelected => isSameDate(_selectedDate, tomorrowDate());

  List<Task> get allTasks => List<Task>.unmodifiable(_tasks);

  UnmodifiableListView<CompletionRecord> get history =>
      UnmodifiableListView<CompletionRecord>(_history);

  List<Task> get tasksForSelectedDate =>
      TaskMutations.tasksForDay(_tasks, _selectedDate);

  List<Task> tasksForDay(DateTime day) =>
      TaskMutations.tasksForDay(_tasks, day);

  Future<void> initialize({StartPage startPage = StartPage.auto}) async {
    _isLoading = true;
    notifyListeners();

    _tasks
      ..clear()
      ..addAll(await storageService.loadTasks());
    _history
      ..clear()
      ..addAll(await storageService.loadHistory());

    await _seedDemoDataIfNeeded();
    if (_ensureSortOrder()) {
      await storageService.saveTasks(_tasks);
    }

    TaskMutations.sortHistory(_history);
    _selectedDate = _initialDate(startPage);
    _isLoading = false;
    notifyListeners();

    await widgetSyncService.syncTodayTasks(_tasks);
    onDataChanged?.call();
  }

  DateTime _initialDate(StartPage startPage) {
    return switch (startPage) {
      StartPage.today => todayDate(),
      StartPage.tomorrow => tomorrowDate(),
      // Plan tomorrow in the evening, focus on today otherwise.
      StartPage.auto =>
        DateTime.now().hour >= 19 ? tomorrowDate() : todayDate(),
    };
  }

  /// Gives legacy tasks a manual order matching their old time-based order.
  bool _ensureSortOrder() {
    final missing = _tasks
        .where((Task task) => task.sortOrder == null)
        .toList();
    if (missing.isEmpty) {
      return false;
    }
    missing.sort(compareTasksByTime);
    var next = _nextSortOrder();
    for (final task in missing) {
      final index = _tasks.indexWhere((Task t) => t.id == task.id);
      _tasks[index] = task.copyWith(sortOrder: next++);
    }
    return true;
  }

  int _nextSortOrder() {
    var max = -1;
    for (final task in _tasks) {
      final order = task.sortOrder;
      if (order != null && order > max) {
        max = order;
      }
    }
    return max + 1;
  }

  // ---------------------------------------------------------------- navigation

  void goToPreviousDay() => setSelectedDate(addDays(_selectedDate, -1));

  void goToNextDay() => setSelectedDate(addDays(_selectedDate, 1));

  void goToToday() => setSelectedDate(todayDate());

  void goToTomorrow() => setSelectedDate(tomorrowDate());

  void setSelectedDate(DateTime date) {
    _selectedDate = dateOnly(date);
    notifyListeners();
  }

  // --------------------------------------------------------------------- CRUD

  Future<void> addTask({
    required String title,
    required DateTime date,
    required TaskType type,
    int? timeInMinutes,
    bool weeklyAnyDay = true,
    Set<int>? weeklyDays,
    int? weekStartDay,
    WeeklyReminderMode weeklyReminder = WeeklyReminderMode.everyDayUntilDone,
    TaskPriority priority = TaskPriority.none,
    String? note,
  }) async {
    final task = Task(
      id: _generateId('task'),
      title: title.trim(),
      type: type,
      scheduledDate: dateOnly(date),
      timeInMinutes: timeInMinutes,
      createdAt: DateTime.now(),
      weeklyAnyDay: type == TaskType.weekly ? weeklyAnyDay : true,
      weeklyDays: type == TaskType.weekly && !weeklyAnyDay
          ? (weeklyDays ?? <int>{})
          : <int>{},
      weekStartDay: type == TaskType.weekly ? weekStartDay : null,
      weeklyReminder: weeklyReminder,
      sortOrder: _nextSortOrder(),
      priority: priority,
      note: _cleanNote(note),
    );

    _tasks.add(task);
    await _saveChanges();
  }

  Future<void> updateTask({
    required String taskId,
    required String title,
    required DateTime date,
    required TaskType type,
    int? timeInMinutes,
    bool weeklyAnyDay = true,
    Set<int>? weeklyDays,
    int? weekStartDay,
    WeeklyReminderMode weeklyReminder = WeeklyReminderMode.everyDayUntilDone,
    TaskPriority priority = TaskPriority.none,
    String? note,
  }) async {
    final index = _tasks.indexWhere((Task task) => task.id == taskId);
    if (index == -1) {
      return;
    }

    final current = _tasks[index];
    final cleanNote = _cleanNote(note);
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
      weekStartDay: type == TaskType.weekly ? weekStartDay : null,
      clearWeekStartDay: type != TaskType.weekly || weekStartDay == null,
      weeklyReminder: weeklyReminder,
      priority: priority,
      note: cleanNote,
      clearNote: cleanNote == null,
    );

    if (current.type != type) {
      // Completion state is type-specific; history stays untouched.
      updated = updated.copyWith(
        clearCompletedAt: true,
        completedDays: <String>{},
        completedWeeks: <String>{},
      );
    }

    _tasks[index] = updated;
    await _saveChanges();
  }

  /// Deletes the task. Its history records are kept (completions on earlier
  /// days stay counted) unless they are removed explicitly with
  /// [deleteHistoryForTask]. Returns the removed task so the UI can offer
  /// "undo".
  Future<Task?> deleteTask(String taskId) async {
    final index = _tasks.indexWhere((Task task) => task.id == taskId);
    if (index == -1) {
      return null;
    }
    final removed = _tasks.removeAt(index);
    await _saveChanges();
    return removed;
  }

  // ------------------------------------------------------------------ history

  /// Number of history records that belong to [taskId].
  int historyCountForTask(String taskId) =>
      _history.where((CompletionRecord r) => r.taskId == taskId).length;

  /// Removes one record from the history. The task itself (and whether it is
  /// checked) is not touched. Returns the removed records for "undo".
  Future<List<CompletionRecord>> deleteHistoryRecord(String recordId) =>
      _deleteHistoryWhere((CompletionRecord r) => r.id == recordId);

  /// Removes every history record of [taskId].
  Future<List<CompletionRecord>> deleteHistoryForTask(String taskId) =>
      _deleteHistoryWhere((CompletionRecord r) => r.taskId == taskId);

  /// Empties the whole history.
  Future<List<CompletionRecord>> clearHistory() =>
      _deleteHistoryWhere((CompletionRecord r) => true);

  Future<List<CompletionRecord>> _deleteHistoryWhere(
    bool Function(CompletionRecord record) test,
  ) async {
    final removed = _history.where(test).toList();
    if (removed.isEmpty) {
      return removed;
    }
    _history.removeWhere(test);
    await _saveChanges(remindersAffected: false);
    return removed;
  }

  /// Puts back records removed by one of the delete methods above.
  Future<void> restoreHistory(List<CompletionRecord> records) async {
    final ids = _history.map((CompletionRecord r) => r.id).toSet();
    var added = false;
    for (final record in records) {
      if (ids.add(record.id)) {
        _history.add(record);
        added = true;
      }
    }
    if (!added) {
      return;
    }
    TaskMutations.sortHistory(_history);
    await _saveChanges(remindersAffected: false);
  }

  Future<void> restoreTask(Task task) async {
    if (_tasks.any((Task t) => t.id == task.id)) {
      return;
    }
    _tasks.add(task);
    await _saveChanges();
  }

  /// Moves a one-off task to another day (default: the day after).
  Future<void> postponeTask(String taskId, {int days = 1}) async {
    final index = _tasks.indexWhere((Task task) => task.id == taskId);
    if (index == -1 || !_tasks[index].isNormal) {
      return;
    }
    final task = _tasks[index];
    _tasks[index] = task.copyWith(
      scheduledDate: addDays(task.scheduledDate, days),
      clearCompletedAt: true,
    );
    await _saveChanges();
  }

  /// Where [carryOverUnfinished] moves tasks: the day after [day], but never
  /// into the past (carrying from an old day lands on today).
  static DateTime carryTarget(DateTime day) {
    final next = addDays(dateOnly(day), 1);
    final today = todayDate();
    return next.isBefore(today) ? today : next;
  }

  /// Moves every unfinished one-off task of [day] to [carryTarget].
  /// Daily and weekly tasks repeat by themselves, so they are not moved.
  Future<int> carryOverUnfinished(DateTime day) async {
    final target = carryTarget(day);
    var moved = 0;
    for (var i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      if (task.isNormal && task.appearsOn(day) && !task.isCompletedOn(day)) {
        _tasks[i] = task.copyWith(scheduledDate: target);
        moved++;
      }
    }
    if (moved > 0) {
      await _saveChanges();
    }
    return moved;
  }

  Future<void> duplicateTaskTo(String taskId, DateTime day) async {
    final index = _tasks.indexWhere((Task task) => task.id == taskId);
    if (index == -1) {
      return;
    }
    final source = _tasks[index];
    await addTask(
      title: source.title,
      date: day,
      type: TaskType.normal,
      timeInMinutes: source.timeInMinutes,
      priority: source.priority,
      note: source.note,
    );
  }

  // ------------------------------------------------------------- completion

  Future<void> toggleTask(Task task, bool isCompleted) {
    return toggleTaskByIdForDate(
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
    final updated = TaskMutations.toggle(
      tasks: _tasks,
      history: _history,
      taskId: taskId,
      day: day,
      forceValue: forceValue,
    );
    if (updated == null) {
      return;
    }
    await _saveChanges();
  }

  // ---------------------------------------------------------------- ordering

  /// Reorders the visible tasks of the selected day. Hidden tasks (other days)
  /// keep their relative positions.
  Future<void> reorderVisible(
    List<Task> visible,
    int oldIndex,
    int newIndex,
  ) async {
    if (oldIndex == newIndex || visible.isEmpty) {
      return;
    }
    final reordered = List<Task>.of(visible);
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex.clamp(0, reordered.length), moved);
    await _applyVisibleOrder(reordered);
  }

  Future<void> sortSelectedDayByTime() async {
    final visible = tasksForSelectedDate..sort(compareTasksByTime);
    await _applyVisibleOrder(visible);
  }

  Future<void> sortSelectedDayByPriority() async {
    final visible = tasksForSelectedDate
      ..sort((Task a, Task b) {
        final byPriority = b.priority.index.compareTo(a.priority.index);
        return byPriority != 0 ? byPriority : compareTasksByTime(a, b);
      });
    await _applyVisibleOrder(visible);
  }

  Future<void> _applyVisibleOrder(List<Task> reorderedVisible) async {
    final all = List<Task>.of(_tasks)..sort(compareTasksForDisplay);
    final visibleIds = reorderedVisible.map((Task t) => t.id).toSet();
    final slots = <int>[];
    for (var i = 0; i < all.length; i++) {
      if (visibleIds.contains(all[i].id)) {
        slots.add(i);
      }
    }
    for (var i = 0; i < slots.length && i < reorderedVisible.length; i++) {
      all[slots[i]] = reorderedVisible[i];
    }
    final orderById = <String, int>{
      for (var i = 0; i < all.length; i++) all[i].id: i,
    };
    for (var i = 0; i < _tasks.length; i++) {
      _tasks[i] = _tasks[i].copyWith(sortOrder: orderById[_tasks[i].id]);
    }
    await _saveChanges(remindersAffected: false);
  }

  // -------------------------------------------------------------------- stats

  TypeCounts get completionCounts {
    var normal = 0;
    var daily = 0;
    var weekly = 0;
    for (final record in _history) {
      switch (record.taskType) {
        case TaskType.normal:
          normal++;
        case TaskType.daily:
          daily++;
        case TaskType.weekly:
          weekly++;
      }
    }
    return TypeCounts(normal: normal, daily: daily, weekly: weekly);
  }

  Set<String> get _activeDayKeys => _history
      .map((CompletionRecord record) => dateKey(record.completedAt))
      .toSet();

  int get currentStreak {
    final days = _activeDayKeys;
    var cursor = todayDate();
    if (!days.contains(dateKey(cursor))) {
      cursor = addDays(cursor, -1);
    }
    var streak = 0;
    while (days.contains(dateKey(cursor))) {
      streak++;
      cursor = addDays(cursor, -1);
    }
    return streak;
  }

  int get bestStreak {
    final days = _activeDayKeys.map(dateFromKey).toList()..sort();
    var best = 0;
    var run = 0;
    DateTime? previous;
    for (final day in days) {
      if (previous != null && isSameDate(addDays(previous, 1), day)) {
        run++;
      } else {
        run = 1;
      }
      if (run > best) {
        best = run;
      }
      previous = day;
    }
    return best;
  }

  /// Completions per day for the last [days] days (oldest first).
  List<int> completionsPerDay(int days) {
    final today = todayDate();
    final counts = <String, int>{};
    for (final record in _history) {
      final key = dateKey(record.completedAt);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return List<int>.generate(
      days,
      (int i) => counts[dateKey(addDays(today, i - days + 1))] ?? 0,
    );
  }

  int completionsSince(DateTime since) => _history
      .where((CompletionRecord record) => !record.completedAt.isBefore(since))
      .length;

  List<TaskStat> topTasks({int limit = 5}) {
    final counts = <String, TaskStat>{};
    for (final record in _history) {
      final key = '${record.taskTitle}|${record.taskType.storageValue}';
      final current = counts[key];
      counts[key] = TaskStat(
        record.taskTitle,
        record.taskType,
        (current?.count ?? 0) + 1,
      );
    }
    final list = counts.values.toList()
      ..sort((TaskStat a, TaskStat b) => b.count.compareTo(a.count));
    return list.take(limit).toList();
  }

  // -------------------------------------------------------------- sync & io

  Future<void> refreshWidget() => widgetSyncService.syncTodayTasks(_tasks);

  Future<bool> requestPinWidget({bool summary = false}) =>
      widgetSyncService.requestPinWidget(summary: summary);

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
    TaskMutations.sortHistory(_history);
    notifyListeners();
  }

  /// Called after the week-start setting changes.
  Future<void> onWeekStartChanged() async {
    notifyListeners();
    await widgetSyncService.syncTodayTasks(_tasks);
  }

  BackupData backupData(List<Goal> goals) => BackupData(
    tasks: List<Task>.of(_tasks),
    history: List<CompletionRecord>.of(_history),
    goals: goals,
  );

  /// Replaces tasks with the backup's tasks. History is merged (never lost).
  Future<void> importBackup(BackupData data) async {
    _tasks
      ..clear()
      ..addAll(data.tasks);
    _ensureSortOrder();
    final ids = _history.map((CompletionRecord r) => r.id).toSet();
    for (final record in data.history) {
      if (!ids.contains(record.id)) {
        _history.add(record);
      }
    }
    TaskMutations.sortHistory(_history);
    await _saveChanges();
  }

  Future<void> _saveChanges({bool remindersAffected = true}) async {
    notifyListeners();
    await storageService.saveTasks(_tasks);
    await storageService.saveHistory(_history);
    await widgetSyncService.syncTodayTasks(_tasks);
    if (remindersAffected) {
      onDataChanged?.call();
    }
  }

  String? _cleanNote(String? note) {
    final trimmed = note?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  Future<void> _seedDemoDataIfNeeded() async {
    final hasSeeded = await storageService.hasSeededDemoData();
    if (hasSeeded || _tasks.isNotEmpty || _history.isNotEmpty) {
      return;
    }

    final now = DateTime.now();
    final today = todayDate();

    _tasks.addAll(<Task>[
      Task(
        id: _generateId('task'),
        title: 'تخطيط أولويات الغد',
        type: TaskType.daily,
        scheduledDate: today,
        timeInMinutes: 21 * 60 + 30,
        createdAt: now,
        sortOrder: 0,
        priority: TaskPriority.medium,
      ),
      Task(
        id: _generateId('task'),
        title: 'شرب 8 أكواب ماء',
        type: TaskType.daily,
        scheduledDate: today,
        createdAt: now,
        sortOrder: 1,
      ),
      Task(
        id: _generateId('task'),
        title: 'تمارين خفيفة 20 دقيقة',
        type: TaskType.weekly,
        scheduledDate: today,
        weeklyAnyDay: false,
        weeklyDays: <int>{
          DateTime.saturday,
          DateTime.monday,
          DateTime.wednesday,
        },
        createdAt: now,
        sortOrder: 2,
      ),
    ]);

    await storageService.setDemoSeeded();
    await storageService.saveTasks(_tasks);
  }

  int _idCounter = 0;

  String _generateId(String prefix) {
    final stamp = DateTime.now().microsecondsSinceEpoch;
    return '$prefix-$stamp-${_idCounter++}';
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
