import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/error/screen_on_off_exceptions.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mawaqit/src/helpers/TimeShiftManager.dart';
import 'package:mawaqit/src/services/background_work_managers/work_manager_services.dart';
import 'package:screen_control/screen_control.dart';
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
    try {
      await cancelAllScheduledTimers();

      final List<String> prayerTimes = List.from(timeStrings);
      prayerTimes.removeAt(1);
      final now = AppDateTime.now();

      if (isfajrIshaonly) {
        await _scheduleForPrayer(
          prayerTimes[0],
          now,
          beforeDelayMinutes,
          afterDelayMinutes,
          true,
        );

        await _scheduleForPrayer(
          prayerTimes[4],
          now,
          beforeDelayMinutes,
          afterDelayMinutes,
          true,
        );
      } else {
        for (String prayerTime in prayerTimes) {
          await _scheduleForPrayer(
            prayerTime,
            now,
            beforeDelayMinutes,
            afterDelayMinutes,
            false,
          );
        }
      }

      await Future.wait([
        toggleFeatureState(true),
        setLastEventDate(now),
        saveBeforeDelayMinutes(beforeDelayMinutes),
        saveAfterDelayMinutes(afterDelayMinutes),
      ]);
    } catch (e) {
      logger.e('Failed to schedule toggle screen: $e');
      throw ScheduleToggleScreenException(e.toString());
    }
  }

  static Future<int> getBeforeDelayMinutes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(TurnOnOffTvConstant.kMinuteBeforeKey) ?? 0;
  }

  static Future<int> getAfterDelayMinutes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(TurnOnOffTvConstant.kMinuteAfterKey) ?? 0;
  }

  static Future<void> saveBeforeDelayMinutes(int minutes) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(TurnOnOffTvConstant.kMinuteBeforeKey, minutes);
  }

  static Future<void> saveAfterDelayMinutes(int minutes) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(TurnOnOffTvConstant.kMinuteAfterKey, minutes);
  }

  static Future<bool> shouldReschedule() async {
    final lastEventDate = await getLastEventDate();
    final today = AppDateTime.now();
    final isFeatureActive = await getToggleFeatureState();

    final shouldReschedule = lastEventDate != null && lastEventDate.day != today.day && isFeatureActive;
    return shouldReschedule;
  }

  static Future<void> handleDailyRescheduling({
    required bool isIshaFajrOnly,
    required List<String> timeStrings,
    required int minuteBefore,
    required int minuteAfter,
  }) async {
    try {
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
      }
    } catch (e) {
      logger.e('Failed to handle daily rescheduling: $e');
      throw DailyReschedulingException(e.toString());
    }
  }

  static Future<void> _scheduleForPrayer(
    String timeString,
    DateTime now,
    int beforeDelayMinutes,
    int afterDelayMinutes,
    bool isFajrIsha,
  ) async {
    try {
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
        final uniqueIdOn = 'screenOn_${timeString}_${DateTime.now().millisecondsSinceEpoch}';

        await WorkManagerService.registerScreenTask(
          uniqueIdOn,
          'screenOn',
          beforeScheduleTime.difference(now),
        );
      }

      // Schedule screen off
      final afterScheduleTime = scheduledDateTime.add(Duration(minutes: afterDelayMinutes));
      final uniqueIdOff = 'screenOff_${timeString}_${DateTime.now().millisecondsSinceEpoch}';

      await WorkManagerService.registerScreenTask(
        uniqueIdOff,
        'screenOff',
        afterScheduleTime.difference(now),
      );
    } catch (e) {
      logger.e('Error scheduling prayer time: $e');
      throw SchedulePrayerTimeException(e.toString());
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(TurnOnOffTvConstant.kIsEventsSet, false);
  }

  static Future<bool> checkEventsScheduled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final isEventsSet = prefs.getBool(TurnOnOffTvConstant.kIsEventsSet) ?? false;
    logger.d("value$isEventsSet");
    return isEventsSet;
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
