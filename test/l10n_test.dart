import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mongez/l10n/l10n.dart';
import 'package:mongez/models/app_settings.dart';
import 'package:mongez/utils/date_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await initializeDateFormatting();
  });

  tearDown(() => L10n.apply(AppLanguage.ar));

  group('language resolution', () {
    test('an explicit choice wins over the device', () {
      expect(
        L10n.resolve(AppLanguage.ar, const <Locale>[Locale('en', 'US')]),
        'ar',
      );
      expect(
        L10n.resolve(AppLanguage.en, const <Locale>[Locale('ar', 'EG')]),
        'en',
      );
    });

    test('system follows the first supported device language', () {
      expect(
        L10n.resolve(AppLanguage.system, const <Locale>[Locale('ar', 'EG')]),
        'ar',
      );
      expect(
        L10n.resolve(AppLanguage.system, const <Locale>[
          Locale('fr'),
          Locale('ar'),
          Locale('en'),
        ]),
        'ar',
      );
      expect(
        L10n.resolve(AppLanguage.system, const <Locale>[Locale('en', 'GB')]),
        'en',
      );
    });

    test('system falls back to English for unsupported languages', () {
      expect(
        L10n.resolve(AppLanguage.system, const <Locale>[Locale('fr')]),
        'en',
      );
      expect(L10n.resolve(AppLanguage.system, const <Locale>[]), 'en');
    });

    test('apply reports changes and switches the strings', () {
      L10n.apply(AppLanguage.ar);
      expect(L10n.isArabic, isTrue);
      expect(L10n.apply(AppLanguage.ar), isFalse);
      expect(L10n.apply(AppLanguage.en), isTrue);
      expect(L10n.current.navTasks, 'Tasks');
      expect(
        L10n.apply(
          AppLanguage.system,
          deviceLocales: const <Locale>[Locale('ar', 'EG')],
        ),
        isTrue,
      );
      expect(L10n.current.navTasks, 'المهام');
    });
  });

  test('language is saved with the settings and defaults to system', () {
    expect(const AppSettings().language, AppLanguage.system);
    final json = const AppSettings(language: AppLanguage.en).toJson();
    expect(AppSettings.fromJson(json).language, AppLanguage.en);
    // Settings saved before this feature existed.
    expect(
      AppSettings.fromJson(<String, dynamic>{}).language,
      AppLanguage.system,
    );
  });

  test('helpers follow the active language', () {
    L10n.apply(AppLanguage.en);
    expect(weekDayName(DateTime.friday), 'Friday');
    expect(weekDayName(DateTime.friday, short: true), 'Fri');
    expect(formatMinutesOfDay(21 * 60 + 5), '9:05 PM');
    expect(formatDurationShort(const Duration(minutes: 85)), '1 h 25 min');
    expect(formatFullDate(DateTime(2026, 11, 13)), 'Friday, November 13, 2026');
    expect(
      formatWeekDays(<int>{DateTime.monday, DateTime.friday}, DateTime.monday),
      'Mon, Fri',
    );
    expect(L10n.current.tasksCount(1), '1 task');
    expect(L10n.current.tasksCount(4), '4 tasks');

    L10n.apply(AppLanguage.ar);
    expect(weekDayName(DateTime.friday, short: true), 'الجمعة');
    expect(formatMinutesOfDay(21 * 60 + 5), '9:05 م');
    expect(formatDurationShort(const Duration(minutes: 85)), '1 س 25 د');
    expect(L10n.current.tasksCount(1), 'مهمة واحدة');
    expect(L10n.current.tasksCount(2), 'مهمتان');
    expect(L10n.current.tasksCount(5), '5 مهام');
    expect(L10n.current.tasksCount(20), '20 مهمة');
  });

  test('Arabic and English translations have the same keys', () {
    Set<String> keys(String path) {
      final json =
          jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
      return json.keys.where((String k) => !k.startsWith('@')).toSet();
    }

    final en = keys('lib/l10n/app_en.arb');
    final ar = keys('lib/l10n/app_ar.arb');
    expect(ar.difference(en), isEmpty, reason: 'only in Arabic');
    expect(en.difference(ar), isEmpty, reason: 'missing in Arabic');
  });
}
