class ScheduleSlot {
  const ScheduleSlot({required this.start, required this.end, required this.isAvailable});

  final DateTime start;
  final DateTime end;
  final bool isAvailable;
}
