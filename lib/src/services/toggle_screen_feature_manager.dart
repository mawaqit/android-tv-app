import 'dart:async';
import 'dart:convert';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/error/screen_on_off_exceptions.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mawaqit/src/helpers/TimeShiftManager.dart';
import 'package:mawaqit/src/services/background_work_managers/work_manager_services.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerScheduleInfo {
  final DateTime scheduledTime;
  final String actionType; // 'screenOn' or 'screenOff'
  final bool isFajrIsha;
  final String prayerName;

  TimerScheduleInfo({
    required this.scheduledTime,
    required this.actionType,
    required this.isFajrIsha,
    required this.prayerName,
  });

  Map<String, dynamic> toJson() {
    return {
      'scheduledTime': scheduledTime.toIso8601String(),
      'actionType': actionType,
      'isFajrIsha': isFajrIsha,
      'prayerName': prayerName,
    };
  }

  factory TimerScheduleInfo.fromJson(Map<String, dynamic> json) {
    return TimerScheduleInfo(
      scheduledTime: DateTime.parse(json['scheduledTime']),
      actionType: json['actionType'],
      isFajrIsha: json['isFajrIsha'] ?? false,
      prayerName: json['prayerName'] ?? '',
    );
  }
}

class ToggleScreenFeature {
  static final ToggleScreenFeature _instance = ToggleScreenFeature._internal();

  factory ToggleScreenFeature() => _instance;

  ToggleScreenFeature._internal();

  static const String _scheduledInfoKey = 'scheduled_info_key';
  static const int DEFAULT_DAYS_TO_SCHEDULE = 2;
  static const int FAJR_ISHA_DAYS_TO_SCHEDULE = 6;
  static const int BACKGROUND_CHECK_ALARM_ID = 999888777;

  /// Schedule screen toggle timers for multiple days
  static Future<void> scheduleToggleScreen(bool isFajrIshaOnly, int beforeDelayMinutes, int afterDelayMinutes,
      [BuildContext? context]) async {
    try {
      // Cancel any existing timers before scheduling new ones
      await cancelAllScheduledTimers();

      // Determine days to schedule based on the mode
      final daysToSchedule = isFajrIshaOnly ? FAJR_ISHA_DAYS_TO_SCHEDULE : DEFAULT_DAYS_TO_SCHEDULE;

      // Save scheduling parameters for future rescheduling
      await _saveSchedulingParameters(isFajrIshaOnly, beforeDelayMinutes, afterDelayMinutes);

      // Schedule for multiple days with fresh prayer times for each day
      for (int dayOffset = 0; dayOffset <= daysToSchedule; dayOffset++) {
        await _scheduleForDay(isFajrIshaOnly, beforeDelayMinutes, afterDelayMinutes, dayOffset);
      }

      // Update feature state and last scheduled date
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setBool(TurnOnOffTvConstant.kActivateToggleFeature, true),
        prefs.setString(TurnOnOffTvConstant.kLastEventDate, AppDateTime.now().toIso8601String()),
        prefs.setInt(TurnOnOffTvConstant.kMinuteBeforeKey, beforeDelayMinutes),
        prefs.setInt(TurnOnOffTvConstant.kMinuteAfterKey, afterDelayMinutes),
        prefs.setBool(TurnOnOffTvConstant.kIsEventsSet, true),
      ]);

      logger.i(
          'Screen toggle scheduled successfully for ${daysToSchedule + 1} days in ${isFajrIshaOnly ? "Fajr/Isha only" : "all prayers"} mode');
    } catch (e) {
      logger.e('Failed to schedule toggle screen: $e');
      throw ScheduleToggleScreenException(e.toString());
    }
  }

  /// Schedule timers for a specific day offset from today
  static Future<void> _scheduleForDay(
      bool isFajrIshaOnly, int beforeDelayMinutes, int afterDelayMinutes, int dayOffset) async {
    try {
      final now = AppDateTime.now();
      final targetDate = now.add(Duration(days: dayOffset));

      // Get prayer times for THIS specific day
      final mosqueManager = MosqueManager.getInstance();
      if (mosqueManager?.times == null) {
        throw ScheduleToggleScreenException('No prayer times available for day $dayOffset');
      }

      final List<String> prayerTimes = mosqueManager!.times!.dayTimesStrings(targetDate, salahOnly: false);
      prayerTimes.removeAt(1); // Remove sunrise
      final prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

      final List<TimerScheduleInfo> schedulesToSave = [];

      if (isFajrIshaOnly) {
        // Handle Fajr (Screen ON)
        final fajrScheduleInfo = await _schedulePrayerAction(
          prayerName: 'Fajr',
          timeString: prayerTimes[0],
          targetDate: targetDate,
          delayMinutes: beforeDelayMinutes,
          actionType: 'screenOn',
          isFajrIsha: true,
          dayOffset: dayOffset,
        );
        if (fajrScheduleInfo != null) schedulesToSave.add(fajrScheduleInfo);

        // Handle Isha (Screen OFF)
        final ishaScheduleInfo = await _schedulePrayerAction(
          prayerName: 'Isha',
          timeString: prayerTimes[4],
          targetDate: targetDate,
          delayMinutes: afterDelayMinutes,
          actionType: 'screenOff',
          isFajrIsha: true,
          dayOffset: dayOffset,
        );
        if (ishaScheduleInfo != null) schedulesToSave.add(ishaScheduleInfo);
      } else {
        // Schedule for all prayers
        for (int i = 0; i < prayerTimes.length; i++) {
          final prayerName = prayerNames[i];
          final prayerTime = prayerTimes[i];

          // Schedule Screen ON
          final onScheduleInfo = await _schedulePrayerAction(
            prayerName: prayerName,
            timeString: prayerTime,
            targetDate: targetDate,
            delayMinutes: beforeDelayMinutes,
            actionType: 'screenOn',
            isFajrIsha: false,
            dayOffset: dayOffset,
          );
          if (onScheduleInfo != null) schedulesToSave.add(onScheduleInfo);

          // Schedule Screen OFF
          final offScheduleInfo = await _schedulePrayerAction(
            prayerName: prayerName,
            timeString: prayerTime,
            targetDate: targetDate,
            delayMinutes: afterDelayMinutes,
            actionType: 'screenOff',
            isFajrIsha: false,
            dayOffset: dayOffset,
          );
          if (offScheduleInfo != null) schedulesToSave.add(offScheduleInfo);
        }
      }

      // Save all schedules in a single batch operation
      if (schedulesToSave.isNotEmpty) {
        await _saveScheduledInfoBatch(schedulesToSave);
      }
    } catch (e) {
      logger.e('Failed to schedule for day with offset $dayOffset: $e');
      throw ScheduleToggleScreenException(e.toString());
    }
  }

  /// Schedule a single prayer action (screen on/off) and return the TimerScheduleInfo if scheduled
  static Future<TimerScheduleInfo?> _schedulePrayerAction({
    required String prayerName,
    required String timeString,
    required DateTime targetDate,
    required int delayMinutes,
    required String actionType,
    required bool isFajrIsha,
    required int dayOffset,
  }) async {
    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      DateTime prayerDateTime = DateTime(targetDate.year, targetDate.month, targetDate.day, hour, minute);

      DateTime scheduledTime;
      if (actionType == 'screenOn') {
        scheduledTime = prayerDateTime.subtract(Duration(minutes: delayMinutes));
      } else {
        scheduledTime = prayerDateTime.add(Duration(minutes: delayMinutes));
      }

      final now = AppDateTime.now();

      if (scheduledTime.isAfter(now)) {
        final uniqueId = '${actionType}_${prayerName}_${dayOffset}_${DateTime.now().millisecondsSinceEpoch}';
        final isBox = TimeShiftManager().isLauncherInstalled;

        await WorkManagerService.registerScreenTask(uniqueId, actionType, scheduledTime.difference(now), isBox);

        return TimerScheduleInfo(
          scheduledTime: scheduledTime,
          actionType: actionType,
          isFajrIsha: isFajrIsha,
          prayerName: prayerName,
        );
      }
      return null;
    } catch (e) {
      logger.e('Error scheduling $actionType for $prayerName: $e');
      throw SchedulePrayerTimeException(e.toString());
    }
  }

  /// Save a batch of scheduled timer infos for tracking
  static Future<void> _saveScheduledInfoBatch(List<TimerScheduleInfo> newInfoList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<TimerScheduleInfo> existingInfoList = await _getScheduledInfoList();

      existingInfoList.addAll(newInfoList);

      final now = AppDateTime.now();
      existingInfoList = existingInfoList.where((item) => item.scheduledTime.isAfter(now)).toList();

      final jsonList = existingInfoList.map((item) => item.toJson()).toList();
      await prefs.setString(_scheduledInfoKey, jsonEncode(jsonList));

      logger.i('Saved ${newInfoList.length} new timer schedules (total: ${existingInfoList.length})');
    } catch (e) {
      logger.e('Failed to save scheduled info batch: $e');
    }
  }

  /// Reschedule all timers using saved parameters with fresh prayer times
  static Future<void> _rescheduleAllTimers() async {
    print('Reschedule all timers started');

    try {
      final params = await _getSchedulingParameters();

      if (params == null) {
        print('No params found - Cannot reschedule, keeping existing timers');
        return;
      }

      print('Found valid scheduling parameters');
      print('About to cancel all existing timers');
      await cancelAllScheduledTimers();
      print('All timers cancelled');

      print('About to reschedule with fresh prayer times');
      await scheduleToggleScreen(
        params['isFajrIshaOnly'],
        params['beforeDelayMinutes'],
        params['afterDelayMinutes'],
      );
      print('Successfully rescheduled all timers');
    } catch (e) {
      print('Reschedule error: $e');
      print('Reschedule failed');
    }

    print('Reschedule all timers ended');
  }

  static Future<void> checkAndRescheduleIfNeeded() async {
    try {
      final now = DateTime.now();

      final isToggleActive = await getToggleFeatureState();
      if (!isToggleActive) return;

      final lastEventDate = await getLastEventDate();
      if (lastEventDate != null) {
        final daysSinceLastSchedule = now.difference(lastEventDate).inDays;

        // Get current mode to determine reschedule threshold
        final currentIsFajrIshaOnly = await getToggleFeatureishaFajrState();

        // Different thresholds based on mode:
        // - Fajr/Isha only: reschedule on 5th day (before 6-day schedule expires)
        // - All prayers: reschedule on 1st day (before 2-day schedule expires)
        final rescheduleThreshold = currentIsFajrIshaOnly ? 5 : 1;

        logger.i(
            'Days since last schedule: $daysSinceLastSchedule, Mode: ${currentIsFajrIshaOnly ? "Fajr/Isha" : "All prayers"}, Threshold: $rescheduleThreshold');

        if (daysSinceLastSchedule >= rescheduleThreshold) {
          // Get current values from SharedPreferences (actual current settings)
          final mosqueManager = MosqueManager.getInstance();
          if (mosqueManager != null && mosqueManager.times != null) {
            final currentMinuteBefore = await getBeforeDelayMinutes();
            final currentMinuteAfter = await getAfterDelayMinutes();

            logger.i(
                'Rescheduling toggle screen with current values: FajrIsha=$currentIsFajrIshaOnly, Before=$currentMinuteBefore, After=$currentMinuteAfter');
            await scheduleToggleScreen(
              currentIsFajrIshaOnly,
              currentMinuteBefore,
              currentMinuteAfter,
            );
          }
        } else {
          logger.i('Still within scheduling window for ${currentIsFajrIshaOnly ? "Fajr/Isha" : "All prayers"} mode');
        }
      }
    } catch (e) {
      logger.e('Error in toggle screen reschedule check: $e');
    }
  }

  /// Save scheduling parameters for future rescheduling
  static Future<void> _saveSchedulingParameters(
      bool isFajrIshaOnly, int beforeDelayMinutes, int afterDelayMinutes) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> params = {
        'isFajrIshaOnly': isFajrIshaOnly,
        'beforeDelayMinutes': beforeDelayMinutes,
        'afterDelayMinutes': afterDelayMinutes,
        'savedAt': DateTime.now().toIso8601String(),
      };

      await prefs.setString(TurnOnOffTvConstant.kScheduleParamsKey, jsonEncode(params));
    } catch (e) {
      logger.e('Failed to save scheduling parameters: $e');
    }
  }

  /// Get saved scheduling parameters
  static Future<Map<String, dynamic>?> _getSchedulingParameters() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final paramsString = prefs.getString(TurnOnOffTvConstant.kScheduleParamsKey);

      if (paramsString != null) {
        return jsonDecode(paramsString);
      }
      return null;
    } catch (e) {
      logger.e('Failed to get scheduling parameters: $e');
      return null;
    }
  }

  /// Get list of scheduled timer info
  static Future<List<TimerScheduleInfo>> _getScheduledInfoList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_scheduledInfoKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((item) => TimerScheduleInfo.fromJson(item)).toList();
    } catch (e) {
      logger.e('Failed to get scheduled info list: $e');
      return [];
    }
  }

  /// Mark events as scheduled or unscheduled
  static Future<void> _setEventsScheduled(bool isScheduled) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(TurnOnOffTvConstant.kIsEventsSet, isScheduled);
  }

  // Preference getters and setters
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

  static Future<void> recordEventExecution() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(TurnOnOffTvConstant.kLastExecutedEventDate, DateTime.now().toIso8601String());
  }

  static Future<DateTime?> getLastExecutedEventDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastExecDateString = prefs.getString(TurnOnOffTvConstant.kLastExecutedEventDate);
    if (lastExecDateString != null) {
      return DateTime.parse(lastExecDateString);
    } else {
      return null;
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

      await _setEventsScheduled(false);

      final allKeys = prefs.getKeys().toList();
      final mappingKeys = allKeys.where((key) => key.startsWith('screen_task_id_mapping_')).toList();

      for (String mappingKey in mappingKeys) {
        final uniqueId = mappingKey.substring('screen_task_id_mapping_'.length);
        final alarmIdString = prefs.getString(mappingKey);

        if (alarmIdString != null) {
          final int alarmId = int.parse(alarmIdString);

          final bool success = await AndroidAlarmManager.cancel(alarmId);

          if (success) {
            logger.i('Alarm cancelled successfully: $alarmId');
          } else {
            logger.w('Failed to cancel alarm: $alarmId');
          }

          await prefs.remove('alarm_data_$alarmId');
          await prefs.remove(mappingKey);
        }
      }

      await AndroidAlarmManager.cancel(BACKGROUND_CHECK_ALARM_ID);
      await prefs.remove(_scheduledInfoKey);

      logger.i('All scheduled timers cancelled');
    } catch (e) {
      logger.e('Failed to cancel all scheduled timers: $e');
      throw ScheduleToggleScreenException(e.toString());
    }
  }

  static Future<bool> checkEventsScheduled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final isEventsSet = prefs.getBool(TurnOnOffTvConstant.kIsEventsSet) ?? false;
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
