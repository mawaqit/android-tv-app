import 'package:flutter/foundation.dart';

/// return
class AppDateTime {
  AppDateTime._();

  /// for debug purpose to be able to skip the time forward or backward
  static Duration get difference => Duration(hours: -6, minutes: 30);

  static DateTime now() => kDebugMode ? DateTime.now().add(difference) : DateTime.now();

  static DateTime tomorrow() => DateTime.now().add(const Duration(days: 1));

  static bool get isFriday => now().weekday == DateTime.friday;
}
