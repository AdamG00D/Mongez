# Changelog

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
