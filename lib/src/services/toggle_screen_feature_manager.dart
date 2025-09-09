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
  static const Duration BACKGROUND_CHECK_INTERVAL =
      Duration(minutes: 10); // Check more frequently

  /// Schedule screen toggle timers for multiple days with battery optimization check
  static Future<void> scheduleToggleScreen(bool isFajrIshaOnly,
      List<String> timeStrings, int beforeDelayMinutes, int afterDelayMinutes,
      [BuildContext? context]) async {
    try {
      // Cancel any existing timers before scheduling new ones
      await cancelAllScheduledTimers();

      // Determine days to schedule based on the mode
      final daysToSchedule = isFajrIshaOnly
          ? FAJR_ISHA_DAYS_TO_SCHEDULE
          : DEFAULT_DAYS_TO_SCHEDULE;

      // Save scheduling parameters for future rescheduling
      await _saveSchedulingParameters(
          isFajrIshaOnly, timeStrings, beforeDelayMinutes, afterDelayMinutes);

      // Schedule for multiple days
      for (int dayOffset = 0; dayOffset <= daysToSchedule; dayOffset++) {
        await _scheduleForDay(isFajrIshaOnly, timeStrings, beforeDelayMinutes,
            afterDelayMinutes, dayOffset);
      }

      // Schedule background check to ensure timers are still active
      await _scheduleBackgroundCheck();

      // Update feature state and last scheduled date
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setBool(TurnOnOffTvConstant.kActivateToggleFeature, true),
        prefs.setString(TurnOnOffTvConstant.kLastEventDate,
            AppDateTime.now().toIso8601String()),
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
      bool isFajrIshaOnly,
      List<String> timeStrings,
      int beforeDelayMinutes,
      int afterDelayMinutes,
      int dayOffset) async {
    try {
      final List<String> prayerTimes = List.from(timeStrings);
      prayerTimes.removeAt(1); // Remove sunrise
      final now = AppDateTime.now();
      final targetDate = now.add(Duration(days: dayOffset));
      final prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

      final List<TimerScheduleInfo> schedulesToSave = [];

      if (isFajrIshaOnly) {
        // Handle Fajr (Screen ON)
        final fajrTimeString = prayerTimes[0];
        final fajrScheduleInfo = await _schedulePrayerAction(
          prayerName: 'Fajr',
          timeString: fajrTimeString,
          targetDate: targetDate,
          delayMinutes: beforeDelayMinutes,
          actionType: 'screenOn',
          isFajrIsha: true,
          dayOffset: dayOffset,
        );

        if (fajrScheduleInfo != null) {
          schedulesToSave.add(fajrScheduleInfo);
        }

        // Handle Isha (Screen OFF)
        final ishaTimeString = prayerTimes[4];
        final ishaScheduleInfo = await _schedulePrayerAction(
          prayerName: 'Isha',
          timeString: ishaTimeString,
          targetDate: targetDate,
          delayMinutes: afterDelayMinutes,
          actionType: 'screenOff',
          isFajrIsha: true,
          dayOffset: dayOffset,
        );

        if (ishaScheduleInfo != null) {
          schedulesToSave.add(ishaScheduleInfo);
        }
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

          if (onScheduleInfo != null) {
            schedulesToSave.add(onScheduleInfo);
          }

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

          if (offScheduleInfo != null) {
            schedulesToSave.add(offScheduleInfo);
          }
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

      DateTime prayerDateTime = DateTime(
          targetDate.year, targetDate.month, targetDate.day, hour, minute);

      DateTime scheduledTime;
      if (actionType == 'screenOn') {
        scheduledTime =
            prayerDateTime.subtract(Duration(minutes: delayMinutes));
      } else {
        scheduledTime = prayerDateTime.add(Duration(minutes: delayMinutes));
      }

      final now = AppDateTime.now();

      if (scheduledTime.isAfter(now)) {
        final uniqueId =
            '${actionType}_${prayerName}_${dayOffset}_${DateTime.now().millisecondsSinceEpoch}';
        final isBox = TimeShiftManager().isLauncherInstalled;

        await WorkManagerService.registerScreenTask(
            uniqueId, actionType, scheduledTime.difference(now), isBox);

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
  static Future<void> _saveScheduledInfoBatch(
      List<TimerScheduleInfo> newInfoList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<TimerScheduleInfo> existingInfoList = await _getScheduledInfoList();

      existingInfoList.addAll(newInfoList);

      final now = AppDateTime.now();
      existingInfoList = existingInfoList
          .where((item) => item.scheduledTime.isAfter(now))
          .toList();

      final jsonList = existingInfoList.map((item) => item.toJson()).toList();
      await prefs.setString(_scheduledInfoKey, jsonEncode(jsonList));

      logger.i(
          'Saved ${newInfoList.length} new timer schedules (total: ${existingInfoList.length})');
    } catch (e) {
      logger.e('Failed to save scheduled info batch: $e');
    }
  }

  /// Schedule a background check to ensure all timers are still active
  static Future<void> _scheduleBackgroundCheck() async {
    try {
      await AndroidAlarmManager.cancel(BACKGROUND_CHECK_ALARM_ID);

      await AndroidAlarmManager.periodic(
        BACKGROUND_CHECK_INTERVAL,
        BACKGROUND_CHECK_ALARM_ID,
        backgroundCheckCallback,
        wakeup: true,
        rescheduleOnReboot: true,
      );

      logger.i(
          'Background check scheduled with interval of ${BACKGROUND_CHECK_INTERVAL.inHours} hours');
    } catch (e) {
      logger.e('Failed to schedule background check: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> backgroundCheckCallback() async {
    print('🔄 BACKGROUND CHECK STARTED at ${DateTime.now()}');

    try {
      if (!(await getToggleFeatureState())) {
        print('❌ Toggle feature is inactive, skipping background check');
        return;
      }
      print('✅ Toggle feature is active');

      bool needsReschedule = await shouldReschedule();
      print('🤔 shouldReschedule() returned: $needsReschedule');

      if (needsReschedule) {
        print('🚨 RESCHEDULING TRIGGERED - About to cancel all timers!');
        await _rescheduleAllTimers();
        print('✅ Rescheduling completed');
        return;
      }

      final scheduledTimers = await _getScheduledInfoList();
      print('📋 Found ${scheduledTimers.length} total scheduled timers');

      if (scheduledTimers.isEmpty) {
        print('🚨 NO TIMERS FOUND - About to reschedule!');
        await _rescheduleAllTimers();
        return;
      }

      final now = AppDateTime.now();
      final futureTimers = scheduledTimers
          .where((timer) => timer.scheduledTime.isAfter(now))
          .toList();
      print('⏰ Found ${futureTimers.length} future timers');

      if (futureTimers.isEmpty) {
        print('🚨 NO FUTURE TIMERS - About to reschedule!');
        await _rescheduleAllTimers();
      } else {
        print('✅ Background check completed - timers are healthy');
        // Print next few timers for visibility
        futureTimers.take(3).forEach((timer) {
          print(
              '   - ${timer.actionType} ${timer.prayerName} at ${timer.scheduledTime}');
        });
      }
    } catch (e) {
      print('💥 BACKGROUND CHECK ERROR: $e');
      print('🚨 ERROR TRIGGERED RESCHEDULE - About to cancel all timers!');
      await _rescheduleAllTimers();
    }

    print('🏁 BACKGROUND CHECK ENDED at ${DateTime.now()}');
  }

  /// Reschedule all timers using saved parameters
  static Future<void> _rescheduleAllTimers() async {
    print('🔄 _rescheduleAllTimers() STARTED');

    try {
      final params = await _getSchedulingParameters();
      print(
          '📝 Retrieved scheduling parameters: ${params != null ? "Found" : "NULL"}');

      if (params != null) {
        print('🗑️ About to CANCEL ALL existing timers');
        await cancelAllScheduledTimers();
        print('✅ All timers cancelled');

        print('🔄 About to reschedule with params: ${params.toString()}');
        await scheduleToggleScreen(
          params['isFajrIshaOnly'],
          List<String>.from(params['timeStrings']),
          params['beforeDelayMinutes'],
          params['afterDelayMinutes'],
        );
        print('✅ Successfully rescheduled all timers');
      } else {
        print('🚨 NO PARAMS FOUND - TIMERS CANCELLED BUT NOT RESCHEDULED!');
      }
    } catch (e) {
      print('💥 RESCHEDULE ERROR: $e');
      print('🚨 RESCHEDULE FAILED - Your timers might be gone!');
    }

    print('🏁 _rescheduleAllTimers() ENDED');
  }

  /// Save scheduling parameters for future rescheduling
  static Future<void> _saveSchedulingParameters(
      bool isFajrIshaOnly,
      List<String> timeStrings,
      int beforeDelayMinutes,
      int afterDelayMinutes) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> params = {
        'isFajrIshaOnly': isFajrIshaOnly,
        'timeStrings': timeStrings,
        'beforeDelayMinutes': beforeDelayMinutes,
        'afterDelayMinutes': afterDelayMinutes,
        'savedAt': DateTime.now().toIso8601String(),
      };

      await prefs.setString(
          TurnOnOffTvConstant.kScheduleParamsKey, jsonEncode(params));
    } catch (e) {
      logger.e('Failed to save scheduling parameters: $e');
    }
  }

  /// Get saved scheduling parameters
  static Future<Map<String, dynamic>?> _getSchedulingParameters() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final paramsString =
          prefs.getString(TurnOnOffTvConstant.kScheduleParamsKey);

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
    print('🤔 shouldReschedule() checking...');

    final lastEventDate = await getLastEventDate();
    final today = AppDateTime.now();
    final isFeatureActive = await getToggleFeatureState();
    final isEventsSet = await checkEventsScheduled();
    final isFajrIshaOnly = await getToggleFeatureishaFajrState();

    print('   - lastEventDate: $lastEventDate');
    print('   - today: $today');
    print('   - isFeatureActive: $isFeatureActive');
    print('   - isEventsSet: $isEventsSet');
    print('   - isFajrIshaOnly: $isFajrIshaOnly');

    if (isFeatureActive && !isEventsSet) {
      print('🚨 RESCHEDULE REASON: Feature active but no events scheduled');
      return true;
    }

    final daysToSchedule =
        isFajrIshaOnly ? FAJR_ISHA_DAYS_TO_SCHEDULE : DEFAULT_DAYS_TO_SCHEDULE;

    if (isFeatureActive && !isEventsSet) {
      logger.i('Rescheduling needed: Feature active but no events scheduled');
      return true;
    }

    if (lastEventDate != null && isFeatureActive) {
      final daysSinceLastSchedule = today.difference(lastEventDate).inDays;
      final rescheduleThreshold = isFajrIshaOnly ? (daysToSchedule - 2) : 1;

      if (daysSinceLastSchedule >= rescheduleThreshold) {
        logger.i(
            'Rescheduling needed: Approaching end of scheduling window (${isFajrIshaOnly ? "Fajr/Isha mode" : "All prayers mode"})');
        return true;
      }

      final lastExecutedEvent = await getLastExecutedEventDate();

      if (lastExecutedEvent == null) {
        final hoursSinceLastSchedule = today.difference(lastEventDate).inHours;
        if (hoursSinceLastSchedule > 24) {
          logger.w('Rescheduling needed: No events have ever executed');
          return true;
        }
      } else {
        final hoursSinceLastExecution =
            today.difference(lastExecutedEvent).inHours;
        if (hoursSinceLastExecution > 24) {
          logger.w(
              'Rescheduling needed: No events executed in the last 24 hours');
          return true;
        }
      }
    }
  print('✅ shouldReschedule() = false');

    return false;
  }

  static Future<void> recordEventExecution() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(TurnOnOffTvConstant.kLastExecutedEventDate,
        DateTime.now().toIso8601String());
  }

  static Future<DateTime?> getLastExecutedEventDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastExecDateString =
        prefs.getString(TurnOnOffTvConstant.kLastExecutedEventDate);
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
    final state =
        prefs.getBool(TurnOnOffTvConstant.kActivateToggleFeature) ?? false;
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
      final mappingKeys = allKeys
          .where((key) => key.startsWith('screen_task_id_mapping_'))
          .toList();

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
    final isEventsSet =
        prefs.getBool(TurnOnOffTvConstant.kIsEventsSet) ?? false;
    return isEventsSet;
  }

  static Future<void> setLastEventDate(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        TurnOnOffTvConstant.kLastEventDate, date.toIso8601String());
  }

  static Future<DateTime?> getLastEventDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastEventDateString =
        prefs.getString(TurnOnOffTvConstant.kLastEventDate);
    if (lastEventDateString != null) {
      return DateTime.parse(lastEventDateString);
    } else {
      return null;
    }
  }
}
