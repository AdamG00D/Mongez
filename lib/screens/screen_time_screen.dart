import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../models/usage.dart';
import '../providers/screen_time_provider.dart';
import '../services/system_service.dart';
import '../utils/date_helpers.dart';
import '../widgets/common.dart';
import 'privacy_policy_screen.dart';

class ScreenTimeScreen extends StatefulWidget {
  const ScreenTimeScreen({super.key});

  @override
  State<ScreenTimeScreen> createState() => _ScreenTimeScreenState();
}

class _ScreenTimeScreenState extends State<ScreenTimeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScreenTimeProvider>().initialize();
    });
  }

  Future<void> _editLimit(ScreenTimeProvider provider, AppUsage app) async {
    const options = <int>[0, 15, 30, 60, 90, 120, 180];
    final current = provider.limitFor(app.packageName);
    final picked = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                context.l10n.dailyLimitFor(app.label),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: options.map((int minutes) {
                  return ChoiceChip(
                    label: Text(
                      minutes == 0
                          ? context.l10n.noLimit
                          : formatDurationShort(Duration(minutes: minutes)),
                    ),
                    selected: current == minutes,
                    onSelected: (_) => Navigator.pop(context, minutes),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
    if (picked != null) {
      await provider.setTracked(app.packageName, limitMinutes: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScreenTimeProvider>();
    final textTheme = Theme.of(context).textTheme;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    Widget body;
    if (!provider.isSupported) {
      body = EmptyState(
        icon: Icons.phone_android_rounded,
        title: context.l10n.notSupportedTitle,
        message: context.l10n.notSupportedMessage,
      );
    } else if (!provider.checked) {
      body = const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (!provider.hasPermission) {
      body = _PermissionCard(onGrant: provider.openPermissionSettings);
    } else {
      body = _UsageContent(
        provider: provider,
        onEditLimit: (AppUsage app) => _editLimit(provider, app),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: provider.refresh,
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomPad),
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      context.l10n.navScreenTime,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (provider.hasPermission)
                    IconButton(
                      tooltip: context.l10n.refresh,
                      onPressed: provider.loading ? null : provider.refresh,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              body,
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatefulWidget {
  const _PermissionCard({required this.onGrant});

  final VoidCallback onGrant;

  @override
  State<_PermissionCard> createState() => _PermissionCardState();
}

class _PermissionCardState extends State<_PermissionCard> {
  /// The user already went to the settings page and came back without the
  /// permission, so the "switch is greyed out" help is opened for them.
  bool _attempted = false;

  /// Explains exactly what is read and asks for consent before sending the
  /// user to the system "Usage access" page.
  Future<void> _grant() async {
    final agreed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        icon: const Icon(Icons.privacy_tip_rounded),
        title: Text(context.l10n.usageAccessTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(context.l10n.usageAccessDisclosure),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: () => PrivacyPolicyScreen.open(context),
                  child: Text(context.l10n.privacyPolicy),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.noThanks),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.agreeContinue),
          ),
        ],
      ),
    );
    if (agreed != true || !mounted) {
      return;
    }
    widget.onGrant();
    // Flip after the settings page has covered the app.
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _attempted = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    Widget point(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: <Widget>[
          Icon(icon, color: scheme.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: textTheme.bodyMedium)),
        ],
      ),
    );

    return Column(
      children: <Widget>[
        EmptyState(
          icon: Icons.hourglass_bottom_rounded,
          title: context.l10n.screenTimeIntroTitle,
          message: context.l10n.screenTimeIntroMessage,
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                point(Icons.timer_rounded, context.l10n.screenTimePoint1),
                point(Icons.apps_rounded, context.l10n.screenTimePoint2),
                point(
                  Icons.track_changes_rounded,
                  context.l10n.screenTimePoint3,
                ),
                point(Icons.lock_rounded, context.l10n.screenTimePoint4),
                const SizedBox(height: 6),
                Text(
                  context.l10n.screenTimeGrantHint,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _grant,
                    icon: const Icon(Icons.verified_user_rounded),
                    label: Text(context.l10n.grantUsageAccess),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _RestrictedSettingHelp(
          // Rebuilds expanded once the user has tried and come back.
          key: ValueKey<bool>(_attempted),
          initiallyExpanded: _attempted,
        ),
      ],
    );
  }
}

/// Android 13+ greys out "Usage access" for apps installed from an APK file
/// ("Controlled by restricted setting") until the user allows restricted
/// settings from the app's info page. Apps installed from a store aren't
/// affected.
class _RestrictedSettingHelp extends StatelessWidget {
  const _RestrictedSettingHelp({super.key, required this.initiallyExpanded});

  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    Widget step(int number, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: textTheme.bodyMedium)),
        ],
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: Icon(Icons.help_outline_rounded, color: scheme.primary),
          title: Text(context.l10n.restrictedTitle),
          subtitle: Text(context.l10n.restrictedSubtitle),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              context.l10n.restrictedIntro,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            step(1, context.l10n.restrictedStep1),
            step(2, context.l10n.restrictedStep2),
            step(3, context.l10n.restrictedStep3),
            step(4, context.l10n.restrictedStep4),
            Text(
              context.l10n.restrictedNote,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: SystemService.openAppInfo,
                icon: const Icon(Icons.info_outline_rounded),
                label: Text(context.l10n.openAppInfo),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageContent extends StatelessWidget {
  const _UsageContent({required this.provider, required this.onEditLimit});

  final ScreenTimeProvider provider;
  final ValueChanged<AppUsage> onEditLimit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final summary = provider.summary;
    final today = todayDate();
    final selected = provider.selectedDay;
    final apps = summary?.apps ?? const <AppUsage>[];
    final maxApp = apps.isEmpty ? 1 : apps.first.foreground.inSeconds;
    final average = provider.weekAverage;
    final screenOn = summary?.screenOn ?? Duration.zero;
    final diff = screenOn - average;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List<Widget>.generate(7, (int i) {
              final day = addDays(today, -i);
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: Text(
                    i == 0
                        ? context.l10n.today
                        : i == 1
                        ? context.l10n.yesterday
                        : weekDayName(day.weekday),
                  ),
                  selected: isSameDate(day, selected),
                  onSelected: (_) => provider.selectDay(day),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        GradientCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                context.l10n.screenOnTime,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              provider.loading && summary == null
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Text(
                      formatDurationShort(screenOn),
                      style: textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _HeroPill(
                    icon: Icons.lock_open_rounded,
                    text: context.l10n.unlocksCount(summary?.unlocks ?? 0),
                  ),
                  _HeroPill(
                    icon: Icons.apps_rounded,
                    text: context.l10n.appsCount(apps.length),
                  ),
                  if (average > Duration.zero)
                    _HeroPill(
                      icon: diff.isNegative
                          ? Icons.trending_down_rounded
                          : Icons.trending_up_rounded,
                      text: diff.isNegative
                          ? context.l10n.belowAverage(
                              formatDurationShort(-diff),
                            )
                          : context.l10n.aboveAverage(
                              formatDurationShort(diff),
                            ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (provider.week.length == 7) ...<Widget>[
          SectionTitle(
            context.l10n.last7Days,
            trailing: Text(
              context.l10n.averageLabel(formatDurationShort(average)),
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 16, 10, 12),
              child: MiniBarChart(
                values: provider.week
                    .map((Duration d) => d.inMinutes / 60)
                    .toList(),
                labels: List<String>.generate(
                  7,
                  (int i) =>
                      weekDayName(addDays(today, i - 6).weekday, short: true),
                ),
                highlightIndex: 6 - daysBetween(selected, today),
                valueLabel: (double h) => h < 1
                    ? context.l10n.durationMinutesCompact((h * 60).round())
                    : context.l10n.durationHoursCompact(h.toStringAsFixed(1)),
              ),
            ),
          ),
        ],
        if (provider.tracked.isNotEmpty) ...<Widget>[
          SectionTitle(context.l10n.trackedApps),
          ...provider.trackedUsage.map((AppUsage app) {
            final limit = provider.limitFor(app.packageName);
            final ratio = limit == 0 ? 0.0 : app.foreground.inMinutes / limit;
            final over = limit > 0 && ratio >= 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  leading: _AppIcon(app: app),
                  title: Text(app.label),
                  subtitle: limit == 0
                      ? Text(
                          context.l10n.durationToday(
                            formatDurationShort(app.foreground),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              context.l10n.usageOfLimit(
                                    formatDurationShort(app.foreground),
                                    formatDurationShort(
                                      Duration(minutes: limit),
                                    ),
                                  ) +
                                  (over ? context.l10n.overLimit : ''),
                              style: TextStyle(
                                color: over ? scheme.error : null,
                                fontWeight: over ? FontWeight.w800 : null,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: ratio.clamp(0, 1),
                                minHeight: 6,
                                color: over
                                    ? scheme.error
                                    : (ratio > 0.8
                                          ? const Color(0xFFF59E0B)
                                          : scheme.primary),
                              ),
                            ),
                          ],
                        ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (String v) {
                      if (v == 'limit') {
                        onEditLimit(app);
                      } else {
                        provider.untrack(app.packageName);
                      }
                    },
                    itemBuilder: (_) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'limit',
                        child: Text(context.l10n.editDailyLimit),
                      ),
                      PopupMenuItem<String>(
                        value: 'remove',
                        child: Text(context.l10n.stopTracking),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
        SectionTitle(
          context.l10n.mostUsedApps,
          trailing: Text(
            context.l10n.tapToTrack,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        if (apps.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                provider.loading
                    ? context.l10n.loading
                    : context.l10n.noDataForDay,
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          Card(
            child: Column(
              children: apps.take(25).map((AppUsage app) {
                final tracked = provider.isTracked(app.packageName);
                return ListTile(
                  leading: _AppIcon(app: app),
                  title: Text(
                    app.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: maxApp == 0
                            ? 0
                            : app.foreground.inSeconds / maxApp,
                        minHeight: 5,
                      ),
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        formatDurationShort(app.foreground),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      if (tracked)
                        Icon(
                          Icons.track_changes_rounded,
                          size: 14,
                          color: scheme.primary,
                        ),
                    ],
                  ),
                  onTap: () => tracked
                      ? onEditLimit(app)
                      : provider
                            .setTracked(app.packageName)
                            .then((_) => onEditLimit(app)),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppIcon extends StatelessWidget {
  const _AppIcon({required this.app});

  final AppUsage app;

  @override
  Widget build(BuildContext context) {
    final icon = app.icon;
    if (icon == null) {
      return CircleAvatar(
        child: Text(app.label.isEmpty ? '?' : app.label.characters.first),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.memory(icon, width: 40, height: 40, gaplessPlayback: true),
    );
  }
}
