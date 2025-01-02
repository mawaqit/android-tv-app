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

  factory ToggleScreenFeature() {
    logger.d('Creating ToggleScreenFeature instance');
    return _instance;
  }

  ToggleScreenFeature._internal() {
    logger.d('Initializing ToggleScreenFeature');
  }

  static const String _scheduledTimersKey = TurnOnOffTvConstant.kScheduledTimersKey;
  static final Map<String, List<Timer>> _scheduledTimers = {};

  static Future<void> scheduleToggleScreen(
      bool isfajrIshaonly, List<String> timeStrings, int beforeDelayMinutes, int afterDelayMinutes) async {
    logger.d('Scheduling toggle screen - Fajr/Isha only: $isfajrIshaonly');
    logger.d('Time strings: $timeStrings');
    logger.d(
        'Before delay: $beforeDelayMinutes minutes, After delay: $afterDelayMinutes minutes');
    
    final timeShiftManager = TimeShiftManager();
    logger.d('Is launcher installed: ${timeShiftManager.isLauncherInstalled}');

    if (isfajrIshaonly) {
      logger.d('Processing Fajr/Isha only mode');
      String fajrTime = timeStrings[0];
      List<String> parts = fajrTime.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      logger.d('Fajr time: $hour:$minute');

      final now = AppDateTime.now();
      DateTime scheduledDateTime = DateTime(now.year, now.month, now.day, hour, minute);
      logger.d('Current time: $now');
      logger.d('Initial scheduled datetime for Fajr: $scheduledDateTime');

      if (scheduledDateTime.isBefore(now)) {
        scheduledDateTime = scheduledDateTime.add(Duration(days: 1));
        logger.d('Adjusted scheduled datetime for Fajr: $scheduledDateTime');
      }

      final beforeDelay = scheduledDateTime.difference(now) - Duration(minutes: beforeDelayMinutes);
      logger.d(
          'Before delay duration for Fajr: ${beforeDelay.inMinutes} minutes');

      if (!beforeDelay.isNegative) {
        logger.d('Setting Fajr before timer');
        final beforeTimer = Timer(beforeDelay, () {
          logger.d('Executing Fajr before timer - turning screen on');
          timeShiftManager.isLauncherInstalled ? _toggleBoxScreenOn() : _toggleTabletScreenOn();
        });
        _scheduledTimers[fajrTime] = [beforeTimer];
      } else {
        logger.d('Skipping Fajr before timer - negative delay');
      }

      String ishaTime = timeStrings[5];
      parts = ishaTime.split(':');
      hour = int.parse(parts[0]);
      minute = int.parse(parts[1]);
      logger.d('Isha time: $hour:$minute');

      scheduledDateTime = DateTime(now.year, now.month, now.day, hour, minute);
      logger.d('Initial scheduled datetime for Isha: $scheduledDateTime');

      if (scheduledDateTime.isBefore(now)) {
        scheduledDateTime = scheduledDateTime.add(Duration(days: 1));
        logger.d('Adjusted scheduled datetime for Isha: $scheduledDateTime');
      }

      final afterDelay = scheduledDateTime.difference(now) + Duration(minutes: afterDelayMinutes);
      logger
          .d('After delay duration for Isha: ${afterDelay.inMinutes} minutes');

      logger.d('Setting Isha after timer');
      final afterTimer = Timer(afterDelay, () {
        logger.d('Executing Isha after timer - turning screen off');
        timeShiftManager.isLauncherInstalled ? _toggleBoxScreenOff() : _toggleTabletScreenOff();
      });
      _scheduledTimers[ishaTime] = [afterTimer];
    } else {
      logger.d('Processing all prayer times');
      for (String timeString in timeStrings) {
        logger.d('Processing time: $timeString');
        final parts = timeString.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        final now = AppDateTime.now();
        DateTime scheduledDateTime = DateTime(now.year, now.month, now.day, hour, minute);
        logger.d('Initial scheduled datetime: $scheduledDateTime');

        if (scheduledDateTime.isBefore(now)) {
          scheduledDateTime = scheduledDateTime.add(Duration(days: 1));
          logger.d('Adjusted scheduled datetime: $scheduledDateTime');
        }

        final beforeDelay = scheduledDateTime.difference(now) - Duration(minutes: beforeDelayMinutes);
        logger.d('Before delay duration: ${beforeDelay.inMinutes} minutes');
        
        if (beforeDelay.isNegative) {
          logger.d('Skipping time $timeString - negative before delay');
          continue;
        }
        
        logger.d('Setting before timer for $timeString');
        final beforeTimer = Timer(beforeDelay, () {
          logger
              .d('Executing before timer for $timeString - turning screen on');
          timeShiftManager.isLauncherInstalled ? _toggleBoxScreenOn() : _toggleTabletScreenOn();
        });

        final afterDelay = scheduledDateTime.difference(now) + Duration(minutes: afterDelayMinutes);
        logger.d('After delay duration: ${afterDelay.inMinutes} minutes');

        logger.d('Setting after timer for $timeString');
        final afterTimer = Timer(afterDelay, () {
          logger
              .d('Executing after timer for $timeString - turning screen off');
          timeShiftManager.isLauncherInstalled ? _toggleBoxScreenOff() : _toggleTabletScreenOff();
        });

        _scheduledTimers[timeString] = [beforeTimer, afterTimer];
      }
    }
    logger.d('Saving scheduled timers to preferences');
    await _saveScheduledTimersToPrefs();
  }

  static Future<void> loadScheduledTimersFromPrefs() async {
    logger.d('Loading scheduled timers from preferences');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final timersJson = prefs.getString(_scheduledTimersKey);
    logger.d('Loaded timers JSON: $timersJson');
    
    if (timersJson != null) {
      final timersMap = json.decode(timersJson) as Map<String, dynamic>;
      logger.d('Decoded timers map: $timersMap');
      
      timersMap.forEach((timeString, timerDataList) {
        logger.d('Processing saved timer for time: $timeString');
        _scheduledTimers[timeString] = [];
        for (final timerData in timerDataList) {
          final tick = timerData['tick'] as int;
          logger.d('Creating timer with tick: $tick');
          final timer = Timer(Duration(milliseconds: tick), () {});
          _scheduledTimers[timeString]!.add(timer);
        }
      });
    } else {
      logger.d('No saved timers found in preferences');
    }
  }

  static Future<void> _saveScheduledTimersToPrefs() async {
    logger.d('Saving timers to preferences');
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final timersMap = _scheduledTimers.map((timeString, timers) {
      logger.d('Processing timers for time: $timeString');
      return MapEntry(
        timeString,
        timers.map((timer) {
          logger.d('Timer tick: ${timer.tick}');
          return {'tick': timer.tick};
        }).toList(),
      );
    });
    
    final encodedMap = json.encode(timersMap);
    logger.d('Encoded timers map: $encodedMap');
    await prefs.setString(_scheduledTimersKey, encodedMap);
  }

  static Future<void> toggleFeatureState(bool isActive) async {
    logger.d('Toggling feature state: $isActive');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(TurnOnOffTvConstant.kActivateToggleFeature, isActive);
    logger.d('Feature state toggled successfully');
  }

  static Future<bool> getToggleFeatureState() async {
    logger.d('Getting toggle feature state');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final state =
        prefs.getBool(TurnOnOffTvConstant.kActivateToggleFeature) ?? false;
    logger.d('Toggle feature state: $state');
    return state;
  }

  static Future<bool> getToggleFeatureishaFajrState() async {
    logger.d('Getting Isha/Fajr feature state');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final state = prefs.getBool(TurnOnOffTvConstant.kisFajrIshaOnly) ?? false;
    logger.d('Isha/Fajr feature state: $state');
    return state;
  }

  static Future<void> cancelAllScheduledTimers() async {
    logger.d('Cancelling all scheduled timers');
    logger.d('Current scheduled timers: ${_scheduledTimers.length}');
    
    _scheduledTimers.forEach((timeString, timers) {
      logger.d('Cancelling timers for time: $timeString');
      for (final timer in timers) {
        timer.cancel();
        logger.d('Timer cancelled for $timeString');
      }
    });
    _scheduledTimers.clear();
    logger.d('All timers cleared from memory');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scheduledTimersKey);
    logger.d('Timers removed from preferences');
  }

  static Future<void> _toggleBoxScreenOn() async {
    logger.d('Attempting to turn box screen on');
    try {
      await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel)
          .invokeMethod(TurnOnOffTvConstant.kToggleBoxScreenOn);
      logger.d('Box screen turned on successfully');
    } on PlatformException catch (e) {
      logger.e('Failed to turn box screen on: ${e.message}');
    }
  }

  static Future<void> _toggleBoxScreenOff() async {
    logger.d('Attempting to turn box screen off');
    try {
      await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel)
          .invokeMethod(TurnOnOffTvConstant.kToggleBoxScreenOff);
      logger.d('Box screen turned off successfully');
    } on PlatformException catch (e) {
      logger.e('Failed to turn box screen off: ${e.message}');
    }
  }

  static Future<void> _toggleTabletScreenOn() async {
    logger.d('Attempting to turn tablet screen on');
    try {
      await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel)
          .invokeMethod(TurnOnOffTvConstant.kToggleTabletScreenOn);
      logger.d('Tablet screen turned on successfully');
    } on PlatformException catch (e) {
      logger.e('Failed to turn tablet screen on: ${e.message}');
    }
  }

  static Future<void> _toggleTabletScreenOff() async {
    logger.d('Attempting to turn tablet screen off');
    try {
      await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel)
          .invokeMethod(TurnOnOffTvConstant.kToggleTabletScreenOff);
      logger.d('Tablet screen turned off successfully');
    } on PlatformException catch (e) {
      logger.e('Failed to turn tablet screen off: ${e.message}');
    }
  }

  static Future<bool> checkEventsScheduled() async {
    logger.d('Checking if events are scheduled');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final isEventsSet =
        prefs.getBool(TurnOnOffTvConstant.kIsEventsSet) ?? false;
    logger.d('Events scheduled status: $isEventsSet');
    return isEventsSet;
  }

  static Future<void> saveScheduledEventsToLocale() async {
    logger.d('Saving scheduled events to local storage');
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final Map<String, dynamic> timersMap = {};
    logger.d('Number of timers to save: ${_scheduledTimers.length}');

    _scheduledTimers.forEach((key, value) {
      logger.d('Processing timers for time: $key');
      timersMap[key] = value.map((timer) {
        logger
            .d('Timer state - Active: ${timer.isActive}, Tick: ${timer.tick}');
        return {
          'isActive': timer.isActive,
          'tick': timer.tick,
        };
      }).toList();
    });

    final encodedMap = json.encode(timersMap);
    logger.d('Encoded timer map: $encodedMap');
    await prefs.setString(TurnOnOffTvConstant.kScheduledTimersKey, encodedMap);

    logger.d('Setting events scheduled flag to true');
    await prefs.setBool(TurnOnOffTvConstant.kIsEventsSet, true);
  }

  static Future<void> setLastEventDate(DateTime date) async {
    logger.d('Setting last event date: $date');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final dateString = date.toIso8601String();
    await prefs.setString(TurnOnOffTvConstant.kLastEventDate, dateString);
    logger.d('Last event date saved: $dateString');
  }

  static Future<DateTime?> getLastEventDate() async {
    logger.d('Getting last event date');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastEventDateString = prefs.getString(TurnOnOffTvConstant.kLastEventDate);
    logger.d('Retrieved last event date string: $lastEventDateString');
    
    if (lastEventDateString != null) {
      final parsedDate = DateTime.parse(lastEventDateString);
      logger.d('Parsed last event date: $parsedDate');
      return parsedDate;
    } else {
      logger.d('No last event date found');
      return null;
    }
  }
}
