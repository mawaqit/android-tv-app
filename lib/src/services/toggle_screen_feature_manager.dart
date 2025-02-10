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
    return {
      'scheduledTime': scheduledTime.toIso8601String(),
      'actionType': actionType,
      'isFajrIsha': isFajrIsha,
    };
  }

  factory TimerScheduleInfo.fromJson(Map<String, dynamic> json) {
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

  ToggleScreenFeature._internal();

  static const String _scheduledTimersKey = TurnOnOffTvConstant.kScheduledTimersKey;
  static final Map<String, List<Timer>> _scheduledTimers = {};
  static const String _scheduledInfoKey = 'scheduled_info_key';
  static List<TimerScheduleInfo> _scheduleInfoList = [];

  static Future<void> scheduleToggleScreen(
      bool isfajrIshaonly, List<String> timeStrings, int beforeDelayMinutes, int afterDelayMinutes) async {
    await cancelAllScheduledTimers();
    _scheduleInfoList.clear();

    final now = AppDateTime.now();
    final timeShiftManager = TimeShiftManager();

    if (isfajrIshaonly) {
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

    final shouldReschedule =
        lastEventDate != null && lastEventDate.day != today.day && isFeatureActive && !areEventsScheduled;
    return shouldReschedule;
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
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final scheduleDataString = prefs.getString(_scheduledInfoKey);
      final isFeatureActive = await getToggleFeatureState();

      if (scheduleDataString == null || !isFeatureActive) {
        return;
      }

      final scheduleData = json.decode(scheduleDataString) as List;
      _scheduleInfoList = scheduleData
          .map((data) => TimerScheduleInfo.fromJson(data))
          .where((info) => info != null) // Filter out any null entries
          .toList();

      final now = AppDateTime.now();
      final timeShiftManager = TimeShiftManager();

      _scheduleInfoList.removeWhere((info) {
        final isPast = info.scheduledTime.isBefore(now);
        return isPast;
      });

      for (var info in _scheduleInfoList) {
        try {
          final delay = info.scheduledTime.difference(now);
          if (delay.isNegative) {
            continue;
          }

          final timer = Timer(delay, () {
            try {
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
    } else {
      print('Screen ON time already passed: $beforeScheduleTime');
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
    final state = prefs.getBool(TurnOnOffTvConstant.kActivateToggleFeature) ?? false;
    return state;
  }

  static Future<bool> getToggleFeatureishaFajrState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final state = prefs.getBool(TurnOnOffTvConstant.kisFajrIshaOnly) ?? false;
    return state;
  }

  static Future<void> cancelAllScheduledTimers() async {
    int canceledTimers = 0;
    _scheduledTimers.forEach((timeString, timers) {
      for (final timer in timers) {
        timer.cancel();
        canceledTimers++;
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
    final isEventsSet = prefs.getBool(TurnOnOffTvConstant.kIsEventsSet) ?? false;
    logger.d("value$isEventsSet");
    return isEventsSet;
  }

  static Future<void> saveScheduledEventsToLocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final scheduleData = _scheduleInfoList.map((info) => info.toJson()).toList();
    await prefs.setString(_scheduledInfoKey, json.encode(scheduleData));

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
