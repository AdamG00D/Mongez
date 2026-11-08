import '../models/completion_record.dart';
import '../models/task.dart';
import '../utils/date_helpers.dart';

/// Pure helpers shared by the UI provider and the background isolates
/// (home-screen widget taps and notification "done" actions), so every entry
/// point records completions identically.
class TaskMutations {
  TaskMutations._();

  static String historyId(Task task, DateTime day) =>
      '${task.id}-${task.occurrenceKey(day)}';

  /// Toggles [taskId] for [day]. Returns the updated task, or `null` when
  /// nothing changed. [tasks] and [history] are modified in place.
  ///
  /// History is permanent: deleting or editing a task never removes its
  /// records. The only thing that removes a record is un-checking that same
  /// occurrence (i.e. correcting a mistaken check).
  static Task? toggle({
    required List<Task> tasks,
    required List<CompletionRecord> history,
    required String taskId,
    required DateTime day,
    bool? forceValue,
  }) {
    final index = tasks.indexWhere((Task task) => task.id == taskId);
    if (index == -1) {
      return null;
    }

    final activeDay = dateOnly(day);
    final current = tasks[index];
    if (!current.appearsOn(activeDay)) {
      return null;
    }

    final wasCompleted = current.isCompletedOn(activeDay);
    final shouldComplete = forceValue ?? !wasCompleted;
    if (shouldComplete == wasCompleted) {
      return null;
    }

    final updated = current.toggleCompletionForDay(activeDay, shouldComplete);
    tasks[index] = updated;

    final completionDay = updated.isNormal
        ? dateOnly(updated.scheduledDate)
        : activeDay;

    if (shouldComplete) {
      final record = CompletionRecord(
        id: historyId(updated, activeDay),
        taskId: updated.id,
        taskTitle: updated.title,
        taskType: updated.type,
        completedAt: DateTime.now(),
        completedForDate: completionDay,
        taskTimeInMinutes: updated.timeInMinutes,
      );
      history.removeWhere(
        (CompletionRecord item) =>
            item.taskId == updated.id &&
            item.taskType == updated.type &&
            updated.sameOccurrence(item.completedForDate, activeDay),
      );
      history.add(record);
    } else {
      history.removeWhere(
        (CompletionRecord item) =>
            item.taskId == updated.id &&
            item.taskType == updated.type &&
            updated.sameOccurrence(item.completedForDate, activeDay),
      );
    }

    sortHistory(history);
    return updated;
  }

  static void sortHistory(List<CompletionRecord> history) {
    history.sort(
      (CompletionRecord first, CompletionRecord second) =>
          second.completedAt.compareTo(first.completedAt),
    );
  }

  static List<Task> tasksForDay(Iterable<Task> tasks, DateTime day) {
    final normalized = dateOnly(day);
    return tasks.where((Task task) => task.appearsOn(normalized)).toList()
      ..sort(compareTasksForDisplay);
  }
}
