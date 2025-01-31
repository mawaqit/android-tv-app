import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:notification_overlay/notification_overlay.dart';

class PrayerNotificationService {
  static Timer? _notificationTimer;
  static bool _shouldShowNotification = false;
  static BuildContext? _context;

  static void initialize(BuildContext context) {
    _context = context;
  }

  static Future<void> showPrayerNotification(
    String salahName,
    String prayerTime,
  ) async {
    if (!_shouldShowNotification) return;
    if (_context == null) {
      throw Exception('PrayerNotificationService not initialized with context');
    }

    await dismissNotification();
    await NotificationOverlay.showNotification(S.of(_context!).prayerTimeNotification(salahName, prayerTime));
    _scheduleNotificationDismissal();
  }

  static Future<void> dismissNotification() async {
    await NotificationOverlay.hideNotification();
    _notificationTimer?.cancel();
  }

  static void setShouldShowNotification(bool shouldShow) {
    _shouldShowNotification = shouldShow;
  }

  static void _scheduleNotificationDismissal() {
    _notificationTimer?.cancel();
    _notificationTimer = Timer(
      const Duration(minutes: 5),
      dismissNotification,
    );
  }

  // Clean up when no longer needed
  static void dispose() {
    _notificationTimer?.cancel();
    _context = null;
  }
}
