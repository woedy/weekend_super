import 'package:flutter/material.dart';

import '../../../../core/models/delivery_assignment.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../shared/widgets/route_preview_map.dart';

class AssignmentCard extends StatelessWidget {
  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
  });

  final DeliveryAssignment assignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceVariant.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(
                    avatar: Icon(
                      assignment.status.index >= DeliveryStatus.enRoute.index
                          ? Icons.delivery_dining
                          : Icons.inbox_outlined,
                      size: 18,
                    ),
                    label: Text(assignment.status.label),
                  ),
                  const SizedBox(width: 8),
                  if (assignment.rush)
                    Chip(
                      backgroundColor: colorScheme.errorContainer,
                      labelStyle: TextStyle(color: colorScheme.onErrorContainer),
                      avatar: Icon(Icons.flash_on, color: colorScheme.onErrorContainer, size: 18),
                      label: const Text('Rush'),
                    ),
                  const Spacer(),
                  Text(
                    assignment.orderNumber,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${assignment.cookName} → ${assignment.clientName}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${assignment.route.distanceKm.toStringAsFixed(1)} km • ETA ${assignment.route.estimatedDuration.inMinutes} mins',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              RoutePreviewMap(
                polyline: assignment.route.polyline,
                pickup: assignment.route.pickup.coordinate,
                dropoff: assignment.route.dropoff.coordinate,
                height: 150,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 18),
                  const SizedBox(width: 4),
                  Text('Window ${formatWindow(assignment.scheduledWindowStart, assignment.scheduledWindowEnd)}'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                assignment.notes ?? 'No special notes for this run.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
