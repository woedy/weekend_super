import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../core/app_state.dart';
import '../../core/models/cook_profile.dart';
import '../../core/utils/date_formatters.dart';
import '../support/cook_tutorial_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onEditVerification});

  final VoidCallback onEditVerification;

  @override
  Widget build(BuildContext context) {
    final state = CookAppScope.of(context);
    final profile = state.profile;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cook profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(pagePadding),
        children: [
          _ApprovalCard(profile: profile, onEditVerification: onEditVerification),
          const SizedBox(height: 16),
          _DocumentsCard(profile: profile, onEditVerification: onEditVerification),
          const SizedBox(height: 16),
          _ServiceAreaCard(onEdit: () => _editServiceAreas(context, state)),
          const SizedBox(height: 16),
          _AvailabilityCard(onAddSlot: () => _addAvailability(context, state)),
          const SizedBox(height: 16),
          _SpecialtiesCard(onEdit: () => _editSpecialties(context, state)),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.school_outlined),
              title: const Text('Training & tutorials'),
              subtitle: const Text('Refresh food safety, packaging, and delivery best practices.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CookTutorialScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Need to update verification documents?',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'You can resubmit improved photos or add new certifications anytime. We prioritise re-verifications within 12 hours.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: brandTextSecondary),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: onEditVerification,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Resubmit verification'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editServiceAreas(BuildContext context, AppState state) async {
    final current = Set<String>.from(state.profile.serviceAreas);
    final areas = state.allServiceAreas;
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Service areas', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final area in areas)
                        FilterChip(
                          label: Text(area),
                          selected: current.contains(area),
                          onSelected: (value) => setModalState(() {
                            if (value) {
                              current.add(area);
                            } else {
                              current.remove(area);
                            }
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () {
                        state.updateServiceAreas(current.toList());
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _editSpecialties(BuildContext context, AppState state) async {
    final current = Set<String>.from(state.profile.specialties);
    final specialties = state.allSpecialties;
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select specialties', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final specialty in specialties)
                        FilterChip(
                          label: Text(specialty),
                          selected: current.contains(specialty),
                          onSelected: (value) => setModalState(() {
                            if (value) {
                              current.add(specialty);
                            } else {
                              current.remove(specialty);
                            }
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () {
                        state.updateSpecialties(current.toList());
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _addAvailability(BuildContext context, AppState state) async {
    const daysOfWeek = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    String selectedDay = daysOfWeek.first;
    TimeOfDay start = const TimeOfDay(hour: 10, minute: 0);
    TimeOfDay end = const TimeOfDay(hour: 14, minute: 0);

    final window = await showDialog<AvailabilityWindow>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Add availability'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedDay,
                    items: [
                      for (final day in daysOfWeek)
                        DropdownMenuItem<String>(
                          value: day,
                          child: Text(day),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() => selectedDay = value);
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Day of week'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: start,
                            );
                            if (picked != null) {
                              setModalState(() => start = picked);
                            }
                          },
                          child: Text('Start: ${formatTimeOfDay(start)}'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: end,
                            );
                            if (picked != null) {
                              setModalState(() => end = picked);
                            }
                          },
                          child: Text('End: ${formatTimeOfDay(end)}'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (start.hour * 60 + start.minute >= end.hour * 60 + end.minute) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Start time must be before end time.')),
                      );
                      return;
                    }
                    Navigator.of(context).pop(
                      AvailabilityWindow(day: selectedDay, start: start, end: end),
                    );
                  },
                  child: const Text('Add window'),
                ),
              ],
            );
          },
        );
      },
    );

    if (window != null) {
      state.addAvailabilityWindow(window);
    }
  }
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({required this.profile, required this.onEditVerification});

  final CookProfile profile;
  final VoidCallback onEditVerification;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(profile.approvalStatus);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified_user, color: statusColor),
                const SizedBox(width: 12),
                Text(
                  profile.approvalStatus.name.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(profile.approvalCopy()),
            if (profile.submittedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Submitted ${formatPayoutStatus(profile.submittedAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: brandTextSecondary),
              ),
            ],
            if (profile.approvalStatus == ApprovalStatus.rejected)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onEditVerification,
                  child: const Text('Update documents'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.approved:
        return brandSuccess;
      case ApprovalStatus.pending:
        return brandWarning;
      case ApprovalStatus.rejected:
        return brandDanger;
      case ApprovalStatus.draft:
      default:
        return brandTextSecondary;
    }
  }
}

class _DocumentsCard extends StatelessWidget {
  const _DocumentsCard({required this.profile, required this.onEditVerification});

  final CookProfile profile;
  final VoidCallback onEditVerification;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Verification documents', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _documentTile(
              context,
              label: 'Government ID',
              document: profile.idDocument,
            ),
            const SizedBox(height: 12),
            _documentTile(
              context,
              label: 'Food safety certification',
              document: profile.certificationDocument,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onEditVerification,
              icon: const Icon(Icons.edit_document),
              label: const Text('Replace or add documents'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _documentTile(BuildContext context,
      {required String label, DocumentUpload? document}) {
    final hasDoc = document != null;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        hasDoc ? Icons.check_circle : Icons.highlight_off,
        color: hasDoc ? brandSuccess : brandWarning,
      ),
      title: Text(label),
      subtitle: Text(
        hasDoc
            ? 'Uploaded ${formatPayoutStatus(document!.uploadedAt)}'
            : 'Upload required before approval',
      ),
    );
  }
}

class _ServiceAreaCard extends StatelessWidget {
  const _ServiceAreaCard({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final profile = CookAppScope.of(context).profile;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Service areas', style: Theme.of(context).textTheme.titleLarge),
                TextButton(onPressed: onEdit, child: const Text('Edit')),
              ],
            ),
            const SizedBox(height: 12),
            if (profile.serviceAreas.isEmpty)
              const Text('Select at least one area to receive bookings.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final area in profile.serviceAreas)
                    Chip(
                      label: Text(area),
                      backgroundColor: brandSurface,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({required this.onAddSlot});

  final VoidCallback onAddSlot;

  @override
  Widget build(BuildContext context) {
    final profile = CookAppScope.of(context).profile;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Availability', style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: onAddSlot,
                  icon: const Icon(Icons.add),
                  label: const Text('Add slot'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (profile.availability.isEmpty)
              const Text('No availability set. Add slots so clients can schedule you.')
            else
              Column(
                children: [
                  for (final window in profile.availability)
                    Card(
                      color: brandSurface,
                      child: ListTile(
                        title: Text(window.displayLabel),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            CookAppScope.of(context).removeAvailabilityWindow(window);
                          },
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SpecialtiesCard extends StatelessWidget {
  const _SpecialtiesCard({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final profile = CookAppScope.of(context).profile;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Specialties', style: Theme.of(context).textTheme.titleLarge),
                TextButton(onPressed: onEdit, child: const Text('Edit')),
              ],
            ),
            const SizedBox(height: 12),
            if (profile.specialties.isEmpty)
              const Text('Clients love knowing your niche — add at least one specialty.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final specialty in profile.specialties)
                    Chip(
                      label: Text(specialty),
                      backgroundColor: brandSurface,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
