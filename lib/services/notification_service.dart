import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../l10n/l10n.dart';
import '../models/app_settings.dart';
import '../models/goal.dart';
import '../models/task.dart';
import '../models/task_type.dart';
import '../utils/date_helpers.dart';
import '../utils/motivation.dart';
import 'local_storage_service.dart';

/// Handles notification action taps while the app process is not in the
/// foreground (e.g. the "Done ✓" button on a task reminder).
typedef BackgroundNotificationHandler =
    void Function(NotificationResponse response);

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String actionDone = 'done';

  // Channel names are shown in the system settings, so they follow the app
  // language. Re-creating a channel with the same id only renames it.
  static AndroidNotificationChannel get _taskChannel =>
      AndroidNotificationChannel(
        'mongez_task_channel',
        L10n.current.channelTasks,
        description: L10n.current.channelTasksDescription,
        importance: Importance.high,
      );
  static AndroidNotificationChannel get _followUpChannel =>
      AndroidNotificationChannel(
        'mongez_followup_channel',
        L10n.current.channelFollowUp,
        description: L10n.current.channelFollowUpDescription,
        importance: Importance.high,
      );
  static AndroidNotificationChannel get _planningChannel =>
      AndroidNotificationChannel(
        'mongez_planning_channel',
        L10n.current.channelPlanning,
        description: L10n.current.channelPlanningDescription,
        importance: Importance.defaultImportance,
      );
  static AndroidNotificationChannel get _goalsChannel =>
      AndroidNotificationChannel(
        'mongez_goals_channel',
        L10n.current.channelGoals,
        description: L10n.current.channelGoalsDescription,
        importance: Importance.defaultImportance,
      );

  /// Language the channels were last created with.
  static String? _channelsLanguage;

  /// Android allows ~500 pending alarms per app; stay well below it.
  static const int _maxScheduled = 380;
  static const int _horizonDays = 14;

  static bool _isInitialized = false;
  static final StreamController<NotificationResponse> _responses =
      StreamController<NotificationResponse>.broadcast();

  /// Foreground notification taps / actions.
  static Stream<NotificationResponse> get responses => _responses.stream;

  bool _supportsExactAlarms = false;
  Future<void>? _running;
  bool _rerunRequested = false;

  /// When true (main UI isolate only) reminders that fall due while the app
  /// is open are also posted directly from a Dart timer, so they show up on
  /// time even if the OS delays the inexact alarm.
  bool foregroundDelivery = false;
  Timer? _foregroundTimer;
  List<_Planned> _plan = const <_Planned>[];

  Future<void> initialize({
    BackgroundNotificationHandler? backgroundHandler,
  }) async {
    if (_isInitialized || kIsWeb) {
      return;
    }

    tz_data.initializeTimeZones();
    await _configureLocalTimeZone();

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@drawable/ic_stat_mongez'),
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _responses.add,
      onDidReceiveBackgroundNotificationResponse: backgroundHandler,
    );

    await _createChannels();

    _isInitialized = true;
  }

  Future<void> _createChannels() async {
    final androidPlugin = _android;
    for (final channel in <AndroidNotificationChannel>[
      _taskChannel,
      _followUpChannel,
      _planningChannel,
      _goalsChannel,
    ]) {
      await androidPlugin?.createNotificationChannel(channel);
    }
    _channelsLanguage = L10n.code;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  Future<NotificationResponse?> launchResponse() async {
    if (kIsWeb) {
      return null;
    }
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp ?? false) {
      return details!.notificationResponse;
    }
    return null;
  }

  Future<bool> areNotificationsEnabled() async {
    if (kIsWeb) {
      return false;
    }
    try {
      return await _android?.areNotificationsEnabled() ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Whether exact alarms are allowed (always true below Android 12).
  Future<bool> canScheduleExact() async {
    if (kIsWeb) {
      return false;
    }
    try {
      return await _android?.canScheduleExactNotifications() ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Shows the system "Allow notifications" prompt (Android 13+).
  /// Returns whether notifications are enabled afterwards.
  Future<bool> requestNotificationPermission() async {
    if (kIsWeb) {
      return false;
    }
    await initialize();
    try {
      final granted = await _android?.requestNotificationsPermission();
      if (granted ?? false) {
        return true;
      }
    } catch (_) {}
    return areNotificationsEnabled();
  }

  /// Opens the "Alarms & reminders" page (Android 12+). Returns whether exact
  /// alarms are allowed afterwards.
  Future<bool> requestExactAlarmPermission() async {
    if (kIsWeb) {
      return false;
    }
    await initialize();
    try {
      await _android?.requestExactAlarmsPermission();
    } catch (_) {}
    _supportsExactAlarms = await canScheduleExact();
    return _supportsExactAlarms;
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) {
      return;
    }

    await initialize();
    final androidPlugin = _android;
    if (androidPlugin == null) {
      return;
    }

    try {
      await androidPlugin.requestNotificationsPermission();
    } catch (_) {}

    final canScheduleExact =
        await androidPlugin.canScheduleExactNotifications() ?? true;
    if (!canScheduleExact) {
      try {
        await androidPlugin.requestExactAlarmsPermission();
      } catch (_) {}
    }

    _supportsExactAlarms =
        await androidPlugin.canScheduleExactNotifications() ?? false;
  }

  /// Loads everything from storage and reschedules. Used by background
  /// isolates after the widget / a notification action changed data.
  Future<void> syncFromStorage(LocalStorageService storage) async {
    final settings = await storage.loadSettings();
    final tasks = await storage.loadTasks();
    final goals = await storage.loadGoals();
    await sync(tasks: tasks, settings: settings, goals: goals);
  }

  /// Reschedules all reminders. Calls are coalesced so rapid changes don't
  /// interleave cancel/schedule passes.
  Future<void> sync({
    required List<Task> tasks,
    required AppSettings settings,
    required List<Goal> goals,
  }) {
    if (kIsWeb) {
      return Future<void>.value();
    }
    _latest = _SyncInput(List<Task>.of(tasks), settings, List<Goal>.of(goals));
    if (_running != null) {
      _rerunRequested = true;
      return _running!;
    }
    _running = _drain();
    return _running!;
  }

  _SyncInput? _latest;

  Future<void> _drain() async {
    try {
      do {
        _rerunRequested = false;
        final input = _latest;
        if (input == null) {
          break;
        }
        await _syncNow(input);
      } while (_rerunRequested);
    } catch (error) {
      debugPrint('[Mongez.Notifications] sync error: $error');
    } finally {
      _running = null;
    }
  }

  Future<void> _syncNow(_SyncInput input) async {
    await initialize();
    if (_channelsLanguage != L10n.code && !kIsWeb) {
      await _createChannels();
    }
    _supportsExactAlarms =
        await _android?.canScheduleExactNotifications() ?? false;

    // Only cancel *pending* alarms. `cancelAll()` would also wipe reminders
    // already shown in the tray every time the app resumes or data changes.
    await _plugin.cancelAllPendingNotifications();

    final now = tz.TZDateTime.now(tz.local);
    final today = dateOnly(DateTime.now());
    final items = <_Planned>[];

    for (final task in input.tasks) {
      _planTask(task, input.settings, today, now, items);
    }
    if (input.settings.planningReminder) {
      _planPlanning(input.tasks, input.settings, today, now, items);
    }
    if (input.settings.goalsReminder) {
      _planGoals(input.goals, today, now, items);
    }

    items.sort((_Planned a, _Planned b) => a.at.compareTo(b.at));
    final planned = items.take(_maxScheduled).toList();
    for (final item in planned) {
      await _schedule(item);
    }
    _plan = planned;
    await _removeStaleShown(input.tasks);
    _armForegroundTimer();
  }

  /// Removes shown task reminders whose task was deleted or completed.
  Future<void> _removeStaleShown(List<Task> tasks) async {
    try {
      final active = await _plugin.getActiveNotifications();
      for (final shown in active) {
        final parts = (shown.payload ?? '').split('|');
        if (shown.id == null || parts.length != 3 || parts[0] != 'task') {
          continue;
        }
        final day = dateFromKey(parts[2]);
        final task = tasks.where((Task t) => t.id == parts[1]).firstOrNull;
        if (task == null || task.isCompletedOn(day)) {
          await _plugin.cancel(id: shown.id!);
        }
      }
    } catch (_) {
      // getActiveNotifications is unsupported on very old Android versions.
    }
  }

  void _armForegroundTimer() {
    _foregroundTimer?.cancel();
    _foregroundTimer = null;
    if (!foregroundDelivery) {
      return;
    }
    final now = tz.TZDateTime.now(tz.local);
    final next = _plan.where((_Planned p) => p.at.isAfter(now)).firstOrNull;
    if (next == null) {
      return;
    }
    final wait = next.at.difference(now);
    // Re-armed on every sync / resume, so a long horizon isn't needed.
    if (wait > const Duration(hours: 12)) {
      return;
    }
    _foregroundTimer = Timer(wait, () => _deliverDue(next.at));
  }

  /// Posts every reminder due at [at] right now if the app is in the
  /// foreground, replacing its pending alarm so it never shows twice.
  Future<void> _deliverDue(tz.TZDateTime at) async {
    final state = WidgetsBinding.instance.lifecycleState;
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive) {
      List<ActiveNotification> active = const <ActiveNotification>[];
      try {
        active = await _plugin.getActiveNotifications();
      } catch (_) {}
      final shownIds = active.map((ActiveNotification a) => a.id).toSet();
      for (final item in _plan.where((_Planned p) => p.at == at)) {
        if (shownIds.contains(item.id)) {
          continue; // The alarm already fired.
        }
        try {
          await _plugin.cancel(id: item.id);
          await _plugin.show(
            id: item.id,
            title: item.title,
            body: item.body,
            notificationDetails: _details(item),
            payload: item.payload,
          );
        } catch (_) {}
      }
    }
    _plan = _plan.where((_Planned p) => p.at.isAfter(at)).toList();
    _armForegroundTimer();
  }

  void _planTask(
    Task task,
    AppSettings settings,
    DateTime today,
    tz.TZDateTime now,
    List<_Planned> out,
  ) {
    final minutes = task.timeInMinutes;
    if (minutes == null) {
      return;
    }

    for (var offset = 0; offset <= _horizonDays; offset++) {
      final day = addDays(today, offset);
      if (!shouldRemindOn(task, day)) {
        continue;
      }
      if (task.isCompletedOn(day)) {
        continue;
      }

      final at = _dateAtTime(day, minutes);
      final key = dateKey(day);
      final payload = 'task|${task.id}|$key';
      final title = switch (task.type) {
        TaskType.normal => L10n.current.notifTaskNormal,
        TaskType.daily => L10n.current.notifTaskDaily,
        TaskType.weekly => L10n.current.notifTaskWeekly,
      };

      if (at.isAfter(now)) {
        out.add(
          _Planned(
            id: _stableId('t-${task.id}-$key'),
            at: at,
            title: title,
            body: task.title,
            channel: _taskChannel,
            payload: payload,
            withDoneAction: true,
          ),
        );
      }

      if (settings.followUpReminders && settings.followUpMinutes > 0) {
        final followAt = at.add(Duration(minutes: settings.followUpMinutes));
        // Don't push a follow-up past the end of that day.
        if (followAt.isAfter(now) && followAt.day == at.day) {
          out.add(
            _Planned(
              id: _stableId('f-${task.id}-$key'),
              at: followAt,
              title: L10n.current.notifFollowUpTitle,
              body: L10n.current.notifFollowUpBody(task.title),
              channel: _followUpChannel,
              payload: payload,
              withDoneAction: true,
            ),
          );
        }
      }
    }
  }

  /// Whether [task] should remind on [day] (ignoring completion state).
  @visibleForTesting
  static bool shouldRemindOn(Task task, DateTime day) {
    if (!task.appearsOn(day)) {
      return false;
    }
    if (!task.isWeekly) {
      return true;
    }

    switch (task.weeklyReminder) {
      case WeeklyReminderMode.everyDayUntilDone:
        return true;
      case WeeklyReminderMode.onDays:
        if (task.weeklyAnyDay || task.weeklyDays.isEmpty) {
          return day.weekday == task.scheduledDate.weekday;
        }
        return true;
      case WeeklyReminderMode.lastDay:
        // Last day in this week on which the task can still be done.
        final start = startOfWeek(day, task.effectiveWeekStart);
        for (var i = 6; i >= 0; i--) {
          final candidate = addDays(start, i);
          if (task.appearsOn(candidate)) {
            return isSameDate(candidate, day);
          }
        }
        return false;
    }
  }

  void _planPlanning(
    List<Task> tasks,
    AppSettings settings,
    DateTime today,
    tz.TZDateTime now,
    List<_Planned> out,
  ) {
    for (var offset = 0; offset <= _horizonDays; offset++) {
      final day = addDays(today, offset);
      final at = _dateAtTime(day, settings.planningReminderMinutes);
      if (!at.isAfter(now)) {
        continue;
      }
      final next = addDays(day, 1);
      final count = tasks
          .where((Task task) => task.appearsOn(next) && task.isNormal)
          .length;
      out.add(
        _Planned(
          id: _stableId('plan-${dateKey(day)}'),
          at: at,
          title: L10n.current.notifPlanTitle,
          body: count == 0
              ? L10n.current.notifPlanEmpty
              : L10n.current.notifPlanCount(count),
          channel: _planningChannel,
          payload: 'plan|${dateKey(next)}',
        ),
      );
    }
  }

  void _planGoals(
    List<Goal> goals,
    DateTime today,
    tz.TZDateTime now,
    List<_Planned> out,
  ) {
    final yearGoals = goals.where((Goal goal) => goal.year == today.year);
    if (yearGoals.isEmpty) {
      return;
    }
    final done = yearGoals.where((Goal goal) => goal.isCompleted).length;
    final total = yearGoals.length;
    final pending = yearGoals.where((Goal goal) => !goal.isCompleted).toList();

    // Every Friday at 10:00 for the next 6 weeks, each with a different quote.
    var day = today;
    while (day.weekday != DateTime.friday) {
      day = addDays(day, 1);
    }
    for (var week = 0; week < 6; week++) {
      final at = _dateAtTime(addDays(day, week * 7), 10 * 60);
      if (!at.isAfter(now)) {
        continue;
      }
      final focus = pending.isEmpty ? null : pending[week % pending.length];
      final quotes = motivationalQuotes;
      final quote = quotes[(at.day + week) % quotes.length];
      out.add(
        _Planned(
          id: _stableId('goal-${dateKey(at)}'),
          at: at,
          title: L10n.current.notifGoalsTitle(today.year),
          body: focus == null
              ? L10n.current.notifGoalsAllDone(done, total, quote)
              : L10n.current.notifGoalsFocus(done, total, focus.title, quote),
          channel: _goalsChannel,
          payload: 'goals',
        ),
      );
    }
  }

  NotificationDetails _details(_Planned item) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        item.channel.id,
        item.channel.name,
        channelDescription: item.channel.description,
        importance: item.channel.importance,
        priority: item.channel.importance == Importance.high
            ? Priority.high
            : Priority.defaultPriority,
        icon: 'ic_stat_mongez',
        color: const Color(0xFF4F6BF6),
        category: AndroidNotificationCategory.reminder,
        styleInformation: BigTextStyleInformation(item.body),
        actions: item.withDoneAction
            ? <AndroidNotificationAction>[
                AndroidNotificationAction(
                  actionDone,
                  L10n.current.notifDoneAction,
                  cancelNotification: true,
                ),
              ]
            : null,
      ),
    );
  }

  Future<void> _schedule(_Planned item) async {
    final details = _details(item);

    Future<void> attempt(AndroidScheduleMode mode) => _plugin.zonedSchedule(
      id: item.id,
      title: item.title,
      body: item.body,
      scheduledDate: item.at,
      notificationDetails: details,
      androidScheduleMode: mode,
      payload: item.payload,
    );

    try {
      await attempt(
        _supportsExactAlarms
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {
      if (!_supportsExactAlarms) {
        return;
      }
      try {
        await attempt(AndroidScheduleMode.inexactAllowWhileIdle);
      } catch (_) {
        // Keep the app stable even if a ROM rejects scheduling.
      }
    }
  }

  Future<void> _configureLocalTimeZone() async {
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  tz.TZDateTime _dateAtTime(DateTime date, int minutes) {
    return tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      minutes ~/ 60,
      minutes % 60,
    );
  }

  int _stableId(String seed) {
    var hash = 0;
    for (var i = 0; i < seed.length; i++) {
      hash = (hash * 31 + seed.codeUnitAt(i)) & 0x7fffffff;
    }
    return hash;
  }
}

class _SyncInput {
  const _SyncInput(this.tasks, this.settings, this.goals);

  final List<Task> tasks;
  final AppSettings settings;
  final List<Goal> goals;
}

class _Planned {
  const _Planned({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
    required this.channel,
    required this.payload,
    this.withDoneAction = false,
  });

  final int id;
  final tz.TZDateTime at;
  final String title;
  final String body;
  final AndroidNotificationChannel channel;
  final String payload;
  final bool withDoneAction;
}
