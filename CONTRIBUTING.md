# Contributing to Mongez

Thanks for helping make Mongez better! Issues and pull requests are welcome in **Arabic or
English**.

## Ways to help

- **Report a bug:** open an issue with the *Bug report* template. Include steps, your device
  and Android version, and a screenshot if possible.
- **Suggest a feature:** use the *Feature request* template and describe the problem first,
  then your idea.
- **Send code:** fix a bug, improve the UI or accessibility, add tests or translations.
  Issues labelled `good first issue` are a good place to start.

For anything bigger than a small fix, please open an issue first so we can agree on the
approach before you spend time on it.

## Development setup

```bash
git clone https://github.com/<you>/Mongez_App.git
cd Mongez_App
flutter pub get
flutter run
```

See the [README](README.md#getting-started) for requirements and release builds. You don't need
a signing key: debug builds and unsigned release builds work out of the box.

## Workflow

1. Fork the repo and create a branch from `main`: `fix/widget-crash`, `feat/task-tags`, ...
2. Make your change. Keep pull requests focused; one topic per PR is easier to review.
3. Run the checks:
   ```bash
   dart format lib test
   flutter analyze      # must report "No issues found!"
   flutter test         # must pass
   ```
4. If you changed behavior, add or update tests in `test/`. Logic belongs in
   `test/logic_test.dart`; screens are covered by `test/ui_smoke_test.dart`.
5. Commit with a clear message (e.g. `fix: keep history when a task is deleted`). Following
   [Conventional Commits](https://www.conventionalcommits.org) is appreciated but not
   required.
6. Open a pull request and fill in the template. CI runs analyze, test and a debug build.

## Code guidelines

- Follow the lints in `analysis_options.yaml` and the existing style.
- **User-facing text is Arabic** and the UI is RTL. Use `EdgeInsetsDirectional` and
  `AlignmentDirectional` rather than left/right.
- State lives in `providers/`. Widgets read it with `context.watch` / `context.read`.
- Every completion change goes through `TaskMutations.toggle`, so the app, the home-screen
  widget and notification actions all behave the same way.
- **Don't silently remove history.** Deleting or editing a task must keep its completion
  records. Only explicit actions in the History tab, or un-checking the same occurrence,
  remove them.
- Week math goes through `utils/date_helpers.dart` (it respects the user's first day of week).
- Native Android code lives in `android/app/src/main/kotlin/`. Home-screen widgets use
  `RemoteViews`, which only allows certain view classes (for example, no plain `<View>`).
- Never commit signing keys, `key.properties` or personal data.

## Testing on a device

Some features can't be fully covered by unit tests. If your change touches them, please test
on a real device and mention it in the PR:

- notifications and the "Done ✓" action (app open, in background and closed)
- home-screen widgets (add, tap, resize, dark mode)
- screen time (needs the "Usage access" permission)

## License

By contributing, you agree that your contributions are licensed under the [MIT License](LICENSE).
