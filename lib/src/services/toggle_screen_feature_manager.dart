import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToggleScreenFeature {
  static const _scheduledTimersKey = 'scheduledTimers';

  static final _scheduledTimers = <String, List<Timer>>{};

  static void scheduleToggleScreen(List<String> timeStrings, int beforeDelayMinutes, int afterDelayMinutes) {
    for (String timeString in timeStrings) {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = AppDateTime.now();
      final scheduledDateTime = DateTime(now.year, now.month, now.day, hour, minute);

      if (scheduledDateTime.isBefore(now)) {
        scheduledDateTime.add(Duration(days: 1));
      }

      final beforeDelay = scheduledDateTime.difference(now) - Duration(minutes: beforeDelayMinutes);
      if (beforeDelay.isNegative) {
        continue;
      }
      final beforeTimer = Timer(beforeDelay, () {
        toggleScreenOn();
      });

      final afterDelay = scheduledDateTime.difference(now) + Duration(minutes: afterDelayMinutes);
      final afterTimer = Timer(afterDelay, () {
        toggleScreenOff();
      });

      // Store the timers in the _scheduledTimers map
      _scheduledTimers[timeString] = [beforeTimer, afterTimer];
      print("triggers $_scheduledTimers");
    }
    saveScheduledTimersToPrefs();
  }

  static Future<void> loadScheduledTimersFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final timersJson = prefs.getString(_scheduledTimersKey);
    if (timersJson != null) {
      final timersMap = json.decode(timersJson) as Map<String, dynamic>;
      timersMap.forEach((timeString, timerDataList) {
        _scheduledTimers[timeString] = [];
        for (final timerData in timerDataList) {
          final tick = timerData['tick'] as int;
          final timer = Timer(Duration(milliseconds: tick), () {});
          _scheduledTimers[timeString]!.add(timer);
        }
      });
    }
  }

  static Future<void> saveScheduledTimersToPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert _scheduledTimers map to a JSON-serializable format
    final timersMap = _scheduledTimers.map((timeString, timers) {
      return MapEntry(
          timeString,
          timers.map((timer) {
            return {'tick': timer.tick};
          }).toList());
    });

    // Save the timersMap to SharedPreferences
    await prefs.setString(_scheduledTimersKey, json.encode(timersMap));
  }

  static Future<void> toggleFeatureState(bool isActive) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save the timersMap to SharedPreferences
    await prefs.setBool("activateToggleFeature", isActive);
  }

  static Future<bool> getToggleFeatureState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save the timersMap to SharedPreferences
    return prefs.getBool("activateToggleFeature") ?? false;
  }

  static Future<void> cancelAllScheduledTimers() async {
    _scheduledTimers.forEach((timeString, timers) {
      for (final timer in timers) {
        timer.cancel();
      }
    });
    _scheduledTimers.clear();

    // Clear the saved timers from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scheduledTimersKey);
  }

  static Future<void> toggleScreenOn() async {
    try {
      await MethodChannel('nativeMethodsChannel').invokeMethod('toggleScreenOn');
    } on PlatformException catch (e) {
      logger.e(e);
    }
  }

  static Future<void> toggleScreenOff() async {
    try {
      await MethodChannel('nativeMethodsChannel').invokeMethod('toggleScreenOff');
    } on PlatformException catch (e) {
      logger.e(e);
    }
  }

  static Future<void> grantDumpPermission() async {
    try {
      await MethodChannel('nativeMethodsChannel').invokeMethod('grantDumpSysPermission');
    } on PlatformException catch (e) {
      logger.e(e);
    }
  }

  static Future<bool> checkEventsScheduled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    logger.d("value${prefs.getBool("isEventsSet")}");
    return prefs.getBool("isEventsSet") ?? false;
  }

  static Future<void> saveScheduledEventsToLocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert the _scheduledTimers map to a JSON-serializable format
    Map<String, dynamic> timersMap = {};
    _scheduledTimers.forEach((key, value) {
      timersMap[key] = value.map((timer) {
        return {
          'isActive': timer.isActive,
          'tick': timer.tick,
        };
      }).toList();
    });

    // Save the timersMap to SharedPreferences
    await prefs.setString('scheduledTimers', json.encode(timersMap));

    logger.d("Saving into local");
    prefs.setBool("isEventsSet", true);
  }

  static Future<void> setLastEventDate(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastEventDate', date.toIso8601String());
  }

  static Future<DateTime?> getLastEventDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastEventDateString = prefs.getString('lastEventDate');
    if (lastEventDateString != null) {
      return DateTime.parse(lastEventDateString);
    } else {
      return null;
    }
  }
}
