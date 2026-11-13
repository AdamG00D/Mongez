import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/l10n.dart';
import '../theme/backgrounds.dart';

/// The privacy policy, readable offline. The same text is published at
/// [privacyPolicyUrl] (PRIVACY.md in the repository) for the store listing.
const String privacyPolicyUrl =
    'https://github.com/AdamG00D/Mongez/blob/main/PRIVACY.md';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const PrivacyPolicyScreen(),
      ),
    );
  }

  static List<(String, String)> _sections(AppLocalizations l) =>
      <(String, String)>[
        (l.privacySummaryTitle, l.privacySummaryBody),
        (l.privacyStoredTitle, l.privacyStoredBody),
        (
          l.privacyUsageTitle,
          '${l.privacyUsageIntro}\n\n${l.usageAccessDisclosure}',
        ),
        (l.privacyPermissionsTitle, l.privacyPermissionsBody),
        (l.privacyBackupTitle, l.privacyBackupBody),
        (l.privacyDeleteTitle, l.privacyDeleteBody),
        (l.privacyChildrenTitle, l.privacyChildrenBody),
        (l.privacyChangesTitle, l.privacyChangesBody),
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
                        context.l10n.privacyPolicy,
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
                    for (final (String title, String body) in _sections(
                      context.l10n,
                    ))
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
                      label: Text(context.l10n.privacyWebVersion),
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
