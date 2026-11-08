import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/usage.dart';
import '../providers/screen_time_provider.dart';
import '../utils/date_helpers.dart';
import '../widgets/common.dart';

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
                'حدّ يومي لـ ${app.label}',
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
                          ? 'بدون حد'
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
      body = const EmptyState(
        icon: Icons.phone_android_rounded,
        title: 'غير مدعوم',
        message: 'ميزة وقت الشاشة متاحة على أجهزة أندرويد فقط.',
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
                      'وقت الشاشة',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (provider.hasPermission)
                    IconButton(
                      tooltip: 'تحديث',
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

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({required this.onGrant});

  final VoidCallback onGrant;

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
        const EmptyState(
          icon: Icons.hourglass_bottom_rounded,
          title: 'اعرف أين يذهب وقتك',
          message:
              'شاهد عدد ساعات فتح الشاشة، ومرات فتح القفل، والوقت في كل تطبيق.',
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                point(
                  Icons.timer_rounded,
                  'إجمالي وقت الشاشة يوميًا وأسبوعيًا',
                ),
                point(Icons.apps_rounded, 'ترتيب التطبيقات حسب الاستخدام'),
                point(
                  Icons.track_changes_rounded,
                  'تتبع تطبيقات معيّنة بحد يومي',
                ),
                point(
                  Icons.lock_rounded,
                  'البيانات تبقى على جهازك ولا تُرسل لأي مكان',
                ),
                const SizedBox(height: 6),
                Text(
                  'اضغط الزر ثم فعّل "مُنجز" في قائمة "الوصول إلى بيانات الاستخدام"، ثم ارجع للتطبيق.',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onGrant,
                    icon: const Icon(Icons.verified_user_rounded),
                    label: const Text('منح صلاحية الوصول للاستخدام'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
                        ? 'اليوم'
                        : i == 1
                        ? 'أمس'
                        : arabicWeekDayNames[day.weekday]!,
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
                'وقت فتح الشاشة',
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
                    text: '${summary?.unlocks ?? 0} مرة فتح قفل',
                  ),
                  _HeroPill(
                    icon: Icons.apps_rounded,
                    text: '${apps.length} تطبيق',
                  ),
                  if (average > Duration.zero)
                    _HeroPill(
                      icon: diff.isNegative
                          ? Icons.trending_down_rounded
                          : Icons.trending_up_rounded,
                      text: diff.isNegative
                          ? 'أقل من متوسطك بـ ${formatDurationShort(-diff)}'
                          : 'أعلى من متوسطك بـ ${formatDurationShort(diff)}',
                    ),
                ],
              ),
            ],
          ),
        ),
        if (provider.week.length == 7) ...<Widget>[
          SectionTitle(
            'آخر 7 أيام',
            trailing: Text(
              'المتوسط ${formatDurationShort(average)}',
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
                  (int i) => arabicWeekDayShort[addDays(today, i - 6).weekday]!,
                ),
                highlightIndex: 6 - daysBetween(selected, today),
                valueLabel: (double h) =>
                    h < 1 ? '${(h * 60).round()}د' : '${h.toStringAsFixed(1)}س',
              ),
            ),
          ),
        ],
        if (provider.tracked.isNotEmpty) ...<Widget>[
          const SectionTitle('تطبيقات أتابعها'),
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
                      ? Text('${formatDurationShort(app.foreground)} اليوم')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${formatDurationShort(app.foreground)} من ${formatDurationShort(Duration(minutes: limit))}${over ? ' — تجاوزت الحد!' : ''}',
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
                    itemBuilder: (_) => const <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'limit',
                        child: Text('تعديل الحد اليومي'),
                      ),
                      PopupMenuItem<String>(
                        value: 'remove',
                        child: Text('إلغاء المتابعة'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
        SectionTitle(
          'التطبيقات الأكثر استخدامًا',
          trailing: Text(
            'اضغط لمتابعة تطبيق',
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
                    ? 'جارٍ التحميل...'
                    : 'لا توجد بيانات لهذا اليوم.',
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
