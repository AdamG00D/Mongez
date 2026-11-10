import '../utils/date_helpers.dart';
import 'background_actions.dart';

class WidgetBackgroundHandler {
  static Future<void> handle(Uri uri) async {
    final today = dateOnly(DateTime.now());
    final fallbackQuery = _extractRawQuery(uri);
    final action = _resolveAction(uri, fallbackQuery);
    if (action == 'refresh') {
      await BackgroundActions.refreshWidgets();
      return;
    }

    var taskId = uri.queryParameters['taskId'] ?? fallbackQuery['taskId'];
    var date = uri.queryParameters['date'] ?? fallbackQuery['date'];
    taskId = _normalizeNullable(taskId);
    date = _normalizeNullable(date);

    if (taskId == null || date == null) {
      final nestedRaw = uri.queryParameters['uri'] ?? fallbackQuery['uri'];
      if (nestedRaw != null && nestedRaw.isNotEmpty) {
        final nestedQuery = _extractNestedQuery(nestedRaw);
        taskId ??= _normalizeNullable(nestedQuery['taskId']);
        date ??= _normalizeNullable(nestedQuery['date']);
      }
    }

    if (taskId == null || date == null) {
      final fromRegex = _extractByPattern(uri.toString());
      taskId ??= _normalizeNullable(fromRegex['taskId']);
      date ??= _normalizeNullable(fromRegex['date']);
    }

    final hasTogglePayload = taskId != null && date != null;
    if (action != 'toggle' && !hasTogglePayload) {
      return;
    }

    if (taskId == null) {
      return;
    }

    var selectedDay = _safeDateFromKey(date) ?? today;
    // The widget always represents today; never toggle a past day from a
    // stale widget snapshot.
    if (selectedDay.isBefore(today)) {
      selectedDay = today;
    }
    await BackgroundActions.toggleTask(taskId: taskId, day: selectedDay);
  }

  static Map<String, String> _extractRawQuery(Uri uri) {
    final uriString = uri.toString();
    final questionMarkIndex = uriString.indexOf('?');
    if (questionMarkIndex == -1 || questionMarkIndex == uriString.length - 1) {
      return const <String, String>{};
    }

    final query = uriString.substring(questionMarkIndex + 1);
    try {
      return Uri.splitQueryString(query);
    } catch (_) {
      return const <String, String>{};
    }
  }

  static String _resolveAction(Uri uri, Map<String, String> fallbackQuery) {
    final queryAction =
        uri.queryParameters['action'] ?? fallbackQuery['action'];
    if (queryAction != null && queryAction.isNotEmpty) {
      return queryAction;
    }

    if (uri.host.isNotEmpty) {
      return uri.host;
    }

    if (uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }

    return '';
  }

  static Map<String, String> _extractNestedQuery(String rawUri) {
    try {
      final nestedUri = Uri.parse(Uri.decodeComponent(rawUri));
      final query = <String, String>{
        ...nestedUri.queryParameters,
        ..._extractRawQuery(nestedUri),
      };
      return query;
    } catch (_) {
      return const <String, String>{};
    }
  }

  static Map<String, String> _extractByPattern(String raw) {
    final taskMatch = RegExp(r'taskId=([^&;]+)').firstMatch(raw);
    final dateMatch = RegExp(
      r'date=([0-9]{4}-[0-9]{2}-[0-9]{2})',
    ).firstMatch(raw);

    String? decode(String? value) {
      if (value == null || value.isEmpty) {
        return null;
      }
      try {
        return Uri.decodeComponent(value);
      } catch (_) {
        return value;
      }
    }

    final taskId = decode(taskMatch?.group(1));
    final date = decode(dateMatch?.group(1));
    if (taskId == null && date == null) {
      return const <String, String>{};
    }

    return <String, String>{
      ...?(taskId == null ? null : <String, String>{'taskId': taskId}),
      ...?(date == null ? null : <String, String>{'date': date}),
    };
  }

  static String? _normalizeNullable(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  static DateTime? _safeDateFromKey(String? value) {
    if (value == null) {
      return null;
    }
    try {
      return dateFromKey(value);
    } catch (_) {
      return null;
    }
  }
}
