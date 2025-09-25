import 'package:flutter/material.dart';

class CookTutorialScreen extends StatelessWidget {
  const CookTutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const sections = [
      _TutorialSection(
        title: 'Food safety & prep',
        subtitle: 'Keep every kitchen compliant before you begin.',
        bullets: [
          'Review allergy flags in the order summary and store allergen ingredients separately.',
          'Wash hands for 20 seconds before handling ingredients and between raw/cooked tasks.',
          'Use the client\'s thermometer or your own to confirm proteins reach safe temperatures.',
        ],
      ),
      _TutorialSection(
        title: 'Packaging & labeling',
        subtitle: 'Set clients up with clear reheating guidance.',
        bullets: [
          'Pack entrees and sides in separate, vented containers so textures stay crisp.',
          'Label each container with the dish name, allergens, and reheating method.',
          'Cool hot dishes for at least 5 minutes before sealing to avoid condensation.',
        ],
      ),
      _TutorialSection(
        title: 'Delivery coordination',
        subtitle: 'Hand off meals smoothly to the dispatcher team.',
        bullets: [
          'Confirm the pickup window inside the app once plating is underway.',
          'Share any last-minute substitutions or notes in the order chat before handoff.',
          'Stage insulated bags near the door so dispatchers can load and depart quickly.',
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Cook onboarding guides')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Use these quick refreshers before accepting a new booking. They cover the top questions from food safety audits and client feedback.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          for (final section in sections) ...[
            _TutorialCard(section: section),
            const SizedBox(height: 16),
          ],
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Need support mid-shift?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.headset_mic_outlined),
                    title: Text('Call operations on +234 800 000 0000'),
                    subtitle: Text('Daily from 6am – 10pm for delivery or ingredient issues.'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.mail_outline),
                    title: Text('Email certifications to safety@weekendchef.app'),
                    subtitle: Text('We review new documents within one business day.'),
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
                    Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(bullet)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
