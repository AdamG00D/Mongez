# Changelog

## 2.1.0

### Added
- English. By default the app follows the device language (Arabic or English; any other
  language falls back to English), and it can be changed in Settings → Language. Home-screen
  widgets, reminders and notification channel names follow the chosen language.

### Changed
- Settings → About → GitHub opens the project's repository instead of the developer profile.

## 2.0.2

### Fixed
- Picking a reminder time (or a date) no longer puts the cursor back in the title field and
  reopens the keyboard.
- A task being written is no longer lost if the sheet does not survive the trip to a system
  permission page: the form is saved before leaving and reopened with everything filled in.
- The greeting in the header now changes with the time of day while the app stays open, and
  when it comes back to the foreground.
- Light mode: chip labels (date, priority, weekly options) and list titles had no color and
  rendered white on a light surface.

### Changed
- Options menu on the Tasks tab: compact rounded design. "Carry unfinished over" is disabled
  when the day has no unfinished one-off tasks and says so; otherwise it shows how many tasks
  will move and where. Sorting is disabled when there is nothing to sort.
- Removed the Facebook link from Settings → About.
- Softer, quieter celebration sound (`tool/gen_celebrate_sound.py`).
- Screen time: before opening the system "Usage access" page, a dialog states exactly what is
  read, why, and that it stays on the device, and asks for consent.
- Privacy policy: readable in the app (Settings → About) and published as `PRIVACY.md`.
- Screen time: step-by-step help for "Controlled by restricted setting" (APK installs on
  Android 13+), with a shortcut to the App info page.
- Dependencies updated to their latest compatible versions.
- Signed with a new release key. Installs of 2.0.1 or older must be uninstalled first (export a
  backup from Settings before).

## 2.0.1

### Fixed
- Content no longer scrolls under the phone's status bar (clock, battery, signal) on the Tasks
  and History tabs.
- The summary home-screen widget showed "Can't load widget": its layout used a view type that
  Android widgets don't allow.
- The "Task deleted" SnackBar stayed on screen until dismissed. It now closes after 4 s and is
  cleared when you switch tabs.
- Reminders shown while the app was open got removed whenever the app rescheduled (on resume or
  after any change). Shown reminders now stay, and reminders that fall due while the app is
  open are posted on time even if Android delays the alarm.
- "Carry unfinished over" from a past day now moves tasks to today instead of another past day.
  It is always available and explains that daily and weekly tasks repeat on their own.

### New
- Delete from history: tap any entry in the History tab to delete it, or delete all entries of
  that task. You can also clear the whole log. Undo is available for all of them.
- "Delete task and its history" option in the task actions sheet. A plain delete still keeps
  completions from earlier days.
- Sounds: a short sound for each completed task, and a celebration sound when all of today's
  tasks are done or a goal is achieved (Settings → Celebration and sounds).
- Setting a reminder time asks for the notification permission, and the "Alarms & reminders"
  permission when needed, so reminders fire on time.
- Full day names in the week strip and charts.
- Sorting by time or priority now confirms with a short message.

### Project
- Open-source setup: new README, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, issue and PR
  templates, Dependabot. CI checks formatting and runs on every PR.

## 2.0.0

### New
- Complete redesign: new logo (adaptive + Android 13 themed icon), new splash, bottom navigation
  (Tasks / Goals / History / Screen time / Settings), week-strip date picker, progress hero card.
- 9 color themes, light/dark/system, optional AMOLED black.
- App backgrounds: 8 built-in backgrounds that follow the theme, or any photo from the gallery
  (with adjustable dimming).
- Drag-and-drop task ordering (long-press or drag handle), plus "sort by time" / "sort by priority".
- Task priority (normal / important / urgent) and notes.
- Swipe right to complete, swipe left to delete with **Undo**.
- Postpone a task to the next day, copy to tomorrow, carry over all unfinished tasks.
- Yearly goals: milestone or numeric goals (e.g. 12 books), a personal "why" for each goal,
  year progress vs. elapsed time, quote of the day, confetti on completion,
  weekly motivational reminder.
- Weekly tasks: choose the first day of the week (globally and per task) and how to be
  reminded while unfinished (every day until done / last day of week / chosen days).
- Smarter reminders: per-occurrence scheduling that skips completed tasks, optional follow-up
  reminder if a task is still not done, evening "plan tomorrow" reminder, "Done ✓" button
  inside the notification.
- Screen time: daily screen-on time, unlock count, 7-day chart, top apps, and tracking of
  specific apps with daily limits (Android "Usage access" permission; data stays on device).
- History & stats: permanent log, completion counter per task type, current/best streak,
  7-day chart, most-completed tasks, filters.
- Backup to / restore from a JSON file.
- Two home-screen widgets: redesigned task list (light/dark, progress bar, add button,
  times and priority) and a new summary widget (percentage + next task).

### Changed / fixed
- History is permanent: deleting or editing a task no longer erases its history.
- Widgets refresh automatically after midnight instead of showing yesterday until the app opens.
- Widget taps always act on today (no accidental changes to a past day).
- The open app refreshes instantly when a task is completed from the widget or a notification.
- Daily reminders no longer fire on days the task is already completed.
- Updated `font_awesome_flutter` to v11 (v10 no longer compiles on current Flutter).

## 1.0.0

- Initial public release of Mongez.
