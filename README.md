# Mongez

Mongez is a mobile-first Flutter todo app focused on planning and tracking tasks with a smooth, minimal UI and strong Arabic RTL support.

## App Identity

- App name: `Mongez`
- Android package: `com.adamg00d.mongez`
- Main target: Android

## Core Features

- Tasks: normal, daily and weekly; priority, notes, drag-and-drop ordering, swipe actions with undo,
  postpone / carry over.
- Weekly tasks with configurable first day of week and "remind until done" modes.
- Yearly goals with progress, motivation and weekly reminders.
- Permanent completion history with per-type counters, streaks and charts.
- Screen time (Android Usage Access): screen-on time, unlocks, per-app usage and daily limits.
- 9 color themes, light/dark/AMOLED, built-in or photo backgrounds.
- Two Android home-screen widgets (task list + summary).
- Local notifications with a "Done ✓" action, follow-ups and an evening planning reminder.
- JSON backup / restore. Fully offline.

## Tech Stack

- Flutter + Dart
- State management: `provider`
- Local storage: `shared_preferences`
- Screen time: native `UsageStatsManager` channel (`ScreenTimeChannel.kt`)
- Widget bridge: `home_widget`
- Local notifications: `flutter_local_notifications`

## Project Structure

```text
lib/
  models/
  providers/
  screens/
  services/
  theme/
  utils/
  widgets/
```

## Run Locally

```bash
flutter pub get
flutter run
```

## Build release

Signing is read from `android/key.properties` (git-ignored). Then:

```bash
./build_release.sh        # signed APKs (universal + per-ABI)
./build_release.sh aab    # signed App Bundle for Google Play
```

Outputs:
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/bundle/release/app-release.aab`

## Quality Checks

```bash
flutter analyze
flutter test
```

## GitHub Publish Checklist

1. Make sure `flutter analyze` and `flutter test` pass.
2. Commit from project root:
   - `git init`
   - `git add .`
   - `git commit -m "Initial Mongez release"`
3. Create remote repository and push:
   - `git branch -M main`
   - `git remote add origin <YOUR_GITHUB_REPO_URL>`
   - `git push -u origin main`

## Notes

- Widget interactions and notifications work completely offline.
- If Android launcher caches an old widget layout, remove and re-add the widget after update.
