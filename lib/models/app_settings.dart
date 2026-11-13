import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

enum StartPage { auto, today, tomorrow }

extension StartPageLabel on StartPage {
  String get label {
    return switch (this) {
      StartPage.auto => L10n.current.startPageAuto,
      StartPage.today => L10n.current.today,
      StartPage.tomorrow => L10n.current.tomorrow,
    };
  }
}

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.language = AppLanguage.system,
    this.paletteId = 'ocean',
    this.backgroundId = 'aurora',
    this.customBackgroundPath,
    this.backgroundDim = 0.35,
    this.amoledDark = false,
    this.weekStartDay = DateTime.saturday,
    this.startPage = StartPage.auto,
    this.followUpReminders = true,
    this.followUpMinutes = 60,
    this.planningReminder = true,
    this.planningReminderMinutes = 21 * 60,
    this.goalsReminder = true,
    this.hideCompleted = false,
    this.celebrate = true,
  });

  final ThemeMode themeMode;

  /// App language; [AppLanguage.system] follows the device.
  final AppLanguage language;
  final String paletteId;
  final String backgroundId;
  final String? customBackgroundPath;

  /// Darkening overlay for custom photo backgrounds (0..0.8).
  final double backgroundDim;
  final bool amoledDark;

  /// Default first day of week (DateTime.monday..DateTime.sunday).
  final int weekStartDay;
  final StartPage startPage;

  /// Re-notify if a timed task is still not done [followUpMinutes] later.
  final bool followUpReminders;
  final int followUpMinutes;

  /// Evening reminder to plan tomorrow.
  final bool planningReminder;
  final int planningReminderMinutes;

  /// Weekly motivational reminder about the yearly goals.
  final bool goalsReminder;
  final bool hideCompleted;
  final bool celebrate;

  AppSettings copyWith({
    ThemeMode? themeMode,
    AppLanguage? language,
    String? paletteId,
    String? backgroundId,
    String? customBackgroundPath,
    bool clearCustomBackground = false,
    double? backgroundDim,
    bool? amoledDark,
    int? weekStartDay,
    StartPage? startPage,
    bool? followUpReminders,
    int? followUpMinutes,
    bool? planningReminder,
    int? planningReminderMinutes,
    bool? goalsReminder,
    bool? hideCompleted,
    bool? celebrate,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      paletteId: paletteId ?? this.paletteId,
      backgroundId: backgroundId ?? this.backgroundId,
      customBackgroundPath: clearCustomBackground
          ? null
          : (customBackgroundPath ?? this.customBackgroundPath),
      backgroundDim: backgroundDim ?? this.backgroundDim,
      amoledDark: amoledDark ?? this.amoledDark,
      weekStartDay: weekStartDay ?? this.weekStartDay,
      startPage: startPage ?? this.startPage,
      followUpReminders: followUpReminders ?? this.followUpReminders,
      followUpMinutes: followUpMinutes ?? this.followUpMinutes,
      planningReminder: planningReminder ?? this.planningReminder,
      planningReminderMinutes:
          planningReminderMinutes ?? this.planningReminderMinutes,
      goalsReminder: goalsReminder ?? this.goalsReminder,
      hideCompleted: hideCompleted ?? this.hideCompleted,
      celebrate: celebrate ?? this.celebrate,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'themeMode': themeMode.name,
    'language': language.name,
    'paletteId': paletteId,
    'backgroundId': backgroundId,
    'customBackgroundPath': customBackgroundPath,
    'backgroundDim': backgroundDim,
    'amoledDark': amoledDark,
    'weekStartDay': weekStartDay,
    'startPage': startPage.name,
    'followUpReminders': followUpReminders,
    'followUpMinutes': followUpMinutes,
    'planningReminder': planningReminder,
    'planningReminderMinutes': planningReminderMinutes,
    'goalsReminder': goalsReminder,
    'hideCompleted': hideCompleted,
    'celebrate': celebrate,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    const defaults = AppSettings();
    T pick<T>(String key, T fallback) {
      final value = json[key];
      return value is T ? value : fallback;
    }

    final weekStart = (json['weekStartDay'] as num?)?.toInt();

    return AppSettings(
      themeMode: ThemeMode.values.firstWhere(
        (ThemeMode mode) => mode.name == json['themeMode'],
        orElse: () => defaults.themeMode,
      ),
      language: AppLanguage.values.firstWhere(
        (AppLanguage language) => language.name == json['language'],
        orElse: () => defaults.language,
      ),
      paletteId: pick<String>('paletteId', defaults.paletteId),
      backgroundId: pick<String>('backgroundId', defaults.backgroundId),
      customBackgroundPath: json['customBackgroundPath'] as String?,
      backgroundDim:
          (json['backgroundDim'] as num?)?.toDouble() ?? defaults.backgroundDim,
      amoledDark: pick<bool>('amoledDark', defaults.amoledDark),
      weekStartDay: (weekStart != null && weekStart >= 1 && weekStart <= 7)
          ? weekStart
          : defaults.weekStartDay,
      startPage: StartPage.values.firstWhere(
        (StartPage page) => page.name == json['startPage'],
        orElse: () => defaults.startPage,
      ),
      followUpReminders: pick<bool>(
        'followUpReminders',
        defaults.followUpReminders,
      ),
      followUpMinutes:
          (json['followUpMinutes'] as num?)?.toInt() ??
          defaults.followUpMinutes,
      planningReminder: pick<bool>(
        'planningReminder',
        defaults.planningReminder,
      ),
      planningReminderMinutes:
          (json['planningReminderMinutes'] as num?)?.toInt() ??
          defaults.planningReminderMinutes,
      goalsReminder: pick<bool>('goalsReminder', defaults.goalsReminder),
      hideCompleted: pick<bool>('hideCompleted', defaults.hideCompleted),
      celebrate: pick<bool>('celebrate', defaults.celebrate),
    );
  }
}
