import 'dart:typed_data';

class AppUsage {
  const AppUsage({
    required this.packageName,
    required this.label,
    required this.foreground,
    this.launches = 0,
    this.icon,
  });

  final String packageName;
  final String label;
  final Duration foreground;
  final int launches;
  final Uint8List? icon;

  factory AppUsage.fromMap(Map<dynamic, dynamic> map) {
    final rawIcon = map['icon'];
    return AppUsage(
      packageName: map['package'] as String,
      label: (map['label'] as String?) ?? map['package'] as String,
      foreground: Duration(milliseconds: (map['ms'] as num?)?.toInt() ?? 0),
      launches: (map['launches'] as num?)?.toInt() ?? 0,
      icon: rawIcon is Uint8List ? rawIcon : null,
    );
  }
}

class UsageSummary {
  const UsageSummary({
    required this.start,
    required this.end,
    required this.screenOn,
    required this.unlocks,
    required this.apps,
  });

  final DateTime start;
  final DateTime end;
  final Duration screenOn;
  final int unlocks;
  final List<AppUsage> apps;

  Duration get appsTotal => apps.fold<Duration>(
    Duration.zero,
    (Duration sum, AppUsage app) => sum + app.foreground,
  );

  factory UsageSummary.fromMap(
    Map<dynamic, dynamic> map,
    DateTime start,
    DateTime end,
  ) {
    final rawApps = map['apps'];
    final apps = <AppUsage>[];
    if (rawApps is List) {
      for (final item in rawApps) {
        if (item is Map) {
          apps.add(AppUsage.fromMap(item));
        }
      }
    }
    apps.sort((AppUsage a, AppUsage b) => b.foreground.compareTo(a.foreground));
    return UsageSummary(
      start: start,
      end: end,
      screenOn: Duration(
        milliseconds: (map['screenOnMs'] as num?)?.toInt() ?? 0,
      ),
      unlocks: (map['unlocks'] as num?)?.toInt() ?? 0,
      apps: apps,
    );
  }
}
