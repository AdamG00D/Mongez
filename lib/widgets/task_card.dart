import 'package:flutter/material.dart';

import '../models/task.dart';
import '../models/task_type.dart';
import '../utils/date_helpers.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.selectedDate,
    required this.onCompletionChanged,
    this.onTap,
    super.key,
  });

  final Task task;
  final DateTime selectedDate;
  final ValueChanged<bool> onCompletionChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompletedOn(selectedDate);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    String statusLabel;
    if (task.isWeekly) {
      statusLabel = isCompleted ? 'مكتملة هذا الأسبوع' : 'قيد هذا الأسبوع';
    } else {
      statusLabel = isCompleted ? 'مكتملة' : 'قيد التنفيذ';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 12, 14),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        task.title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          _MetaChip(
                            icon: switch (task.type) {
                              TaskType.normal => Icons.flag_outlined,
                              TaskType.daily => Icons.repeat_rounded,
                              TaskType.weekly => Icons.view_week_rounded,
                            },
                            label: task.type.label,
                          ),
                          if (task.isWeekly)
                            _MetaChip(
                              icon: Icons.calendar_month_rounded,
                              label: task.weeklyAnyDay
                                  ? 'مرة أسبوعيًا بأي يوم'
                                  : formatWeekDays(task.weeklyDays),
                            ),
                          if (task.timeInMinutes != null)
                            _MetaChip(
                              icon: Icons.schedule_rounded,
                              label: formatTaskTime(
                                context,
                                task.timeInMinutes!,
                              ),
                            ),
                          _MetaChip(
                            icon: isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            label: statusLabel,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: isCompleted,
                  onChanged: (bool? value) {
                    if (value == null) {
                      return;
                    }
                    onCompletionChanged(value);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
