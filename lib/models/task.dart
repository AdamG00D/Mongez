import '../utils/date_helpers.dart';
import 'task_type.dart';

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.type,
    required this.scheduledDate,
    required this.createdAt,
    this.timeInMinutes,
    this.completedAt,
    this.completedDays = const <String>{},
    this.completedWeeks = const <String>{},
    this.weeklyAnyDay = true,
    this.weeklyDays = const <int>{},
    this.weekStartDay,
    this.weeklyReminder = WeeklyReminderMode.everyDayUntilDone,
    this.sortOrder,
    this.priority = TaskPriority.none,
    this.note,
  });

  final String id;
  final String title;
  final TaskType type;
  final DateTime scheduledDate;
  final int? timeInMinutes;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Set<String> completedDays;

  /// For weekly tasks: date keys (yyyy-MM-dd) of the days the task was done.
  /// Legacy entries use the "W-yyyy-MM-dd" (Monday based) format; both are
  /// resolved to the week that contains that date.
  final Set<String> completedWeeks;
  final bool weeklyAnyDay;
  final Set<int> weeklyDays;

  /// First day of the week for this weekly task. `null` = global setting.
  final int? weekStartDay;
  final WeeklyReminderMode weeklyReminder;

  /// Manual ordering position. `null` for legacy tasks (sorted by time).
  final int? sortOrder;
  final TaskPriority priority;
  final String? note;

  bool get isNormal => type == TaskType.normal;
  bool get isDaily => type == TaskType.daily;
  bool get isWeekly => type == TaskType.weekly;

  int get effectiveWeekStart => weekStartDay ?? WeekSettings.defaultStartDay;

  bool appearsOn(DateTime day) {
    final normalizedDay = dateOnly(day);
    final normalizedScheduledDate = dateOnly(scheduledDate);

    if (isNormal) {
      return isSameDate(normalizedScheduledDate, normalizedDay);
    }

    if (normalizedDay.isBefore(normalizedScheduledDate)) {
      return false;
    }

    if (isWeekly) {
      if (weeklyAnyDay || weeklyDays.isEmpty) {
        return true;
      }
      return weeklyDays.contains(normalizedDay.weekday);
    }

    // Daily
    return true;
  }

  bool isCompletedOn(DateTime day) {
    final normalizedDay = dateOnly(day);

    if (isDaily) {
      return completedDays.contains(dateKey(normalizedDay));
    }

    if (isWeekly) {
      return completedWeeks.any(
        (String key) =>
            isInWeek(dateFromKey(key), normalizedDay, effectiveWeekStart),
      );
    }

    return isSameDate(normalizedDay, scheduledDate) && completedAt != null;
  }

  Task toggleCompletionForDay(DateTime day, bool completed) {
    final normalizedDay = dateOnly(day);

    if (isDaily) {
      final updatedDays = Set<String>.from(completedDays);
      final key = dateKey(normalizedDay);
      if (completed) {
        updatedDays.add(key);
      } else {
        updatedDays.remove(key);
      }
      return copyWith(completedDays: updatedDays);
    }

    if (isWeekly) {
      final updatedWeeks = Set<String>.from(completedWeeks)
        ..removeWhere(
          (String key) =>
              isInWeek(dateFromKey(key), normalizedDay, effectiveWeekStart),
        );
      if (completed) {
        updatedWeeks.add(dateKey(normalizedDay));
      }
      return copyWith(completedWeeks: updatedWeeks);
    }

    if (!isSameDate(normalizedDay, scheduledDate)) {
      return this;
    }

    if (completed) {
      return copyWith(completedAt: DateTime.now());
    }

    return copyWith(clearCompletedAt: true);
  }

  /// Identifier of the occurrence (day/week) that [day] belongs to. Used to
  /// build history record ids.
  String occurrenceKey(DateTime day) {
    if (isWeekly) {
      return weekKey(day, effectiveWeekStart);
    }
    if (isDaily) {
      return dateKey(day);
    }
    return dateKey(scheduledDate);
  }

  /// Whether [recordDay] (completedForDate of a history record) belongs to the
  /// same occurrence as [day].
  bool sameOccurrence(DateTime recordDay, DateTime day) {
    if (isWeekly) {
      return isInWeek(recordDay, day, effectiveWeekStart);
    }
    if (isDaily) {
      return isSameDate(recordDay, day);
    }
    return true;
  }

  Task copyWith({
    String? id,
    String? title,
    TaskType? type,
    DateTime? scheduledDate,
    int? timeInMinutes,
    bool removeTime = false,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    Set<String>? completedDays,
    Set<String>? completedWeeks,
    bool? weeklyAnyDay,
    Set<int>? weeklyDays,
    int? weekStartDay,
    bool clearWeekStartDay = false,
    WeeklyReminderMode? weeklyReminder,
    int? sortOrder,
    TaskPriority? priority,
    String? note,
    bool clearNote = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeInMinutes: removeTime ? null : (timeInMinutes ?? this.timeInMinutes),
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      completedDays: completedDays ?? this.completedDays,
      completedWeeks: completedWeeks ?? this.completedWeeks,
      weeklyAnyDay: weeklyAnyDay ?? this.weeklyAnyDay,
      weeklyDays: weeklyDays ?? this.weeklyDays,
      weekStartDay: clearWeekStartDay
          ? null
          : (weekStartDay ?? this.weekStartDay),
      weeklyReminder: weeklyReminder ?? this.weeklyReminder,
      sortOrder: sortOrder ?? this.sortOrder,
      priority: priority ?? this.priority,
      note: clearNote ? null : (note ?? this.note),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'type': type.storageValue,
      'scheduledDate': scheduledDate.toIso8601String(),
      'timeInMinutes': timeInMinutes,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'completedDays': completedDays.toList(),
      'completedWeeks': completedWeeks.toList(),
      'weeklyAnyDay': weeklyAnyDay,
      'weeklyDays': weeklyDays.toList(),
      'weekStartDay': weekStartDay,
      'weeklyReminder': weeklyReminder.storageValue,
      'sortOrder': sortOrder,
      'priority': priority.index,
      'note': note,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    final rawDays = json['completedDays'];
    final parsedDays = <String>{};
    if (rawDays is List) {
      parsedDays.addAll(rawDays.map((dynamic value) => value.toString()));
    }

    final rawWeeks = json['completedWeeks'];
    final parsedWeeks = <String>{};
    if (rawWeeks is List) {
      parsedWeeks.addAll(rawWeeks.map((dynamic value) => value.toString()));
    }

    final rawWeeklyDays = json['weeklyDays'];
    final parsedWeeklyDays = <int>{};
    if (rawWeeklyDays is List) {
      parsedWeeklyDays.addAll(
        rawWeeklyDays
            .map((dynamic value) => int.tryParse(value.toString()))
            .whereType<int>(),
      );
    }

    final note = (json['note'] as String?)?.trim();

    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      type: taskTypeFromStorage((json['type'] as String?) ?? 'normal'),
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      timeInMinutes: (json['timeInMinutes'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      completedDays: parsedDays,
      completedWeeks: parsedWeeks,
      weeklyAnyDay: json['weeklyAnyDay'] as bool? ?? true,
      weeklyDays: parsedWeeklyDays,
      weekStartDay: (json['weekStartDay'] as num?)?.toInt(),
      weeklyReminder: weeklyReminderModeFromStorage(
        json['weeklyReminder'] as String?,
      ),
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
      priority: taskPriorityFromIndex((json['priority'] as num?)?.toInt()),
      note: (note == null || note.isEmpty) ? null : note,
    );
  }
}

/// Shared ordering used by the app list and the home-screen widget.
/// Manual order first; tasks without an order fall back to time then creation.
int compareTasksForDisplay(Task first, Task second) {
  final a = first.sortOrder;
  final b = second.sortOrder;
  if (a != null && b != null && a != b) {
    return a.compareTo(b);
  }
  if (a != null && b == null) {
    return -1;
  }
  if (a == null && b != null) {
    return 1;
  }
  return compareTasksByTime(first, second);
}

int compareTasksByTime(Task first, Task second) {
  final firstTime = first.timeInMinutes ?? 24 * 60 + 1;
  final secondTime = second.timeInMinutes ?? 24 * 60 + 1;
  if (firstTime != secondTime) {
    return firstTime.compareTo(secondTime);
  }
  return first.createdAt.compareTo(second.createdAt);
}
