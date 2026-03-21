import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import 'app.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'services/local_storage_service.dart';
import 'services/notification_service.dart';
import 'services/widget_background_handler.dart';
import 'services/widget_sync_service.dart';

@pragma('vm:entry-point')
Future<void> homeWidgetBackgroundCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  try {
    await initializeDateFormatting('ar');
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
  await HomeWidget.registerInteractivityCallback(homeWidgetBackgroundCallback);

  final storageService = LocalStorageService();
  final widgetSyncService = WidgetSyncService();
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(storageService)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(
            storageService: storageService,
            widgetSyncService: widgetSyncService,
            notificationService: notificationService,
          )..initialize(),
        ),
      ],
      child: const MongezApp(),
    ),
  );
}
