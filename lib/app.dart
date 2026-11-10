import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/reminder_coordinator.dart';
import 'providers/screen_time_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/task_provider.dart';
import 'screens/shell_screen.dart';
import 'theme/app_theme.dart';
import 'theme/palettes.dart';

class MongezApp extends StatefulWidget {
  const MongezApp({super.key});

  @override
  State<MongezApp> createState() => _MongezAppState();
}

class _MongezAppState extends State<MongezApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }
    final tasks = context.read<TaskProvider>();
    tasks.reloadFromStorageIfChanged().then((_) {
      // Keeps the widget on the right day and rolls the reminder horizon.
      tasks.refreshWidget();
      if (mounted) {
        context.read<ReminderCoordinator>().schedule(
          delay: const Duration(seconds: 1),
        );
      }
    });
    final screenTime = context.read<ScreenTimeProvider>();
    // Only refresh usage if the screen-time tab has been opened (it may have
    // just come back from the "Usage access" settings page).
    if (screenTime.checked) {
      screenTime.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final palette = paletteById(settings.paletteId);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مُنجز',
      locale: const Locale('ar'),
      supportedLocales: const <Locale>[Locale('ar'), Locale('en')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: settings.themeMode,
      theme: AppTheme.build(palette: palette, brightness: Brightness.light),
      darkTheme: AppTheme.build(
        palette: palette,
        brightness: Brightness.dark,
        amoled: settings.amoledDark,
      ),
      themeAnimationDuration: const Duration(milliseconds: 280),
      home: const ShellScreen(),
    );
  }
}
