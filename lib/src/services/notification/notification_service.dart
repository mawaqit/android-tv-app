import 'dart:async';
import 'package:notification_overlay/notification_overlay.dart';

class NotificationService {
  static Timer? _notificationTimer;

  static Future<void> showPrayerNotification(String salahName, String prayerTime) async {
    await dismissNotification();
    await NotificationOverlay.showNotification(
      '$salahName time ($prayerTime) notification',
    );
    _scheduleNotificationDismissal();
  }

  static Future<void> dismissNotification() async {
    await NotificationOverlay.hideNotification();
  }

  static void cancelScheduledDismissal() {
    _notificationTimer?.cancel();
  }

  static void _scheduleNotificationDismissal() {
    _notificationTimer?.cancel();
    _notificationTimer = Timer(
      const Duration(minutes: 2),
      dismissNotification,
    );
  }
}
