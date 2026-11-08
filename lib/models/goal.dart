import 'package:flutter/material.dart';

/// Icons the user can attach to a yearly goal.
const Map<String, IconData> goalIcons = <String, IconData>{
  'star': Icons.star_rounded,
  'book': Icons.menu_book_rounded,
  'fitness': Icons.fitness_center_rounded,
  'health': Icons.favorite_rounded,
  'money': Icons.savings_rounded,
  'work': Icons.work_rounded,
  'study': Icons.school_rounded,
  'travel': Icons.flight_takeoff_rounded,
  'faith': Icons.mosque_rounded,
  'family': Icons.family_restroom_rounded,
  'code': Icons.code_rounded,
  'language': Icons.translate_rounded,
  'home': Icons.home_rounded,
  'art': Icons.palette_rounded,
  'run': Icons.directions_run_rounded,
  'idea': Icons.lightbulb_rounded,
};

class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.year,
    required this.createdAt,
    this.why,
    this.target,
    this.progress = 0,
    this.unit,
    this.completedAt,
    this.iconKey = 'star',
    this.sortOrder = 0,
  });

  final String id;
  final String title;
  final int year;

  /// The personal reason behind this goal – shown back as motivation.
  final String? why;

  /// Optional numeric target (e.g. read 12 books). `null` = a single milestone.
  final int? target;
  final int progress;

  /// Unit label for numeric goals (e.g. "كتاب").
  final String? unit;
  final DateTime? completedAt;
  final DateTime createdAt;
  final String iconKey;
  final int sortOrder;

  bool get isCompleted => completedAt != null;
  bool get hasTarget => target != null && target! > 0;

  double get ratio {
    if (isCompleted) {
      return 1;
    }
    if (!hasTarget) {
      return 0;
    }
    return (progress / target!).clamp(0, 1).toDouble();
  }

  IconData get icon => goalIcons[iconKey] ?? Icons.star_rounded;

  Goal copyWith({
    String? title,
    int? year,
    String? why,
    bool clearWhy = false,
    int? target,
    bool clearTarget = false,
    int? progress,
    String? unit,
    bool clearUnit = false,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    String? iconKey,
    int? sortOrder,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      year: year ?? this.year,
      createdAt: createdAt,
      why: clearWhy ? null : (why ?? this.why),
      target: clearTarget ? null : (target ?? this.target),
      progress: progress ?? this.progress,
      unit: clearUnit ? null : (unit ?? this.unit),
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      iconKey: iconKey ?? this.iconKey,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'year': year,
    'why': why,
    'target': target,
    'progress': progress,
    'unit': unit,
    'completedAt': completedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'iconKey': iconKey,
    'sortOrder': sortOrder,
  };

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      title: json['title'] as String,
      year: (json['year'] as num).toInt(),
      why: json['why'] as String?,
      target: (json['target'] as num?)?.toInt(),
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      unit: json['unit'] as String?,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      iconKey: json['iconKey'] as String? ?? 'star',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }
}
