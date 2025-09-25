import 'package:flutter/material.dart';

import '../../../core/models/dispatcher_profile.dart';
import '../../support/presentation/dispatcher_tutorial_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.dispatcher});

  final DispatcherProfile dispatcher;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(dispatcher.name),
            subtitle: Text(dispatcher.email),
            trailing: Chip(
              avatar: const Icon(Icons.star, size: 16),
              label: Text('${(dispatcher.onTimeRate * 100).round()}% on-time'),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Service areas', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: dispatcher.serviceAreas
                        .map((area) => Chip(label: Text(area)))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.fact_check_outlined),
                  title: const Text('Deliveries completed'),
                  trailing: Text(dispatcher.completedDeliveries.toString()),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: true,
                  onChanged: (_) {},
                  title: const Text('Accepting new assignments'),
                  subtitle: const Text('You can toggle availability when you need a break.'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.school_outlined),
              title: const Text('Training hub'),
              subtitle: const Text('Tutorials on food safety, packaging, and delivery etiquette.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DispatcherTutorialScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text('Need assistance?'),
                  subtitle: Text('Reach support at support@weekendchef.app or via dispatcher Slack channel.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
