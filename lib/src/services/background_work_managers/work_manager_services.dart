import 'dart:convert';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/domain/error/screen_on_off_exceptions.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mawaqit/src/helpers/TimeShiftManager.dart';
import 'package:mawaqit/src/services/toggle_screen_feature_manager.dart';
import 'package:screen_control/screen_control.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void prayerAlarmCallback(int id) async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Retrieve stored prayer data
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString('alarm_data_$id');

    if (dataString != null) {
      final Map<String, dynamic> inputData = jsonDecode(dataString);

      // Use the background service the same way you did with WorkManager
      final service = FlutterBackgroundService();
      logger.i('Prayer task triggered at ${DateTime.now()}');
      logger.i('Prayer data: $inputData');

      service.invoke('prayerTime', inputData);
    }
  } catch (e) {
    logger.e('Prayer alarm callback error: $e');
  }
}

// Screen on callback
@pragma('vm:entry-point')
void screenOnCallback(int id) async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await ScreenControl.toggleBoxScreenOn();
    ToggleScreenFeature.recordEventExecution();

    logger.i('Screen turned ON at ${DateTime.now()}');
  } catch (e) {
    logger.e('Screen ON alarm callback error: $e');
  }
}

@pragma('vm:entry-point')
void screenOnTabletCallback(int id) async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await ScreenControl.toggleTabletScreenOn();
    ToggleScreenFeature.recordEventExecution();

    logger.i('Screen turned ON at ${DateTime.now()}');
  } catch (e) {
    logger.e('Screen ON alarm callback error: $e');
  }
}

// Screen off callback
@pragma('vm:entry-point')
void screenOffCallback(int id) async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await ScreenControl.toggleBoxScreenOff();
    ToggleScreenFeature.recordEventExecution();
    logger.i('Screen turned OFF at ${DateTime.now()}');
  } catch (e) {
    logger.e('Screen OFF alarm callback error: $e');
  }
}

@pragma('vm:entry-point')
void screenOffTabletCallback(int id) async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await ScreenControl.toggleTabletScreenOff();
    ToggleScreenFeature.recordEventExecution();

    logger.i('Screen turned OFF at ${DateTime.now()}');
  } catch (e) {
    logger.e('Screen OFF alarm callback error: $e');
  }
}

@pragma('vm:entry-point')
class WorkManagerService {
  static bool _isInitialized = false;

  @pragma('vm:entry-point')
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize AlarmManager
      _isInitialized = await AndroidAlarmManager.initialize();

      if (!_isInitialized) {
        logger.e('AlarmManager initialization failed');
      } else {
        logger.i('AlarmManager initialized successfully');
      }
    } catch (e) {
      logger.e('AlarmManager initialization error: $e');
    }
  }

  @pragma('vm:entry-point')
  void backgroundCheckCallback(int id) async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      logger.i('Background check started at ${DateTime.now()}');
      await ToggleScreenFeature.backgroundCheckCallback();
    } catch (e) {
      logger.e('Background check error: $e');
    }
  }

  // Prayer task using AlarmManager
  @pragma('vm:entry-point')
  static Future<void> registerPrayerTask(String uniqueId, Map<String, dynamic> inputData, Duration initialDelay) async {
    try {
      // Convert uniqueId to integer ID for AlarmManager
      final int alarmId = uniqueId.hashCode;

      // Store prayer data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('alarm_data_$alarmId', jsonEncode(inputData));

      // Store mapping for later cancellation
      await prefs.setString('id_mapping_$uniqueId', alarmId.toString());

      // Calculate exact time for the alarm
      final scheduledTime = DateTime.now().add(initialDelay);

      logger.i('Scheduling prayer alarm for: ${scheduledTime.toString()}');
      logger.i('Prayer data: $inputData');

      // Schedule alarm with exact timing
      final bool success = await AndroidAlarmManager.oneShotAt(
        scheduledTime,
        alarmId,
        prayerAlarmCallback,
        wakeup: true,
        alarmClock: true,
        rescheduleOnReboot: true,
      );

      if (!success) {
        throw SchedulePrayerTimeException('Failed to schedule prayer alarm');
      }

      logger.i('Prayer alarm scheduled successfully with ID: $alarmId');
    } catch (e) {
      logger.e('Failed to register prayer task: $e');
      throw SchedulePrayerTimeException(e.toString());
    }
  }

  // Screen task using AlarmManager
  @pragma('vm:entry-point')
  static Future<void> registerScreenTask(String uniqueId, String taskName, Duration initialDelay, bool isBox) async {
    try {
      // Convert uniqueId to integer ID for AlarmManager
      final int alarmId = ('screen_$uniqueId').hashCode;

      // Store mapping for later cancellation
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('screen_task_id_mapping_$uniqueId', alarmId.toString());

      // Calculate exact time for the alarm
      final scheduledTime = DateTime.now().add(initialDelay);

      logger.i('Scheduling $taskName for: ${scheduledTime.toString()}');

      // Choose the appropriate callback based on task name
      final callback = taskName == 'screenOn'
          ? (isBox ? screenOnCallback : screenOnTabletCallback)
          : (isBox ? screenOffCallback : screenOffTabletCallback);

      // Schedule alarm
      final bool success = await AndroidAlarmManager.oneShotAt(
        scheduledTime,
        alarmId,
        callback,
        wakeup: true,
        alarmClock: true,
        rescheduleOnReboot: true,
      );

      if (!success) {
        throw ScheduleToggleScreenException('Failed to schedule $taskName alarm');
      }

      logger.i('$taskName alarm scheduled successfully with ID: $alarmId');
    } catch (e) {
      logger.e('Failed to register screen task: $e');
      throw ScheduleToggleScreenException(e.toString());
    }
  }

  @pragma('vm:entry-point')
  static Future<void> cancelTask(String uniqueId) async {
    try {
      // Get the alarm ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final alarmIdString = prefs.getString('id_mapping_$uniqueId');

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
        await prefs.remove('id_mapping_$uniqueId');
      } else {
        logger.w('No alarm ID found for uniqueId: $uniqueId');
      }
    } catch (e) {
      logger.e('Failed to cancel task: $e');
      throw ScheduleToggleScreenException(e.toString());
    }
  }
}
