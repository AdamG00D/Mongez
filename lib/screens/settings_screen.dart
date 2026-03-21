import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import 'history_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _refreshWidget(BuildContext context) async {
    final provider = context.read<TaskProvider>();
    await provider.refreshWidget();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم تحديث ويدجت مهام اليوم')));
  }

  Future<void> _requestPinWidget(BuildContext context) async {
    final provider = context.read<TaskProvider>();
    final isSupported = await provider.requestPinWidget();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSupported
              ? 'تم إرسال طلب إضافة الويدجت إلى الشاشة الرئيسية'
              : 'قد لا يدعم اللانشر الإضافة التلقائية. أضف الويدجت يدويًا من قائمة الويدجت.',
        ),
      ),
    );
  }

  Future<void> _enableNotifications(BuildContext context) async {
    final provider = context.read<TaskProvider>();
    await provider.requestNotificationPermissions();

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تفعيل إعدادات الإشعارات وتحديث مواعيد المهام'),
      ),
    );
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر فتح الرابط')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'المظهر',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('اختر الثيم المناسب لك'),
                  const SizedBox(height: 14),
                  SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: const <ButtonSegment<ThemeMode>>[
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded),
                        label: Text('Light'),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded),
                        label: Text('Dark'),
                      ),
                      ButtonSegment<ThemeMode>(
                        value: ThemeMode.system,
                        icon: Icon(Icons.phone_android_rounded),
                        label: Text('System'),
                      ),
                    ],
                    selected: <ThemeMode>{themeProvider.themeMode},
                    onSelectionChanged: (Set<ThemeMode> selection) {
                      themeProvider.setThemeMode(selection.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history_rounded),
              title: const Text('فتح سجل الإنجاز'),
              subtitle: const Text('عرض المهام المكتملة من الأحدث إلى الأقدم'),
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HistoryScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'الإشعارات',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'فعّل صلاحيات الإشعارات لضمان وصول تنبيه عند وقت المهمة.',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _enableNotifications(context),
                    icon: const Icon(Icons.notifications_active_rounded),
                    label: const Text('تفعيل الإشعارات'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'ويدجت الشاشة الرئيسية',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'الويدجت يعرض مهام اليوم بتصميم احترافي، ويمكنك إتمام المهمة مباشرة منه.',
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      FilledButton.icon(
                        onPressed: () => _refreshWidget(context),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('تحديث الويدجت'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _requestPinWidget(context),
                        icon: const Icon(Icons.add_box_rounded),
                        label: const Text('طلب إضافة الويدجت'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'صفحات التواصل',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('تابعني عبر المنصات التالية:'),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: <Widget>[
                      _SocialCircleButton(
                        icon: FontAwesomeIcons.github,
                        label: 'GitHub',
                        onTap: () =>
                            _openLink(context, 'https://github.com/AdamG00D'),
                      ),
                      _SocialCircleButton(
                        icon: FontAwesomeIcons.facebookF,
                        label: 'Facebook',
                        onTap: () => _openLink(
                          context,
                          'https://www.facebook.com/AdamGO0D',
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
    );
  }
}

class _SocialCircleButton extends StatelessWidget {
  const _SocialCircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 23),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
