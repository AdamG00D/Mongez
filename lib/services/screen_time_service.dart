import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/usage.dart';
import '../utils/date_helpers.dart';

/// Reads Android's UsageStats (requires the user to grant "Usage access").
class ScreenTimeService {
  static const MethodChannel _channel = MethodChannel('mongez/screen_time');

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  Future<bool> hasPermission() async {
    if (!isSupported) {
      return false;
    }
    try {
      return await _channel.invokeMethod<bool>('hasPermission') ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> openPermissionSettings() async {
    if (!isSupported) {
      return;
    }
    try {
      await _channel.invokeMethod<void>('openSettings');
    } on PlatformException {
      // ignore
    }
  }

  Future<UsageSummary?> usageBetween(
    DateTime start,
    DateTime end, {
    bool includeApps = true,
  }) async {
    if (!isSupported) {
      return null;
    }
    try {
      final result = await _channel
          .invokeMapMethod<dynamic, dynamic>('getUsage', <String, dynamic>{
            'start': start.millisecondsSinceEpoch,
            'end': end.millisecondsSinceEpoch,
            'includeApps': includeApps,
          });
      if (result == null) {
        return null;
      }
      return UsageSummary.fromMap(result, start, end);
    } on PlatformException catch (error) {
      debugPrint('[Mongez.ScreenTime] $error');
      return null;
    }
  }

  Future<UsageSummary?> usageForDay(DateTime day, {bool includeApps = true}) {
    final start = dateOnly(day);
    final now = DateTime.now();
    var end = addDays(start, 1);
    if (end.isAfter(now)) {
      end = now;
    }
    return usageBetween(start, end, includeApps: includeApps);
  }
}
