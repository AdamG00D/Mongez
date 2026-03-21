import 'task_type.dart';

class CompletionRecord {
  const CompletionRecord({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.taskType,
    required this.completedAt,
    required this.completedForDate,
    this.taskTimeInMinutes,
  });

  final String id;
  final String taskId;
  final String taskTitle;
  final TaskType taskType;
  final DateTime completedAt;
  final DateTime completedForDate;
  final int? taskTimeInMinutes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'taskId': taskId,
      'taskTitle': taskTitle,
      'taskType': taskType.storageValue,
      'completedAt': completedAt.toIso8601String(),
      'completedForDate': completedForDate.toIso8601String(),
      'taskTimeInMinutes': taskTimeInMinutes,
    };
  }

  factory CompletionRecord.fromJson(Map<String, dynamic> json) {
    return CompletionRecord(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      taskTitle: json['taskTitle'] as String,
      taskType: taskTypeFromStorage((json['taskType'] as String?) ?? 'normal'),
      completedAt: DateTime.parse(json['completedAt'] as String),
      completedForDate: DateTime.parse(json['completedForDate'] as String),
      taskTimeInMinutes: json['taskTimeInMinutes'] as int?,
    );
  }
}
