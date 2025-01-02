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
    print('Creating ToggleScreenFeature instance');
    return _instance;
  }

  ToggleScreenFeature._internal() {
    print('Initializing ToggleScreenFeature');
  }

  static const String _scheduledTimersKey = TurnOnOffTvConstant.kScheduledTimersKey;
  static final Map<String, List<Timer>> _scheduledTimers = {};

  static Future<void> scheduleToggleScreen(
      bool isfajrIshaonly, List<String> timeStrings, int beforeDelayMinutes, int afterDelayMinutes) async {
    print('Scheduling toggle screen - Fajr/Isha only: $isfajrIshaonly');
    print('Time strings: $timeStrings');
    print(
        'Before delay: $beforeDelayMinutes minutes, After delay: $afterDelayMinutes minutes');
    
    final timeShiftManager = TimeShiftManager();
    print('Is launcher installed: ${timeShiftManager.isLauncherInstalled}');

    if (isfajrIshaonly) {
      print('Processing Fajr/Isha only mode');
      String fajrTime = timeStrings[0];
      List<String> parts = fajrTime.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      print('Fajr time: $hour:$minute');

      final now = AppDateTime.now();
      DateTime scheduledDateTime = DateTime(now.year, now.month, now.day, hour, minute);
      print('Current time: $now');
      print('Initial scheduled datetime for Fajr: $scheduledDateTime');

      if (scheduledDateTime.isBefore(now)) {
        scheduledDateTime = scheduledDateTime.add(Duration(days: 1));
        print('Adjusted scheduled datetime for Fajr: $scheduledDateTime');
      }

      final beforeDelay = scheduledDateTime.difference(now) - Duration(minutes: beforeDelayMinutes);
      print(
          'Before delay duration for Fajr: ${beforeDelay.inMinutes} minutes');

      if (!beforeDelay.isNegative) {
        print('Setting Fajr before timer');
        final beforeTimer = Timer(beforeDelay, () {
          print('Executing Fajr before timer - turning screen on');
          timeShiftManager.isLauncherInstalled ? _toggleBoxScreenOn() : _toggleTabletScreenOn();
        });
        _scheduledTimers[fajrTime] = [beforeTimer];
      } else {
        print('Skipping Fajr before timer - negative delay');
      }

      String ishaTime = timeStrings[5];
      parts = ishaTime.split(':');
      hour = int.parse(parts[0]);
      minute = int.parse(parts[1]);
      print('Isha time: $hour:$minute');

      scheduledDateTime = DateTime(now.year, now.month, now.day, hour, minute);
      print('Initial scheduled datetime for Isha: $scheduledDateTime');

      if (scheduledDateTime.isBefore(now)) {
        scheduledDateTime = scheduledDateTime.add(Duration(days: 1));
        print('Adjusted scheduled datetime for Isha: $scheduledDateTime');
      }

      final afterDelay = scheduledDateTime.difference(now) + Duration(minutes: afterDelayMinutes);
      print('After delay duration for Isha: ${afterDelay.inMinutes} minutes');

      print('Setting Isha after timer');
      final afterTimer = Timer(afterDelay, () {
        print('Executing Isha after timer - turning screen off');
        timeShiftManager.isLauncherInstalled ? _toggleBoxScreenOff() : _toggleTabletScreenOff();
      });
      _scheduledTimers[ishaTime] = [afterTimer];
    } else {
      print('Processing all prayer times');
      for (String timeString in timeStrings) {
        print('Processing time: $timeString');
        final parts = timeString.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        final now = AppDateTime.now();
        DateTime scheduledDateTime = DateTime(now.year, now.month, now.day, hour, minute);
        print('Initial scheduled datetime: $scheduledDateTime');

        if (scheduledDateTime.isBefore(now)) {
          scheduledDateTime = scheduledDateTime.add(Duration(days: 1));
          print('Adjusted scheduled datetime: $scheduledDateTime');
        }

        final beforeDelay = scheduledDateTime.difference(now) - Duration(minutes: beforeDelayMinutes);
        print('Before delay duration: ${beforeDelay.inMinutes} minutes');
        
        if (beforeDelay.isNegative) {
          print('Skipping time $timeString - negative before delay');
          continue;
        }
        
        print('Setting before timer for $timeString');
        final beforeTimer = Timer(beforeDelay, () {
          print('Executing before timer for $timeString - turning screen on');
          timeShiftManager.isLauncherInstalled ? _toggleBoxScreenOn() : _toggleTabletScreenOn();
        });

        final afterDelay = scheduledDateTime.difference(now) + Duration(minutes: afterDelayMinutes);
        print('After delay duration: ${afterDelay.inMinutes} minutes');

        print('Setting after timer for $timeString');
        final afterTimer = Timer(afterDelay, () {
          print('Executing after timer for $timeString - turning screen off');
          timeShiftManager.isLauncherInstalled ? _toggleBoxScreenOff() : _toggleTabletScreenOff();
        });

        _scheduledTimers[timeString] = [beforeTimer, afterTimer];
      }
    }
    print('Saving scheduled timers to preferences');
    await _saveScheduledTimersToPrefs();
  }

  static Future<void> loadScheduledTimersFromPrefs() async {
    print('Loading scheduled timers from preferences');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final timersJson = prefs.getString(_scheduledTimersKey);
    print('Loaded timers JSON: $timersJson');
    
    if (timersJson != null) {
      final timersMap = json.decode(timersJson) as Map<String, dynamic>;
      print('Decoded timers map: $timersMap');
      
      timersMap.forEach((timeString, timerDataList) {
        print('Processing saved timer for time: $timeString');
        _scheduledTimers[timeString] = [];
        for (final timerData in timerDataList) {
          final tick = timerData['tick'] as int;
          print('Creating timer with tick: $tick');
          final timer = Timer(Duration(milliseconds: tick), () {});
          _scheduledTimers[timeString]!.add(timer);
        }
      });
    } else {
      print('No saved timers found in preferences');
    }
  }

  static Future<void> _saveScheduledTimersToPrefs() async {
    print('Saving timers to preferences');
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final timersMap = _scheduledTimers.map((timeString, timers) {
      print('Processing timers for time: $timeString');
      return MapEntry(
        timeString,
        timers.map((timer) {
          print('Timer tick: ${timer.tick}');
          return {'tick': timer.tick};
        }).toList(),
      );
    });
    
    final encodedMap = json.encode(timersMap);
    print('Encoded timers map: $encodedMap');
    await prefs.setString(_scheduledTimersKey, encodedMap);
  }

  static Future<void> toggleFeatureState(bool isActive) async {
    print('Toggling feature state: $isActive');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(TurnOnOffTvConstant.kActivateToggleFeature, isActive);
    print('Feature state toggled successfully');
  }

  static Future<bool> getToggleFeatureState() async {
    print('Getting toggle feature state');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final state =
        prefs.getBool(TurnOnOffTvConstant.kActivateToggleFeature) ?? false;
    print('Toggle feature state: $state');
    return state;
  }

  static Future<bool> getToggleFeatureishaFajrState() async {
    print('Getting Isha/Fajr feature state');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final state = prefs.getBool(TurnOnOffTvConstant.kisFajrIshaOnly) ?? false;
    print('Isha/Fajr feature state: $state');
    return state;
  }

  static Future<void> cancelAllScheduledTimers() async {
    print('Cancelling all scheduled timers');
    print('Current scheduled timers: ${_scheduledTimers.length}');
    
    _scheduledTimers.forEach((timeString, timers) {
      print('Cancelling timers for time: $timeString');
      for (final timer in timers) {
        timer.cancel();
        print('Timer cancelled for $timeString');
      }
    });
    _scheduledTimers.clear();
    print('All timers cleared from memory');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scheduledTimersKey);
    print('Timers removed from preferences');
  }

  static Future<void> _toggleBoxScreenOn() async {
    print('Attempting to turn box screen on');
    try {
      await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel)
          .invokeMethod(TurnOnOffTvConstant.kToggleBoxScreenOn);
      print('Box screen turned on successfully');
    } on PlatformException catch (e) {
      print('Failed to turn box screen on: ${e.message}');
    }
  }

  static Future<void> _toggleBoxScreenOff() async {
    print('Attempting to turn box screen off');
    try {
      await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel)
          .invokeMethod(TurnOnOffTvConstant.kToggleBoxScreenOff);
      print('Box screen turned off successfully');
    } on PlatformException catch (e) {
      print('Failed to turn box screen off: ${e.message}');
    }
  }

  static Future<void> _toggleTabletScreenOn() async {
    print('Attempting to turn tablet screen on');
    try {
      await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel)
          .invokeMethod(TurnOnOffTvConstant.kToggleTabletScreenOn);
      print('Tablet screen turned on successfully');
    } on PlatformException catch (e) {
      print('Failed to turn tablet screen on: ${e.message}');
    }
  }

  static Future<void> _toggleTabletScreenOff() async {
    print('Attempting to turn tablet screen off');
    try {
      await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel)
          .invokeMethod(TurnOnOffTvConstant.kToggleTabletScreenOff);
      print('Tablet screen turned off successfully');
    } on PlatformException catch (e) {
      print('Failed to turn tablet screen off: ${e.message}');
    }
  }

  static Future<bool> checkEventsScheduled() async {
    print('Checking if events are scheduled');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final isEventsSet =
        prefs.getBool(TurnOnOffTvConstant.kIsEventsSet) ?? false;
    print('Events scheduled status: $isEventsSet');
    return isEventsSet;
  }

  static Future<void> saveScheduledEventsToLocale() async {
    print('Saving scheduled events to local storage');
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final Map<String, dynamic> timersMap = {};
    print('Number of timers to save: ${_scheduledTimers.length}');

    _scheduledTimers.forEach((key, value) {
      print('Processing timers for time: $key');
      timersMap[key] = value.map((timer) {
        print('Timer state - Active: ${timer.isActive}, Tick: ${timer.tick}');
        return {
          'isActive': timer.isActive,
          'tick': timer.tick,
        };
      }).toList();
    });

    final encodedMap = json.encode(timersMap);
    print('Encoded timer map: $encodedMap');
    await prefs.setString(TurnOnOffTvConstant.kScheduledTimersKey, encodedMap);

    print('Setting events scheduled flag to true');
    await prefs.setBool(TurnOnOffTvConstant.kIsEventsSet, true);
  }

  static Future<void> setLastEventDate(DateTime date) async {
    print('Setting last event date: $date');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final dateString = date.toIso8601String();
    await prefs.setString(TurnOnOffTvConstant.kLastEventDate, dateString);
    print('Last event date saved: $dateString');
  }

  static Future<DateTime?> getLastEventDate() async {
    print('Getting last event date');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastEventDateString = prefs.getString(TurnOnOffTvConstant.kLastEventDate);
    print('Retrieved last event date string: $lastEventDateString');
    
    if (lastEventDateString != null) {
      final parsedDate = DateTime.parse(lastEventDateString);
      print('Parsed last event date: $parsedDate');
      return parsedDate;
    } else {
      print('No last event date found');
      return null;
    }
  }
}
