import 'dart:async';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../app_navigation.dart';
import '../theme/backgrounds.dart';
import 'goals_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'screen_time_screen.dart';
import 'settings_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  final Set<int> _visited = <int>{AppNavigation.tasksTab};
  StreamSubscription<Uri?>? _widgetClicks;

  @override
  void initState() {
    super.initState();
    AppNavigation.currentTab.addListener(_onTabChanged);
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_handleWidgetUri);
    _widgetClicks = HomeWidget.widgetClicked.listen(_handleWidgetUri);
  }

  @override
  void dispose() {
    AppNavigation.currentTab.removeListener(_onTabChanged);
    _widgetClicks?.cancel();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() => _visited.add(AppNavigation.currentTab.value));
  }

  void _handleWidgetUri(Uri? uri) {
    if (uri == null) {
      return;
    }
    if (uri.host == 'add' || uri.path.contains('add')) {
      AppNavigation.currentTab.value = AppNavigation.tasksTab;
      // Let the tasks tab build before asking it to open the sheet.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => AppNavigation.send(AppCommand.addTask),
      );
    } else {
      AppNavigation.currentTab.value = AppNavigation.tasksTab;
    }
  }

  static const List<Widget> _tabs = <Widget>[
    HomeScreen(),
    GoalsScreen(),
    HistoryScreen(),
    ScreenTimeScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final current = AppNavigation.currentTab.value;

    return PopScope(
      canPop: current == AppNavigation.tasksTab,
      onPopInvokedWithResult: (bool didPop, _) {
        if (!didPop) {
          AppNavigation.currentTab.value = AppNavigation.tasksTab;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppBackground(
          child: IndexedStack(
            index: current,
            children: List<Widget>.generate(_tabs.length, (int i) {
              if (!_visited.contains(i)) {
                return const SizedBox.shrink();
              }
              return ScaffoldMessenger(child: _tabs[i]);
            }),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: current,
          onDestinationSelected: (int index) =>
              AppNavigation.currentTab.value = index,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.check_circle_outline_rounded),
              selectedIcon: Icon(Icons.check_circle_rounded),
              label: 'المهام',
            ),
            NavigationDestination(
              icon: Icon(Icons.flag_outlined),
              selectedIcon: Icon(Icons.flag_rounded),
              label: 'الأهداف',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights_rounded),
              label: 'السجل',
            ),
            NavigationDestination(
              icon: Icon(Icons.phone_android_outlined),
              selectedIcon: Icon(Icons.phone_android_rounded),
              label: 'وقت الشاشة',
            ),
            NavigationDestination(
              icon: Icon(Icons.tune_outlined),
              selectedIcon: Icon(Icons.tune_rounded),
              label: 'الإعدادات',
            ),
          ],
        ),
      ),
    );
  }
}
