import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import '../models/completion_record.dart';
import '../models/goal.dart';
import '../models/task.dart';

class BackupData {
  const BackupData({
    required this.tasks,
    required this.history,
    required this.goals,
  });

  final List<Task> tasks;
  final List<CompletionRecord> history;
  final List<Goal> goals;
}

/// Exports / imports a JSON backup file chosen by the user.
class BackupService {
  static const int _formatVersion = 2;

  Future<bool> export(BackupData data) async {
    final payload = <String, dynamic>{
      'app': 'mongez',
      'version': _formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'tasks': data.tasks.map((Task task) => task.toJson()).toList(),
      'history': data.history
          .map((CompletionRecord record) => record.toJson())
          .toList(),
      'goals': data.goals.map((Goal goal) => goal.toJson()).toList(),
    };
    final bytes = Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(payload)),
    );
    final stamp = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final uri = await FilePicker.saveFile(
      fileName: 'mongez-backup-$stamp.json',
      bytes: bytes,
      mimeType: 'application/json',
      dialogTitle: 'حفظ نسخة احتياطية',
    );
    return uri != null;
  }

  /// Returns `null` if the user cancelled. Throws [FormatException] if the
  /// file is not a valid Mongez backup.
  Future<BackupData?> pickAndParse() async {
    final files = await FilePicker.pickFiles(dialogTitle: 'اختر ملف النسخة');
    if (files.isEmpty) {
      return null;
    }
    final bytes = await files.first.readAsBytes();
    final dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(bytes));
    } catch (_) {
      throw const FormatException('الملف ليس نسخة احتياطية صالحة');
    }
    if (decoded is! Map || decoded['app'] != 'mongez') {
      throw const FormatException('الملف ليس نسخة احتياطية من مُنجز');
    }

    List<T> parse<T>(String key, T Function(Map<String, dynamic>) fromJson) {
      final raw = decoded[key];
      if (raw is! List) {
        return <T>[];
      }
      final out = <T>[];
      for (final item in raw) {
        if (item is Map) {
          try {
            out.add(fromJson(Map<String, dynamic>.from(item)));
          } catch (_) {}
        }
      }
      return out;
    }

    return BackupData(
      tasks: parse('tasks', Task.fromJson),
      history: parse('history', CompletionRecord.fromJson),
      goals: parse('goals', Goal.fromJson),
    );
  }
}
