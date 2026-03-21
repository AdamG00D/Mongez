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
  });

  final String id;
  final String title;
  final TaskType type;
  final DateTime scheduledDate;
  final int? timeInMinutes;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Set<String> completedDays;
  final Set<String> completedWeeks;
  final bool weeklyAnyDay;
  final Set<int> weeklyDays;

  bool get isNormal => type == TaskType.normal;
  bool get isDaily => type == TaskType.daily;
  bool get isWeekly => type == TaskType.weekly;

  bool appearsOn(DateTime day) {
    final normalizedDay = dateOnly(day);
    final normalizedScheduledDate = dateOnly(scheduledDate);

    if (normalizedDay.isBefore(normalizedScheduledDate)) {
      return false;
    }

    if (isDaily) {
      return true;
    }

    if (isWeekly) {
      if (weeklyAnyDay || weeklyDays.isEmpty) {
        return true;
      }
      return weeklyDays.contains(normalizedDay.weekday);
    }

    return isSameDate(normalizedScheduledDate, normalizedDay);
  }

  bool isCompletedOn(DateTime day) {
    final normalizedDay = dateOnly(day);

    if (isDaily) {
      return completedDays.contains(dateKey(normalizedDay));
    }

    if (isWeekly) {
      return completedWeeks.contains(weekKey(normalizedDay));
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
      final updatedWeeks = Set<String>.from(completedWeeks);
      final key = weekKey(normalizedDay);
      if (completed) {
        updatedWeeks.add(key);
      } else {
        updatedWeeks.remove(key);
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

    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      type: taskTypeFromStorage((json['type'] as String?) ?? 'normal'),
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      timeInMinutes: json['timeInMinutes'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      completedDays: parsedDays,
      completedWeeks: parsedWeeks,
      weeklyAnyDay: json['weeklyAnyDay'] as bool? ?? true,
      weeklyDays: parsedWeeklyDays,
    );
  }
}
