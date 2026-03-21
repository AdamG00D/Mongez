import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/date_helpers.dart';
import '../widgets/add_task_sheet.dart';
import '../widgets/day_navigation_bar.dart';
import '../widgets/empty_tasks_state.dart';
import '../widgets/task_card.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _pickDate(BuildContext context, TaskProvider provider) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('ar'),
    );

    if (selected == null) {
      return;
    }

    provider.setSelectedDate(selected);
  }

  void _openAddTaskSheet(
    BuildContext context, {
    Task? task,
    DateTime? initialDate,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) =>
          AddTaskSheet(taskToEdit: task, initialDate: initialDate),
    );
  }

  Future<void> _openTaskActions(
    BuildContext parentContext,
    TaskProvider provider,
    Task task,
  ) async {
    await showModalBottomSheet<void>(
      context: parentContext,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('تعديل المهمة'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _openAddTaskSheet(parentContext, task: task);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('حذف المهمة'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  provider.deleteTask(task.id);
                },
              ),
              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final selectedDate = taskProvider.selectedDate;
    final tasks = taskProvider.tasksForSelectedDate;
    final today = dateOnly(DateTime.now());
    final addTaskDefaultDate = isSameDate(selectedDate, today)
        ? today
        : tomorrowDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text('مُنجّز'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'الإعدادات',
          ),
        ],
      ),
      body: taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: <Widget>[
                  _SelectedDateBanner(selectedDate: selectedDate),
                  const SizedBox(height: 10),
                  DayNavigationBar(
                    onPrevious: taskProvider.goToPreviousDay,
                    onNext: taskProvider.goToNextDay,
                    onTomorrow: taskProvider.goToTomorrow,
                    onPickDate: () => _pickDate(context, taskProvider),
                    isTomorrowSelected: taskProvider.isTomorrowSelected,
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: tasks.isEmpty
                        ? const EmptyTasksState()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                            itemCount: tasks.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (BuildContext context, int index) {
                              final task = tasks[index];
                              return TaskCard(
                                task: task,
                                selectedDate: selectedDate,
                                onTap: () => _openTaskActions(
                                  context,
                                  taskProvider,
                                  task,
                                ),
                                onCompletionChanged: (bool isCompleted) {
                                  taskProvider.toggleTask(task, isCompleted);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _openAddTaskSheet(context, initialDate: addTaskDefaultDate),
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('إضافة مهمة'),
      ),
    );
  }
}

class _SelectedDateBanner extends StatelessWidget {
  const _SelectedDateBanner({required this.selectedDate});

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: <Color>[
              colorScheme.primaryContainer,
              colorScheme.secondaryContainer,
            ],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              relativeDateLabel(selectedDate),
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatFullDate(selectedDate),
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
