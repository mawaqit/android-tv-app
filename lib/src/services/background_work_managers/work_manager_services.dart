import 'dart:convert';
import 'dart:io';

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

  print('🔔 PRAYER ALARM CALLBACK STARTED - ID: $id at ${DateTime.now()}');

  try {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString('alarm_data_$id');

    if (dataString != null) {
      final Map<String, dynamic> inputData = jsonDecode(dataString);
      final service = FlutterBackgroundService();
      print('📿 Prayer task triggered successfully - ID: $id');
      print('📿 Prayer data: $inputData');
      service.invoke('prayerTime', inputData);

      // Record execution for debugging
      await _recordAlarmExecution('PRAYER', id);
    } else {
      print('❌ Prayer alarm data not found for ID: $id');
    }
  } catch (e, stackTrace) {
    print('💥 Prayer alarm callback FAILED - ID: $id, Error: $e');
    print('Stack trace: $stackTrace');
  }

  print('✅ PRAYER ALARM CALLBACK COMPLETED - ID: $id');
}

@pragma('vm:entry-point')
void screenOnCallback(int id) async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🔔 SCREEN ON CALLBACK STARTED - ID: $id at ${DateTime.now()}');

  try {
    print('📱 Attempting to turn screen ON...');
    await ScreenControl.toggleBoxScreenOn();
    print('📱 Screen turned ON successfully');

    ToggleScreenFeature.recordEventExecution();
    print('📊 Event execution recorded');

    // Record execution for debugging
    await _recordAlarmExecution('SCREEN_ON_BOX', id);

    print('✅ Screen ON completed successfully - ID: $id');
  } catch (e, stackTrace) {
    print('💥 Screen ON FAILED - ID: $id, Error: $e');
    print('Stack trace: $stackTrace');
  }

  print('✅ SCREEN ON CALLBACK COMPLETED - ID: $id');
}

@pragma('vm:entry-point')
void screenOnTabletCallback(int id) async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🔔 SCREEN ON TABLET CALLBACK STARTED - ID: $id at ${DateTime.now()}');

  try {
    print('📱 Attempting to turn tablet screen ON...');
    await ScreenControl.toggleTabletScreenOn();
    print('📱 Tablet screen turned ON successfully');

    ToggleScreenFeature.recordEventExecution();
    print('📊 Event execution recorded');

    // Record execution for debugging
    await _recordAlarmExecution('SCREEN_ON_TABLET', id);

    print('✅ Tablet screen ON completed successfully - ID: $id');
  } catch (e, stackTrace) {
    print('💥 Tablet screen ON FAILED - ID: $id, Error: $e');
    print('Stack trace: $stackTrace');
  }

  print('✅ SCREEN ON TABLET CALLBACK COMPLETED - ID: $id');
}

@pragma('vm:entry-point')
void screenOffCallback(int id) async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🔔 SCREEN OFF CALLBACK STARTED - ID: $id at ${DateTime.now()}');

  try {
    print('📱 Attempting to turn screen OFF...');
    await ScreenControl.toggleBoxScreenOff();
    print('📱 Screen turned OFF successfully');

    ToggleScreenFeature.recordEventExecution();
    print('📊 Event execution recorded');

    // Record execution for debugging
    await _recordAlarmExecution('SCREEN_OFF_BOX', id);

    print('✅ Screen OFF completed successfully - ID: $id');
  } catch (e, stackTrace) {
    print('💥 Screen OFF FAILED - ID: $id, Error: $e');
    print('Stack trace: $stackTrace');
  }

  print('✅ SCREEN OFF CALLBACK COMPLETED - ID: $id');
}

@pragma('vm:entry-point')
void screenOffTabletCallback(int id) async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🔔 SCREEN OFF TABLET CALLBACK STARTED - ID: $id at ${DateTime.now()}');

  try {
    print('📱 Attempting to turn tablet screen OFF...');
    await ScreenControl.toggleTabletScreenOff();
    print('📱 Tablet screen turned OFF successfully');

    ToggleScreenFeature.recordEventExecution();
    print('📊 Event execution recorded');

    // Record execution for debugging
    await _recordAlarmExecution('SCREEN_OFF_TABLET', id);

    print('✅ Tablet screen OFF completed successfully - ID: $id');
  } catch (e, stackTrace) {
    print('💥 Tablet screen OFF FAILED - ID: $id, Error: $e');
    print('Stack trace: $stackTrace');
  }

  print('✅ SCREEN OFF TABLET CALLBACK COMPLETED - ID: $id');
}

// Helper function to record alarm executions for debugging
Future<void> _recordAlarmExecution(String type, int id) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final key = 'alarm_execution_${type}_$id';
    await prefs.setString(key, now.toIso8601String());
    print('📝 Recorded execution: $type ID:$id at $now');
  } catch (e) {
    print('❌ Failed to record execution: $e');
  }
}

@pragma('vm:entry-point')
class WorkManagerService {
  static bool _isInitialized = false;

  @pragma('vm:entry-point')
  static Future<void> initialize() async {
    if (_isInitialized) return;

    print('🚀 Initializing AlarmManager...');

    try {
      _isInitialized = await AndroidAlarmManager.initialize();

      if (!_isInitialized) {
        print('❌ AlarmManager initialization failed');
      } else {
        print('✅ AlarmManager initialized successfully');
      }
    } catch (e, stackTrace) {
      print('💥 AlarmManager initialization error: $e');
      print('Stack trace: $stackTrace');
    }
  }

  static int _alarmCounter = 0;

  static int _generateUniqueAlarmId() {
    final baseId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final uniqueId = (baseId + (++_alarmCounter)) % 2147483647;
    print('🔢 Generated alarm ID: $uniqueId (counter: $_alarmCounter)');
    return uniqueId;
  }

  @pragma('vm:entry-point')
  static Future<void> registerPrayerTask(String uniqueId, Map<String, dynamic> inputData, Duration initialDelay) async {
    print('📅 Starting to register prayer task - UniqueID: $uniqueId');

    try {
      final int alarmId = _generateUniqueAlarmId();
      final scheduledTime = DateTime.now().add(initialDelay);

      print('⏰ Prayer alarm details:');
      print('   - Alarm ID: $alarmId');
      print('   - Unique ID: $uniqueId');
      print('   - Scheduled for: $scheduledTime');
      print('   - Delay: ${initialDelay.inMinutes} minutes');
      print('   - Data: $inputData');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('alarm_data_$alarmId', jsonEncode(inputData));
      await prefs.setString('id_mapping_$uniqueId', alarmId.toString());

      // Store scheduling info for debugging
      await prefs.setString('alarm_scheduled_$alarmId', scheduledTime.toIso8601String());

      final bool success = await AndroidAlarmManager.oneShotAt(
        scheduledTime,
        alarmId,
        prayerAlarmCallback,
        wakeup: true,
        alarmClock: true,
        rescheduleOnReboot: true,
        allowWhileIdle: true,
        exact: true,
      );

      if (!success) {
        print('❌ Prayer alarm scheduling returned false');
        throw SchedulePrayerTimeException('Failed to schedule prayer alarm');
      }

      print('✅ Prayer alarm scheduled successfully with ID: $alarmId');
    } catch (e, stackTrace) {
      print('💥 Failed to register prayer task: $e');
      print('Stack trace: $stackTrace');
      throw SchedulePrayerTimeException(e.toString());
    }
  }

  @pragma('vm:entry-point')
  static Future<void> registerScreenTask(String uniqueId, String taskName, Duration initialDelay, bool isBox) async {
    print('📱 Starting to register screen task - UniqueID: $uniqueId, Task: $taskName');

    try {
      final int alarmId = _generateUniqueAlarmId();
      final scheduledTime = DateTime.now().add(initialDelay);

      print('⏰ Screen alarm details:');
      print('   - Alarm ID: $alarmId');
      print('   - Unique ID: $uniqueId');
      print('   - Task: $taskName');
      print('   - Device type: ${isBox ? 'Box' : 'Tablet'}');
      print('   - Scheduled for: $scheduledTime');
      print('   - Delay: ${initialDelay.inMinutes} minutes');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('screen_task_id_mapping_$uniqueId', alarmId.toString());

      // Store scheduling info for debugging
      await prefs.setString('alarm_scheduled_$alarmId', scheduledTime.toIso8601String());
      await prefs.setString('alarm_task_$alarmId', taskName);

      final callback = taskName == 'screenOn'
          ? (isBox ? screenOnCallback : screenOnTabletCallback)
          : (isBox ? screenOffCallback : screenOffTabletCallback);

      final bool success = await AndroidAlarmManager.oneShotAt(
        scheduledTime,
        alarmId,
        callback,
        wakeup: true,
        alarmClock: true,
        rescheduleOnReboot: true,
        allowWhileIdle: true,
        exact: true,
      );

      if (!success) {
        print('❌ Screen alarm scheduling returned false');
        throw ScheduleToggleScreenException('Failed to schedule $taskName alarm');
      }

      print('✅ $taskName alarm scheduled successfully with ID: $alarmId');
    } catch (e, stackTrace) {
      print('💥 Failed to register screen task: $e');
      print('Stack trace: $stackTrace');
      throw ScheduleToggleScreenException(e.toString());
    }
  }

  @pragma('vm:entry-point')
  static Future<void> cancelTask(String uniqueId) async {
    print('🗑️ Starting to cancel task - UniqueID: $uniqueId');

    try {
      final prefs = await SharedPreferences.getInstance();
      final alarmIdString = prefs.getString('id_mapping_$uniqueId');

      if (alarmIdString != null) {
        final int alarmId = int.parse(alarmIdString);
        print('🎯 Found alarm ID: $alarmId for uniqueId: $uniqueId');

        final bool success = await AndroidAlarmManager.cancel(alarmId);

        if (success) {
          print('✅ Alarm cancelled successfully: $alarmId');
        } else {
          print('⚠️ Failed to cancel alarm: $alarmId');
        }

        // Clean up all related data
        await prefs.remove('alarm_data_$alarmId');
        await prefs.remove('id_mapping_$uniqueId');
        await prefs.remove('alarm_scheduled_$alarmId');
        await prefs.remove('alarm_task_$alarmId');

        print('🧹 Cleaned up alarm data for ID: $alarmId');
      } else {
        print('⚠️ No alarm ID found for uniqueId: $uniqueId');
      }
    } catch (e, stackTrace) {
      print('💥 Failed to cancel task: $e');
      print('Stack trace: $stackTrace');
      throw ScheduleToggleScreenException(e.toString());
    }
  }

  // Debug helper method to check alarm execution history
  static Future<void> printAlarmExecutionHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      print('📊 ALARM EXECUTION HISTORY:');

      for (final key in keys) {
        if (key.startsWith('alarm_execution_')) {
          final value = prefs.getString(key);
          print('   $key: $value');
        }
      }

      print('📋 ALARM SCHEDULING HISTORY:');

      for (final key in keys) {
        if (key.startsWith('alarm_scheduled_')) {
          final value = prefs.getString(key);
          final taskKey = key.replaceFirst('scheduled', 'task');
          final task = prefs.getString(taskKey) ?? 'UNKNOWN';
          print('   $key ($task): $value');
        }
      }
    } catch (e) {
      print('❌ Failed to print alarm history: $e');
    }
  }
}
