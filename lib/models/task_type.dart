enum TaskType { normal, daily, weekly }

extension TaskTypePresentation on TaskType {
  String get storageValue {
    return switch (this) {
      TaskType.normal => 'normal',
      TaskType.daily => 'daily',
      TaskType.weekly => 'weekly',
    };
  }

  String get label {
    return switch (this) {
      TaskType.normal => 'عادية',
      TaskType.daily => 'يومية',
      TaskType.weekly => 'أسبوعية',
    };
  }
}

TaskType taskTypeFromStorage(String value) {
  return switch (value) {
    'daily' => TaskType.daily,
    'weekly' => TaskType.weekly,
    _ => TaskType.normal,
  };
}
