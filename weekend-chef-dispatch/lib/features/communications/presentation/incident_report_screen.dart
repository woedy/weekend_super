import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/delivery_assignment.dart';
import '../../../core/models/incident_report.dart';
import '../../../core/services/app_state_scope.dart';
import '../../assignments/controllers/assignment_controller.dart';

class IncidentReportScreen extends StatefulWidget {
  const IncidentReportScreen({super.key, required this.assignment});

  final DeliveryAssignment assignment;

  @override
  State<IncidentReportScreen> createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends State<IncidentReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedType = 'Delay';
  XFile? _photo;
  bool _submitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report delivery incident'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assignment ${widget.assignment.orderNumber}',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Incident type'),
                items: const [
                  DropdownMenuItem(value: 'Delay', child: Text('Delay')),
                  DropdownMenuItem(value: 'Unable to reach client', child: Text('Unable to reach client')),
                  DropdownMenuItem(value: 'Damaged packaging', child: Text('Damaged packaging')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) => setState(() => _selectedType = value ?? 'Delay'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'What happened?',
                  hintText: 'Share context for support and the cook/client.',
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Please provide a short summary.' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Add photo'),
                  ),
                  const SizedBox(width: 12),
                  if (_photo != null)
                    Expanded(
                      child: Text(
                        _photo!.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitting ? null : () => _submit(context),
                  child: _submitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Submit incident'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() => _photo = photo);
    }
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    final incident = IncidentReport(
      id: 'incident-${DateTime.now().millisecondsSinceEpoch}',
      assignmentId: widget.assignment.id,
      type: _selectedType,
      description: _descriptionController.text,
      submittedAt: DateTime.now(),
      photoPath: _photo?.path,
    );
    AssignmentController(AppStateScope.of(context)).logIncident(incident);
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
