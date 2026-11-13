import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreWhenLoaded());
  }

  /// After a cold start: reopen the task that was being written when Android
  /// closed the app behind a permission page.
  void _restoreWhenLoaded() {
    if (!mounted) {
      return;
    }
    final provider = context.read<TaskProvider>();
    if (!provider.isLoading) {
      _restoreInterruptedDraft();
      return;
    }
    void listener() {
      if (provider.isLoading) {
        return;
      }
      provider.removeListener(listener);
      if (mounted) {
        _restoreInterruptedDraft();
      }
    }

    provider.addListener(listener);
  }

  /// Reopens the add/edit sheet with the saved draft, if a sheet was lost
  /// while the user was on a system permission page.
  Future<void> _restoreInterruptedDraft() async {
    final provider = context.read<TaskProvider>();
    final storage = provider.storageService;
    final draft = await storage.loadTaskDraft();
    if (draft == null) {
      return;
    }
    // One shot, whatever happens next.
    await storage.clearTaskDraft();
    if (!mounted) {
      return;
    }
    final savedAt = draft['savedAt'];
    final age = savedAt is int
        ? DateTime.now().difference(
            DateTime.fromMillisecondsSinceEpoch(savedAt),
          )
        : AddTaskSheet.draftMaxAge;
    if (age.isNegative || age >= AddTaskSheet.draftMaxAge) {
      return;
    }
    Task? task;
    final taskId = draft['taskId'];
    if (taskId is String) {
      for (final candidate in provider.allTasks) {
        if (candidate.id == taskId) {
          task = candidate;
        }
      }
      if (task == null) {
        return; // The task being edited no longer exists.
      }
    }
    AppNavigation.currentTab.value = AppNavigation.tasksTab;
    _openAddSheet(task: task, draft: draft);
  }

  @override
  void dispose() {
    _commands?.cancel();
    super.dispose();
  }

  Future<void> _openAddSheet({Task? task, Map<String, dynamic>? draft}) async {
    final provider = context.read<TaskProvider>();
    final selected = provider.selectedDate;
    await AddTaskSheet.show(
      context,
      task: task,
      draft: draft,
      initialDate: selected.isBefore(todayDate()) ? todayDate() : selected,
    );
    // A draft is still stored only if the sheet went away in the middle of the
    // permission flow; bring it back.
    if (mounted) {
      await _restoreInterruptedDraft();
    }
  }

  Future<void> _pickDate(TaskProvider provider) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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
      _snack(context.l10n.allDoneSnack);
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
          ? context.l10n.taskDeletedKeepHistory
          : context.l10n.taskDeleted,
      action: SnackBarAction(
        label: context.l10n.undo,
        onPressed: () => provider.restoreTask(removed),
      ),
    );
  }

  Future<void> _deleteWithHistory(TaskProvider provider, Task task) async {
    final count = provider.historyCountForTask(task.id);
    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(context.l10n.deleteTaskAndHistoryTitle),
        content: Text(
          context.l10n.deleteTaskAndHistoryMessage(task.title, count),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.delete),
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
      context.l10n.taskAndHistoryDeleted,
      action: SnackBarAction(
        label: context.l10n.undo,
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
                title: Text(
                  isDone ? context.l10n.markNotDone : context.l10n.markDone,
                ),
                onTap: () {
                  close();
                  _toggle(provider, task, !isDone);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: Text(context.l10n.edit),
                onTap: () {
                  close();
                  _openAddSheet(task: task);
                },
              ),
              if (task.isNormal && !isDone)
                ListTile(
                  leading: const Icon(Icons.next_plan_rounded),
                  title: Text(context.l10n.postponeToNextDay),
                  onTap: () {
                    close();
                    provider.postponeTask(task.id);
                    _snack(context.l10n.postponedSnack);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: Text(context.l10n.copyToTomorrow),
                onTap: () {
                  close();
                  provider.duplicateTaskTo(task.id, addDays(day, 1));
                  _snack(context.l10n.copiedSnack);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: Theme.of(sheetContext).colorScheme.error,
                ),
                title: Text(
                  context.l10n.deleteTask,
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
                    context.l10n.deleteTaskAndHistory,
                    style: TextStyle(
                      color: Theme.of(sheetContext).colorScheme.error,
                    ),
                  ),
                  subtitle: Text(
                    context.l10n.deletesCompletionsToo(
                      provider.historyCountForTask(task.id),
                    ),
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
          _snack(context.l10n.sortedByTime);
        }
      case 'priority':
        await provider.sortSelectedDayByPriority();
        if (mounted) {
          _snack(context.l10n.sortedByPriority);
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
                ? context.l10n.nothingToCarry
                : context.l10n.movedTasks(
                    moved,
                    carryTargetLabel(context.l10n, target),
                  ),
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
        label: Text(
          context.l10n.newTask,
          style: const TextStyle(fontWeight: FontWeight.w800),
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
                          taskCount: allTasks.length,
                          doneCount: done,
                          carryCount: allTasks
                              .where(
                                (Task t) =>
                                    t.isNormal &&
                                    !t.isCompletedOn(selectedDate),
                              )
                              .length,
                          carryTarget: TaskProvider.carryTarget(selectedDate),
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
                              ? context.l10n.navTasks
                              : context.l10n.tasksHeaderCount(
                                  visibleTasks.length,
                                ),
                          trailing: visibleTasks.length > 1
                              ? Text(
                                  context.l10n.longPressToDrag,
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
                            ? context.l10n.noTasksForDay
                            : context.l10n.allDoneTitle,
                        message: allTasks.isEmpty
                            ? context.l10n.noTasksMessage
                            : context.l10n.completedHiddenMessage,
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

/// Where "move unfinished" sends tasks, phrased to follow "to"
/// ("tomorrow" / "الغد", "Friday" / "يوم الجمعة").
String carryTargetLabel(AppLocalizations l10n, DateTime target) {
  final today = todayDate();
  if (isSameDate(target, addDays(today, 1))) {
    return l10n.carryToTomorrow;
  }
  if (isSameDate(target, today)) {
    return l10n.carryToToday;
  }
  if (isSameDate(target, addDays(today, 2))) {
    return l10n.carryToDayAfter;
  }
  return l10n.carryToWeekday(weekDayName(target.weekday));
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onMenu,
    required this.hideCompleted,
    required this.taskCount,
    required this.doneCount,
    required this.carryCount,
    required this.carryTarget,
  });

  final ValueChanged<String> onMenu;
  final bool hideCompleted;

  /// Tasks on the selected day, and how many of them are done.
  final int taskCount;
  final int doneCount;

  /// Unfinished one-off tasks on the selected day, and the day they'd move to.
  final int carryCount;
  final DateTime carryTarget;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final carryTo = carryTargetLabel(l10n, carryTarget);
    return Row(
      children: <Widget>[
        const MongezLogo(size: 42),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _Greeting(),
              Text(
                l10n.appName,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          tooltip: l10n.options,
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: onMenu,
          position: PopupMenuPosition.under,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          constraints: const BoxConstraints(minWidth: 240, maxWidth: 300),
          menuPadding: const EdgeInsets.symmetric(vertical: 6),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            _MenuLabel(l10n.sortTodayTasks),
            _menuItem(
              context,
              value: 'time',
              icon: Icons.schedule_rounded,
              title: l10n.byTime,
              enabled: taskCount > 1,
            ),
            _menuItem(
              context,
              value: 'priority',
              icon: Icons.local_fire_department_rounded,
              title: l10n.byPriority,
              enabled: taskCount > 1,
            ),
            const PopupMenuDivider(height: 10),
            _menuItem(
              context,
              value: 'hide',
              icon: hideCompleted
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              title: hideCompleted ? l10n.showCompleted : l10n.hideCompleted,
              subtitle: hideCompleted && doneCount > 0
                  ? l10n.hiddenNow(l10n.tasksCount(doneCount))
                  : null,
            ),
            _menuItem(
              context,
              value: 'carry',
              icon: Icons.redo_rounded,
              title: l10n.moveUnfinishedTo(carryTo),
              subtitle: carryCount > 0
                  ? l10n.oneTimeCount(l10n.tasksCount(carryCount))
                  : l10n.noUnfinishedOneTime,
              enabled: carryCount > 0,
            ),
          ],
        ),
      ],
    );
  }

  static PopupMenuItem<String> _menuItem(
    BuildContext context, {
    required String value,
    required IconData icon,
    required String title,
    String? subtitle,
    bool enabled = true,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final faded = scheme.onSurface.withValues(alpha: 0.38);
    return PopupMenuItem<String>(
      value: value,
      enabled: enabled,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (enabled ? scheme.primary : scheme.onSurface).withValues(
                alpha: enabled ? 0.12 : 0.06,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: enabled ? scheme.primary : faded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    height: 1.3,
                    color: enabled ? scheme.onSurface : faded,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.3,
                      color: enabled ? scheme.onSurfaceVariant : faded,
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

/// Small section caption inside the options menu.
class _MenuLabel extends PopupMenuEntry<String> {
  const _MenuLabel(this.text);

  final String text;

  @override
  double get height => 30;

  @override
  bool represents(String? value) => false;

  @override
  State<_MenuLabel> createState() => _MenuLabelState();
}

class _MenuLabelState extends State<_MenuLabel> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 4),
      child: Text(
        widget.text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Time-of-day greeting that updates itself when the period changes (morning,
/// afternoon, evening, night) and when the app comes back to the foreground.
class _Greeting extends StatefulWidget {
  const _Greeting();

  @override
  State<_Greeting> createState() => _GreetingState();
}

class _GreetingState extends State<_Greeting> with WidgetsBindingObserver {
  Timer? _timer;
  String _text = greetingForNow();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _schedule();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  void _schedule() {
    _timer?.cancel();
    final now = DateTime.now();
    _timer = Timer(
      nextGreetingChange(now).difference(now) + const Duration(seconds: 1),
      _refresh,
    );
  }

  void _refresh() {
    if (!mounted) {
      return;
    }
    final text = greetingForNow();
    if (text != _text) {
      setState(() => _text = text);
    }
    _schedule();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      _text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
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
        isDone ? context.l10n.swipeUndo : context.l10n.swipeDone,
        true,
      ),
      secondaryBackground: background(
        scheme.error,
        Icons.delete_outline_rounded,
        context.l10n.delete,
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
