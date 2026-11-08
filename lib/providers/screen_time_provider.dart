import 'package:flutter/foundation.dart';

import '../models/usage.dart';
import '../services/local_storage_service.dart';
import '../services/screen_time_service.dart';
import '../utils/date_helpers.dart';

class ScreenTimeProvider extends ChangeNotifier {
  ScreenTimeProvider(this._service, this._storage);

  final ScreenTimeService _service;
  final LocalStorageService _storage;

  bool _checked = false;
  bool _hasPermission = false;
  bool _loading = false;
  DateTime _selectedDay = todayDate();
  UsageSummary? _summary;

  /// Screen-on time for the last 7 days, oldest first.
  List<Duration> _week = <Duration>[];
  Map<String, int> _tracked = <String, int>{};

  bool get isSupported => _service.isSupported;
  bool get checked => _checked;
  bool get hasPermission => _hasPermission;
  bool get loading => _loading;
  DateTime get selectedDay => _selectedDay;
  UsageSummary? get summary => _summary;
  List<Duration> get week => _week;
  Map<String, int> get tracked => Map<String, int>.unmodifiable(_tracked);

  Duration get weekAverage {
    final nonZero = _week.where((Duration d) => d > Duration.zero).toList();
    if (nonZero.isEmpty) {
      return Duration.zero;
    }
    final total = nonZero.fold<Duration>(
      Duration.zero,
      (Duration a, Duration b) => a + b,
    );
    return Duration(milliseconds: total.inMilliseconds ~/ nonZero.length);
  }

  List<AppUsage> get trackedUsage {
    final apps = _summary?.apps ?? const <AppUsage>[];
    return _tracked.keys.map((String package) {
      return apps.firstWhere(
        (AppUsage app) => app.packageName == package,
        orElse: () => AppUsage(
          packageName: package,
          label: _labels[package] ?? package,
          foreground: Duration.zero,
          icon: _icons[package],
        ),
      );
    }).toList();
  }

  final Map<String, String> _labels = <String, String>{};
  final Map<String, Uint8List> _icons = <String, Uint8List>{};

  Future<void> initialize() async {
    _tracked = await _storage.loadTrackedApps();
    await refresh();
  }

  Future<void> openPermissionSettings() => _service.openPermissionSettings();

  Future<void> selectDay(DateTime day) async {
    _selectedDay = dateOnly(day);
    await refresh(weekToo: false);
  }

  Future<void> refresh({bool weekToo = true}) async {
    if (!_service.isSupported) {
      _checked = true;
      notifyListeners();
      return;
    }
    _hasPermission = await _service.hasPermission();
    _checked = true;
    if (!_hasPermission) {
      notifyListeners();
      return;
    }

    _loading = true;
    notifyListeners();

    _summary = await _service.usageForDay(_selectedDay);
    for (final app in _summary?.apps ?? const <AppUsage>[]) {
      _labels[app.packageName] = app.label;
      if (app.icon != null) {
        _icons[app.packageName] = app.icon!;
      }
    }

    if (weekToo) {
      final today = todayDate();
      final days = <Duration>[];
      for (var i = 6; i >= 0; i--) {
        final day = addDays(today, -i);
        final summary = isSameDate(day, _selectedDay) && _summary != null
            ? _summary
            : await _service.usageForDay(day, includeApps: false);
        days.add(summary?.screenOn ?? Duration.zero);
      }
      _week = days;
    }

    _loading = false;
    notifyListeners();
  }

  bool isTracked(String package) => _tracked.containsKey(package);

  Future<void> setTracked(String package, {int? limitMinutes}) async {
    _tracked[package] = limitMinutes ?? _tracked[package] ?? 0;
    notifyListeners();
    await _storage.saveTrackedApps(_tracked);
  }

  Future<void> untrack(String package) async {
    _tracked.remove(package);
    notifyListeners();
    await _storage.saveTrackedApps(_tracked);
  }

  int limitFor(String package) => _tracked[package] ?? 0;
}
