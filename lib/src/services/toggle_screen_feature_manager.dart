import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mawaqit/src/helpers/TimeShiftManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToggleScreenFeature {
  static final ToggleScreenFeature _instance = ToggleScreenFeature._internal();

  factory ToggleScreenFeature() => _instance;

  ToggleScreenFeature._internal();

  static const String _scheduledTimersKey = TurnOnOffTvConstant.kScheduledTimersKey;
  static final Map<String, List<Timer>> _scheduledTimers = {};

  static Future<void> initializeTimersAfterRestart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final scheduledTimesJson = prefs.getString('scheduled_prayer_times');
    final isFeatureActive = await getToggleFeatureState();

    if (!isFeatureActive || scheduledTimesJson == null) return;

    final scheduledData = json.decode(scheduledTimesJson) as Map<String, dynamic>;
    final timeStrings = List<String>.from(scheduledData['times']);
    final beforeDelay = scheduledData['beforeDelay'] as int;
    final afterDelay = scheduledData['afterDelay'] as int;
    final isFajrIshaOnly = scheduledData['isFajrIshaOnly'] as bool;

    // Reschedule timers
    await scheduleToggleScreen(isFajrIshaOnly, timeStrings, beforeDelay, afterDelay);
  }

  static Future<void> saveSchedulingData({
    required List<String> timeStrings,
    required int beforeDelayMinutes,
    required int afterDelayMinutes,
    required bool isFajrIshaOnly,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final scheduledData = {
      'times': timeStrings,
      'beforeDelay': beforeDelayMinutes,
      'afterDelay': afterDelayMinutes,
      'isFajrIshaOnly': isFajrIshaOnly,
    };
    await prefs.setString('scheduled_prayer_times', json.encode(scheduledData));
  }

  static Future<void> scheduleToggleScreen(
      bool isfajrIshaonly, List<String> timeStrings, int beforeDelayMinutes, int afterDelayMinutes) async {
    final timeShiftManager = TimeShiftManager();
    await saveSchedulingData(
      timeStrings: timeStrings,
      beforeDelayMinutes: beforeDelayMinutes,
      afterDelayMinutes: afterDelayMinutes,
      isFajrIshaOnly: isfajrIshaonly,
    );
    if (isfajrIshaonly) {
      String fajrTime = timeStrings[0];
      List<String> parts = fajrTime.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      final now = AppDateTime.now();
      DateTime scheduledDateTime = DateTime(now.year, now.month, now.day, hour, minute);

      if (scheduledDateTime.isBefore(now)) {
        scheduledDateTime = scheduledDateTime.add(Duration(days: 1));
      }

      final beforeDelay = scheduledDateTime.difference(now) - Duration(minutes: beforeDelayMinutes);

      if (!beforeDelay.isNegative) {
        final beforeTimer = Timer(beforeDelay, () {
          timeShiftManager.isLauncherInstalled ? _toggleBoxScreenOn() : _toggleTabletScreenOn();
        });
        _scheduledTimers[fajrTime] = [beforeTimer];
      }

      String ishaTime = timeStrings[5];
      parts = ishaTime.split(':');
      hour = int.parse(parts[0]);
      minute = int.parse(parts[1]);

      scheduledDateTime = DateTime(now.year, now.month, now.day, hour, minute);

      if (scheduledDateTime.isBefore(now)) {
        scheduledDateTime = scheduledDateTime.add(Duration(days: 1));
      }

      final afterDelay = scheduledDateTime.difference(now) + Duration(minutes: afterDelayMinutes);

      final afterTimer = Timer(afterDelay, () {
        timeShiftManager.isLauncherInstalled ? _toggleBoxScreenOff() : _toggleTabletScreenOff();
      });
      _scheduledTimers[ishaTime] = [afterTimer];
    } else {
      // Original logic for all prayer times
      for (String timeString in timeStrings) {
        final parts = timeString.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        final now = AppDateTime.now();
        DateTime scheduledDateTime = DateTime(now.year, now.month, now.day, hour, minute);

        if (scheduledDateTime.isBefore(now)) {
          scheduledDateTime = scheduledDateTime.add(Duration(days: 1));
        }

        final beforeDelay = scheduledDateTime.difference(now) - Duration(minutes: beforeDelayMinutes);
        if (beforeDelay.isNegative) {
          continue;
        }
        final beforeTimer = Timer(beforeDelay, () {
          timeShiftManager.isLauncherInstalled ? _toggleBoxScreenOn() : _toggleTabletScreenOn();
        });

        final afterDelay = scheduledDateTime.difference(now) + Duration(minutes: afterDelayMinutes);
        final afterTimer = Timer(afterDelay, () {
          timeShiftManager.isLauncherInstalled ? _toggleBoxScreenOff() : _toggleTabletScreenOff();
        });

        _scheduledTimers[timeString] = [beforeTimer, afterTimer];
      }
    }
    await _saveScheduledTimersToPrefs();
    await setLastEventDate(AppDateTime.now());
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

  static Future<void> _saveScheduledTimersToPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final timersMap = _scheduledTimers.map((timeString, timers) {
      return MapEntry(
        timeString,
        timers.map((timer) {
          return {'tick': timer.tick};
        }).toList(),
      );
    });
    await prefs.setString(_scheduledTimersKey, json.encode(timersMap));
  }

  static Future<void> toggleFeatureState(bool isActive) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(TurnOnOffTvConstant.kActivateToggleFeature, isActive);
  }

  static Future<bool> getToggleFeatureState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(TurnOnOffTvConstant.kActivateToggleFeature) ?? false;
  }

  static Future<bool> getToggleFeatureishaFajrState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(TurnOnOffTvConstant.kisFajrIshaOnly) ?? false;
  }

  static Future<void> cancelAllScheduledTimers() async {
    _scheduledTimers.forEach((timeString, timers) {
      for (final timer in timers) {
        timer.cancel();
      }
    });
    _scheduledTimers.clear();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scheduledTimersKey);
  }

  static Future<void> _toggleBoxScreenOn() async {
    try {
      await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel)
          .invokeMethod(TurnOnOffTvConstant.kToggleBoxScreenOn);
    } on PlatformException catch (e) {
      logger.e(e);
    }
  }

  static Future<void> _toggleBoxScreenOff() async {
    try {
      await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel)
          .invokeMethod(TurnOnOffTvConstant.kToggleBoxScreenOff);
    } on PlatformException catch (e) {
      logger.e(e);
    }
  }

  static Future<void> _toggleTabletScreenOn() async {
    try {
      await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel)
          .invokeMethod(TurnOnOffTvConstant.kToggleTabletScreenOn);
    } on PlatformException catch (e) {
      logger.e(e);
    }
  }

  static Future<void> _toggleTabletScreenOff() async {
    try {
      await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel)
          .invokeMethod(TurnOnOffTvConstant.kToggleTabletScreenOff);
    } on PlatformException catch (e) {
      logger.e(e);
    }
  }

  static Future<bool> checkEventsScheduled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    logger.d("value${prefs.getBool("isEventsSet")}");
    return prefs.getBool(TurnOnOffTvConstant.kIsEventsSet) ?? false;
  }

  static Future<void> saveScheduledEventsToLocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final Map<String, dynamic> timersMap = {};
    _scheduledTimers.forEach((key, value) {
      timersMap[key] = value.map((timer) {
        return {
          'isActive': timer.isActive,
          'tick': timer.tick,
        };
      }).toList();
    });

    await prefs.setString(TurnOnOffTvConstant.kScheduledTimersKey, json.encode(timersMap));
    logger.d("Saving into local");
    await prefs.setBool(TurnOnOffTvConstant.kIsEventsSet, true);
  }

  static Future<void> setLastEventDate(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(TurnOnOffTvConstant.kLastEventDate, date.toIso8601String());
  }

  static Future<DateTime?> getLastEventDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastEventDateString = prefs.getString(TurnOnOffTvConstant.kLastEventDate);
    if (lastEventDateString != null) {
      return DateTime.parse(lastEventDateString);
    } else {
      return null;
    }
  }
}
