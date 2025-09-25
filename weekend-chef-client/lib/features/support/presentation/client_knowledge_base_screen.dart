import 'package:flutter/material.dart';

import '../../../localization/app_localizations.dart';
import '../../../localization/localization_extension.dart';

class ClientKnowledgeBaseScreen extends StatelessWidget {
  const ClientKnowledgeBaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sections = _buildSections(l10n);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('knowledgeBaseTitle'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l10n.translate('knowledgeBaseIntro'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          for (final section in sections) ...[
            _TutorialCard(section: section),
            const SizedBox(height: 16),
          ],
          const _SupportCard(),
        ],
      ),
    );
  }

  List<_TutorialSection> _buildSections(AppLocalizations l10n) {
    return [
      _TutorialSection(
        title: l10n.translate('knowledgeClientSection1Title'),
        subtitle: l10n.translate('knowledgeClientSection1Subtitle'),
        bullets: [
          l10n.translate('knowledgeClientSection1Item1'),
          l10n.translate('knowledgeClientSection1Item2'),
          l10n.translate('knowledgeClientSection1Item3'),
        ],
      ),
      _TutorialSection(
        title: l10n.translate('knowledgeClientSection2Title'),
        subtitle: l10n.translate('knowledgeClientSection2Subtitle'),
        bullets: [
          l10n.translate('knowledgeClientSection2Item1'),
          l10n.translate('knowledgeClientSection2Item2'),
          l10n.translate('knowledgeClientSection2Item3'),
        ],
      ),
      _TutorialSection(
        title: l10n.translate('knowledgeClientSection3Title'),
        subtitle: l10n.translate('knowledgeClientSection3Subtitle'),
        bullets: [
          l10n.translate('knowledgeClientSection3Item1'),
          l10n.translate('knowledgeClientSection3Item2'),
          l10n.translate('knowledgeClientSection3Item3'),
        ],
      ),
    ];
  }
}

class _TutorialSection {
  const _TutorialSection({
    required this.title,
    required this.subtitle,
    required this.bullets,
  });

  final String title;
  final String subtitle;
  final List<String> bullets;
}

class _TutorialCard extends StatelessWidget {
  const _TutorialCard({required this.section});

  final _TutorialSection section;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(section.subtitle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            for (final bullet in section.bullets)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.teal, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        bullet,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      color: Colors.teal.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.translate('knowledgeSupportTitle'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email_outlined),
              title: Text(l10n.translate('knowledgeSupportEmailTitle')),
              subtitle: Text('support@weekendchef.app'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.phone_in_talk_outlined),
              title: Text(l10n.translate('knowledgeSupportPhoneTitle')),
              subtitle: Text(l10n.translate('knowledgeSupportPhoneHours')),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.translate('knowledgeSupportFaqCta'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            SelectableText(
              'weekendchef.app/support/faq',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}
