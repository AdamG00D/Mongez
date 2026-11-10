<div align="center">

<img src="assets/icon.png" width="96" alt="Mongez logo" />

# Mongez · مُنجز

**A free, open-source, offline-first Arabic (RTL) planner for Android.**
Plan your day, keep your streaks, track yearly goals and screen time. No accounts, no ads, no tracking.

[![Flutter CI](https://github.com/AdamG00D/Mongez/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/AdamG00D/Mongez/actions/workflows/flutter-ci.yml)
[![Latest release](https://img.shields.io/github/v/release/AdamG00D/Mongez?label=download)](https://github.com/AdamG00D/Mongez/releases/latest)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](LICENSE)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

[العربية](#بالعربية) · [Download](#download) · [Features](#features) · [Getting started](#getting-started) · [Contributing](#contributing)

</div>

---

## Download

Get the latest APK from the **[Releases page](https://github.com/AdamG00D/Mongez/releases/latest)**
(Android 7.0+).

| File | For |
| --- | --- |
| `Mongez-<version>-arm64-v8a.apk` | Most phones from the last few years (recommended) |
| `Mongez-<version>-armeabi-v7a.apk` | Older 32-bit phones |
| `Mongez-<version>.apk` | Universal: works on any device, larger download |

Open the file on your phone and allow installing from this source when asked. Each release
lists SHA-256 checksums in `SHA256SUMS.txt`. Upgrading from 2.0.1 or older? Those builds used a
different signing key, so uninstall the old version first (export a backup from Settings
before you do).

## Features

- **Tasks:** one-off, daily and weekly tasks with priority, notes and reminder time.
  Drag-and-drop ordering, sort by time or priority, swipe to complete or delete (with undo),
  postpone, copy to tomorrow, carry unfinished tasks over.
- **Weekly tasks:** configurable first day of the week and "remind until done" modes.
- **History & stats:** a completion log that survives task deletion, per-type counters,
  streaks, a 7-day chart and most-completed tasks. You can delete single entries, all
  entries of one task, or the whole log.
- **Yearly goals:** milestone or numeric goals, progress vs. elapsed year, weekly motivation.
- **Screen time:** screen-on time, unlocks, per-app usage and daily limits (Android Usage
  Access; data never leaves the device).
- **Reminders:** exact-time notifications (also while the app is open) with a "Done ✓" action,
  follow-ups for unfinished tasks and an evening "plan tomorrow" reminder.
- **Look & feel:** 9 color themes, light / dark / AMOLED, built-in or photo backgrounds,
  celebration effects with sound.
- **Home-screen widgets:** a task list and a summary widget.
- **Backup / restore** to a JSON file. Fully offline.

## Privacy

No account, no ads, no trackers, and no Internet permission. See the [privacy policy](PRIVACY.md).
Store listing texts and graphics live in [`fastlane/metadata/android`](fastlane/metadata/android);
the Google Play release steps are in [`docs/GOOGLE_PLAY.md`](docs/GOOGLE_PLAY.md) (Arabic).

## Tech stack

| Area | Choice |
| --- | --- |
| UI | Flutter (Material 3), Arabic RTL first |
| State | [`provider`](https://pub.dev/packages/provider) |
| Storage | [`shared_preferences`](https://pub.dev/packages/shared_preferences) (JSON) |
| Notifications | [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) + `timezone` |
| Widgets | [`home_widget`](https://pub.dev/packages/home_widget) + native `RemoteViews` (Kotlin) |
| Screen time / sounds | Small Kotlin method channels (`ScreenTimeChannel.kt`, `SystemChannel.kt`) |

## Getting started

### Requirements

- Flutter stable with Dart **3.11.3+** (see `environment` in `pubspec.yaml`; developed on 3.47)
- Android SDK and JDK 17+
- An Android device or emulator. Android is the main target; iOS isn't set up.

### Run

```bash
git clone https://github.com/AdamG00D/Mongez.git
cd Mongez
flutter pub get
flutter run
```

### Checks (run these before opening a PR)

```bash
dart format lib test
flutter analyze
flutter test
```

### Release build

Release signing reads `android/key.properties`, which is git-ignored. Copy
[`android/key.properties.example`](android/key.properties.example) and point it to your own
keystore. Without it, `flutter build apk --release` falls back to the debug key, which is fine
for local testing. `build_release.sh` refuses to run without a key unless you set
`ALLOW_DEBUG_SIGNING=1`.

```bash
./build_release.sh        # analyze + test + signed APKs (universal and per-ABI)
./build_release.sh aab    # analyze + test + signed App Bundle
```

If your Flutter, Android SDK or JDK aren't on `PATH`, set `TOOLCHAINS` to a folder containing
`flutter/`, `android-sdk/` and `jdk-*`, or export `ANDROID_HOME` and `JAVA_HOME` yourself.

## Project structure

```text
lib/
  models/      plain data classes (Task, CompletionRecord, Goal, AppSettings, ...)
  providers/   ChangeNotifiers that own app state (tasks, goals, settings, screen time)
  screens/     one file per tab + the shell with the bottom navigation
  services/    storage, notifications, widgets, backup, platform channels
  theme/       palettes, backgrounds, ThemeData
  utils/       date helpers (week start, keys), motivation texts
  widgets/     reusable UI (task card, sheets, week strip, charts)
android/app/src/main/kotlin/   widget providers, screen-time and system channels
test/          logic tests + UI smoke tests
```

Some rules that keep the data consistent:

- **History** is a log of completions. Deleting or editing a task never removes its records.
  Records go away only when the same occurrence is un-checked, or when the user deletes them
  from the History tab.
- All completion changes go through `TaskMutations.toggle`, so the UI, widget taps and
  notification actions record history the same way.
- Week calculations always go through `utils/date_helpers.dart` (`startOfWeek`, `weekKey`).

## Contributing

Contributions of all sizes are welcome: bug reports, translations, UI polish, features and
tests. Please read [CONTRIBUTING.md](CONTRIBUTING.md) and our
[Code of Conduct](CODE_OF_CONDUCT.md) first. Security issues: see [SECURITY.md](SECURITY.md).

## License

[GPL-3.0](LICENSE) © AdamG00D and contributors.

---

## بالعربية

**مُنجز** تطبيق مفتوح المصدر ومجاني لتنظيم اليوم باللغة العربية. يعمل بدون إنترنت وبدون حسابات أو إعلانات.

- مهام لمرة واحدة ويومية وأسبوعية، مع الأولوية والملاحظات ووقت التذكير وترتيب بالسحب.
- سجل للإنجازات لا يضيع عند حذف المهمة، مع إمكانية حذف أي إنجاز منه يدويًا.
- أهداف سنوية، ووقت الشاشة، وثيمات وخلفيات، وويدجت للشاشة الرئيسية.
- تذكيرات في موعدها حتى والتطبيق مفتوح، مع زر «تم الإنجاز» داخل الإشعار.

**التحميل:** نزّل ملف APK من [صفحة الإصدارات](https://github.com/AdamG00D/Mongez/releases/latest).
لو مش عارف تختار، نزّل ملف `arm64-v8a` (مناسب لمعظم الموبايلات الحديثة) أو النسخة العامة.
لو عندك إصدار 2.0.1 أو أقدم، احذفه الأول (بعد ما تاخد نسخة احتياطية من الإعدادات) لأن مفتاح التوقيع اتغير.

**للمساهمة:** اقرأ [دليل المساهمة](CONTRIBUTING.md). المساهمات مرحب بها بالعربية أو الإنجليزية:
بلاغ عن مشكلة، أو اقتراح ميزة، أو Pull Request.
