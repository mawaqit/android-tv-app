import 'package:flutter/foundation.dart';

import 'TimeShiftManager.dart';

final TimeShiftManager timeManager = TimeShiftManager();

/// return
class AppDateTime {
  AppDateTime._();

  // Access the adjusted time

  /// for debug purpose to be able to skip the time forward or backward
  static Duration get difference =>
      Duration(days: 30 * 8 + 6, hours: -6, minutes: 30);

  static DateTime now() => DateTime.now().add(
      Duration(hours: timeManager.shift, minutes: timeManager.shiftInMinutes));

  static DateTime tomorrow() => DateTime.now().add(const Duration(days: 1));

  static bool get isFriday => now().weekday == DateTime.friday;
}
