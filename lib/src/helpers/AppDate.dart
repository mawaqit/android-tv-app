import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// return
class AppDateTime {
  AppDateTime._();

  /// for debug purpose to be able to skip the time forward or backward
  static Duration get difference => Duration();

  static Duration productionDifference = Duration.zero;

  static DateTime now() => kDebugMode ? DateTime.now().add(difference) : DateTime.now().add(productionDifference);
  
  static DateTime tomorrow() => DateTime.now().add(const Duration(days: 1));

  static bool get isFriday => now().weekday == DateTime.friday;
}

class AppDateFixer {
  final Duration tickDuration = const Duration(minutes: 5);
  DateTime latestTime;

  AppDateFixer._() : latestTime = DateTime.now() {}

  updateDateTimeDuration(int difference) {
    AppDateTime.productionDifference = Duration(minutes: difference);
  }

  static Future<AppDateFixer> init() async {
    final fixer = AppDateFixer._();

    final prefs = await SharedPreferences.getInstance();
    final savedDifference = prefs.getInt("time_difference") ?? 0;

    fixer.updateDateTimeDuration(savedDifference);

    Stream.periodic(Duration(minutes: 5)).listen((e) {
      fixer.newTickHandler(prefs: prefs);
    });

    return fixer;
  }

  newTickHandler({
    required SharedPreferences prefs,
  }) {
    final now = DateTime.now();
    final difference = now.difference(latestTime) - tickDuration;
    final savedDifference = prefs.getInt("time_difference") ?? 0;

    if (difference > Duration(minutes: 55) || difference < Duration(minutes: -55)) {
      final newDifference = savedDifference + difference.inMinutes;

      prefs.setInt("time_difference", newDifference);
      updateDateTimeDuration(newDifference);
    }
  }
}
