import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/widgets.dart' show BuildContext;
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

/// The user's language preference, stored in the settings.
enum AppLanguage { system, ar, en }

extension BuildContextL10n on BuildContext {
  /// Strings for the language the app is currently shown in.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// The active app language, available everywhere — including code without a
/// [BuildContext] (notifications, widgets, background isolates).
///
/// Widgets should prefer `context.l10n` so they rebuild when it changes.
class L10n {
  L10n._();

  static const List<String> supportedCodes = <String>['ar', 'en'];
  static const String _lastResolvedKey = 'mongez.language.resolved';

  static AppLocalizations _current = lookupAppLocalizations(const Locale('ar'));
  static AppLanguage _preference = AppLanguage.system;

  static AppLocalizations get current => _current;
  static String get code => _current.localeName;
  static Locale get locale => Locale(code);
  static bool get isArabic => code == 'ar';

  /// Picks the language code for [preference]. "System" uses the first
  /// device language the app supports, falling back to English.
  static String resolve(AppLanguage preference, List<Locale> deviceLocales) {
    if (preference != AppLanguage.system) {
      return preference.name;
    }
    for (final locale in deviceLocales) {
      if (supportedCodes.contains(locale.languageCode)) {
        return locale.languageCode;
      }
    }
    return 'en';
  }

  /// Applies [preference] (or re-reads the device languages when it is
  /// [AppLanguage.system]). Returns true when the language changed.
  static bool apply(AppLanguage preference, {List<Locale>? deviceLocales}) {
    _preference = preference;
    final code = resolve(
      preference,
      deviceLocales ?? PlatformDispatcher.instance.locales,
    );
    _rememberResolved(code);
    if (code == _current.localeName) {
      return false;
    }
    _current = lookupAppLocalizations(Locale(code));
    return true;
  }

  /// Re-resolves after the device language changed.
  static bool refreshFromDevice() => apply(_preference);

  /// For background isolates: headless engines may not receive the device
  /// languages, so fall back to the language the app last resolved.
  static Future<void> applyInBackground(AppLanguage preference) async {
    final device = PlatformDispatcher.instance.locales;
    if (preference != AppLanguage.system || device.isNotEmpty) {
      apply(preference, deviceLocales: device);
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final last = prefs.getString(_lastResolvedKey);
      if (last != null && supportedCodes.contains(last)) {
        _preference = preference;
        _current = lookupAppLocalizations(Locale(last));
      }
    } catch (_) {}
  }

  static void _rememberResolved(String code) {
    SharedPreferences.getInstance()
        .then((SharedPreferences prefs) {
          if (prefs.getString(_lastResolvedKey) != code) {
            return prefs.setString(_lastResolvedKey, code);
          }
          return true;
        })
        .catchError((Object _) => false);
  }
}
