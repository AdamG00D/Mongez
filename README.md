# Mongez

Mongez is a mobile-first Flutter todo app focused on planning and tracking tasks with a smooth, minimal UI and strong Arabic RTL support.

## App Identity

- App name: `Mongez`
- Android package: `com.adamg00d.mongez`
- Main target: Android

## Core Features

- Day-based task browsing (previous, next, date picker, quick return).
- Task types:
  - Normal
  - Daily
  - Weekly (any day in week / selected weekdays)
- Add, edit, complete, uncomplete tasks.
- Completion history screen.
- Theme modes: Light / Dark / System.
- Android Home Screen Widget with interactive task toggle.
- Local persistence (no internet required).
- Scheduled local notifications for timed tasks.

## Tech Stack

- Flutter + Dart
- State management: `provider`
- Local storage: `shared_preferences`
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

## Build APK

```bash
flutter build apk --release
```

Output:
- `build/app/outputs/flutter-apk/app-release.apk`

### Production Signing (Recommended)

1. Generate keystore:
```bash
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Create `android/key.properties` from `android/key.properties.example` and set real values.

3. Build signed release APK:
```bash
flutter build apk --release
```

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
