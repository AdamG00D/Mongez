import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/l10n.dart';

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

/// Formats [date] with a pattern taken from the translations (so each
/// language can order day/month its own way).
String _format(String pattern, DateTime date) {
  try {
    return DateFormat(pattern, L10n.code).format(date);
  } catch (_) {
    return DateFormat('yyyy/MM/dd').format(date);
  }
}

String formatFullDate(DateTime date) =>
    _format(L10n.current.dateFormatFull, dateOnly(date));

String formatShortDate(DateTime date) =>
    _format(L10n.current.dateFormatShort, dateOnly(date));

/// "Friday, November 13" / "الجمعة، 13 نوفمبر".
String formatWeekdayDayMonth(DateTime date) =>
    _format(L10n.current.dateFormatWeekdayDayMonth, dateOnly(date));

String formatMonthYear(DateTime date) =>
    _format(L10n.current.dateFormatMonthYear, date);

/// Clock time of [date], e.g. "9:05 PM".
String formatClockTime(DateTime date) => _format('h:mm a', date);

String relativeDateLabel(DateTime date) {
  final normalized = dateOnly(date);
  final today = todayDate();

  final l10n = L10n.current;

  if (isSameDate(normalized, addDays(today, 1))) {
    return l10n.tomorrow;
  }
  if (isSameDate(normalized, today)) {
    return l10n.today;
  }
  if (isSameDate(normalized, addDays(today, -1))) {
    return l10n.yesterday;
  }
  if (isSameDate(normalized, addDays(today, 2))) {
    return l10n.dayAfterTomorrow;
  }

  return weekDayName(normalized.weekday);
}

/// Hours at which the greeting changes: night, morning, afternoon, evening.
const List<int> _greetingHours = <int>[0, 5, 12, 17];

/// The next moment after [now] at which [greetingForNow] returns a new text.
DateTime nextGreetingChange(DateTime now) {
  for (final hour in _greetingHours) {
    if (hour > now.hour) {
      return DateTime(now.year, now.month, now.day, hour);
    }
  }
  return DateTime(now.year, now.month, now.day + 1);
}

String greetingForNow([DateTime? now]) {
  final hour = (now ?? DateTime.now()).hour;
  final l10n = L10n.current;
  if (hour < 5) {
    return l10n.greetingNight;
  }
  if (hour < 12) {
    return l10n.greetingMorning;
  }
  if (hour < 17) {
    return l10n.greetingAfternoon;
  }
  return l10n.greetingEvening;
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
  final suffix = hour < 12 ? L10n.current.timeAm : L10n.current.timePm;
  var displayHour = hour % 12;
  if (displayHour == 0) {
    displayHour = 12;
  }
  return '$displayHour:${minute.toString().padLeft(2, '0')} $suffix';
}

int minutesFromTimeOfDay(TimeOfDay time) => (time.hour * 60) + time.minute;

/// Formats a duration as "3 h 25 min" / "3 س 25 د" style text.
String formatDurationShort(Duration duration) {
  final l10n = L10n.current;
  final totalMinutes = duration.inMinutes;
  if (totalMinutes < 1) {
    return duration.inSeconds > 0
        ? l10n.durationLessThanMinute
        : l10n.durationMinutes(0);
  }
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  if (hours == 0) {
    return l10n.durationMinutes(minutes);
  }
  if (minutes == 0) {
    return l10n.durationHours(hours);
  }
  return l10n.durationHoursMinutes(hours, minutes);
}

/// Name of [weekday] ([DateTime.monday] .. [DateTime.sunday]). [short] gives
/// "Mon" in English for tight spaces; Arabic names are used as they are.
String weekDayName(int weekday, {bool short = false}) {
  if (short && !L10n.isArabic) {
    // 2024-01-01 was a Monday.
    return _format('EEE', DateTime(2024, 1, weekday));
  }
  final l10n = L10n.current;
  return switch (weekday) {
    DateTime.monday => l10n.weekdayMonday,
    DateTime.tuesday => l10n.weekdayTuesday,
    DateTime.wednesday => l10n.weekdayWednesday,
    DateTime.thursday => l10n.weekdayThursday,
    DateTime.friday => l10n.weekdayFriday,
    DateTime.saturday => l10n.weekdaySaturday,
    DateTime.sunday => l10n.weekdaySunday,
    _ => weekday.toString(),
  };
}

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
      .map((int day) => weekDayName(day, short: true))
      .join(L10n.current.listSeparator);
}
