import 'package:flutter/material.dart';
import '../../../core/models/delivery_assignment.dart';
import '../../../core/services/app_state.dart';
import '../../../core/services/app_state_scope.dart';
import '../controllers/assignment_controller.dart';
import 'assignment_detail_screen.dart';
import 'widgets/assignment_card.dart';

class AssignmentDashboard extends StatefulWidget {
  const AssignmentDashboard({super.key});

  @override
  State<AssignmentDashboard> createState() => _AssignmentDashboardState();
}

class _AssignmentDashboardState extends State<AssignmentDashboard> {
  int _segmentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final controller = AssignmentController(appState);

    final segments = <String, List<DeliveryAssignment>>{
      'Ready': controller.assignmentsForStatus(DeliveryStatus.readyForPickup),
      'In progress': controller.inProgressAssignments,
      'Completed': controller.completedAssignments,
    };

    final labels = segments.keys.toList();
    final activeList = segments.values.elementAt(_segmentIndex);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh assignments',
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _QueueMetrics(appState: appState),
            const SizedBox(height: 16),
            SegmentedButton<int>(
              segments: [
                for (var i = 0; i < labels.length; i++)
                  ButtonSegment(value: i, label: Text(labels[i])),
              ],
              selected: <int>{_segmentIndex},
              onSelectionChanged: (selection) {
                setState(() => _segmentIndex = selection.first);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: activeList.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      itemCount: activeList.length,
                      itemBuilder: (context, index) {
                        final assignment = activeList[index];
                        return AssignmentCard(
                          assignment: assignment,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AssignmentDetailScreen(assignmentId: assignment.id),
                              ),
                            );
                          },
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueMetrics extends StatelessWidget {
  const _QueueMetrics({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        _MetricChip(
          label: 'Ready',
          value: appState.assignments.where((a) => a.status == DeliveryStatus.readyForPickup).length.toString(),
          color: colorScheme.primary,
        ),
        const SizedBox(width: 12),
        _MetricChip(
          label: 'En route',
          value: appState.assignments
              .where((a) => a.status == DeliveryStatus.enRoute || a.status == DeliveryStatus.pickedUp)
              .length
              .toString(),
          color: colorScheme.secondary,
        ),
        const SizedBox(width: 12),
        _MetricChip(
          label: 'Completed (24h)',
          value: appState.assignments
              .where((a) =>
                  (a.status == DeliveryStatus.completed || a.status == DeliveryStatus.delivered) &&
                  DateTime.now().difference(a.scheduledWindowEnd).inHours <= 24)
              .length
              .toString(),
          color: colorScheme.tertiary,
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          const Text('No assignments in this bucket right now.'),
          const SizedBox(height: 4),
          Text(
            'Enjoy the breather! You will get a push notification once a new route is ready.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
