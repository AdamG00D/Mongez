import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/backgrounds.dart';

/// The privacy policy, readable offline. The same text is published at
/// [privacyPolicyUrl] (PRIVACY.md in the repository) for the store listing.
const String privacyPolicyUrl =
    'https://github.com/AdamG00D/Mongez_App/blob/main/PRIVACY.md';

/// What the app reads through Android's "Usage access", in plain words. Shown
/// before the user is sent to the system settings page and in the policy.
const String usageAccessDisclosure =
    'لعرض وقت الشاشة، يقرأ مُنجز من نظام أندرويد بيانات استخدام هاتفك: '
    'التطبيقات التي تفتحها، ومدة استخدام كل تطبيق، ومدة تشغيل الشاشة، وعدد '
    'مرات فتح القفل.\n\n'
    'تُقرأ هذه البيانات أثناء فتحك للتطبيق فقط (وليس في الخلفية)، وتُعرض لك في '
    'شاشة "وقت الشاشة"، وتبقى على جهازك: لا تُرسل ولا تُباع ولا تُشارك مع أي جهة. التطبيق لا يتصل '
    'بالإنترنت أصلًا.\n\n'
    'يمكنك إلغاء الصلاحية في أي وقت من إعدادات الهاتف.';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const PrivacyPolicyScreen(),
      ),
    );
  }

  static const List<(String, String)> _sections = <(String, String)>[
    (
      'الخلاصة',
      'مُنجز يعمل بالكامل على هاتفك. لا يوجد حساب، ولا إعلانات، ولا أدوات تتبّع '
          'أو تحليلات، والتطبيق لا يملك صلاحية الاتصال بالإنترنت. نحن لا نجمع أي '
          'بيانات عنك ولا نستقبلها.',
    ),
    (
      'البيانات المحفوظة على جهازك',
      'مهامك وملاحظاتها، سجل الإنجاز، أهدافك، إعدادات التطبيق، قائمة التطبيقات '
          'التي اخترت متابعتها وحدودها اليومية، وصورة الخلفية إن اخترت واحدة. '
          'كلها محفوظة في مساحة التطبيق الخاصة على الهاتف فقط.',
    ),
    (
      'بيانات استخدام الهاتف (وقت الشاشة)',
      'هذه الميزة اختيارية ولا تعمل إلا إذا منحت التطبيق صلاحية "الوصول إلى '
          'بيانات الاستخدام" بنفسك من إعدادات الهاتف.\n\n$usageAccessDisclosure',
    ),
    (
      'الصلاحيات الأخرى',
      '• الإشعارات والمنبّهات والتذكيرات: لإرسال تذكيرات المهام في موعدها.\n'
          '• التشغيل عند إقلاع الهاتف: لإعادة جدولة التذكيرات بعد إعادة التشغيل.\n'
          '• الاهتزاز: مع التذكيرات.\n'
          '• الصور: لا يطلب التطبيق صلاحية الصور؛ عند اختيار خلفية تُفتح أداة '
          'اختيار الصور الخاصة بالنظام ويحصل التطبيق على الصورة التي تختارها فقط.',
    ),
    (
      'النسخ الاحتياطي',
      'عند تصدير نسخة احتياطية يُنشأ ملف في المكان الذي تختاره أنت، وأنت من '
          'يتحكم فيه. قد ينسخ نظام أندرويد بيانات التطبيق ضمن النسخ الاحتياطي '
          'لحسابك في Google إذا كان مفعّلًا على هاتفك؛ هذا خاضع لإعدادات هاتفك '
          'وسياسة Google.',
    ),
    (
      'حذف بياناتك',
      'يمكنك حذف المهام والسجل من داخل التطبيق. ولحذف كل شيء: امسح بيانات '
          'التطبيق من إعدادات الهاتف أو أزل التطبيق.',
    ),
    (
      'الأطفال',
      'التطبيق أداة تنظيم عامة وغير موجّه للأطفال، ولا يجمع بيانات من أي '
          'مستخدم.',
    ),
    (
      'التغييرات والتواصل',
      'أي تغيير على هذه السياسة يُنشر مع تحديث التطبيق وفي صفحة المشروع. '
          'التطبيق مفتوح المصدر، وللأسئلة يمكنك فتح تذكرة في صفحة المشروع على '
          'GitHub.\n\nآخر تحديث: 10 نوفمبر 2026',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                child: Row(
                  children: <Widget>[
                    const BackButton(),
                    Expanded(
                      child: Text(
                        'سياسة الخصوصية',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: <Widget>[
                    for (final (String title, String body) in _sections)
                      Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                title,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                body,
                                style: textTheme.bodyMedium?.copyWith(
                                  height: 1.7,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    OutlinedButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse(privacyPolicyUrl),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('نسخة الويب (عربي / English)'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
