import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n.dart';
import '../models/task.dart';
import '../models/task_type.dart';
import '../utils/date_helpers.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.selectedDate,
    required this.onCompletionChanged,
    this.onTap,
    this.dragHandle,
    super.key,
  });

  final Task task;
  final DateTime selectedDate;
  final ValueChanged<bool> onCompletionChanged;
  final VoidCallback? onTap;
  final Widget? dragHandle;

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompletedOn(selectedDate);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasPriority = task.priority != TaskPriority.none;

    final chips = <Widget>[
      _MetaChip(icon: task.type.icon, label: task.type.label),
      if (task.timeInMinutes != null)
        _MetaChip(
          icon: Icons.schedule_rounded,
          label: formatTaskTime(context, task.timeInMinutes!),
          emphasize: !isCompleted && _isOverdue(),
        ),
      if (task.isWeekly)
        _MetaChip(
          icon: Icons.date_range_rounded,
          label: task.weeklyAnyDay
              ? (isCompleted
                    ? context.l10n.taskDoneThisWeek
                    : context.l10n.taskOnceThisWeek)
              : formatWeekDays(task.weeklyDays, task.effectiveWeekStart),
        ),
      if (hasPriority)
        _MetaChip(
          icon: Icons.local_fire_department_rounded,
          label: task.priority.label,
          color: task.priority.color,
        ),
    ];

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: isCompleted ? 0.62 : 1,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  width: 5,
                  color: hasPriority
                      ? task.priority.color
                      : scheme.primary.withValues(alpha: 0.0),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: Center(
                    child: _CheckCircle(
                      checked: isCompleted,
                      onChanged: (bool value) {
                        HapticFeedback.lightImpact();
                        onCompletionChanged(value);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(6, 14, 4, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          task.title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationThickness: 2,
                          ),
                        ),
                        if (task.note != null) ...<Widget>[
                          const SizedBox(height: 2),
                          Text(
                            task.note!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(spacing: 6, runSpacing: 6, children: chips),
                      ],
                    ),
                  ),
                ),
                ?dragHandle,
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isOverdue() {
    final minutes = task.timeInMinutes;
    if (minutes == null) {
      return false;
    }
    final now = DateTime.now();
    final day = dateOnly(selectedDate);
    if (day.isBefore(todayDate())) {
      return true;
    }
    if (!isSameDate(day, now)) {
      return false;
    }
    return now.hour * 60 + now.minute > minutes;
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.checked, required this.onChanged});

  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      checked: checked,
      button: true,
      label: checked ? context.l10n.markNotDone : context.l10n.markDone,
      child: InkResponse(
        onTap: () => onChanged(!checked),
        radius: 26,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: checked ? const Color(0xFF10B981) : Colors.transparent,
              border: Border.all(
                color: checked ? const Color(0xFF10B981) : scheme.outline,
                width: 2,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (Widget child, Animation<double> a) =>
                  ScaleTransition(scale: a, child: child),
              child: checked
                  ? const Icon(
                      Icons.check_rounded,
                      key: ValueKey<bool>(true),
                      size: 18,
                      color: Colors.white,
                    )
                  : const SizedBox(key: ValueKey<bool>(false)),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.color,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tint = emphasize ? scheme.error : (color ?? scheme.onSurfaceVariant);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (color ?? (emphasize ? scheme.error : scheme.primary))
            .withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13, color: tint),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tint,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
