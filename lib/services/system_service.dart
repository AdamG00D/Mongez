import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Thin wrapper over the `mongez/system` channel (see `SystemChannel.kt`).
class SystemService {
  SystemService._();

  static const MethodChannel _channel = MethodChannel('mongez/system');

  static bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  /// Short sound for a single completed task.
  static Future<void> playDone() => _play('done');

  /// Celebration sound (all tasks done / goal achieved).
  static Future<void> playCelebrate() => _play('celebrate');

  static Future<void> _play(String name) async {
    if (!_isAndroid) {
      return;
    }
    try {
      await _channel.invokeMethod<void>('playSound', <String, String>{
        'name': name,
      });
    } catch (_) {
      // Sound is a nicety; never break the flow because of it.
    }
  }

  /// Opens the app's notification settings page. Returns false if it failed.
  static Future<bool> openNotificationSettings() async {
    if (!_isAndroid) {
      return false;
    }
    try {
      return await _channel.invokeMethod<bool>('openNotificationSettings') ??
          false;
    } catch (_) {
      return false;
    }
  }
}
