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

  Map<String, dynamic> toJson() => {
        'scheduledTime': scheduledTime.toIso8601String(),
        'actionType': actionType,
        'isFajrIsha': isFajrIsha,
      };

  factory TimerScheduleInfo.fromJson(Map<String, dynamic> json) => TimerScheduleInfo(
        scheduledTime: DateTime.parse(json['scheduledTime']),
        actionType: json['actionType'],
        isFajrIsha: json['isFajrIsha'],
      );
}

class ToggleScreenFeature {
  static final ToggleScreenFeature _instance = ToggleScreenFeature._internal();

  factory ToggleScreenFeature() => _instance;

  ToggleScreenFeature._internal();

  static const String _scheduledTimersKey = TurnOnOffTvConstant.kScheduledTimersKey;
  static final Map<String, List<Timer>> _scheduledTimers = {};
  static const String _scheduledInfoKey = 'scheduled_info_key';
  static List<TimerScheduleInfo> _scheduleInfoList = [];

  static Future<void> scheduleToggleScreen(
      bool isfajrIshaonly, List<String> timeStrings, int beforeDelayMinutes, int afterDelayMinutes) async {
    // Clear existing schedules
    await cancelAllScheduledTimers();
    _scheduleInfoList.clear();

    final now = AppDateTime.now();
    final timeShiftManager = TimeShiftManager();

    if (isfajrIshaonly) {
      // Handle Fajr prayer
      _scheduleForPrayer(
        timeStrings[0],
        now,
        beforeDelayMinutes,
        afterDelayMinutes,
        true,
        timeShiftManager,
      );

      // Handle Isha prayer
      _scheduleForPrayer(
        timeStrings[5],
        now,
        beforeDelayMinutes,
        afterDelayMinutes,
        true,
        timeShiftManager,
      );
    } else {
      // Schedule for all prayers
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

    // Save all states in one go
    await Future.wait([saveScheduledEventsToLocale(), toggleFeatureState(true), setLastEventDate(now)]);
  }

  static Future<void> _saveScheduleInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final scheduleData = _scheduleInfoList.map((info) => info.toJson()).toList();
    await prefs.setString(_scheduledInfoKey, json.encode(scheduleData));
  }

  static Future<bool> shouldReschedule() async {
    final lastEventDate = await getLastEventDate();
    final today = AppDateTime.now();
    final isFeatureActive = await getToggleFeatureState();
    final areEventsScheduled = await checkEventsScheduled();

    return lastEventDate != null && lastEventDate.day != today.day && isFeatureActive && !areEventsScheduled;
  }

  static Future<void> handleDailyRescheduling({
    required bool isIshaFajrOnly,
    required List<String> timeStrings,
    required int minuteBefore,
    required int minuteAfter,
  }) async {
    final shouldSchedule = await shouldReschedule();

    if (shouldSchedule) {
      await cancelAllScheduledTimers();
      await toggleFeatureState(false);

      // Schedule new timers
      await scheduleToggleScreen(
        isIshaFajrOnly,
        timeStrings,
        minuteBefore,
        minuteAfter,
      );

      await saveScheduledEventsToLocale();
    }
  }

  static Future<void> restoreScheduledTimers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final scheduleDataString = prefs.getString(_scheduledInfoKey);
    final isFeatureActive = await getToggleFeatureState();

    if (scheduleDataString != null && isFeatureActive) {
      final scheduleData = json.decode(scheduleDataString) as List;
      _scheduleInfoList = scheduleData.map((data) => TimerScheduleInfo.fromJson(data)).toList();

      final now = AppDateTime.now();
      final timeShiftManager = TimeShiftManager();

      // Remove past schedules and create new timers for future schedules
      _scheduleInfoList.removeWhere((info) => info.scheduledTime.isBefore(now));

      for (var info in _scheduleInfoList) {
        final delay = info.scheduledTime.difference(now);
        if (delay.isNegative) continue;

        final timer = Timer(delay, () {
          if (info.actionType == 'screenOn') {
            timeShiftManager.isLauncherInstalled ? _toggleBoxScreenOn() : _toggleTabletScreenOn();
          } else {
            timeShiftManager.isLauncherInstalled ? _toggleBoxScreenOff() : _toggleTabletScreenOff();
          }
        });

        final timeString = '${info.scheduledTime.hour}:${info.scheduledTime.minute}';
        if (_scheduledTimers[timeString] != null) {
          _scheduledTimers[timeString]!.add(timer);
        } else {
          _scheduledTimers[timeString] = [timer];
        }
      }

      // Save the newly created timers
      await saveScheduledEventsToLocale();
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
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    DateTime scheduledDateTime = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledDateTime.isBefore(now)) {
      scheduledDateTime = scheduledDateTime.add(Duration(days: 1));
    }

    // Schedule screen on
    final beforeScheduleTime = scheduledDateTime.subtract(Duration(minutes: beforeDelayMinutes));
    if (beforeScheduleTime.isAfter(now)) {
      _scheduleInfoList.add(TimerScheduleInfo(
        scheduledTime: beforeScheduleTime,
        actionType: 'screenOn',
        isFajrIsha: isFajrIsha,
      ));

      final beforeTimer = Timer(beforeScheduleTime.difference(now), () {
        timeShiftManager.isLauncherInstalled ? _toggleBoxScreenOn() : _toggleTabletScreenOn();
      });
      _scheduledTimers[timeString] = [beforeTimer];
    }

    // Schedule screen off
    final afterScheduleTime = scheduledDateTime.add(Duration(minutes: afterDelayMinutes));
    _scheduleInfoList.add(TimerScheduleInfo(
      scheduledTime: afterScheduleTime,
      actionType: 'screenOff',
      isFajrIsha: isFajrIsha,
    ));

    final afterTimer = Timer(afterScheduleTime.difference(now), () {
      timeShiftManager.isLauncherInstalled ? _toggleBoxScreenOff() : _toggleTabletScreenOff();
    });

    if (_scheduledTimers[timeString] != null) {
      _scheduledTimers[timeString]!.add(afterTimer);
    } else {
      _scheduledTimers[timeString] = [afterTimer];
    }
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
    _scheduleInfoList.clear();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scheduledInfoKey);
    await prefs.remove(TurnOnOffTvConstant.kScheduledTimersKey);
    await prefs.setBool(TurnOnOffTvConstant.kIsEventsSet, false);
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

    // Save schedule info
    final scheduleData = _scheduleInfoList.map((info) => info.toJson()).toList();
    await prefs.setString(_scheduledInfoKey, json.encode(scheduleData));

    // Save timer states
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

    logger.d("Saving into local");
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
