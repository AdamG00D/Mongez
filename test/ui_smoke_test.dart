import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mongez/app.dart';
import 'package:mongez/app_navigation.dart';
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
import 'package:mongez/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> buildApp({String theme = 'light'}) async {
  final storage = LocalStorageService();
  final settings = SettingsProvider(storage);
  await settings.initialize();
  await settings.update(
    (s) => s.copyWith(
      themeMode: theme == 'dark' ? ThemeMode.dark : ThemeMode.light,
    ),
  );
  final goals = GoalsProvider(storage);
  await goals.initialize();
  await goals.addGoal(
    title: 'قراءة 12 كتابًا',
    target: 12,
    unit: 'كتاب',
    why: 'لأن القراءة توسّع تفكيري',
  );
  await goals.addGoal(title: 'السفر');
  final tasks = TaskProvider(
    storageService: storage,
    widgetSyncService: WidgetSyncService(),
  );
  await tasks.initialize();
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
    child: const MongezApp(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('ar');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('home_widget'), (
          MethodCall call,
        ) async {
          return null;
        });
  });

  for (final theme in <String>['light', 'dark']) {
    testWidgets('all tabs and sheets render ($theme)', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues(<String, Object>{});
      AppNavigation.currentTab.value = AppNavigation.tasksTab;

      final app = await tester.runAsync(() => buildApp(theme: theme));
      await tester.pumpWidget(app!);
      await tester.pumpAndSettle();

      // Tasks tab with seeded demo tasks.
      expect(find.text('مُنجز'), findsWidgets);
      expect(find.text('شرب 8 أكواب ماء'), findsOneWidget);

      // Complete a task via its check circle.
      await tester.tap(find.bySemanticsLabel('تم الإنجاز').first);
      await tester.pumpAndSettle();

      // Add task sheet.
      await tester.tap(find.text('مهمة جديدة'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(SegmentedButton<TaskType>),
          matching: find.text('أسبوعية'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('يبدأ الأسبوع يوم'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).first, 'مهمة اختبار');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('إضافة المهمة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('إضافة المهمة'));
      await tester.pumpAndSettle();
      expect(find.text('يبدأ الأسبوع يوم'), findsNothing); // sheet closed
      final taskProvider = Provider.of<TaskProvider>(
        tester.element(find.byType(MaterialApp)),
        listen: false,
      );
      final added = taskProvider.allTasks.where(
        (t) => t.title == 'مهمة اختبار',
      );
      expect(added, hasLength(1));
      expect(added.single.type, TaskType.weekly);
      expect(added.single.sortOrder, isNotNull);

      for (final tab in <int>[
        AppNavigation.goalsTab,
        AppNavigation.statsTab,
        AppNavigation.screenTimeTab,
        AppNavigation.settingsTab,
        AppNavigation.tasksTab,
      ]) {
        AppNavigation.currentTab.value = tab;
        await tester.pumpAndSettle();
      }

      // Goals: progress step and goal sheet.
      AppNavigation.currentTab.value = AppNavigation.goalsTab;
      await tester.pumpAndSettle();
      expect(find.text('قراءة 12 كتابًا'), findsOneWidget);
      await tester.ensureVisible(find.byTooltip('زيادة').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('زيادة').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('1 / 12'), findsOneWidget);
      await tester.tap(find.text('هدف جديد'));
      await tester.pumpAndSettle();
      expect(find.textContaining('هدف جديد لعام'), findsOneWidget);
      Navigator.of(tester.element(find.textContaining('هدف جديد لعام'))).pop();
      await tester.pumpAndSettle();

      // History shows the completion counter.
      AppNavigation.currentTab.value = AppNavigation.statsTab;
      await tester.pumpAndSettle();
      expect(find.text('عدّاد الإنجاز حسب النوع'), findsOneWidget);

      // Settings: scroll through everything and switch palette/background.
      AppNavigation.currentTab.value = AppNavigation.settingsTab;
      await tester.pumpAndSettle();
      await tester.tap(find.text('زمردي'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('نقاط'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('نقاط'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('حول التطبيق'),
        400,
        scrollable: find
            .descendant(
              of: find.byType(SettingsScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();

      AppNavigation.currentTab.value = AppNavigation.tasksTab;
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
