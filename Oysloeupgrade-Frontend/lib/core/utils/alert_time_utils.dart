import 'package:intl/intl.dart';

class AlertTimeUtils {
  const AlertTimeUtils._();

  static String describeAlertDay(DateTime date, DateTime now) {
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime normalized = DateTime(date.year, date.month, date.day);
    if (normalized == today) {
      return 'Today';
    }
    if (normalized == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    return DateFormat('MMMM d, yyyy').format(normalized);
  }

  static String formatAlertTimeLabel(DateTime timestamp) {
    return DateFormat('h:mm a').format(timestamp.toLocal());
  }
}
