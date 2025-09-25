import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatDayAndTime(DateTime value) {
  final formatter = DateFormat('EEE • MMM d, h:mm a');
  return formatter.format(value);
}

String formatShortDate(DateTime value) {
  final formatter = DateFormat('MMM d');
  return formatter.format(value);
}

String formatPayoutStatus(DateTime value) {
  final formatter = DateFormat('MMM d, yyyy');
  return formatter.format(value);
}

String formatTimeOfDay(TimeOfDay value) {
  final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
  final minute = value.minute.toString().padLeft(2, '0');
  final suffix = value.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $suffix';
}
