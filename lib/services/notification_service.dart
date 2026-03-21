import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/task.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'mongez_task_channel',
    'Task Reminders',
    description: 'Notifications for task due times',
    importance: Importance.high,
  );

  static bool _isInitialized = false;
  bool _supportsExactAlarms = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    tz_data.initializeTimeZones();
    await _configureLocalTimeZone();

    const androidInitializationSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await _plugin.initialize(initSettings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_channel);

    _isInitialized = true;
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) {
      return;
    }

    await initialize();

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
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

  Future<void> syncTaskNotifications(List<Task> tasks) async {
    if (kIsWeb) {
      return;
    }

    await initialize();
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    _supportsExactAlarms =
        await androidPlugin?.canScheduleExactNotifications() ?? false;

    await _plugin.cancelAll();

    final now = tz.TZDateTime.now(tz.local);
    for (final task in tasks) {
      final minutes = task.timeInMinutes;
      if (minutes == null) {
        continue;
      }

      if (task.isNormal) {
        await _scheduleNormal(task, minutes, now);
      } else if (task.isDaily) {
        await _scheduleDaily(task, minutes, now);
      } else if (task.isWeekly) {
        await _scheduleWeekly(task, minutes, now);
      }
    }
  }

  Future<void> syncTaskNotificationsAfterWidgetToggle(Task task) async {
    if (kIsWeb || !task.isNormal) {
      return;
    }

    final minutes = task.timeInMinutes;
    if (minutes == null) {
      return;
    }

    await initialize();
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    _supportsExactAlarms =
        await androidPlugin?.canScheduleExactNotifications() ?? false;

    final notificationId = _stableId('n-${task.id}');
    await _plugin.cancel(notificationId);

    if (task.completedAt != null) {
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    final scheduled = _dateAtTime(task.scheduledDate, minutes);
    if (!scheduled.isAfter(now)) {
      return;
    }

    await _scheduleWithFallback(
      id: notificationId,
      title: 'Task Reminder',
      body: task.title,
      scheduleDate: scheduled,
    );
  }

  Future<void> _scheduleNormal(
    Task task,
    int minutes,
    tz.TZDateTime now,
  ) async {
    if (task.completedAt != null) {
      return;
    }

    final scheduled = _dateAtTime(task.scheduledDate, minutes);
    if (!scheduled.isAfter(now)) {
      return;
    }

    await _scheduleWithFallback(
      id: _stableId('n-${task.id}'),
      title: 'حان وقت مهمة',
      body: task.title,
      scheduleDate: scheduled,
    );
  }

  Future<void> _scheduleDaily(Task task, int minutes, tz.TZDateTime now) async {
    var next = _nextDailyTime(minutes, now);
    final earliest = _dateAtTime(task.scheduledDate, minutes);
    while (next.isBefore(earliest)) {
      next = next.add(const Duration(days: 1));
    }

    await _scheduleWithFallback(
      id: _stableId('d-${task.id}'),
      title: 'تذكير يومي',
      body: task.title,
      scheduleDate: next,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleWeekly(
    Task task,
    int minutes,
    tz.TZDateTime now,
  ) async {
    final weeklyDays = (task.weeklyAnyDay || task.weeklyDays.isEmpty)
        ? <int>{task.scheduledDate.weekday}
        : task.weeklyDays;

    for (final weekday in weeklyDays) {
      var next = _nextWeekdayTime(weekday, minutes, now);
      final earliest = _nextWeekdayTime(
        weekday,
        minutes,
        _dateAtTime(task.scheduledDate, minutes),
      );
      while (next.isBefore(earliest)) {
        next = next.add(const Duration(days: 7));
      }

      await _scheduleWithFallback(
        id: _stableId('w-${task.id}-$weekday'),
        title: 'تذكير أسبوعي',
        body: task.title,
        scheduleDate: next,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> _scheduleWithFallback({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduleDate,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    final primaryMode = _supportsExactAlarms
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
    final fallbackMode = _supportsExactAlarms
        ? AndroidScheduleMode.inexactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduleDate,
        _notificationDetails(),
        androidScheduleMode: primaryMode,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    } catch (_) {
      if (primaryMode == fallbackMode) {
        return;
      }

      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          scheduleDate,
          _notificationDetails(),
          androidScheduleMode: fallbackMode,
          matchDateTimeComponents: matchDateTimeComponents,
        );
      } catch (_) {
        // Keep app stable even if the OS rejects scheduling on a specific ROM.
      }
    }
  }

  NotificationDetails _notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
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

  tz.TZDateTime _nextDailyTime(int minutes, tz.TZDateTime now) {
    var candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minutes ~/ 60,
      minutes % 60,
    );

    if (!candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }

    return candidate;
  }

  tz.TZDateTime _nextWeekdayTime(int weekday, int minutes, tz.TZDateTime now) {
    var candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minutes ~/ 60,
      minutes % 60,
    );

    while (candidate.weekday != weekday || !candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }

    return candidate;
  }

  int _stableId(String seed) {
    var hash = 0;
    for (var i = 0; i < seed.length; i++) {
      hash = (hash * 31 + seed.codeUnitAt(i)) & 0x7fffffff;
    }
    return hash;
  }
}
