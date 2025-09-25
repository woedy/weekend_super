import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../core/app_state.dart';
import '../../core/models/cook_profile.dart';
import '../../core/utils/date_formatters.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.isEditing = false});

  final bool isEditing;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _identityFormKey = GlobalKey<FormState>();
  int _currentStep = 0;
  late TextEditingController _legalNameController;
  late TextEditingController _kitchenNameController;
  late TextEditingController _bioController;
  DocumentUpload? _idDocument;
  DocumentUpload? _certDocument;
  late List<String> _selectedSpecialties;
  late List<String> _selectedAreas;
  late List<AvailabilityWindow> _availability;
  bool _acknowledgedGuidelines = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _legalNameController = TextEditingController();
    _kitchenNameController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final appState = CookAppScope.of(context);
    final profile = appState.profile;
    _legalNameController.text = profile.legalName;
    _kitchenNameController.text = profile.kitchenName;
    _bioController.text = profile.bio;
    _selectedSpecialties = List<String>.from(profile.specialties);
    _selectedAreas = List<String>.from(profile.serviceAreas);
    _availability = List<AvailabilityWindow>.from(profile.availability);
    _idDocument = profile.idDocument;
    _certDocument = profile.certificationDocument;
    _acknowledgedGuidelines = widget.isEditing ? true : false;
    _initialized = true;
  }

  @override
  void dispose() {
    _legalNameController.dispose();
    _kitchenNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = CookAppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Update verification' : 'Get verified to cook'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        controlsBuilder: _buildControls,
        onStepCancel: () {
          if (_currentStep == 0) {
            if (widget.isEditing) Navigator.of(context).pop();
            return;
          }
          setState(() => _currentStep -= 1);
        },
        onStepContinue: () {
          if (_currentStep == 0) {
            if (_identityFormKey.currentState?.validate() ?? false) {
              setState(() => _currentStep += 1);
            }
          } else if (_currentStep == 1) {
            if (_selectedAreas.isEmpty) {
              _showSnack('Select at least one service area.');
              return;
            }
            if (_availability.isEmpty) {
              _showSnack('Add at least one availability window.');
              return;
            }
            setState(() => _currentStep += 1);
          } else {
            _submit(appState);
          }
        },
        steps: [
          Step(
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            title: const Text('Verification'),
            subtitle: const Text('KYC, certifications & specialties'),
            content: _buildIdentityStep(appState),
          ),
          Step(
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            title: const Text('Service area & schedule'),
            subtitle: const Text('Where and when you can cook'),
            content: _buildScheduleStep(appState),
          ),
          Step(
            isActive: _currentStep >= 2,
            state: _currentStep == 2 && !_acknowledgedGuidelines
                ? StepState.editing
                : StepState.indexed,
            title: const Text('Review & submit'),
            subtitle: const Text('Confirm details for admin review'),
            content: _buildSummaryStep(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityStep(AppState state) {
    return Form(
      key: _identityFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _legalNameController,
            decoration: const InputDecoration(labelText: 'Legal full name'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Enter the name that matches your government ID'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _kitchenNameController,
            decoration: const InputDecoration(
              labelText: 'Kitchen name',
              hintText: 'How clients recognize your brand',
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Provide the name shown to clients'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: 'Pitch your kitchen',
              hintText: 'Tell clients what makes you unique',
            ),
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          Text('Upload documents', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _DocumentTile(
            label: 'Government-issued ID',
            document: _idDocument,
            onTap: () {
              setState(() {
                final timestamp = DateTime.now();
                _idDocument = DocumentUpload(
                  label: 'Government ID',
                  fileName: 'id_${timestamp.millisecondsSinceEpoch}.pdf',
                  uploadedAt: timestamp,
                );
              });
              _showSnack('ID upload simulated — replace with actual picker integration.');
            },
          ),
          const SizedBox(height: 12),
          _DocumentTile(
            label: 'Food safety certification',
            document: _certDocument,
            onTap: () {
              setState(() {
                final timestamp = DateTime.now();
                _certDocument = DocumentUpload(
                  label: 'Food safety cert',
                  fileName: 'cert_${timestamp.millisecondsSinceEpoch}.pdf',
                  uploadedAt: timestamp,
                );
              });
              _showSnack('Certification upload simulated for demo purposes.');
            },
          ),
          const SizedBox(height: 24),
          Text('Specialties', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final specialty in state.allSpecialties)
                FilterChip(
                  label: Text(specialty),
                  selected: _selectedSpecialties.contains(specialty),
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedSpecialties.add(specialty);
                      } else {
                        _selectedSpecialties.remove(specialty);
                      }
                    });
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleStep(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Service areas', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final area in state.allServiceAreas)
              FilterChip(
                label: Text(area),
                selected: _selectedAreas.contains(area),
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _selectedAreas.add(area);
                    } else {
                      _selectedAreas.remove(area);
                    }
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Weekly availability', style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: _openAvailabilityDialog,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add window'),
            ),
          ],
        ),
        if (_availability.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('No availability added yet.'),
          )
        else
          Column(
            children: [
              for (final window in _availability)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(window.displayLabel),
                    subtitle: const Text('Tap trash icon to remove'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() => _availability.remove(window));
                      },
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildSummaryStep(ThemeData theme) {
    final profile = CookAppScope.of(context).profile.copyWith(
          legalName: _legalNameController.text,
          kitchenName: _kitchenNameController.text,
          bio: _bioController.text,
          specialties: _selectedSpecialties,
          serviceAreas: _selectedAreas,
          availability: _availability,
          idDocument: _idDocument,
          certificationDocument: _certDocument,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.kitchenName, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(profile.bio, style: theme.textTheme.bodyMedium),
                const Divider(),
                _SummaryRow(label: 'Legal name', value: profile.legalName),
                _SummaryRow(
                  label: 'Specialties',
                  value: profile.specialties.isEmpty
                      ? 'Add at least one specialty'
                      : profile.specialties.join(', '),
                ),
                _SummaryRow(
                  label: 'Service areas',
                  value: profile.serviceAreas.isEmpty
                      ? 'No areas selected yet'
                      : profile.serviceAreas.join(', '),
                ),
                _SummaryRow(
                  label: 'Availability',
                  value: profile.availability.isEmpty
                      ? 'Add at least one window'
                      : profile.availability.map((w) => w.displayLabel).join(' • '),
                ),
                _SummaryRow(
                  label: 'ID document',
                  value: _idDocument == null
                      ? 'Upload required'
                      : 'Uploaded ${formatShortDate(_idDocument!.uploadedAt)}',
                ),
                _SummaryRow(
                  label: 'Food safety cert',
                  value: _certDocument == null
                      ? 'Upload required'
                      : 'Uploaded ${formatShortDate(_certDocument!.uploadedAt)}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _acknowledgedGuidelines,
          onChanged: (value) => setState(() => _acknowledgedGuidelines = value ?? false),
          title: const Text('I confirm my kitchen meets food safety standards and delivery packaging expectations.'),
        ),
        const SizedBox(height: 8),
        Text(
          'Our operations team reviews documents within 24 hours. You will receive push and email updates with the decision.',
          style: theme.textTheme.bodySmall?.copyWith(color: brandTextSecondary),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, ControlsDetails details) {
    final isLastStep = _currentStep == 2;
    return Row(
      children: [
        if (_currentStep > 0)
          TextButton(
            onPressed: details.onStepCancel,
            child: const Text('Back'),
          ),
        const Spacer(),
        ElevatedButton(
          onPressed: isLastStep ? details.onStepContinue : details.onStepContinue,
          child: Text(isLastStep ? 'Submit for review' : 'Continue'),
        ),
      ],
    );
  }

  Future<void> _openAvailabilityDialog() async {
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
                ElevatedButton(
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
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (window != null) {
      setState(() {
        _availability.removeWhere((existing) => existing == window);
        _availability.add(window);
        _availability.sort((a, b) => a.day.compareTo(b.day));
      });
    }
  }

  void _submit(AppState state) {
    final updatedProfile = state.profile.copyWith(
      legalName: _legalNameController.text.trim(),
      kitchenName: _kitchenNameController.text.trim(),
      bio: _bioController.text.trim(),
      specialties: List<String>.from(_selectedSpecialties),
      serviceAreas: List<String>.from(_selectedAreas),
      availability: List<AvailabilityWindow>.from(_availability),
      idDocument: _idDocument,
      certificationDocument: _certDocument,
    );

    if (!updatedProfile.readyForReview) {
      _showSnack('Complete all required fields and uploads before submitting.');
      return;
    }

    if (!_acknowledgedGuidelines) {
      _showSnack('Confirm you meet the food safety and packaging requirements.');
      return;
    }

    state.submitProfile(updatedProfile);
    _showSnack('Submitted for verification. You will receive a decision soon.');
    if (widget.isEditing && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.label,
    this.document,
    required this.onTap,
  });

  final String label;
  final DocumentUpload? document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          document == null ? Icons.cloud_upload_outlined : Icons.verified,
          color: document == null ? brandTextSecondary : brandSuccess,
        ),
        title: Text(label),
        subtitle: Text(
          document == null
              ? 'Upload PDF or photo for verification'
              : 'Uploaded ${formatShortDate(document!.uploadedAt)}',
        ),
        trailing: TextButton(
          onPressed: onTap,
          child: Text(document == null ? 'Upload' : 'Replace'),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
