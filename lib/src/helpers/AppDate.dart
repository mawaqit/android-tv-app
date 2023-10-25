import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' show initializeTimeZones;
import 'package:timezone/timezone.dart' as tz;

/// return
class AppDateTime {
  AppDateTime._();

  static Future<void> init() async {
    initializeTimeZones();
  }

  /// for debug purpose to be able to skip the time forward or backward
  static Duration get difference => Duration();

  static DateTime productionNow() => tz.TZDateTime.now(tz.getLocation('Europe/Paris'));

  static DateTime now() => kDebugMode ? DateTime.now().add(difference) : productionNow();

  static DateTime tomorrow() => DateTime.now().add(const Duration(days: 1));

  static bool get isFriday => now().weekday == DateTime.friday;
}
