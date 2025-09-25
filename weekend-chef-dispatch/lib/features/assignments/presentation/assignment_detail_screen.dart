import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../../../core/models/contact.dart';
import '../../../core/models/delivery_assignment.dart';
import '../../../core/models/proof_of_delivery.dart';
import '../../../core/models/geo_point.dart';
import '../../../core/services/app_state.dart';
import '../../../core/services/app_state_scope.dart';
import '../../../core/utils/time_utils.dart';
import '../../communications/presentation/chat_screen.dart';
import '../../communications/presentation/incident_report_screen.dart';
import '../../proof/presentation/proof_capture_screen.dart';
import '../../shared/widgets/route_preview_map.dart';
import '../controllers/assignment_controller.dart';

class AssignmentDetailScreen extends StatelessWidget {
  const AssignmentDetailScreen({super.key, required this.assignmentId});

  final String assignmentId;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final controller = AssignmentController(appState);
    final assignment = controller.assignment(assignmentId);
    final optimizedRoute = controller.optimizedRoute(assignment);

    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${assignment.orderNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RoutePreviewMap(
              polyline: optimizedRoute.polyline,
              pickup: optimizedRoute.pickup.coordinate,
              dropoff: optimizedRoute.dropoff.coordinate,
              height: 220,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Chip(label: Text(assignment.status.label)),
                const SizedBox(width: 8),
                Chip(
                  avatar: const Icon(Icons.speed),
                  label: Text('${optimizedRoute.distanceKm.toStringAsFixed(1)} km / ${optimizedRoute.estimatedDuration.inMinutes} mins'),
                ),
                if (assignment.rush) ...[
                  const SizedBox(width: 8),
                  Chip(
                    avatar: const Icon(Icons.flash_on),
                    label: const Text('Rush delivery'),
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Stops & timing',
              child: Column(
                children: [
                  _StopTile(
                    icon: Icons.restaurant,
                    title: assignment.route.pickup.label,
                    subtitle: assignment.route.pickup.address,
                    trailing: Text(formatRelative(assignment.scheduledWindowStart)),
                  ),
                  const Divider(height: 1),
                  _StopTile(
                    icon: Icons.home_work,
                    title: assignment.route.dropoff.label,
                    subtitle: assignment.route.dropoff.address,
                    trailing: Text('Window ${formatWindow(assignment.scheduledWindowStart, assignment.scheduledWindowEnd)}'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Next actions',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    icon: Icon(_primaryActionIcon(assignment.status)),
                    label: Text(_primaryActionLabel(assignment.status)),
                    onPressed: () => _handlePrimaryAction(context, controller, assignment),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.navigation),
                    label: const Text('Copy route link'),
                    onPressed: () => _copyNavigationLink(context, optimizedRoute.pickup.coordinate,
                        optimizedRoute.dropoff.coordinate),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.report_gmailerrorred),
                    label: const Text('Report incident'),
                    onPressed: () => _openIncidentForm(context, assignment),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Contacts & messaging',
              child: Column(
                children: [
                  _ContactRow(
                    label: 'Cook ${assignment.cookName}',
                    phone: assignment.maskedCookPhone,
                    onChat: () => _openChat(context, assignment.id, ContactRole.cook),
                  ),
                  const Divider(height: 1),
                  _ContactRow(
                    label: 'Client ${assignment.clientName}',
                    phone: assignment.maskedClientPhone,
                    onChat: () => _openChat(context, assignment.id, ContactRole.client),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Timeline',
              child: Column(
                children: [
                  for (final event in assignment.events.reversed)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(event.message),
                      subtitle: Text(DateFormat.jm().format(event.timestamp)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Proof of delivery',
              child: assignment.proofOfDelivery == null
                  ? const Text('Pending — capture a signature and photo once the client receives the order.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Submitted ${DateFormat.yMMMd().add_jm().format(assignment.proofOfDelivery!.capturedAt)}'),
                        if (assignment.proofOfDelivery!.notes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(assignment.proofOfDelivery!.notes!),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _primaryActionIcon(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.readyForPickup:
        return Icons.local_shipping;
      case DeliveryStatus.pickedUp:
        return Icons.play_arrow;
      case DeliveryStatus.enRoute:
        return Icons.camera_alt_outlined;
      case DeliveryStatus.delivered:
        return Icons.fact_check;
      case DeliveryStatus.completed:
        return Icons.check_circle;
    }
  }

  String _primaryActionLabel(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.readyForPickup:
        return 'Start route';
      case DeliveryStatus.pickedUp:
        return 'Mark en route';
      case DeliveryStatus.enRoute:
        return 'Capture proof';
      case DeliveryStatus.delivered:
        return 'Complete order';
      case DeliveryStatus.completed:
        return 'Completed';
    }
  }

  void _handlePrimaryAction(
    BuildContext context,
    AssignmentController controller,
    DeliveryAssignment assignment,
  ) {
    if (assignment.status == DeliveryStatus.enRoute) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProofCaptureScreen(
            assignmentId: assignment.id,
            onProofCaptured: (proof) => controller.submitProof(assignment.id, proof),
          ),
        ),
      );
      return;
    }
    if (assignment.status == DeliveryStatus.delivered) {
      controller.advanceStatus(assignment.id);
      return;
    }
    if (assignment.status != DeliveryStatus.completed) {
      controller.advanceStatus(assignment.id);
    }
  }

  Future<void> _copyNavigationLink(
      BuildContext context, GeoPoint origin, GeoPoint destination) async {
    final link =
        'https://www.google.com/maps/dir/?api=1&origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&travelmode=driving';
    await Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('Navigation link copied to clipboard.')),
    );
  }

  void _openChat(BuildContext context, String assignmentId, ContactRole role) {
    final appState = AppStateScope.of(context);
    final thread = appState.chatThreads.firstWhere(
      (t) => t.assignmentId == assignmentId,
      orElse: () => ChatThread(
        id: 'thread-new-$assignmentId',
        assignmentId: assignmentId,
        subject: 'Order $assignmentId',
        participants: const [],
        messages: const [],
      ),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(thread: thread, initialFocusRole: role),
      ),
    );
  }

  void _openIncidentForm(BuildContext context, DeliveryAssignment assignment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IncidentReportScreen(assignment: assignment),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _StopTile extends StatelessWidget {
  const _StopTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.label,
    required this.phone,
    required this.onChat,
  });

  final String label;
  final String phone;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text('Masked line $phone'),
      trailing: Wrap(
        spacing: 8,
        children: [
          IconButton(
            icon: const Icon(Icons.sms_outlined),
            onPressed: onChat,
            tooltip: 'Open chat',
          ),
              IconButton(
            icon: const Icon(Icons.call),
            tooltip: 'Copy masked number',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: phone));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Masked number copied. Dial via your dispatcher device.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
