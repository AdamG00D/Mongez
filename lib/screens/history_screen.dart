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

  void _snack(String text, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          action: action,
          persist: false,
          duration: Duration(seconds: action == null ? 2 : 4),
        ),
      );
  }

  void _offerUndo(
    TaskProvider provider,
    List<CompletionRecord> removed,
    String text,
  ) {
    if (removed.isEmpty || !mounted) {
      return;
    }
    _snack(
      text,
      action: SnackBarAction(
        label: 'تراجع',
        onPressed: () => provider.restoreHistory(removed),
      ),
    );
  }

  Future<bool> _confirm({
    required String title,
    required String message,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _openRecordActions(
    TaskProvider provider,
    CompletionRecord record,
  ) async {
    final sameTask = provider.historyCountForTask(record.taskId);
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        final error = Theme.of(sheetContext).colorScheme.error;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                child: Text(
                  record.taskTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  'أُنجزت ${formatFullDate(record.completedAt)} • ${DateFormat('h:mm a', 'ar').format(record.completedAt)}',
                  style: Theme.of(sheetContext).textTheme.bodySmall,
                ),
              ),
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: error),
                title: Text(
                  'حذف هذا الإنجاز من السجل',
                  style: TextStyle(color: error),
                ),
                onTap: () => Navigator.pop(sheetContext, 'one'),
              ),
              if (sameTask > 1)
                ListTile(
                  leading: Icon(Icons.delete_sweep_rounded, color: error),
                  title: Text(
                    'حذف كل إنجازات هذه المهمة ($sameTask)',
                    style: TextStyle(color: error),
                  ),
                  onTap: () => Navigator.pop(sheetContext, 'task'),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (!mounted) {
      return;
    }
    switch (choice) {
      case 'one':
        final removed = await provider.deleteHistoryRecord(record.id);
        _offerUndo(provider, removed, 'تم الحذف من السجل');
      case 'task':
        final ok = await _confirm(
          title: 'حذف كل إنجازات المهمة؟',
          message:
              'سيتم حذف $sameTask إنجاز لـ "${record.taskTitle}" من السجل والعدّادات. المهمة نفسها لن تُحذف.',
        );
        if (ok) {
          final removed = await provider.deleteHistoryForTask(record.taskId);
          _offerUndo(provider, removed, 'تم حذف ${removed.length} إنجاز');
        }
    }
  }

  Future<void> _clearAll(TaskProvider provider) async {
    final ok = await _confirm(
      title: 'مسح السجل بالكامل؟',
      message:
          'سيتم حذف كل الإنجازات (${provider.history.length}) والعدّادات وسلاسل الأيام. مهامك نفسها لن تُحذف.',
    );
    if (!ok) {
      return;
    }
    final removed = await provider.clearHistory();
    _offerUndo(provider, removed, 'تم مسح السجل');
  }

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
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverList.list(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'السجل والإحصائيات',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (provider.history.isNotEmpty)
                        PopupMenuButton<String>(
                          tooltip: 'خيارات السجل',
                          icon: const Icon(Icons.more_vert_rounded),
                          onSelected: (_) => _clearAll(provider),
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: 'clear',
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.delete_forever_rounded,
                                      color: scheme.error,
                                    ),
                                    title: const Text('مسح السجل بالكامل'),
                                  ),
                                ),
                              ],
                        ),
                    ],
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
                              arabicWeekDayNames[addDays(
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
                          Icons.touch_app_rounded,
                          size: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'اضغط على إنجاز لحذفه',
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
            if (rows.isEmpty)
              const SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.history_rounded,
                  title: 'لا إنجازات بعد',
                  message:
                      'كل مهمة تنهيها تُسجَّل هنا مع وقت إنجازها، ولا يضيع السجل عند حذف المهمة.',
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
                    final record = row as CompletionRecord;
                    return _RecordTile(
                      record: record,
                      color: _typeColors[record.taskType]!,
                      onTap: () => _openRecordActions(provider, record),
                    );
                  },
                ),
              ),
            SliverToBoxAdapter(child: SizedBox(height: 24 + bottomPad)),
          ],
        ),
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
  const _RecordTile({
    required this.record,
    required this.color,
    required this.onTap,
  });

  final CompletionRecord record;
  final Color color;
  final VoidCallback onTap;

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
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onTap,
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
      ),
    );
  }
}
