import 'package:flutter/foundation.dart';

import '../models/goal.dart';
import '../services/local_storage_service.dart';
import '../utils/date_helpers.dart';

class GoalsProvider extends ChangeNotifier {
  GoalsProvider(this._storage);

  final LocalStorageService _storage;
  final List<Goal> _goals = <Goal>[];

  VoidCallback? onDataChanged;

  int _year = DateTime.now().year;
  bool _loaded = false;

  bool get isLoaded => _loaded;
  int get year => _year;
  List<Goal> get goals => List<Goal>.unmodifiable(_goals);

  List<Goal> get goalsForYear =>
      _goals.where((Goal goal) => goal.year == _year).toList()
        ..sort((Goal a, Goal b) {
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          return a.sortOrder.compareTo(b.sortOrder);
        });

  List<int> get availableYears {
    final years = _goals.map((Goal goal) => goal.year).toSet()
      ..add(DateTime.now().year)
      ..add(DateTime.now().year + 1);
    return years.toList()..sort();
  }

  /// Overall progress for the selected year (each goal weighs the same).
  double get yearGoalsRatio {
    final list = goalsForYear;
    if (list.isEmpty) {
      return 0;
    }
    return list.fold<double>(0, (double sum, Goal g) => sum + g.ratio) /
        list.length;
  }

  /// How much of the selected year has elapsed (0..1).
  double get yearElapsedRatio {
    final now = DateTime.now();
    if (_year < now.year) {
      return 1;
    }
    if (_year > now.year) {
      return 0;
    }
    final start = DateTime(_year);
    final end = DateTime(_year + 1);
    return now.difference(start).inSeconds / end.difference(start).inSeconds;
  }

  int get daysLeftInYear {
    final now = DateTime.now();
    if (_year < now.year) {
      return 0;
    }
    final from = _year > now.year ? DateTime(_year) : now;
    return daysBetween(from, DateTime(_year + 1));
  }

  Future<void> initialize() async {
    _goals
      ..clear()
      ..addAll(await _storage.loadGoals());
    _loaded = true;
    notifyListeners();
  }

  void setYear(int year) {
    _year = year;
    notifyListeners();
  }

  Future<void> addGoal({
    required String title,
    String? why,
    int? target,
    String? unit,
    String iconKey = 'star',
  }) async {
    final maxOrder = _goals.fold<int>(
      -1,
      (int max, Goal g) => g.sortOrder > max ? g.sortOrder : max,
    );
    _goals.add(
      Goal(
        id: 'goal-${DateTime.now().microsecondsSinceEpoch}',
        title: title.trim(),
        year: _year,
        createdAt: DateTime.now(),
        why: _clean(why),
        target: (target != null && target > 0) ? target : null,
        unit: _clean(unit),
        iconKey: iconKey,
        sortOrder: maxOrder + 1,
      ),
    );
    await _save();
  }

  Future<void> updateGoal(
    String id, {
    required String title,
    String? why,
    int? target,
    String? unit,
    required String iconKey,
  }) async {
    final index = _goals.indexWhere((Goal goal) => goal.id == id);
    if (index == -1) {
      return;
    }
    final cleanWhy = _clean(why);
    final cleanUnit = _clean(unit);
    final hasTarget = target != null && target > 0;
    var updated = _goals[index].copyWith(
      title: title.trim(),
      why: cleanWhy,
      clearWhy: cleanWhy == null,
      target: hasTarget ? target : null,
      clearTarget: !hasTarget,
      unit: cleanUnit,
      clearUnit: cleanUnit == null,
      iconKey: iconKey,
    );
    updated = _autoComplete(updated);
    _goals[index] = updated;
    await _save();
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((Goal goal) => goal.id == id);
    await _save();
  }

  /// Returns true when this change completed the goal.
  Future<bool> changeProgress(String id, int delta) async {
    final index = _goals.indexWhere((Goal goal) => goal.id == id);
    if (index == -1 || !_goals[index].hasTarget) {
      return false;
    }
    final goal = _goals[index];
    final wasDone = goal.isCompleted;
    final next = (goal.progress + delta).clamp(0, goal.target!);
    final updated = _autoComplete(goal.copyWith(progress: next));
    _goals[index] = updated;
    await _save();
    return !wasDone && updated.isCompleted;
  }

  /// Returns true when the goal became completed.
  Future<bool> toggleCompleted(String id) async {
    final index = _goals.indexWhere((Goal goal) => goal.id == id);
    if (index == -1) {
      return false;
    }
    final goal = _goals[index];
    if (goal.isCompleted) {
      _goals[index] = goal.copyWith(
        clearCompletedAt: true,
        progress: goal.hasTarget && goal.progress >= goal.target!
            ? goal.target! - 1
            : goal.progress,
      );
      await _save();
      return false;
    }
    _goals[index] = goal.copyWith(
      completedAt: DateTime.now(),
      progress: goal.hasTarget ? goal.target : goal.progress,
    );
    await _save();
    return true;
  }

  Future<void> replaceAll(List<Goal> goals) async {
    _goals
      ..clear()
      ..addAll(goals);
    await _save();
  }

  Goal _autoComplete(Goal goal) {
    if (!goal.hasTarget) {
      return goal;
    }
    if (goal.progress >= goal.target! && !goal.isCompleted) {
      return goal.copyWith(completedAt: DateTime.now());
    }
    if (goal.progress < goal.target! && goal.isCompleted) {
      return goal.copyWith(clearCompletedAt: true);
    }
    return goal;
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  Future<void> _save() async {
    notifyListeners();
    await _storage.saveGoals(_goals);
    onDataChanged?.call();
  }
}
