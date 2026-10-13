import 'package:intl/intl.dart';

class TimeFormatter {
  TimeFormatter._();

  /// Formats seconds to "HH:mm:ss" (e.g., 04:32:18)
  static String formatDurationHms(int totalSeconds) {
    if (totalSeconds < 0) totalSeconds = 0;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    final hStr = hours.toString().padLeft(2, '0');
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');

    return '$hStr:$mStr:$sStr';
  }

  /// Formats seconds to "Xh Ym" (e.g. 4h 32m, or 45m, or 0m)
  static String formatDurationHm(int totalSeconds) {
    if (totalSeconds <= 0) return '0m';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h 0m';
    } else {
      return '${minutes}m';
    }
  }

  /// Formats DateTime to "08:15 AM"
  static String formatTime(DateTime dt) {
    return DateFormat('hh:mm a').format(dt);
  }

  /// Formats DateTime to "12 Oct 2026"
  static String formatDate(DateTime dt) {
    return DateFormat('dd MMM yyyy').format(dt);
  }

  /// Formats DateTime to "12 Oct 2026, 10:45 PM"
  static String formatDateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  /// Formats DateTime to "October 2026"
  static String formatMonthYear(DateTime dt) {
    return DateFormat('MMMM yyyy').format(dt);
  }

  /// Day format e.g. "12"
  static String formatDayNumber(DateTime dt) {
    return DateFormat('dd').format(dt);
  }

  /// Weekday format e.g. "Mon"
  static String formatWeekday(DateTime dt) {
    return DateFormat('EEE').format(dt);
  }
}
