import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

enum TaskType { normal, daily, weekly }

extension TaskTypePresentation on TaskType {
  String get storageValue {
    return switch (this) {
      TaskType.normal => 'normal',
      TaskType.daily => 'daily',
      TaskType.weekly => 'weekly',
    };
  }

  String get label {
    return switch (this) {
      TaskType.normal => L10n.current.typeNormal,
      TaskType.daily => L10n.current.typeDaily,
      TaskType.weekly => L10n.current.typeWeekly,
    };
  }

  IconData get icon {
    return switch (this) {
      TaskType.normal => Icons.flag_rounded,
      TaskType.daily => Icons.repeat_rounded,
      TaskType.weekly => Icons.view_week_rounded,
    };
  }
}

TaskType taskTypeFromStorage(String value) {
  return switch (value) {
    'daily' => TaskType.daily,
    'weekly' => TaskType.weekly,
    _ => TaskType.normal,
  };
}

enum TaskPriority { none, medium, high }

extension TaskPriorityPresentation on TaskPriority {
  String get label {
    return switch (this) {
      TaskPriority.none => L10n.current.priorityNone,
      TaskPriority.medium => L10n.current.priorityMedium,
      TaskPriority.high => L10n.current.priorityHigh,
    };
  }

  Color get color {
    return switch (this) {
      TaskPriority.none => const Color(0xFF94A3B8),
      TaskPriority.medium => const Color(0xFFF59E0B),
      TaskPriority.high => const Color(0xFFEF4444),
    };
  }
}

TaskPriority taskPriorityFromIndex(int? index) {
  if (index == null || index < 0 || index >= TaskPriority.values.length) {
    return TaskPriority.none;
  }
  return TaskPriority.values[index];
}

/// How a weekly task reminds the user while it is still not done this week.
enum WeeklyReminderMode {
  /// Remind on the task's chosen days (or its start weekday for "any day").
  onDays,

  /// Remind every day at the task time until it's done for the week.
  everyDayUntilDone,

  /// Remind only on the last day of the week if it's still not done.
  lastDay,
}

extension WeeklyReminderModePresentation on WeeklyReminderMode {
  String get storageValue => name;

  String get label {
    return switch (this) {
      WeeklyReminderMode.onDays => L10n.current.weeklyReminderOnDays,
      WeeklyReminderMode.everyDayUntilDone =>
        L10n.current.weeklyReminderEveryDay,
      WeeklyReminderMode.lastDay => L10n.current.weeklyReminderLastDay,
    };
  }
}

WeeklyReminderMode weeklyReminderModeFromStorage(String? value) {
  return WeeklyReminderMode.values.firstWhere(
    (WeeklyReminderMode mode) => mode.name == value,
    orElse: () => WeeklyReminderMode.everyDayUntilDone,
  );
}
