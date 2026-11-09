import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Global week configuration. Loaded from settings at startup (and inside
/// background isolates) so that every week computation agrees.
class WeekSettings {
  WeekSettings._();

  /// The default first day of the week ([DateTime.monday] .. [DateTime.sunday]).
  static int defaultStartDay = DateTime.saturday;
}

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
  var raw = key;
  if (raw.startsWith('W-')) {
    raw = raw.substring(2);
  }
  final segments = raw.split('-');
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

/// Whole calendar days from [from] to [to] (DST safe).
int daysBetween(DateTime from, DateTime to) {
  final a = DateTime.utc(from.year, from.month, from.day);
  final b = DateTime.utc(to.year, to.month, to.day);
  return b.difference(a).inDays;
}

DateTime addDays(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);

/// Start of the week containing [date]. [startDay] defaults to the user's
/// configured first day of week.
DateTime startOfWeek(DateTime date, [int? startDay]) {
  final normalized = dateOnly(date);
  final first = startDay ?? WeekSettings.defaultStartDay;
  final diff = (normalized.weekday - first + 7) % 7;
  return addDays(normalized, -diff);
}

DateTime endOfWeek(DateTime date, [int? startDay]) =>
    addDays(startOfWeek(date, startDay), 6);

bool isInWeek(DateTime candidate, DateTime anyDayOfWeek, [int? startDay]) {
  final start = startOfWeek(anyDayOfWeek, startDay);
  final day = dateOnly(candidate);
  return !day.isBefore(start) && day.isBefore(addDays(start, 7));
}

String weekKey(DateTime date, [int? startDay]) {
  final start = startOfWeek(date, startDay);
  return 'W-${dateKey(start)}';
}

DateTime todayDate() => dateOnly(DateTime.now());

DateTime tomorrowDate() => addDays(todayDate(), 1);

String formatFullDate(DateTime date) {
  return DateFormat('EEEE، d MMMM yyyy', 'ar').format(dateOnly(date));
}

String formatShortDate(DateTime date) {
  return DateFormat('d MMMM', 'ar').format(dateOnly(date));
}

String relativeDateLabel(DateTime date) {
  final normalized = dateOnly(date);
  final today = todayDate();

  if (isSameDate(normalized, addDays(today, 1))) {
    return 'غدًا';
  }
  if (isSameDate(normalized, today)) {
    return 'اليوم';
  }
  if (isSameDate(normalized, addDays(today, -1))) {
    return 'أمس';
  }
  if (isSameDate(normalized, addDays(today, 2))) {
    return 'بعد غد';
  }

  return DateFormat('EEEE', 'ar').format(normalized);
}

String greetingForNow() {
  final hour = DateTime.now().hour;
  if (hour < 5) {
    return 'ليلة هادئة';
  }
  if (hour < 12) {
    return 'صباح الخير';
  }
  if (hour < 17) {
    return 'نهارك سعيد';
  }
  return 'مساء الخير';
}

String formatTaskTime(BuildContext context, int minutes) {
  final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  return MaterialLocalizations.of(
    context,
  ).formatTimeOfDay(time, alwaysUse24HourFormat: false);
}

String formatMinutesOfDay(int minutes) {
  final hour = minutes ~/ 60;
  final minute = minutes % 60;
  final suffix = hour < 12 ? 'ص' : 'م';
  var displayHour = hour % 12;
  if (displayHour == 0) {
    displayHour = 12;
  }
  return '$displayHour:${minute.toString().padLeft(2, '0')} $suffix';
}

int minutesFromTimeOfDay(TimeOfDay time) => (time.hour * 60) + time.minute;

/// Formats a duration as "3 س 25 د" style text.
String formatDurationShort(Duration duration) {
  final totalMinutes = duration.inMinutes;
  if (totalMinutes < 1) {
    return duration.inSeconds > 0 ? 'أقل من دقيقة' : '0 د';
  }
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours == 0) {
    return '$minutes د';
  }
  if (minutes == 0) {
    return '$hours س';
  }
  return '$hours س $minutes د';
}

const Map<int, String> arabicWeekDayNames = <int, String>{
  DateTime.monday: 'الإثنين',
  DateTime.tuesday: 'الثلاثاء',
  DateTime.wednesday: 'الأربعاء',
  DateTime.thursday: 'الخميس',
  DateTime.friday: 'الجمعة',
  DateTime.saturday: 'السبت',
  DateTime.sunday: 'الأحد',
};

/// Week days ordered starting from [startDay] (defaults to the configured
/// first day of the week).
List<int> weekDaysOrdered([int? startDay]) {
  final first = startDay ?? WeekSettings.defaultStartDay;
  return List<int>.generate(7, (int i) => ((first - 1 + i) % 7) + 1);
}

/// Kept for backwards compatibility with older code paths.
List<int> get weekDayDisplayOrder => weekDaysOrdered();

String formatWeekDays(Set<int> days, [int? startDay]) {
  final order = weekDaysOrdered(startDay);
  final sortedDays = days.toList()
    ..sort((int a, int b) => order.indexOf(a).compareTo(order.indexOf(b)));

  return sortedDays
      .map((int day) => arabicWeekDayNames[day] ?? day.toString())
      .join('، ');
}
