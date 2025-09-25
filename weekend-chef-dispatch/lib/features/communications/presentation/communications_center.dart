import 'package:flutter/material.dart';

import '../../../core/models/contact.dart';
import '../../../core/models/incident_report.dart';
import '../../../core/services/app_state_scope.dart';
import '../../assignments/presentation/assignment_detail_screen.dart';
import 'chat_screen.dart';

class CommunicationsCenter extends StatelessWidget {
  const CommunicationsCenter({super.key, required this.threads});

  final List<ChatThread> threads;

  @override
  Widget build(BuildContext context) {
    final incidents = AppStateScope.of(context).incidents;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages & incidents'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Live chats', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (threads.isEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.chat_bubble_outline),
                title: const Text('No active chats'),
                subtitle: const Text('You will be notified when a cook or client reaches out.'),
              ),
            )
          else
            ...threads.map((thread) => _ChatPreview(thread: thread)),
          const SizedBox(height: 24),
          Text('Incident log', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (incidents.isEmpty)
            Card(
              child: ListTile(
                leading: const Icon(Icons.report_gmailerrorred_outlined),
                title: const Text('No incidents filed'),
                subtitle: const Text('Great job keeping everything on schedule!'),
              ),
            )
          else
            ...incidents.map((incident) => _IncidentTile(incident: incident)),
        ],
      ),
    );
  }
}

class _ChatPreview extends StatelessWidget {
  const _ChatPreview({required this.thread});

  final ChatThread thread;

  @override
  Widget build(BuildContext context) {
    final lastMessage = thread.messages.isNotEmpty ? thread.messages.last : null;
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.chat)),
        title: Text(thread.subject),
        subtitle: lastMessage == null
            ? const Text('No messages yet')
            : Text('${lastMessage.sender.name}: ${lastMessage.body}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatScreen(thread: thread),
            ),
          );
        },
      ),
    );
  }
}

class _IncidentTile extends StatelessWidget {
  const _IncidentTile({required this.incident});

  final IncidentReport incident;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.warning_amber_rounded),
        title: Text(incident.type),
        subtitle: Text(incident.description),
        trailing: Text(
          TimeOfDay.fromDateTime(incident.submittedAt).format(context),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AssignmentDetailScreen(assignmentId: incident.assignmentId),
            ),
          );
        },
      ),
    );
  }
}
