import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'app_navigation.dart';
import 'providers/goals_provider.dart';
import 'providers/reminder_coordinator.dart';
import 'providers/screen_time_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/task_provider.dart';
import 'services/background_actions.dart';
import 'services/local_storage_service.dart';
import 'services/notification_service.dart';
import 'services/screen_time_service.dart';
import 'services/widget_background_handler.dart';
import 'services/widget_sync_service.dart';
import 'utils/date_helpers.dart';

@pragma('vm:entry-point')
Future<void> homeWidgetBackgroundCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  try {
    await initializeDateFormatting();
  } catch (_) {}
  if (uri == null) {
    return;
  }
  try {
    await WidgetBackgroundHandler.handle(uri);
  } catch (error, stackTrace) {
    debugPrint('[Mongez.Widget] callback ERROR: $error');
    debugPrint(stackTrace.toString());
  }
}

/// Runs when the "Done ✓" action is pressed while the app isn't open.
@pragma('vm:entry-point')
Future<void> notificationBackgroundHandler(
  NotificationResponse response,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  try {
    await initializeDateFormatting();
  } catch (_) {}
  await handleTaskNotificationAction(response, inBackground: true);
}

/// Parses a task payload (`task|<id>|<yyyy-MM-dd>`) and marks it done.
Future<bool> handleTaskNotificationAction(
  NotificationResponse response, {
  required bool inBackground,
  TaskProvider? provider,
}) async {
  if (response.actionId != NotificationService.actionDone) {
    return false;
  }
  final parts = (response.payload ?? '').split('|');
  if (parts.length != 3 || parts[0] != 'task') {
    return false;
  }
  final day = dateFromKey(parts[2]);
  if (provider != null) {
    await provider.toggleTaskByIdForDate(
      taskId: parts[1],
      day: day,
      forceValue: true,
    );
  } else {
    await BackgroundActions.toggleTask(
      taskId: parts[1],
      day: day,
      forceValue: true,
      fallbackToToday: false,
    );
  }
  return true;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await HomeWidget.registerInteractivityCallback(homeWidgetBackgroundCallback);

  final storage = LocalStorageService();
  final notifications = NotificationService()..foregroundDelivery = true;
  await notifications.initialize(
    backgroundHandler: notificationBackgroundHandler,
  );

  final settingsProvider = SettingsProvider(storage);
  await settingsProvider.initialize();

  final goalsProvider = GoalsProvider(storage);
  await goalsProvider.initialize();

  final taskProvider = TaskProvider(
    storageService: storage,
    widgetSyncService: WidgetSyncService(),
  );
  final screenTimeProvider = ScreenTimeProvider(ScreenTimeService(), storage);

  final reminders = ReminderCoordinator(
    notifications: notifications,
    tasks: taskProvider,
    goals: goalsProvider,
    settings: settingsProvider,
  );
  taskProvider.onDataChanged = reminders.schedule;
  goalsProvider.onDataChanged = reminders.schedule;
  settingsProvider.onRemindersChanged = reminders.schedule;
  settingsProvider.onWeekStartChanged = taskProvider.onWeekStartChanged;
  settingsProvider.onLanguageChanged = () {
    taskProvider.refreshWidget();
    reminders.schedule();
  };

  // Background isolates (widget taps, notification actions) ping this port so
  // the open UI reloads immediately.
  final refreshPort = ReceivePort();
  IsolateNameServer.removePortNameMapping(mainIsolatePortName);
  IsolateNameServer.registerPortWithName(
    refreshPort.sendPort,
    mainIsolatePortName,
  );
  refreshPort.listen((dynamic _) => taskProvider.reloadFromStorageIfChanged());

  // Foreground notification taps / actions.
  NotificationService.responses.listen((NotificationResponse response) {
    _routeNotification(response, taskProvider);
  });

  taskProvider.initialize(startPage: settingsProvider.settings.startPage).then((
    _,
  ) async {
    final launch = await notifications.launchResponse();
    if (launch != null) {
      _routeNotification(launch, taskProvider);
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<TaskProvider>.value(value: taskProvider),
        ChangeNotifierProvider<GoalsProvider>.value(value: goalsProvider),
        ChangeNotifierProvider<ScreenTimeProvider>.value(
          value: screenTimeProvider,
        ),
        Provider<ReminderCoordinator>.value(value: reminders),
        Provider<NotificationService>.value(value: notifications),
      ],
      child: const MongezApp(),
    ),
  );
}

void _routeNotification(NotificationResponse response, TaskProvider tasks) {
  final payload = response.payload ?? '';
  if (response.actionId == NotificationService.actionDone) {
    handleTaskNotificationAction(
      response,
      inBackground: false,
      provider: tasks,
    );
    return;
  }
  final parts = payload.split('|');
  if (parts.first == 'goals') {
    AppNavigation.currentTab.value = AppNavigation.goalsTab;
    return;
  }
  if ((parts.first == 'task' && parts.length == 3) ||
      (parts.first == 'plan' && parts.length == 2)) {
    tasks.setSelectedDate(dateFromKey(parts.last));
    AppNavigation.currentTab.value = AppNavigation.tasksTab;
  }
}
