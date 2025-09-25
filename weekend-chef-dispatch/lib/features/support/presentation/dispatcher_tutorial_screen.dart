import 'package:flutter/material.dart';

class DispatcherTutorialScreen extends StatelessWidget {
  const DispatcherTutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const sections = [
      _TutorialSection(
        title: 'Food safety in transit',
        subtitle: 'Protect meals from temperature abuse and cross-contamination.',
        bullets: [
          'Pre-chill cold bags and pre-heat hot boxes before arriving at the cook\'s location.',
          'Never place raw groceries and ready-to-eat meals in the same compartment.',
          'Log cooler temperatures at pickup and drop-off if the trip exceeds 30 minutes.',
        ],
      ),
      _TutorialSection(
        title: 'Packaging checks',
        subtitle: 'Catch issues before you leave the kitchen.',
        bullets: [
          'Confirm tamper-evident seals are intact and request replacements if damaged.',
          'Verify labels match the client name and include allergen callouts.',
          'Secure soups and sauces upright and double bag any items with risk of leakage.',
        ],
      ),
      _TutorialSection(
        title: 'Delivery etiquette',
        subtitle: 'Create a reassuring doorstep experience for clients.',
        bullets: [
          'Send the "On the way" status update when you depart so clients can prepare.',
          'Arrive in the agreed delivery window and message dispatch if you expect delays.',
          'Offer a quick handoff summary and remind clients to refrigerate items within 2 hours.',
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Dispatcher onboarding tips')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'These guides cover the must-do steps from dispatcher ride-alongs and delivery QA audits.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          for (final section in sections) ...[
            _TutorialCard(section: section),
            const SizedBox(height: 16),
          ],
          Card(
            color: Colors.blueGrey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Need a live assist?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.support_agent_outlined),
                    title: Text('Radio operations via the dispatcher WhatsApp line'),
                    subtitle: Text('+234 800 000 1111 · monitored 6am – midnight'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.description_outlined),
                    title: Text('Log incidents at weekendchef.app/support/faq'),
                    subtitle: Text('Choose "Delivery issue" so the team can escalate within 15 minutes.'),
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
