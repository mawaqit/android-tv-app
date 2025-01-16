import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mawaqit/src/helpers/TimeShiftManager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerScheduleInfo {
  final DateTime scheduledTime;
  final String actionType; // 'screenOn' or 'screenOff'
  final bool isFajrIsha;

  TimerScheduleInfo({
    required this.scheduledTime,
    required this.actionType,
    required this.isFajrIsha,
  });

  Map<String, dynamic> toJson() {
    print('Converting TimerScheduleInfo to JSON: time=${scheduledTime}, action=${actionType}');
    return {
      'scheduledTime': scheduledTime.toIso8601String(),
      'actionType': actionType,
      'isFajrIsha': isFajrIsha,
    };
  }

  factory TimerScheduleInfo.fromJson(Map<String, dynamic> json) {
    print('Creating TimerScheduleInfo from JSON: ${json.toString()}');
    return TimerScheduleInfo(
      scheduledTime: DateTime.parse(json['scheduledTime']),
      actionType: json['actionType'],
      isFajrIsha: json['isFajrIsha'],
    );
  }
}

class ToggleScreenFeature {
  static final ToggleScreenFeature _instance = ToggleScreenFeature._internal();

  factory ToggleScreenFeature() => _instance;

  ToggleScreenFeature._internal() {
    print('Initializing ToggleScreenFeature singleton');
  }

  static const String _scheduledTimersKey = TurnOnOffTvConstant.kScheduledTimersKey;
  static final Map<String, List<Timer>> _scheduledTimers = {};
  static const String _scheduledInfoKey = 'scheduled_info_key';
  static List<TimerScheduleInfo> _scheduleInfoList = [];

  static Future<void> scheduleToggleScreen(
      bool isfajrIshaonly, List<String> timeStrings, int beforeDelayMinutes, int afterDelayMinutes) async {
    print('=== Starting scheduleToggleScreen ===');
    print('Parameters: isfajrIshaonly=$isfajrIshaonly');
    print('timeStrings: ${timeStrings.join(", ")}');
    print('Delays: before=$beforeDelayMinutes, after=$afterDelayMinutes');

    await cancelAllScheduledTimers();
    print('Previous schedules cleared');
    _scheduleInfoList.clear();

    final now = AppDateTime.now();
    print('Current time: $now');
    final timeShiftManager = TimeShiftManager();

    if (isfajrIshaonly) {
      print('Scheduling for Fajr and Isha only');
      _scheduleForPrayer(
        timeStrings[0],
        now,
        beforeDelayMinutes,
        afterDelayMinutes,
        true,
        timeShiftManager,
      );

      _scheduleForPrayer(
        timeStrings[5],
        now,
        beforeDelayMinutes,
        afterDelayMinutes,
        true,
        timeShiftManager,
      );
    } else {
      print('Scheduling for all prayers');
      for (String timeString in timeStrings) {
        _scheduleForPrayer(
          timeString,
          now,
          beforeDelayMinutes,
          afterDelayMinutes,
          false,
          timeShiftManager,
        );
      }
    }

    print('Saving schedules and updating state');
    await Future.wait([saveScheduledEventsToLocale(), toggleFeatureState(true), setLastEventDate(now)]);
    print('Schedule setup completed');
  }

  static Future<void> _saveScheduleInfo() async {
    print('Saving schedule info to SharedPreferences');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final scheduleData = _scheduleInfoList.map((info) => info.toJson()).toList();
    print('Schedule data to save: ${scheduleData.length} items');
    await prefs.setString(_scheduledInfoKey, json.encode(scheduleData));
    print('Schedule info saved successfully');
  }

  static Future<bool> shouldReschedule() async {
    print('Checking if rescheduling is needed');
    final lastEventDate = await getLastEventDate();
    final today = AppDateTime.now();
    final isFeatureActive = await getToggleFeatureState();
    final areEventsScheduled = await checkEventsScheduled();

    print('Last event date: $lastEventDate');
    print('Today: $today');
    print('Feature active: $isFeatureActive');
    print('Events scheduled: $areEventsScheduled');

    final shouldReschedule =
        lastEventDate != null && lastEventDate.day != today.day && isFeatureActive && !areEventsScheduled;
    print('Should reschedule: $shouldReschedule');
    return shouldReschedule;
  }

  static Future<void> handleDailyRescheduling({
    required bool isIshaFajrOnly,
    required List<String> timeStrings,
    required int minuteBefore,
    required int minuteAfter,
  }) async {
    print('=== Starting daily rescheduling check ===');
    final shouldSchedule = await shouldReschedule();

    if (shouldSchedule) {
      print('Rescheduling needed, canceling existing timers');
      await cancelAllScheduledTimers();
      await toggleFeatureState(false);

      print('Setting up new schedule');
      await scheduleToggleScreen(
        isIshaFajrOnly,
        timeStrings,
        minuteBefore,
        minuteAfter,
      );

      await saveScheduledEventsToLocale();
      print('Daily rescheduling completed');
    } else {
      print('No rescheduling needed');
    }
  }

  static Future<void> restoreScheduledTimers() async {
    try {
      print('=== Attempting to restore scheduled timers ===');
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final scheduleDataString = prefs.getString(_scheduledInfoKey);
      final isFeatureActive = await getToggleFeatureState();

      print('Saved schedule data exists: ${scheduleDataString != null}');
      print('Feature is active: $isFeatureActive');

      if (scheduleDataString == null || !isFeatureActive) {
        print('No schedules to restore or feature is inactive');
        return;
      }

      print('Restoring schedules from saved data');
      final scheduleData = json.decode(scheduleDataString) as List;
      _scheduleInfoList = scheduleData
          .map((data) => TimerScheduleInfo.fromJson(data))
          .where((info) => info != null) // Filter out any null entries
          .toList();

      final now = AppDateTime.now();
      final timeShiftManager = TimeShiftManager();

      print('Removing past schedules');
      _scheduleInfoList.removeWhere((info) {
        final isPast = info.scheduledTime.isBefore(now);
        if (isPast) print('Removing past schedule: ${info.scheduledTime}');
        return isPast;
      });

      print('Creating new timers for future schedules');
      for (var info in _scheduleInfoList) {
        try {
          final delay = info.scheduledTime.difference(now);
          if (delay.isNegative) {
            print('Skipping past schedule: ${info.scheduledTime}');
            continue;
          }

          print('Scheduling timer for ${info.scheduledTime} (${info.actionType})');
          final timer = Timer(delay, () {
            try {
              print('Timer triggered for ${info.scheduledTime} (${info.actionType})');
              if (info.actionType == 'screenOn') {
                timeShiftManager.isLauncherInstalled ? _toggleBoxScreenOn() : _toggleTabletScreenOn();
              } else {
                timeShiftManager.isLauncherInstalled ? _toggleBoxScreenOff() : _toggleTabletScreenOff();
              }
            } catch (e) {
              print('Error executing timer action: $e');
            }
          });

          final timeString = '${info.scheduledTime.hour}:${info.scheduledTime.minute}';
          _scheduledTimers[timeString] ??= [];
          _scheduledTimers[timeString]!.add(timer);
        } catch (e) {
          print('Error scheduling timer for ${info.scheduledTime}: $e');
        }
      }

      print('Saving restored schedules');
      await saveScheduledEventsToLocale();
    } catch (e) {
      print('Error restoring scheduled timers: $e');
    }
  }

  static void _scheduleForPrayer(
    String timeString,
    DateTime now,
    int beforeDelayMinutes,
    int afterDelayMinutes,
    bool isFajrIsha,
    TimeShiftManager timeShiftManager,
  ) {
    print('\n=== Scheduling for prayer time: $timeString ===');
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    DateTime scheduledDateTime = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledDateTime.isBefore(now)) {
      print('Prayer time already passed today, scheduling for tomorrow');
      scheduledDateTime = scheduledDateTime.add(Duration(days: 1));
    }
    print('Scheduled prayer time: $scheduledDateTime');

    // Schedule screen on
    final beforeScheduleTime = scheduledDateTime.subtract(Duration(minutes: beforeDelayMinutes));
    if (beforeScheduleTime.isAfter(now)) {
      print('Scheduling screen ON at: $beforeScheduleTime');
      _scheduleInfoList.add(TimerScheduleInfo(
        scheduledTime: beforeScheduleTime,
        actionType: 'screenOn',
        isFajrIsha: isFajrIsha,
      ));

      final beforeTimer = Timer(beforeScheduleTime.difference(now), () {
        print('Executing screen ON timer for $timeString');
        timeShiftManager.isLauncherInstalled ? _toggleBoxScreenOn() : _toggleTabletScreenOn();
      });
      _scheduledTimers[timeString] = [beforeTimer];
    } else {
      print('Screen ON time already passed: $beforeScheduleTime');
    }

    // Schedule screen off
    final afterScheduleTime = scheduledDateTime.add(Duration(minutes: afterDelayMinutes));
    print('Scheduling screen OFF at: $afterScheduleTime');
    _scheduleInfoList.add(TimerScheduleInfo(
      scheduledTime: afterScheduleTime,
      actionType: 'screenOff',
      isFajrIsha: isFajrIsha,
    ));

    final afterTimer = Timer(afterScheduleTime.difference(now), () {
      print('Executing screen OFF timer for $timeString');
      timeShiftManager.isLauncherInstalled ? _toggleBoxScreenOff() : _toggleTabletScreenOff();
    });

    if (_scheduledTimers[timeString] != null) {
      _scheduledTimers[timeString]!.add(afterTimer);
    } else {
      _scheduledTimers[timeString] = [afterTimer];
    }
  }

  static Future<void> loadScheduledTimersFromPrefs() async {
    print('Loading scheduled timers from preferences');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final timersJson = prefs.getString(_scheduledTimersKey);
    print('Saved timers found: ${timersJson != null}');

    if (timersJson != null) {
      final timersMap = json.decode(timersJson) as Map<String, dynamic>;
      print('Number of saved timer entries: ${timersMap.length}');

      timersMap.forEach((timeString, timerDataList) {
        print('Processing timers for $timeString');
        _scheduledTimers[timeString] = [];
        for (final timerData in timerDataList) {
          final tick = timerData['tick'] as int;
          final timer = Timer(Duration(milliseconds: tick), () {});
          _scheduledTimers[timeString]!.add(timer);
        }
      });
    }
  }

  static Future<void> toggleFeatureState(bool isActive) async {
    print('Setting toggle feature state to: $isActive');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(TurnOnOffTvConstant.kActivateToggleFeature, isActive);
  }

  static Future<bool> getToggleFeatureState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final state = prefs.getBool(TurnOnOffTvConstant.kActivateToggleFeature) ?? false;
    print('Current toggle feature state: $state');
    return state;
  }

  static Future<bool> getToggleFeatureishaFajrState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final state = prefs.getBool(TurnOnOffTvConstant.kisFajrIshaOnly) ?? false;
    print('Current Fajr/Isha only state: $state');
    return state;
  }

  static Future<void> cancelAllScheduledTimers() async {
    print('Canceling all scheduled timers');
    int canceledTimers = 0;
    _scheduledTimers.forEach((timeString, timers) {
      for (final timer in timers) {
        timer.cancel();
        canceledTimers++;
      }
    });
    print('Canceled $canceledTimers timers');

    _scheduledTimers.clear();
    _scheduleInfoList.clear();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scheduledInfoKey);
    await prefs.remove(TurnOnOffTvConstant.kScheduledTimersKey);
    await prefs.setBool(TurnOnOffTvConstant.kIsEventsSet, false);
    print('Cleared all scheduled timer data from preferences');
  }

  static Future<void> _toggleBoxScreenOn() async {
    print('Attempting to turn box screen ON');
    try {
      await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel)
          .invokeMethod(TurnOnOffTvConstant.kToggleBoxScreenOn);
      print('Box screen ON command sent successfully');
    } on PlatformException catch (e) {
      print('Failed to turn box screen ON: ${e.message}');
      logger.e(e);
    }
  }

  static Future<void> _toggleBoxScreenOff() async {
    print('Attempting to turn box screen OFF');
    try {
      await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel)
          .invokeMethod(TurnOnOffTvConstant.kToggleBoxScreenOff);
      print('Box screen OFF command sent successfully');
    } on PlatformException catch (e) {
      print('Failed to turn box screen OFF: ${e.message}');
      logger.e(e);
    }
  }

  static Future<void> _toggleTabletScreenOn() async {
    print('Attempting to turn tablet screen ON');
    try {
      await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel)
          .invokeMethod(TurnOnOffTvConstant.kToggleTabletScreenOn);
      print('Tablet screen ON command sent successfully');
    } on PlatformException catch (e) {
      print('Failed to turn tablet screen ON: ${e.message}');
      logger.e(e);
    }
  }

  static Future<void> _toggleTabletScreenOff() async {
    print('Attempting to turn tablet screen OFF');
    try {
      await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel)
          .invokeMethod(TurnOnOffTvConstant.kToggleTabletScreenOff);
      print('Tablet screen OFF command sent successfully');
    } on PlatformException catch (e) {
      print('Failed to turn tablet screen OFF: ${e.message}');
      logger.e(e);
    }
  }

  static Future<bool> checkEventsScheduled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final isEventsSet = prefs.getBool(TurnOnOffTvConstant.kIsEventsSet) ?? false;
    print('Events scheduled check: $isEventsSet');
    logger.d("value$isEventsSet");
    return isEventsSet;
  }

  static Future<void> saveScheduledEventsToLocale() async {
    print('=== Saving scheduled events to local storage ===');
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    print('Saving ${_scheduleInfoList.length} schedule info items');
    final scheduleData = _scheduleInfoList.map((info) => info.toJson()).toList();
    await prefs.setString(_scheduledInfoKey, json.encode(scheduleData));

    print('Saving timer states');
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
    await prefs.setBool(TurnOnOffTvConstant.kIsEventsSet, true);

    print('All data saved successfully');
    logger.d("Saving into local");
  }

  static Future<void> setLastEventDate(DateTime date) async {
    print('Setting last event date to: $date');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(TurnOnOffTvConstant.kLastEventDate, date.toIso8601String());
  }

  static Future<DateTime?> getLastEventDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastEventDateString = prefs.getString(TurnOnOffTvConstant.kLastEventDate);
    print('Retrieved last event date: $lastEventDateString');
    if (lastEventDateString != null) {
      return DateTime.parse(lastEventDateString);
    } else {
      return null;
    }
  }
}
