import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_settings.dart';
import '../providers/goals_provider.dart';
import '../providers/reminder_coordinator.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../services/backup_service.dart';
import '../services/notification_service.dart';
import '../theme/backgrounds.dart';
import '../theme/palettes.dart';
import '../utils/date_helpers.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const String appVersion = '2.0.0';

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool? _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    _checkNotifications();
  }

  Future<void> _checkNotifications() async {
    final enabled = await context
        .read<NotificationService>()
        .areNotificationsEnabled();
    if (mounted) {
      setState(() => _notificationsEnabled = enabled);
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _enableNotifications() async {
    await context.read<NotificationService>().requestPermissions();
    if (!mounted) {
      return;
    }
    await context.read<ReminderCoordinator>().syncNow();
    await _checkNotifications();
    _snack(
      _notificationsEnabled ?? false
          ? 'الإشعارات مفعّلة وتم تحديث التذكيرات'
          : 'لم يتم منح صلاحية الإشعارات',
    );
  }

  Future<void> _pickTime(int currentMinutes, ValueChanged<int> onPicked) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: currentMinutes ~/ 60,
        minute: currentMinutes % 60,
      ),
    );
    if (picked != null) {
      onPicked(minutesFromTimeOfDay(picked));
    }
  }

  Future<void> _export() async {
    final tasks = context.read<TaskProvider>();
    final goals = context.read<GoalsProvider>();
    try {
      final saved = await BackupService().export(tasks.backupData(goals.goals));
      if (saved) {
        _snack('تم حفظ النسخة الاحتياطية');
      }
    } catch (error) {
      _snack('تعذر حفظ النسخة: $error');
    }
  }

  Future<void> _import() async {
    final tasks = context.read<TaskProvider>();
    final goals = context.read<GoalsProvider>();
    final BackupData? data;
    try {
      data = await BackupService().pickAndParse();
    } on FormatException catch (error) {
      _snack(error.message);
      return;
    } catch (error) {
      _snack('تعذر قراءة الملف');
      return;
    }
    if (data == null || !mounted) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('استعادة النسخة؟'),
        content: Text(
          'سيتم استبدال المهام (${data!.tasks.length}) والأهداف (${data.goals.length}) الحالية. '
          'السجل لن يُحذف، بل ستُدمج سجلات النسخة (${data.history.length}) معه.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('استعادة'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) {
      return;
    }
    await tasks.importBackup(data);
    await goals.replaceAll(data.goals);
    _snack('تمت الاستعادة بنجاح');
  }

  Future<void> _pinWidget({required bool summary}) async {
    final ok = await context.read<TaskProvider>().requestPinWidget(
      summary: summary,
    );
    _snack(
      ok
          ? 'تم إرسال طلب إضافة الويدجت إلى الشاشة الرئيسية'
          : 'اللانشر لا يدعم الإضافة التلقائية. أضف الويدجت يدويًا من قائمة الويدجت.',
    );
  }

  Future<void> _openLink(String url) async {
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      _snack('تعذر فتح الرابط');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final s = settingsProvider.settings;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    Future<void> set(AppSettings Function(AppSettings) change) =>
        settingsProvider.update(change);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomPad),
          children: <Widget>[
            Text(
              'الإعدادات',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),

            // ------------------------------------------------ Appearance
            const SectionTitle('المظهر'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        showSelectedIcon: false,
                        segments: const <ButtonSegment<ThemeMode>>[
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode_rounded),
                            label: Text('فاتح'),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode_rounded),
                            label: Text('داكن'),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.system,
                            icon: Icon(Icons.brightness_auto_rounded),
                            label: Text('النظام'),
                          ),
                        ],
                        selected: <ThemeMode>{s.themeMode},
                        onSelectionChanged: (Set<ThemeMode> v) => set(
                          (AppSettings c) => c.copyWith(themeMode: v.first),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'سمة الألوان',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 12,
                      children: appPalettes.map((AppPalette palette) {
                        final selected = palette.id == s.paletteId;
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => set(
                            (AppSettings c) =>
                                c.copyWith(paletteId: palette.id),
                          ),
                          child: SizedBox(
                            width: 62,
                            child: Column(
                              children: <Widget>[
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: palette.gradient,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: selected
                                          ? scheme.onSurface
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                  child: selected
                                      ? const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  palette.name,
                                  style: textTheme.labelSmall?.copyWith(
                                    fontWeight: selected
                                        ? FontWeight.w900
                                        : FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (isDark)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: s.amoledDark,
                        onChanged: (bool v) =>
                            set((AppSettings c) => c.copyWith(amoledDark: v)),
                        title: const Text('أسود كامل (AMOLED)'),
                        subtitle: const Text('يوفّر البطارية في شاشات OLED'),
                      ),
                  ],
                ),
              ),
            ),
            const SectionTitle('خلفية التطبيق'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.78,
                      children: <Widget>[
                        ...backgroundOptions.map(
                          (BackgroundOption option) => _BackgroundTile(
                            label: option.name,
                            selected: s.backgroundId == option.id,
                            onTap: () => set(
                              (AppSettings c) =>
                                  c.copyWith(backgroundId: option.id),
                            ),
                            preview: BackgroundLayer(id: option.id),
                          ),
                        ),
                        _BackgroundTile(
                          label: 'صورة من جهازك',
                          selected: s.backgroundId == 'custom',
                          onTap: () async {
                            try {
                              await settingsProvider.pickCustomBackground();
                            } catch (_) {
                              _snack('تعذر اختيار الصورة');
                            }
                          },
                          preview: s.customBackgroundPath != null
                              ? BackgroundLayer(
                                  id: 'custom',
                                  customPath: s.customBackgroundPath,
                                  dim: s.backgroundDim,
                                )
                              : ColoredBox(
                                  color: scheme.surfaceContainerHigh,
                                  child: Icon(
                                    Icons.add_photo_alternate_rounded,
                                    color: scheme.primary,
                                    size: 30,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    if (s.backgroundId == 'custom') ...<Widget>[
                      const SizedBox(height: 12),
                      Text(
                        'تعتيم الصورة لوضوح النص',
                        style: textTheme.labelLarge,
                      ),
                      Slider(
                        value: s.backgroundDim.clamp(0.0, 0.85),
                        max: 0.85,
                        divisions: 17,
                        label: '${(s.backgroundDim * 100).round()}%',
                        onChanged: (double v) => set(
                          (AppSettings c) => c.copyWith(backgroundDim: v),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          try {
                            await settingsProvider.pickCustomBackground();
                          } catch (_) {
                            _snack('تعذر اختيار الصورة');
                          }
                        },
                        icon: const Icon(Icons.photo_library_rounded),
                        label: const Text('تغيير الصورة'),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // --------------------------------------------------- Tasks
            const SectionTitle('المهام والأسبوع'),
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.calendar_view_week_rounded),
                    title: const Text('أول أيام الأسبوع'),
                    subtitle: const Text(
                      'يحدد بداية الأسبوع للمهام الأسبوعية والإحصائيات',
                    ),
                    trailing: DropdownButton<int>(
                      value: s.weekStartDay,
                      underline: const SizedBox.shrink(),
                      borderRadius: BorderRadius.circular(16),
                      items: weekDaysOrdered(DateTime.saturday)
                          .map(
                            (int d) => DropdownMenuItem<int>(
                              value: d,
                              child: Text(arabicWeekDayNames[d]!),
                            ),
                          )
                          .toList(),
                      onChanged: (int? d) {
                        if (d != null) {
                          set((AppSettings c) => c.copyWith(weekStartDay: d));
                        }
                      },
                    ),
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'اليوم الظاهر عند فتح التطبيق',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'تلقائي: اليوم نهارًا، والغد بعد الساعة 7 مساءً للتخطيط.',
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<StartPage>(
                            showSelectedIcon: false,
                            segments: StartPage.values
                                .map(
                                  (StartPage p) => ButtonSegment<StartPage>(
                                    value: p,
                                    label: Text(p.label),
                                  ),
                                )
                                .toList(),
                            selected: <StartPage>{s.startPage},
                            onSelectionChanged: (Set<StartPage> v) => set(
                              (AppSettings c) => c.copyWith(startPage: v.first),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  SwitchListTile(
                    secondary: const Icon(Icons.visibility_off_rounded),
                    value: s.hideCompleted,
                    onChanged: (bool v) =>
                        set((AppSettings c) => c.copyWith(hideCompleted: v)),
                    title: const Text('إخفاء المهام المكتملة'),
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.celebration_rounded),
                    value: s.celebrate,
                    onChanged: (bool v) =>
                        set((AppSettings c) => c.copyWith(celebrate: v)),
                    title: const Text('احتفال عند إنجاز كل المهام'),
                  ),
                ],
              ),
            ),

            // ----------------------------------------------- Reminders
            const SectionTitle('التذكيرات'),
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(
                      _notificationsEnabled ?? false
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_off_rounded,
                      color: _notificationsEnabled ?? false
                          ? const Color(0xFF10B981)
                          : scheme.error,
                    ),
                    title: Text(
                      _notificationsEnabled ?? false
                          ? 'الإشعارات مفعّلة'
                          : 'الإشعارات غير مفعّلة',
                    ),
                    subtitle: const Text('اضغط لمنح الصلاحيات وتحديث المواعيد'),
                    onTap: _enableNotifications,
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  SwitchListTile(
                    secondary: const Icon(Icons.replay_circle_filled_rounded),
                    value: s.followUpReminders,
                    onChanged: (bool v) => set(
                      (AppSettings c) => c.copyWith(followUpReminders: v),
                    ),
                    title: const Text('ذكّرني مجددًا إن لم أُنجز'),
                    subtitle: Text(
                      'بعد ${formatDurationShort(Duration(minutes: s.followUpMinutes))} من موعد المهمة',
                    ),
                  ),
                  if (s.followUpReminders)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Wrap(
                        spacing: 8,
                        children: <int>[15, 30, 60, 120].map((int m) {
                          return ChoiceChip(
                            label: Text(
                              formatDurationShort(Duration(minutes: m)),
                            ),
                            selected: s.followUpMinutes == m,
                            onSelected: (_) => set(
                              (AppSettings c) => c.copyWith(followUpMinutes: m),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  SwitchListTile(
                    secondary: const Icon(Icons.nightlight_round),
                    value: s.planningReminder,
                    onChanged: (bool v) =>
                        set((AppSettings c) => c.copyWith(planningReminder: v)),
                    title: const Text('تذكير مسائي لتخطيط الغد'),
                    subtitle: Text(
                      'يوميًا الساعة ${formatMinutesOfDay(s.planningReminderMinutes)}',
                    ),
                  ),
                  if (s.planningReminder)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: OutlinedButton.icon(
                          onPressed: () => _pickTime(
                            s.planningReminderMinutes,
                            (int m) => set(
                              (AppSettings c) =>
                                  c.copyWith(planningReminderMinutes: m),
                            ),
                          ),
                          icon: const Icon(Icons.schedule_rounded),
                          label: const Text('تغيير الوقت'),
                        ),
                      ),
                    ),
                  SwitchListTile(
                    secondary: const Icon(Icons.emoji_events_rounded),
                    value: s.goalsReminder,
                    onChanged: (bool v) =>
                        set((AppSettings c) => c.copyWith(goalsReminder: v)),
                    title: const Text('تحفيز أسبوعي بأهداف السنة'),
                    subtitle: const Text('كل جمعة الساعة 10 صباحًا'),
                  ),
                ],
              ),
            ),

            // ------------------------------------------------- Widgets
            const SectionTitle('ويدجت الشاشة الرئيسية'),
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.view_list_rounded),
                    title: const Text('ويدجت مهام اليوم'),
                    subtitle: const Text(
                      'قائمة المهام مع التقدّم وإنجاز بلمسة',
                    ),
                    trailing: const Icon(Icons.add_to_home_screen_rounded),
                    onTap: () => _pinWidget(summary: false),
                  ),
                  ListTile(
                    leading: const Icon(Icons.donut_large_rounded),
                    title: const Text('ويدجت الملخّص'),
                    subtitle: const Text('نسبة الإنجاز والمهمة التالية'),
                    trailing: const Icon(Icons.add_to_home_screen_rounded),
                    onTap: () => _pinWidget(summary: true),
                  ),
                  ListTile(
                    leading: const Icon(Icons.refresh_rounded),
                    title: const Text('تحديث الويدجت الآن'),
                    onTap: () async {
                      await context.read<TaskProvider>().refreshWidget();
                      _snack('تم تحديث الويدجت');
                    },
                  ),
                ],
              ),
            ),

            // ---------------------------------------------------- Data
            const SectionTitle('البيانات'),
            Card(
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.upload_file_rounded),
                    title: const Text('حفظ نسخة احتياطية'),
                    subtitle: const Text('المهام والأهداف والسجل في ملف واحد'),
                    onTap: _export,
                  ),
                  ListTile(
                    leading: const Icon(Icons.restore_page_rounded),
                    title: const Text('استعادة من نسخة'),
                    subtitle: const Text('السجل يُدمج ولا يُحذف أبدًا'),
                    onTap: _import,
                  ),
                ],
              ),
            ),

            // --------------------------------------------------- About
            const SectionTitle('حول التطبيق'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const MongezLogo(size: 52),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'مُنجز',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'الإصدار ${SettingsScreen.appVersion} • يعمل بدون إنترنت',
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _openLink('https://github.com/AdamG00D'),
                            icon: const FaIcon(
                              FontAwesomeIcons.github,
                              size: 18,
                            ),
                            label: const Text('GitHub'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _openLink('https://www.facebook.com/AdamGO0D'),
                            icon: const FaIcon(
                              FontAwesomeIcons.facebookF,
                              size: 18,
                            ),
                            label: const Text('Facebook'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundTile extends StatelessWidget {
  const _BackgroundTile({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.preview,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget preview;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        children: <Widget>[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? scheme.primary
                      : scheme.outlineVariant.withValues(alpha: 0.6),
                  width: selected ? 2.5 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    preview,
                    if (selected)
                      Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: CircleAvatar(
                            radius: 11,
                            backgroundColor: scheme.primary,
                            child: Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
