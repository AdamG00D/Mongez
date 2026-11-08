import 'package:flutter_test/flutter_test.dart';
import 'package:mongez/models/app_settings.dart';
import 'package:mongez/models/completion_record.dart';
import 'package:mongez/models/goal.dart';
import 'package:mongez/models/task.dart';
import 'package:mongez/models/task_type.dart';
import 'package:mongez/providers/goals_provider.dart';
import 'package:mongez/providers/task_provider.dart';
import 'package:mongez/services/backup_service.dart';
import 'package:mongez/services/local_storage_service.dart';
import 'package:mongez/services/notification_service.dart';
import 'package:mongez/services/task_mutations.dart';
import 'package:mongez/services/widget_sync_service.dart';
import 'package:mongez/utils/date_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 2026-11-07 is a Saturday.
final DateTime sat = DateTime(2026, 11, 7);
final DateTime fri = DateTime(2026, 11, 13);
final DateTime mon = DateTime(2026, 11, 9);

Task weekly({
  int? weekStart,
  bool anyDay = true,
  Set<int> days = const <int>{},
  Set<String> completed = const <String>{},
  WeeklyReminderMode mode = WeeklyReminderMode.everyDayUntilDone,
  int? time,
}) {
  return Task(
    id: 'w1',
    title: 'weekly',
    type: TaskType.weekly,
    scheduledDate: DateTime(2026, 11, 1),
    createdAt: DateTime(2026, 11, 1),
    weeklyAnyDay: anyDay,
    weeklyDays: days,
    weekStartDay: weekStart,
    completedWeeks: completed,
    weeklyReminder: mode,
    timeInMinutes: time,
  );
}

void main() {
  setUp(() => WeekSettings.defaultStartDay = DateTime.saturday);

  group('week helpers', () {
    test('startOfWeek honours the configured first day', () {
      expect(startOfWeek(fri, DateTime.saturday), sat);
      expect(startOfWeek(sat, DateTime.saturday), sat);
      expect(startOfWeek(sat, DateTime.sunday), DateTime(2026, 11, 1));
      expect(startOfWeek(sat, DateTime.monday), DateTime(2026, 11, 2));
      expect(endOfWeek(sat, DateTime.saturday), fri);
    });

    test('weekDaysOrdered starts from the chosen day', () {
      expect(weekDaysOrdered(DateTime.saturday).first, DateTime.saturday);
      expect(weekDaysOrdered(DateTime.saturday).last, DateTime.friday);
      expect(weekDaysOrdered(DateTime.monday).last, DateTime.sunday);
    });

    test('dateFromKey accepts legacy W- keys', () {
      expect(dateFromKey('W-2026-11-02'), DateTime(2026, 11, 2));
      expect(dateKey(dateFromKey('2026-03-21')), '2026-03-21');
    });

    test('addDays is DST safe (calendar days)', () {
      expect(addDays(DateTime(2026, 3, 28), 2), DateTime(2026, 3, 30));
    });
  });

  group('weekly tasks', () {
    test('completion covers the whole configured week', () {
      final task = weekly().toggleCompletionForDay(mon, true);
      expect(task.isCompletedOn(sat), isTrue);
      expect(task.isCompletedOn(fri), isTrue);
      expect(task.isCompletedOn(addDays(fri, 1)), isFalse); // next Saturday
      expect(task.isCompletedOn(addDays(sat, -1)), isFalse);
    });

    test('per-task week start overrides the global one', () {
      // Week starts Monday: Sat 7th and Mon 9th are in different weeks.
      final task = weekly(
        weekStart: DateTime.monday,
      ).toggleCompletionForDay(mon, true);
      expect(task.isCompletedOn(sat), isFalse);
      expect(task.isCompletedOn(DateTime(2026, 11, 15)), isTrue); // Sunday
    });

    test('un-checking clears every completion of that week only', () {
      var task = weekly(
        completed: <String>{'2026-11-03', '2026-11-08'},
      ); // previous week (Tue) + this week (Sun)
      task = task.toggleCompletionForDay(fri, false);
      expect(task.completedWeeks, <String>{'2026-11-03'});
    });

    test('legacy Monday-based keys are still honoured', () {
      final task = weekly(completed: <String>{'W-2026-11-09'});
      expect(task.isCompletedOn(fri), isTrue);
    });

    test('appearsOn respects selected days and scheduled date', () {
      final task = weekly(
        anyDay: false,
        days: <int>{DateTime.monday, DateTime.wednesday},
      );
      expect(task.appearsOn(mon), isTrue);
      expect(task.appearsOn(sat), isFalse);
      expect(task.appearsOn(DateTime(2026, 10, 26)), isFalse); // before start
    });
  });

  group('weekly reminder modes', () {
    test('everyDayUntilDone reminds every visible day', () {
      final task = weekly(time: 600);
      expect(NotificationService.shouldRemindOn(task, sat), isTrue);
      expect(NotificationService.shouldRemindOn(task, mon), isTrue);
    });

    test('lastDay reminds only on the last available day of the week', () {
      final any = weekly(time: 600, mode: WeeklyReminderMode.lastDay);
      expect(NotificationService.shouldRemindOn(any, fri), isTrue);
      expect(NotificationService.shouldRemindOn(any, mon), isFalse);

      final specific = weekly(
        time: 600,
        mode: WeeklyReminderMode.lastDay,
        anyDay: false,
        days: <int>{DateTime.monday, DateTime.wednesday},
      );
      expect(
        NotificationService.shouldRemindOn(specific, DateTime(2026, 11, 11)),
        isTrue,
      );
      expect(NotificationService.shouldRemindOn(specific, mon), isFalse);
    });

    test('onDays with "any day" reminds on the start weekday', () {
      final task = weekly(time: 600, mode: WeeklyReminderMode.onDays);
      // scheduledDate 2026-11-01 is a Sunday.
      expect(
        NotificationService.shouldRemindOn(task, DateTime(2026, 11, 8)),
        isTrue,
      );
      expect(NotificationService.shouldRemindOn(task, mon), isFalse);
    });
  });

  group('history (permanent log)', () {
    Task daily() => Task(
      id: 'd1',
      title: 'daily',
      type: TaskType.daily,
      scheduledDate: DateTime(2026, 11, 1),
      createdAt: DateTime(2026, 11, 1),
    );

    test('toggle records and un-toggle removes only that occurrence', () {
      final tasks = <Task>[daily()];
      final history = <CompletionRecord>[];
      TaskMutations.toggle(
        tasks: tasks,
        history: history,
        taskId: 'd1',
        day: sat,
      );
      TaskMutations.toggle(
        tasks: tasks,
        history: history,
        taskId: 'd1',
        day: mon,
      );
      expect(history, hasLength(2));

      TaskMutations.toggle(
        tasks: tasks,
        history: history,
        taskId: 'd1',
        day: mon,
      );
      expect(history, hasLength(1));
      expect(isSameDate(history.single.completedForDate, sat), isTrue);
    });

    test('forcing the current state is a no-op (no duplicates)', () {
      final tasks = <Task>[daily()];
      final history = <CompletionRecord>[];
      for (var i = 0; i < 3; i++) {
        TaskMutations.toggle(
          tasks: tasks,
          history: history,
          taskId: 'd1',
          day: sat,
          forceValue: true,
        );
      }
      expect(history, hasLength(1));
    });

    test('records of a previous type survive un-checking', () {
      final tasks = <Task>[
        daily().copyWith(type: TaskType.normal, scheduledDate: sat),
      ];
      final history = <CompletionRecord>[
        CompletionRecord(
          id: 'old',
          taskId: 'd1',
          taskTitle: 'daily',
          taskType: TaskType.daily,
          completedAt: DateTime(2026, 11, 2),
          completedForDate: DateTime(2026, 11, 2),
        ),
      ];
      TaskMutations.toggle(
        tasks: tasks,
        history: history,
        taskId: 'd1',
        day: sat,
      );
      TaskMutations.toggle(
        tasks: tasks,
        history: history,
        taskId: 'd1',
        day: sat,
      );
      expect(history.map((CompletionRecord r) => r.id), <String>['old']);
    });
  });

  group('TaskProvider', () {
    late TaskProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'mongez.demo_seeded.v1': true,
      });
      provider = TaskProvider(
        storageService: LocalStorageService(),
        widgetSyncService: WidgetSyncService(),
      );
      await provider.initialize(startPage: StartPage.today);
    });

    Future<void> addThree() async {
      for (final title in <String>['A', 'B', 'C']) {
        await provider.addTask(
          title: title,
          date: todayDate(),
          type: TaskType.normal,
        );
      }
    }

    List<String> titles() =>
        provider.tasksForSelectedDate.map((Task t) => t.title).toList();

    test('new tasks append and drag-reorder persists', () async {
      await addThree();
      expect(titles(), <String>['A', 'B', 'C']);

      await provider.reorderVisible(provider.tasksForSelectedDate, 2, 0);
      expect(titles(), <String>['C', 'A', 'B']);

      final reloaded = TaskProvider(
        storageService: LocalStorageService(),
        widgetSyncService: WidgetSyncService(),
      );
      await reloaded.initialize(startPage: StartPage.today);
      expect(reloaded.tasksForSelectedDate.map((Task t) => t.title), <String>[
        'C',
        'A',
        'B',
      ]);
    });

    test('reordering one day keeps other days intact', () async {
      await addThree();
      await provider.addTask(
        title: 'tomorrow',
        date: tomorrowDate(),
        type: TaskType.normal,
      );
      await provider.addTask(
        title: 'every day',
        date: todayDate(),
        type: TaskType.daily,
      );
      await provider.reorderVisible(provider.tasksForSelectedDate, 3, 0);
      expect(titles(), <String>['every day', 'A', 'B', 'C']);
      provider.goToTomorrow();
      expect(titles(), <String>['every day', 'tomorrow']);
    });

    test('sort by time orders timed tasks first', () async {
      await provider.addTask(
        title: 'late',
        date: todayDate(),
        type: TaskType.normal,
        timeInMinutes: 22 * 60,
      );
      await provider.addTask(
        title: 'none',
        date: todayDate(),
        type: TaskType.normal,
      );
      await provider.addTask(
        title: 'early',
        date: todayDate(),
        type: TaskType.normal,
        timeInMinutes: 8 * 60,
      );
      await provider.sortSelectedDayByTime();
      expect(titles(), <String>['early', 'late', 'none']);
    });

    test('deleting a task keeps its history; undo restores it', () async {
      await addThree();
      final a = provider.tasksForSelectedDate.first;
      await provider.toggleTask(a, true);
      expect(provider.completionCounts.normal, 1);

      final removed = await provider.deleteTask(a.id);
      expect(titles(), <String>['B', 'C']);
      expect(provider.history, hasLength(1));

      await provider.restoreTask(removed!);
      expect(titles(), <String>['A', 'B', 'C']);
    });

    test('changing a task type keeps its history', () async {
      await addThree();
      final a = provider.tasksForSelectedDate.first;
      await provider.toggleTask(a, true);
      await provider.updateTask(
        taskId: a.id,
        title: 'A',
        date: todayDate(),
        type: TaskType.daily,
      );
      expect(provider.history, hasLength(1));
      expect(
        provider.tasksForSelectedDate.first.isCompletedOn(todayDate()),
        isFalse,
      );
    });

    test('carry over moves only unfinished one-off tasks', () async {
      await addThree();
      await provider.addTask(
        title: 'daily',
        date: todayDate(),
        type: TaskType.daily,
      );
      await provider.toggleTask(provider.tasksForSelectedDate.first, true);
      final moved = await provider.carryOverUnfinished(todayDate());
      expect(moved, 2);
      expect(titles(), <String>['A', 'daily']);
      provider.goToTomorrow();
      expect(titles(), containsAll(<String>['B', 'C', 'daily']));
    });

    test('streak counts consecutive active days', () async {
      await provider.addTask(
        title: 'd',
        date: addDays(todayDate(), -5),
        type: TaskType.daily,
      );
      final id = provider.allTasks.single.id;
      // Records are timestamped "now", so build history via import instead.
      final records = <CompletionRecord>[
        for (final offset in <int>[0, 1, 2, 4])
          CompletionRecord(
            id: 'r$offset',
            taskId: id,
            taskTitle: 'd',
            taskType: TaskType.daily,
            completedAt: addDays(
              todayDate(),
              -offset,
            ).add(const Duration(hours: 10)),
            completedForDate: addDays(todayDate(), -offset),
          ),
      ];
      await provider.importBackup(
        BackupData(
          tasks: provider.allTasks,
          history: records,
          goals: const <Goal>[],
        ),
      );
      expect(provider.currentStreak, 3);
      expect(provider.bestStreak, 3);
      expect(provider.completionsPerDay(7).reduce((a, b) => a + b), 4);
    });

    test('import merges history instead of replacing it', () async {
      await addThree();
      await provider.toggleTask(provider.tasksForSelectedDate.first, true);
      await provider.importBackup(
        BackupData(
          tasks: const <Task>[],
          history: <CompletionRecord>[
            CompletionRecord(
              id: 'imported',
              taskId: 'x',
              taskTitle: 'x',
              taskType: TaskType.weekly,
              completedAt: DateTime(2025),
              completedForDate: DateTime(2025),
            ),
          ],
          goals: const <Goal>[],
        ),
      );
      expect(provider.allTasks, isEmpty);
      expect(provider.history, hasLength(2));
    });
  });

  group('goals', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('numeric goals auto-complete and reopen', () async {
      final goals = GoalsProvider(LocalStorageService());
      await goals.initialize();
      await goals.addGoal(title: 'books', target: 2, unit: 'كتاب');
      final id = goals.goals.single.id;

      expect(await goals.changeProgress(id, 1), isFalse);
      expect(await goals.changeProgress(id, 1), isTrue);
      expect(goals.goals.single.isCompleted, isTrue);
      expect(await goals.changeProgress(id, 5), isFalse); // clamped
      expect(goals.goals.single.progress, 2);

      await goals.changeProgress(id, -1);
      expect(goals.goals.single.isCompleted, isFalse);
      expect(goals.yearGoalsRatio, 0.5);
    });

    test('milestone goals toggle', () async {
      final goals = GoalsProvider(LocalStorageService());
      await goals.initialize();
      await goals.addGoal(title: 'travel');
      final id = goals.goals.single.id;
      expect(await goals.toggleCompleted(id), isTrue);
      expect(goals.yearGoalsRatio, 1);
      expect(await goals.toggleCompleted(id), isFalse);
      expect(goals.yearGoalsRatio, 0);
    });
  });

  group('settings', () {
    test('migrates the legacy theme preference', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'mongez.theme_mode.v1': 'dark',
      });
      final settings = await LocalStorageService().loadSettings();
      expect(settings.themeMode.name, 'dark');
      expect(settings.weekStartDay, DateTime.saturday);
    });

    test('round-trips through json and applies week start', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final storage = LocalStorageService();
      await storage.saveSettings(
        const AppSettings(weekStartDay: DateTime.monday, paletteId: 'rose'),
      );
      final loaded = await storage.loadSettings();
      expect(loaded.paletteId, 'rose');
      expect(WeekSettings.defaultStartDay, DateTime.monday);
    });
  });

  test('legacy task json (v1) still parses', () {
    final task = Task.fromJson(<String, dynamic>{
      'id': 't',
      'title': 'old',
      'type': 'weekly',
      'scheduledDate': '2026-03-01T00:00:00.000',
      'createdAt': '2026-03-01T00:00:00.000',
      'completedWeeks': <String>['W-2026-03-02'],
      'weeklyAnyDay': true,
      'weeklyDays': <int>[],
    });
    expect(task.sortOrder, isNull);
    expect(task.priority, TaskPriority.none);
    expect(task.isCompletedOn(DateTime(2026, 3, 4)), isTrue);
  });
}
