import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/task_type.dart';
import '../providers/task_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<TaskProvider>().history;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('سجل الإنجاز')),
      body: history.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.history_toggle_off_rounded, size: 62),
                    const SizedBox(height: 12),
                    Text(
                      'لم يتم تسجيل أي إنجاز بعد',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'عند إنهاء المهام ستظهر هنا من الأحدث إلى الأقدم.',
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) {
                final record = history[index];
                final completionDate = DateFormat(
                  'EEEE، d MMMM yyyy',
                  'ar',
                ).format(record.completedForDate);
                final completionTime = DateFormat(
                  'hh:mm a',
                  'ar',
                ).format(record.completedAt);

                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      child: Icon(switch (record.taskType) {
                        TaskType.daily => Icons.repeat_rounded,
                        TaskType.weekly => Icons.view_week_rounded,
                        TaskType.normal => Icons.task_alt_rounded,
                      }),
                    ),
                    title: Text(
                      record.taskTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'اكتملت في $completionDate • $completionTime\n'
                        'النوع: ${record.taskType.label}',
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
