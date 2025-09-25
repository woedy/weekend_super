import 'package:intl/intl.dart';

class DateTimeFormatter {
  const DateTimeFormatter();

  String formatDay(DateTime dateTime) {
    return DateFormat.yMMMMEEEEd().format(dateTime);
  }

  String formatTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }
}
