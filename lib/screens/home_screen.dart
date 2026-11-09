import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app_navigation.dart';
import '../models/task.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../services/system_service.dart';
import '../utils/date_helpers.dart';
import '../utils/motivation.dart';
import '../widgets/add_task_sheet.dart';
import '../widgets/common.dart';
import '../widgets/task_card.dart';
import '../widgets/week_strip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<AppCommand>? _commands;

  @override
  void initState() {
    super.initState();
    _commands = AppNavigation.commands.listen((AppCommand command) {
      if (command == AppCommand.addTask && mounted) {
        _openAddSheet();
      }
    });
  }

  @override
  void dispose() {
    _commands?.cancel();
    super.dispose();
  }

  void _openAddSheet({Task? task}) {
    final provider = context.read<TaskProvider>();
    final selected = provider.selectedDate;
    AddTaskSheet.show(
      context,
      task: task,
      initialDate: selected.isBefore(todayDate()) ? todayDate() : selected,
    );
  }

  Future<void> _pickDate(TaskProvider provider) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('ar'),
    );
    if (selected != null) {
      provider.setSelectedDate(selected);
    }
  }

  void _snack(String text, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          action: action,
          // A SnackBar with an action stays until dismissed by default.
          persist: false,
          duration: Duration(seconds: action == null ? 2 : 4),
        ),
      );
  }

  Future<void> _toggle(TaskProvider provider, Task task, bool value) async {
    final day = provider.selectedDate;
    final wasDone = task.isCompletedOn(day);
    await provider.toggleTask(task, value);
    if (!mounted || !value || wasDone) {
      return;
    }
    final celebrate = context.read<SettingsProvider>().settings.celebrate;
    final tasks = provider.tasksForDay(day);
    final allDone =
        tasks.isNotEmpty && tasks.every((Task t) => t.isCompletedOn(day));
    if (!celebrate) {
      return;
    }
    if (allDone) {
      HapticFeedback.mediumImpact();
      SystemService.playCelebrate();
      showCelebration(context);
      _snack('أنجزت كل مهام اليوم! 🎉 استمر هكذا');
    } else {
      SystemService.playDone();
    }
  }

  Future<void> _delete(TaskProvider provider, Task task) async {
    final hadHistory = provider.historyCountForTask(task.id) > 0;
    final removed = await provider.deleteTask(task.id);
    if (removed == null || !mounted) {
      return;
    }
    _snack(
      hadHistory
          ? 'تم حذف المهمة (إنجازاتها السابقة باقية في السجل)'
          : 'تم حذف المهمة',
      action: SnackBarAction(
        label: 'تراجع',
        onPressed: () => provider.restoreTask(removed),
      ),
    );
  }

  Future<void> _deleteWithHistory(TaskProvider provider, Task task) async {
    final count = provider.historyCountForTask(task.id);
    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('حذف المهمة وسجلها؟'),
        content: Text(
          'سيتم حذف "${task.title}" ومعها $count ${count == 1 ? 'إنجاز' : 'إنجازات'} من السجل والعدّادات.',
        ),
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
    if (ok != true || !mounted) {
      return;
    }
    final records = await provider.deleteHistoryForTask(task.id);
    final removed = await provider.deleteTask(task.id);
    if (!mounted) {
      return;
    }
    _snack(
      'تم حذف المهمة وسجلها',
      action: SnackBarAction(
        label: 'تراجع',
        onPressed: () async {
          if (removed != null) {
            await provider.restoreTask(removed);
          }
          await provider.restoreHistory(records);
        },
      ),
    );
  }

  Future<void> _openTaskActions(TaskProvider provider, Task task) async {
    final day = provider.selectedDate;
    final isDone = task.isCompletedOn(day);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        void close() => Navigator.of(sheetContext).pop();
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              ListTile(
                leading: Icon(
                  isDone ? Icons.undo_rounded : Icons.check_circle_rounded,
                ),
                title: Text(isDone ? 'إلغاء الإنجاز' : 'تم الإنجاز'),
                onTap: () {
                  close();
                  _toggle(provider, task, !isDone);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('تعديل'),
                onTap: () {
                  close();
                  _openAddSheet(task: task);
                },
              ),
              if (task.isNormal && !isDone)
                ListTile(
                  leading: const Icon(Icons.next_plan_rounded),
                  title: const Text('تأجيل لليوم التالي'),
                  onTap: () {
                    close();
                    provider.postponeTask(task.id);
                    _snack('تم تأجيل المهمة يومًا');
                  },
                ),
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: const Text('نسخ إلى الغد'),
                onTap: () {
                  close();
                  provider.duplicateTaskTo(task.id, addDays(day, 1));
                  _snack('تمت إضافة نسخة لليوم التالي');
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: Theme.of(sheetContext).colorScheme.error,
                ),
                title: Text(
                  'حذف المهمة',
                  style: TextStyle(
                    color: Theme.of(sheetContext).colorScheme.error,
                  ),
                ),
                onTap: () {
                  close();
                  _delete(provider, task);
                },
              ),
              if (provider.historyCountForTask(task.id) > 0)
                ListTile(
                  leading: Icon(
                    Icons.delete_sweep_rounded,
                    color: Theme.of(sheetContext).colorScheme.error,
                  ),
                  title: Text(
                    'حذف المهمة وسجلها',
                    style: TextStyle(
                      color: Theme.of(sheetContext).colorScheme.error,
                    ),
                  ),
                  subtitle: Text(
                    'يحذف أيضًا ${provider.historyCountForTask(task.id)} إنجاز من السجل',
                  ),
                  onTap: () {
                    close();
                    _deleteWithHistory(provider, task);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onMenu(String value, TaskProvider provider) async {
    final settings = context.read<SettingsProvider>();
    switch (value) {
      case 'time':
        await provider.sortSelectedDayByTime();
        if (mounted) {
          _snack('تم ترتيب المهام حسب الوقت');
        }
      case 'priority':
        await provider.sortSelectedDayByPriority();
        if (mounted) {
          _snack('تم ترتيب المهام حسب الأولوية');
        }
      case 'hide':
        await settings.update(
          (s) => s.copyWith(hideCompleted: !s.hideCompleted),
        );
      case 'carry':
        final day = provider.selectedDate;
        final target = TaskProvider.carryTarget(day);
        final moved = await provider.carryOverUnfinished(day);
        if (mounted) {
          _snack(
            moved == 0
                ? 'لا توجد مهام لمرة واحدة غير منجزة لنقلها. المهام اليومية والأسبوعية تتكرر تلقائيًا.'
                : 'تم نقل $moved ${moved == 1 ? 'مهمة' : 'مهام'} إلى ${relativeDateLabel(target)}',
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final settings = context.watch<SettingsProvider>().settings;
    final selectedDate = provider.selectedDate;
    final allTasks = provider.tasksForSelectedDate;
    final done = allTasks
        .where((Task t) => t.isCompletedOn(selectedDate))
        .length;
    final visibleTasks = settings.hideCompleted
        ? allTasks.where((Task t) => !t.isCompletedOn(selectedDate)).toList()
        : allTasks;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-task',
        onPressed: () => _openAddSheet(),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'مهمة جديدة',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              bottom: false,
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    sliver: SliverList.list(
                      children: <Widget>[
                        _Header(
                          onMenu: (String v) => _onMenu(v, provider),
                          hideCompleted: settings.hideCompleted,
                        ),
                        const SizedBox(height: 12),
                        WeekStrip(
                          selectedDate: selectedDate,
                          onSelect: provider.setSelectedDate,
                          onPickDate: () => _pickDate(provider),
                          dayProgress: (DateTime day) {
                            final list = provider.tasksForDay(day);
                            return (
                              list
                                  .where((Task t) => t.isCompletedOn(day))
                                  .length,
                              list.length,
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        _ProgressHero(
                          date: selectedDate,
                          done: done,
                          total: allTasks.length,
                        ),
                        SectionTitle(
                          visibleTasks.isEmpty
                              ? 'المهام'
                              : 'المهام (${visibleTasks.length})',
                          trailing: visibleTasks.length > 1
                              ? Text(
                                  'اضغط مطولًا للسحب',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                  if (visibleTasks.isEmpty)
                    SliverToBoxAdapter(
                      child: EmptyState(
                        icon: allTasks.isEmpty
                            ? Icons.wb_twilight_rounded
                            : Icons.celebration_rounded,
                        title: allTasks.isEmpty
                            ? 'لا توجد مهام لهذا اليوم'
                            : 'أنجزت كل شيء!',
                        message: allTasks.isEmpty
                            ? 'ابدأ بأهم 3 مهام. القائمة القصيرة تُنجز.'
                            : 'المهام المكتملة مخفية. يمكنك إظهارها من القائمة.',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverReorderableList(
                        itemCount: visibleTasks.length,
                        onReorderItem: (int oldIndex, int newIndex) {
                          HapticFeedback.selectionClick();
                          provider.reorderVisible(
                            visibleTasks,
                            oldIndex,
                            newIndex,
                          );
                        },
                        proxyDecorator:
                            (Widget child, int index, Animation<double> a) {
                              return AnimatedBuilder(
                                animation: a,
                                builder: (BuildContext context, Widget? c) {
                                  final t = Curves.easeInOut.transform(a.value);
                                  return Transform.scale(
                                    scale: lerpDouble(1, 1.03, t),
                                    child: Material(
                                      color: Colors.transparent,
                                      elevation: lerpDouble(0, 8, t)!,
                                      shadowColor: Colors.black26,
                                      borderRadius: BorderRadius.circular(22),
                                      child: c,
                                    ),
                                  );
                                },
                                child: child,
                              );
                            },
                        itemBuilder: (BuildContext context, int index) {
                          final task = visibleTasks[index];
                          return Padding(
                            key: ValueKey<String>(task.id),
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ReorderableDelayedDragStartListener(
                              index: index,
                              child: _SwipeableTask(
                                task: task,
                                selectedDate: selectedDate,
                                onToggle: (bool v) =>
                                    _toggle(provider, task, v),
                                onDelete: () => _delete(provider, task),
                                onTap: () => _openTaskActions(provider, task),
                                dragHandle: ReorderableDragStartListener(
                                  index: index,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Icon(
                                      Icons.drag_indicator_rounded,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  SliverToBoxAdapter(child: SizedBox(height: 96 + bottomPad)),
                ],
              ),
            ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onMenu, required this.hideCompleted});

  final ValueChanged<String> onMenu;
  final bool hideCompleted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: <Widget>[
        const MongezLogo(size: 42),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                greetingForNow(),
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'مُنجز',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'خيارات',
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: onMenu,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'time',
              child: ListTile(
                leading: Icon(Icons.schedule_rounded),
                title: Text('ترتيب حسب الوقت'),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'priority',
              child: ListTile(
                leading: Icon(Icons.local_fire_department_rounded),
                title: Text('ترتيب حسب الأولوية'),
              ),
            ),
            PopupMenuItem<String>(
              value: 'hide',
              child: ListTile(
                leading: Icon(
                  hideCompleted
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                ),
                title: Text(
                  hideCompleted ? 'إظهار المكتملة' : 'إخفاء المكتملة',
                ),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'carry',
              child: ListTile(
                leading: Icon(Icons.redo_rounded),
                title: Text('نقل غير المنجز لليوم التالي'),
                subtitle: Text('المهام التي لمرة واحدة فقط'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressHero extends StatelessWidget {
  const _ProgressHero({
    required this.date,
    required this.done,
    required this.total,
  });

  final DateTime date;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ratio = total == 0 ? 0.0 : done / total;
    return GradientCard(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  relativeDateLabel(date),
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  formatFullDate(date),
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    progressMessage(done, total),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ProgressRing(
            value: ratio,
            size: 88,
            stroke: 9,
            color: Colors.white,
            trackColor: Colors.white.withValues(alpha: 0.22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '${(ratio * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                Text(
                  '$done/$total',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeableTask extends StatelessWidget {
  const _SwipeableTask({
    required this.task,
    required this.selectedDate,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
    required this.dragHandle,
  });

  final Task task;
  final DateTime selectedDate;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final Widget dragHandle;

  @override
  Widget build(BuildContext context) {
    final isDone = task.isCompletedOn(selectedDate);
    final scheme = Theme.of(context).colorScheme;

    Widget background(Color color, IconData icon, String text, bool start) {
      return Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        alignment: start
            ? AlignmentDirectional.centerStart
            : AlignmentDirectional.centerEnd,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    return Dismissible(
      key: ValueKey<String>('dismiss-${task.id}'),
      background: background(
        const Color(0xFF10B981),
        isDone ? Icons.undo_rounded : Icons.check_rounded,
        isDone ? 'إلغاء' : 'تم',
        true,
      ),
      secondaryBackground: background(
        scheme.error,
        Icons.delete_outline_rounded,
        'حذف',
        false,
      ),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggle(!isDone);
          return false;
        }
        return true;
      },
      onDismissed: (_) => onDelete(),
      child: TaskCard(
        task: task,
        selectedDate: selectedDate,
        onCompletionChanged: onToggle,
        onTap: onTap,
        dragHandle: dragHandle,
      ),
    );
  }
}
