import 'package:flutter/foundation.dart';

class NotificationService {
  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  void setEnabled(bool enabled) {
    _notificationsEnabled = enabled;
  }

  Future<void> showStudyReminder() async {
    if (!_notificationsEnabled) return;
    debugPrint('[Notification] Time for your study session! Keep up your streak.');
  }

  Future<void> showGoalReachedNotification(String hoursFormatted) async {
    if (!_notificationsEnabled) return;
    debugPrint('[Notification] MashaAllah! Daily study goal reached: $hoursFormatted');
  }
}
