import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/palettes.dart';
import '../utils/date_helpers.dart';

/// Week view date selector: the 7 days of the selected week, with a small
/// indicator of each day's progress.
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    required this.selectedDate,
    required this.onSelect,
    required this.dayProgress,
    required this.onPickDate,
    super.key,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;

  /// Returns (done, total) for a day.
  final (int, int) Function(DateTime day) dayProgress;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final start = startOfWeek(selectedDate);
    final today = todayDate();
    final monthLabel = DateFormat('MMMM yyyy', 'ar').format(selectedDate);

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Flexible(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: onPickDate,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 6,
                    end: 2,
                    top: 4,
                    bottom: 4,
                  ),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          monthLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.expand_more_rounded,
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            if (!isSameDate(selectedDate, today))
              TextButton(
                onPressed: () => onSelect(today),
                style: _compactHeaderButtonStyle,
                child: const Text('اليوم'),
              ),
            if (!isSameDate(selectedDate, addDays(today, 1)))
              TextButton(
                onPressed: () => onSelect(addDays(today, 1)),
                style: _compactHeaderButtonStyle,
                child: const Text('غدًا'),
              ),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 36, height: 36),
              tooltip: 'الأسبوع السابق',
              onPressed: () => onSelect(addDays(selectedDate, -7)),
              // Auto-mirrored in RTL: points right (= back in Arabic).
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 36, height: 36),
              tooltip: 'الأسبوع التالي',
              onPressed: () => onSelect(addDays(selectedDate, 7)),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onHorizontalDragEnd: (DragEndDetails details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity.abs() < 250) {
              return;
            }
            // RTL: swiping right goes forward in time.
            onSelect(addDays(selectedDate, velocity > 0 ? 7 : -7));
          },
          child: Row(
            children: List<Widget>.generate(7, (int i) {
              final day = addDays(start, i);
              final (done, total) = dayProgress(day);
              return Expanded(
                child: _DayCell(
                  day: day,
                  selected: isSameDate(day, selectedDate),
                  isToday: isSameDate(day, today),
                  done: done,
                  total: total,
                  onTap: () => onSelect(day),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

const ButtonStyle _compactHeaderButtonStyle = ButtonStyle(
  minimumSize: WidgetStatePropertyAll<Size>(Size.zero),
  padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
    EdgeInsets.symmetric(horizontal: 4),
  ),
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  visualDensity: VisualDensity.compact,
);

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.isToday,
    required this.done,
    required this.total,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final bool isToday;
  final int done;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brand = context.brand;
    final fg = selected ? Colors.white : scheme.onSurface;
    final allDone = total > 0 && done == total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: selected ? brand.linear : null,
            color: selected ? null : Theme.of(context).cardTheme.color,
            border: Border.all(
              color: isToday && !selected
                  ? scheme.primary
                  : scheme.outlineVariant.withValues(alpha: 0.4),
              width: isToday && !selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? <BoxShadow>[
                    BoxShadow(
                      color: brand.gradient[1].withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: <Widget>[
              // Full day name, shrunk to fit narrow cells (الأربعاء, الثلاثاء).
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    arabicWeekDayNames[day.weekday] ?? '',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? Colors.white.withValues(alpha: 0.9)
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: fg,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 6,
                child: total == 0
                    ? null
                    : Container(
                        width: allDone ? 14 : 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: selected
                              ? Colors.white
                              : (allDone
                                    ? const Color(0xFF10B981)
                                    : scheme.primary.withValues(alpha: 0.6)),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
