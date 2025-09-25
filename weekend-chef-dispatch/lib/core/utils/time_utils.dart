import 'package:intl/intl.dart';

String formatWindow(DateTime start, DateTime end) {
  final timeFormatter = DateFormat.jm();
  return '${timeFormatter.format(start)} – ${timeFormatter.format(end)}';
}

String formatRelative(DateTime target) {
  final now = DateTime.now();
  final difference = target.difference(now);
  if (difference.inMinutes.abs() < 1) {
    return 'now';
  }
  if (difference.isNegative) {
    final minutes = difference.inMinutes.abs();
    if (minutes < 60) {
      return '$minutes min ago';
    }
    return '${difference.inHours} hr ago';
  } else {
    if (difference.inMinutes < 60) {
      return 'in ${difference.inMinutes} min';
    }
    return 'in ${difference.inHours} hr';
  }
}
