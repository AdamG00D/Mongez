import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool isSameDate(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

String dateKey(DateTime date) {
  final normalized = dateOnly(date);
  final year = normalized.year.toString().padLeft(4, '0');
  final month = normalized.month.toString().padLeft(2, '0');
  final day = normalized.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

DateTime dateFromKey(String key) {
  final segments = key.split('-');
  if (segments.length != 3) {
    return dateOnly(DateTime.now());
  }

  final year = int.tryParse(segments[0]);
  final month = int.tryParse(segments[1]);
  final day = int.tryParse(segments[2]);

  if (year == null || month == null || day == null) {
    return dateOnly(DateTime.now());
  }

  return DateTime(year, month, day);
}

DateTime startOfWeek(DateTime date) {
  final normalized = dateOnly(date);
  return normalized.subtract(
    Duration(days: normalized.weekday - DateTime.monday),
  );
}

String weekKey(DateTime date) {
  final start = startOfWeek(date);
  return 'W-${dateKey(start)}';
}

DateTime tomorrowDate() =>
    dateOnly(DateTime.now().add(const Duration(days: 1)));

String formatFullDate(DateTime date) {
  return DateFormat('EEEE، d MMMM yyyy', 'ar').format(dateOnly(date));
}

String relativeDateLabel(DateTime date) {
  final normalized = dateOnly(date);
  final today = dateOnly(DateTime.now());
  final tomorrow = today.add(const Duration(days: 1));
  final yesterday = today.subtract(const Duration(days: 1));

  if (isSameDate(normalized, tomorrow)) {
    return 'غدًا';
  }
  if (isSameDate(normalized, today)) {
    return 'اليوم';
  }
  if (isSameDate(normalized, yesterday)) {
    return 'أمس';
  }

  return 'الخطة اليومية';
}

String formatTaskTime(BuildContext context, int minutes) {
  final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  return MaterialLocalizations.of(
    context,
  ).formatTimeOfDay(time, alwaysUse24HourFormat: false);
}

int minutesFromTimeOfDay(TimeOfDay time) => (time.hour * 60) + time.minute;

const Map<int, String> arabicWeekDayNames = <int, String>{
  DateTime.monday: 'الإثنين',
  DateTime.tuesday: 'الثلاثاء',
  DateTime.wednesday: 'الأربعاء',
  DateTime.thursday: 'الخميس',
  DateTime.friday: 'الجمعة',
  DateTime.saturday: 'السبت',
  DateTime.sunday: 'الأحد',
};

const List<int> weekDayDisplayOrder = <int>[
  DateTime.saturday,
  DateTime.sunday,
  DateTime.monday,
  DateTime.tuesday,
  DateTime.wednesday,
  DateTime.thursday,
  DateTime.friday,
];

String formatWeekDays(Set<int> days) {
  final sortedDays = days.toList()
    ..sort((int a, int b) {
      final aIndex = weekDayDisplayOrder.indexOf(a);
      final bIndex = weekDayDisplayOrder.indexOf(b);
      return aIndex.compareTo(bIndex);
    });

  return sortedDays
      .map((int day) => arabicWeekDayNames[day] ?? day.toString())
      .join('، ');
}
