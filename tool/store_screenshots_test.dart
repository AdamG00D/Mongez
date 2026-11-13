// Renders the phone screenshots for the store listing into
// fastlane/metadata/android/ar/images/phoneScreenshots/.
//
// Not part of the normal test run. From the repo root:
//   flutter test tool/store_screenshots_test.dart
//
// 1080x2160 px (Google Play accepts at most a 2:1 aspect ratio).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mongez/app.dart';
import 'package:mongez/app_navigation.dart';
import 'package:mongez/l10n/l10n.dart';
import 'package:mongez/models/app_settings.dart';
import 'package:mongez/models/completion_record.dart';
import 'package:mongez/models/task_type.dart';
import 'package:mongez/providers/goals_provider.dart';
import 'package:mongez/providers/reminder_coordinator.dart';
import 'package:mongez/providers/screen_time_provider.dart';
import 'package:mongez/providers/settings_provider.dart';
import 'package:mongez/providers/task_provider.dart';
import 'package:mongez/services/local_storage_service.dart';
import 'package:mongez/services/notification_service.dart';
import 'package:mongez/services/screen_time_service.dart';
import 'package:mongez/services/widget_sync_service.dart';
import 'package:mongez/utils/date_helpers.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String outDir = 'fastlane/metadata/android/ar/images/phoneScreenshots';
const double pixelRatio = 2.7;
const Size physical = Size(1080, 2160);

Future<void> loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final bytes = File(path).readAsBytesSync();
    loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

String flutterRoot() {
  final env = Platform.environment['FLUTTER_ROOT'];
  if (env != null && env.isNotEmpty) {
    return env;
  }
  // .../flutter/bin/cache/dart-sdk/bin/dart
  return File(
    Platform.resolvedExecutable,
  ).parent.parent.parent.parent.parent.path;
}

String fontAwesomeDir() {
  final config = File('.dart_tool/package_config.json').readAsStringSync();
  final match = RegExp(
    r'"rootUri":\s*"file://([^"]*font_awesome_flutter[^"]*)"',
  ).firstMatch(config);
  return '${Uri.decodeFull(match!.group(1)!)}/lib/fonts';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsProvider settings;
  late TaskProvider tasks;
  late GoalsProvider goals;

  Future<Widget> buildApp() async {
    final storage = LocalStorageService();
    settings = SettingsProvider(storage);
    await settings.initialize();
    // The store screenshots are the Arabic listing; tests run with an English
    // device locale, so pin the language.
    await settings.update(
      (s) => s.copyWith(themeMode: ThemeMode.light, language: AppLanguage.ar),
    );
    goals = GoalsProvider(storage);
    await goals.initialize();
    await goals.addGoal(title: 'قراءة 12 كتابًا', target: 12, unit: 'كتاب');
    await goals.addGoal(title: 'ادخار 50 ألفًا', target: 50, unit: 'ألف');
    await goals.addGoal(title: 'تعلّم الإنجليزية');
    await goals.addGoal(title: 'السفر لأداء العمرة');
    for (var i = 0; i < 7; i++) {
      await goals.changeProgress(goals.goals.first.id, 1);
    }
    for (var i = 0; i < 4; i++) {
      await goals.changeProgress(goals.goals[1].id, 5);
    }

    tasks = TaskProvider(
      storageService: storage,
      widgetSyncService: WidgetSyncService(),
    );
    await tasks.initialize(startPage: StartPage.today);
    final today = todayDate();
    await tasks.addTask(
      title: 'مراجعة عرض المشروع',
      date: today,
      type: TaskType.normal,
      timeInMinutes: 10 * 60,
      priority: TaskPriority.high,
      note: 'الشرائح من 5 إلى 12',
    );
    await tasks.addTask(
      title: 'قراءة 20 صفحة',
      date: today,
      type: TaskType.daily,
      timeInMinutes: 20 * 60 + 30,
      priority: TaskPriority.medium,
    );
    await tasks.addTask(
      title: 'الاتصال بالوالدة',
      date: today,
      type: TaskType.normal,
      timeInMinutes: 18 * 60,
    );
    await tasks.addTask(
      title: 'شراء مستلزمات البيت',
      date: today,
      type: TaskType.normal,
    );
    // Today's progress, plus a few weeks of history so the stats look alive.
    final todays = tasks.tasksForDay(today);
    for (final task in todays.take(todays.length - 1)) {
      await tasks.toggleTaskByIdForDate(
        taskId: task.id,
        day: today,
        forceValue: true,
      );
    }
    final repeating = tasks.allTasks.where((t) => !t.isNormal).toList();
    final records = <CompletionRecord>[];
    for (var back = 1; back <= 24; back++) {
      final day = addDays(today, -back);
      final count = 1 + (back * 7) % repeating.length;
      for (final task in repeating.take(count)) {
        records.add(
          CompletionRecord(
            id: 'shot-${task.id}-$back',
            taskId: task.id,
            taskTitle: task.title,
            taskType: task.type,
            completedAt: day.add(const Duration(hours: 20)),
            completedForDate: day,
            taskTimeInMinutes: task.timeInMinutes,
          ),
        );
      }
    }
    await tasks.restoreHistory(records);
    tasks.setSelectedDate(today);

    final notifications = NotificationService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settings),
        ChangeNotifierProvider<TaskProvider>.value(value: tasks),
        ChangeNotifierProvider<GoalsProvider>.value(value: goals),
        ChangeNotifierProvider<ScreenTimeProvider>.value(
          value: ScreenTimeProvider(ScreenTimeService(), storage),
        ),
        Provider<ReminderCoordinator>.value(
          value: ReminderCoordinator(
            notifications: notifications,
            tasks: tasks,
            goals: goals,
            settings: settings,
          ),
        ),
        Provider<NotificationService>.value(value: notifications),
      ],
      child: RepaintBoundary(
        key: const ValueKey<String>('shot'),
        child: const MongezApp(),
      ),
    );
  }

  setUpAll(() async {
    await initializeDateFormatting('ar');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('home_widget'),
          (MethodCall call) async => null,
        );
    final material = '${flutterRoot()}/bin/cache/artifacts/material_fonts';
    await loadFont('Cairo', <String>['fonts/Cairo-Variable.ttf']);
    await loadFont('MaterialIcons', <String>[
      '$material/MaterialIcons-Regular.otf',
    ]);
    await loadFont('Roboto', <String>['$material/Roboto-Regular.ttf']);
    final fa = fontAwesomeDir();
    for (final entry in <String, String>{
      'FontAwesomeBrands': 'fa-brands-400.ttf',
      'FontAwesomeSolid': 'fa-solid-900.ttf',
      'FontAwesomeRegular': 'fa-regular-400.ttf',
    }.entries) {
      final file = File('$fa/${entry.value}');
      if (file.existsSync()) {
        await loadFont('packages/font_awesome_flutter/${entry.key}', <String>[
          file.path,
        ]);
      }
    }
    Directory(outDir).createSync(recursive: true);
  });

  testWidgets('store screenshots', (WidgetTester tester) async {
    debugDisableShadows = false;
    tester.view.physicalSize = physical;
    tester.view.devicePixelRatio = pixelRatio;
    addTearDown(tester.view.reset);
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppNavigation.currentTab.value = AppNavigation.tasksTab;

    final app = await tester.runAsync(buildApp);
    await tester.pumpWidget(app!);
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage('assets/icon.png'),
        tester.element(find.byType(MaterialApp)),
      );
    });
    await tester.pumpAndSettle();

    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey<String>('shot')),
      );
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: pixelRatio);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        File('$outDir/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
        image.dispose();
      });
    }

    Future<void> tab(int index) async {
      AppNavigation.currentTab.value = index;
      await tester.pumpAndSettle();
    }

    await shot('1_tasks');

    await tester.tap(find.text('مهمة جديدة'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'تمرين 30 دقيقة');
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('2_new_task');
    Navigator.of(tester.element(find.text('إضافة المهمة'))).pop();
    await tester.pumpAndSettle();

    await tab(AppNavigation.goalsTab);
    await shot('3_goals');

    await tab(AppNavigation.statsTab);
    await shot('4_history');

    await tab(AppNavigation.settingsTab);
    await shot('5_settings');

    await tester.runAsync(
      () => settings.update(
        (s) => s.copyWith(themeMode: ThemeMode.dark, paletteId: 'violet'),
      ),
    );
    await tab(AppNavigation.tasksTab);
    await tester.pump(const Duration(seconds: 1));
    await shot('6_dark');

    debugDisableShadows = true;
    // Plugins without a test implementation (home widget stream) complain.
    tester.takeException();
  });
}
