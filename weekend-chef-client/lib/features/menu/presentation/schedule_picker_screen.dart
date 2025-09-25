import 'package:flutter/material.dart';

import '../../../core/utils/date_time_extensions.dart';
import '../../../localization/localization_extension.dart';
import '../../orders/domain/schedule_slot.dart';
import 'menu_builder_controller.dart';

class SchedulePickerScreen extends StatefulWidget {
  const SchedulePickerScreen({
    super.key,
    required this.controller,
    required this.earliest,
    required this.onContinue,
  });

  final MenuBuilderController controller;
  final DateTime earliest;
  final VoidCallback onContinue;

  @override
  State<SchedulePickerScreen> createState() => _SchedulePickerScreenState();
}

class _SchedulePickerScreenState extends State<SchedulePickerScreen> {
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  List<ScheduleSlot> _slots = const [];
  final DateTimeFormatter _formatter = const DateTimeFormatter();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.earliest;
    _generateSlots();
  }

  void _generateSlots() {
    final now = DateTime.now();
    final List<TimeOfDay> template = const [
      TimeOfDay(hour: 10, minute: 0),
      TimeOfDay(hour: 13, minute: 0),
      TimeOfDay(hour: 16, minute: 0),
      TimeOfDay(hour: 19, minute: 0),
    ];
    final slots = <ScheduleSlot>[];
    for (final time in template) {
      final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, time.hour, time.minute);
      final end = start.add(const Duration(hours: 1));
      final isAfterEarliest = start.isAfter(widget.earliest) || start.isAtSameMomentAs(widget.earliest);
      final isAfterNow = start.isAfter(now);
      slots.add(ScheduleSlot(start: start, end: end, isAvailable: isAfterEarliest && isAfterNow));
    }
    setState(() {
      _slots = slots;
      if (_selectedTime != null) {
        final matched = slots.firstWhere(
          (slot) => slot.start.hour == _selectedTime!.hour && slot.start.minute == _selectedTime!.minute,
          orElse: () => slots.firstWhere((slot) => slot.isAvailable, orElse: () => slots.first),
        );
        if (!matched.isAvailable) {
          _selectedTime = null;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('scheduleDelivery'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.translate('selectDate'), style: Theme.of(context).textTheme.titleMedium),
            CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: widget.earliest,
              lastDate: widget.earliest.add(const Duration(days: 14)),
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                  _selectedTime = null;
                });
                _generateSlots();
              },
            ),
            const SizedBox(height: 16),
            Text(l10n.translate('selectTime'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _slots
                  .map(
                    (slot) => ChoiceChip(
                      label: Text(_formatter.formatTime(slot.start)),
                      selected: _selectedTime != null &&
                          _selectedTime!.hour == slot.start.hour &&
                          _selectedTime!.minute == slot.start.minute,
                      onSelected: slot.isAvailable
                          ? (_) {
                              setState(() {
                                _selectedTime = TimeOfDay(hour: slot.start.hour, minute: slot.start.minute);
                              });
                            }
                          : null,
                      disabledColor: Colors.grey.shade200,
                    ),
                  )
                  .toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _selectedTime == null
                  ? null
                  : () {
                      widget.controller.schedule(_selectedDate, _selectedTime!);
                      widget.onContinue();
                      Navigator.of(context).pop();
                    },
              child: Text(l10n.translate('continue')),
            ),
          ],
        ),
      ),
    );
  }
}
