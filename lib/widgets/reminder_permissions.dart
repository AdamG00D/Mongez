import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/reminder_coordinator.dart';
import '../services/notification_service.dart';
import '../services/system_service.dart';

/// Makes sure a timed reminder can actually fire: asks for the notification
/// permission and, when needed, the "Alarms & reminders" (exact alarm)
/// permission. Safe to call repeatedly; it only prompts for what's missing.
Future<void> ensureReminderPermissions(BuildContext context) async {
  final notifications = context.read<NotificationService>();
  final reminders = context.read<ReminderCoordinator>();
  var changed = false;

  if (!await notifications.areNotificationsEnabled()) {
    final granted = await notifications.requestNotificationPermission();
    changed |= granted;
    if (!granted && context.mounted) {
      final open = await _explain(
        context,
        icon: Icons.notifications_off_rounded,
        title: 'الإشعارات متوقفة',
        message:
            'لن يصلك تذكير المهمة لأن إشعارات مُنجز متوقفة. فعّلها من الإعدادات.',
        action: 'فتح الإعدادات',
      );
      if (open) {
        await SystemService.openNotificationSettings();
      }
      return;
    }
  }

  if (!context.mounted) {
    return;
  }
  if (!await notifications.canScheduleExact()) {
    if (!context.mounted) {
      return;
    }
    final allow = await _explain(
      context,
      icon: Icons.alarm_rounded,
      title: 'اسمح بالمنبّهات والتذكيرات',
      message:
          'ليصل التذكير في موعده بالضبط، فعّل خيار "المنبّهات والتذكيرات" لمُنجز في الصفحة التالية.',
      action: 'السماح',
    );
    if (allow) {
      changed |= await notifications.requestExactAlarmPermission();
    }
  }

  if (changed) {
    reminders.schedule();
  }
}

Future<bool> _explain(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  required String action,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      icon: Icon(icon),
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('لاحقًا'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(action),
        ),
      ],
    ),
  );
  return result ?? false;
}
