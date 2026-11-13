# AGENTS.md

Guide for AI coding agents (and humans) working on Mongez (مُنجز): a Flutter planner for
Android with tasks, yearly goals, completion history, screen time and home-screen widgets.
It is fully offline: the app has **no INTERNET permission** and the privacy policy promises
that. Do not add network calls, analytics or SDKs that need it.

## Commands

```bash
flutter pub get          # also regenerates lib/l10n/app_localizations*.dart from the .arb files
dart format lib test
flutter analyze          # must report "No issues found!"
flutter test             # must pass
./build_release.sh       # release APKs (universal + per ABI); `./build_release.sh aab` for Play
```

`build_release.sh` runs analyze and test first. Flutter, the Android SDK and the JDK may not
be on `PATH`. In that case set `TOOLCHAINS` to a folder containing `flutter/`, `android-sdk/` and
`jdk-21*`. Release signing reads `android/key.properties`, which is git-ignored. Never commit
keys or `key.properties`.

## Layout

| Path | What lives there |
| --- | --- |
| `lib/main.dart` | Startup, provider wiring, background entry points (widget and notification callbacks) |
| `lib/app.dart` | `MaterialApp`, theme, locale |
| `lib/l10n/` | Translations (`app_ar.arb`, `app_en.arb`), generated classes, `l10n.dart` helper |
| `lib/models/` | Plain data classes and their JSON |
| `lib/providers/` | App state (`ChangeNotifier`s) |
| `lib/services/` | Storage, notifications, widget sync, backups, background actions |
| `lib/screens/`, `lib/widgets/` | UI |
| `lib/utils/date_helpers.dart` | All date, week and duration math and formatting |
| `android/app/src/main/kotlin/` | Widget providers, screen-time and system method channels |
| `test/` | `logic_test.dart` (rules), `ui_smoke_test.dart` (screens), `l10n_test.dart` (languages) |

## Rules that are easy to break

- **Languages.** The app is Arabic (RTL) and English (LTR). By default it follows the device
  language: Arabic or English, otherwise English. The user can override this in Settings.
  - Every user-facing string goes in **both** `lib/l10n/app_ar.arb` and `lib/l10n/app_en.arb`.
    `test/l10n_test.dart` fails if their keys differ.
  - In widgets use `context.l10n.key`. Code without a `BuildContext` (models, notifications,
    widget sync, background isolates) uses `L10n.current.key`.
  - Use `EdgeInsetsDirectional`, `AlignmentDirectional` and `PositionedDirectional`, never
    left/right. Gestures with a direction must check `Directionality`.
  - Dates go through the helpers in `date_helpers.dart`. Their patterns come from the ARB
    files (`dateFormat*`). Don't hard-code a locale in `DateFormat`.
- **History is permanent.** Deleting or editing a task must keep its completion records. Only
  explicit actions in the History tab, or un-checking the same occurrence, remove records.
  Backup import merges history; it never replaces it.
- **One completion path.** Every completion change goes through `TaskMutations.toggle`, so the
  app, the widget and the notification "Done ✓" action behave the same.
- **Week math** respects the user's first day of the week (default Saturday) through
  `date_helpers.dart`.
- **Background isolates** (widget taps, notification actions) start with nothing loaded. They
  go through `BackgroundActions`, which loads the settings and applies the language first.
- **Home-screen widgets** use `RemoteViews`, which only allows certain view classes (no plain
  `<View>`). Dart writes everything they show into the `widget_*` keys in
  `WidgetSyncService`, including texts in the app language and `widget_rtl` for direction.
  Kotlin only falls back to `res/values*/strings.xml`.
- **Pinned dependencies.** `home_widget` is pinned to exactly `0.9.0`, and
  `glance-appwidget` is forced to `1.1.1` in `android/build.gradle.kts`. Newer versions fail
  the *release* build, and CI only runs a debug build, so it won't catch that. Plugins are
  forced to JVM 17 in the same file.

## Releasing a version

Update all of these together:

1. `version:` in `pubspec.yaml` (`name+build`; the build number must increase).
2. `SettingsScreen.appVersion` in `lib/screens/settings_screen.dart`.
3. `CHANGELOG.md`.
4. Play "What's new": `fastlane/metadata/android/{ar,en-US}/changelogs/<build>.txt`
   (500 characters max each).

When permissions or data handling change, keep these in sync: `PRIVACY.md`, the in-app policy
(`privacy*` and `usageAccessDisclosure` keys in the ARB files), the store descriptions under
`fastlane/metadata/android/`, and `docs/GOOGLE_PLAY.md`.

## Checking on a device

Unit tests can't cover these. Test them on a phone when you touch them: notifications and the
"Done ✓" action (with the app open, in the background and closed), the home-screen widgets in
both languages, and screen time (needs "Usage access").
