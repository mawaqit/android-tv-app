import 'dart:async';
import 'dart:convert';

import 'package:android_alarm_manager/android_alarm_manager.dart';
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
        final fajrTimeString = prayerTimes[0];
        final fajrParts = fajrTimeString.split(':');
        final fajrHour = int.parse(fajrParts[0]);
        final fajrMinute = int.parse(fajrParts[1]);

        DateTime fajrDateTime = DateTime(now.year, now.month, now.day, fajrHour, fajrMinute);
        if (fajrDateTime.isBefore(now)) {
          fajrDateTime = fajrDateTime.add(Duration(days: 1));
        }

        final beforeFajrTime = fajrDateTime.subtract(Duration(minutes: beforeDelayMinutes));
        final isBox = TimeShiftManager().isLauncherInstalled;

        if (beforeFajrTime.isAfter(now)) {
          final uniqueIdOn = 'screenOn_fajr_${DateTime.now().millisecondsSinceEpoch}';
          await WorkManagerService.registerScreenTask(
              uniqueIdOn, 'screenOn', beforeFajrTime.difference(now), isBox);
        }

        // Isha prayer - SCREEN OFF
        final ishaTimeString = prayerTimes[4];
        final ishaParts = ishaTimeString.split(':');
        final ishaHour = int.parse(ishaParts[0]);
        final ishaMinute = int.parse(ishaParts[1]);

        DateTime ishaDateTime = DateTime(now.year, now.month, now.day, ishaHour, ishaMinute);
        if (ishaDateTime.isBefore(now)) {
          ishaDateTime = ishaDateTime.add(Duration(days: 1));
        }

        // Schedule screen OFF after Isha
        final afterIshaTime = ishaDateTime.add(Duration(minutes: afterDelayMinutes));
        final uniqueIdOff = 'screenOff_isha_${DateTime.now().millisecondsSinceEpoch}';

        await WorkManagerService.registerScreenTask(
            uniqueIdOff, 'screenOff', afterIshaTime.difference(now), isBox);
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
        final isBox = TimeShiftManager().isLauncherInstalled;

        await WorkManagerService.registerScreenTask(
            uniqueIdOn, 'screenOn', beforeScheduleTime.difference(now), isBox);
      }

      // Schedule screen off
      final afterScheduleTime = scheduledDateTime.add(Duration(minutes: afterDelayMinutes));
      final uniqueIdOff = 'screenOff_${timeString}_${DateTime.now().millisecondsSinceEpoch}';
      final isBox = TimeShiftManager().isLauncherInstalled;
      await WorkManagerService.registerScreenTask(
          uniqueIdOff, 'screenOff', afterScheduleTime.difference(now), isBox);
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
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // First set the flag to false
      await prefs.setBool(TurnOnOffTvConstant.kIsEventsSet, false);

      // Get all keys from SharedPreferences
      final allKeys = prefs.getKeys();

      // Filter keys that start with 'id_mapping_'
      final mappingKeys = allKeys.where((key) => key.startsWith('screen_task_id_mapping_')).toList();

      // Cancel each alarm and clean up SharedPreferences
      for (String mappingKey in mappingKeys) {
        // Extract uniqueId from the key (remove 'id_mapping_' prefix)
        final uniqueId = mappingKey.substring('screen_task_id_mapping_'.length);
        // Get the alarm ID
        final alarmIdString = prefs.getString(mappingKey);

        if (alarmIdString != null) {
          final int alarmId = int.parse(alarmIdString);

          // Cancel the alarm
          final bool success = await AndroidAlarmManager.cancel(alarmId);

          if (success) {
            logger.i('Alarm cancelled successfully: $alarmId');
          } else {
            logger.w('Failed to cancel alarm: $alarmId');
          }

          // Clean up SharedPreferences
          await prefs.remove('alarm_data_$alarmId');
          await prefs.remove(mappingKey);
        }
      }

      logger.i('All scheduled timers cancelled');
    } catch (e) {
      logger.e('Failed to cancel all scheduled timers: $e');
      throw ScheduleToggleScreenException(e.toString());
    }
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
