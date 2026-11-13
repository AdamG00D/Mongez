import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/l10n.dart';

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
  void didChangeLocales(List<Locale>? locales) {
    // Following the device language: pick up a change made in system settings.
    context.read<SettingsProvider>().refreshDeviceLanguage();
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
      onGenerateTitle: (BuildContext context) => context.l10n.appName,
      locale: L10n.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
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
      // Keyed by language so every screen rebuilds its texts (including
      // ones computed outside the widget tree) when the language changes.
      home: ShellScreen(key: ValueKey<String>(L10n.code)),
    );
  }
}
