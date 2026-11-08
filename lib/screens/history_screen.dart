import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/completion_record.dart';
import '../models/task_type.dart';
import '../providers/task_provider.dart';
import '../utils/date_helpers.dart';
import '../widgets/common.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TaskType? _filter;

  static const Map<TaskType, Color> _typeColors = <TaskType, Color>{
    TaskType.normal: Color(0xFF3B82F6),
    TaskType.daily: Color(0xFF10B981),
    TaskType.weekly: Color(0xFF8B5CF6),
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final counts = provider.completionCounts;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final perDay = provider.completionsPerDay(7);
    final today = todayDate();
    final weekStart = startOfWeek(today);
    final monthStart = DateTime(today.year, today.month);
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    final records = provider.history
        .where((CompletionRecord r) => _filter == null || r.taskType == _filter)
        .toList();

    // Flatten into day headers + records for a lazy sliver list.
    final rows = <Object>[];
    String? lastKey;
    for (final record in records) {
      final key = dateKey(record.completedAt);
      if (key != lastKey) {
        rows.add(dateOnly(record.completedAt));
        lastKey = key;
      }
      rows.add(record);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverSafeArea(
            bottom: false,
            sliver: SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverList.list(
                children: <Widget>[
                  Text(
                    'السجل والإحصائيات',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GradientCard(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'إجمالي الإنجازات',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${counts.total}',
                                style: textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'هذا الأسبوع ${provider.completionsSince(weekStart)} • هذا الشهر ${provider.completionsSince(monthStart)}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            const Icon(
                              Icons.local_fire_department_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                            Text(
                              '${provider.currentStreak}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'أيام متتالية',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'الأفضل: ${provider.bestStreak}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SectionTitle('عدّاد الإنجاز حسب النوع'),
                  Row(
                    children: TaskType.values.map((TaskType type) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: StatTile(
                            icon: type.icon,
                            label: 'مهام ${type.label}',
                            value: '${counts.of(type)}',
                            color: _typeColors[type],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SectionTitle('آخر 7 أيام'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 16, 10, 12),
                      child: MiniBarChart(
                        values: perDay.map((int v) => v.toDouble()).toList(),
                        labels: List<String>.generate(
                          7,
                          (int i) =>
                              arabicWeekDayShort[addDays(
                                today,
                                i - 6,
                              ).weekday]!,
                        ),
                        valueLabel: (double v) => v.toInt().toString(),
                      ),
                    ),
                  ),
                  if (provider.topTasks().isNotEmpty) ...<Widget>[
                    const SectionTitle('الأكثر إنجازًا'),
                    Card(
                      child: Column(
                        children: provider.topTasks().map((TaskStat stat) {
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              stat.type.icon,
                              color: _typeColors[stat.type],
                            ),
                            title: Text(
                              stat.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              '×${stat.count}',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: scheme.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  SectionTitle(
                    'سجل الإنجاز',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.lock_rounded,
                          size: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'محفوظ دائمًا',
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        _filterChip(null, 'الكل (${counts.total})'),
                        for (final type in TaskType.values)
                          _filterChip(
                            type,
                            '${type.label} (${counts.of(type)})',
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          if (rows.isEmpty)
            const SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.history_rounded,
                title: 'لا إنجازات بعد',
                message: 'كل مهمة تنهيها تُسجَّل هنا للأبد مع وقت إنجازها.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemCount: rows.length,
                itemBuilder: (BuildContext context, int index) {
                  final row = rows[index];
                  if (row is DateTime) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
                      child: Text(
                        '${relativeDateLabel(row)} • ${formatShortDate(row)}',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return _RecordTile(
                    record: row as CompletionRecord,
                    color: _typeColors[row.taskType]!,
                  );
                },
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 24 + bottomPad)),
        ],
      ),
    );
  }

  Widget _filterChip(TaskType? type, String label) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _filter == type,
        onSelected: (_) => setState(() => _filter = type),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record, required this.color});

  final CompletionRecord record;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final time = DateFormat('h:mm a', 'ar').format(record.completedAt);
    final forDate = isSameDate(record.completedForDate, record.completedAt)
        ? null
        : formatShortDate(record.completedForDate);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(record.taskType.icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      record.taskTitle,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      forDate == null
                          ? '${record.taskType.label} • $time'
                          : '${record.taskType.label} • $time • عن يوم $forDate',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
