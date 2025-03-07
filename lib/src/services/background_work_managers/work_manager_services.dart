import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/domain/error/screen_on_off_exceptions.dart';
import 'package:mawaqit/src/services/background_work_managers/workmanager_callback.dart';
import 'package:workmanager/workmanager.dart';

class WorkManagerService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Workmanager().initialize(callbackDispatcher);
      _isInitialized = true;
    } catch (e) {
      logger.e('WorkManager initialization error: $e');
    }
  }

  static Future<void> registerPrayerTask(String uniqueId, Map<String, dynamic> inputData, Duration initialDelay) async {
    try {
      await Workmanager().registerOneOffTask(
        uniqueId,
        'prayer_task',
        inputData: inputData,
        initialDelay: initialDelay,
        constraints: Constraints(
            networkType: NetworkType.not_required,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
    } catch (e) {
      throw SchedulePrayerTimeException(e.toString());
    }
  }

  static Future<void> registerScreenTask(String uniqueId, String taskName, Duration initialDelay) async {
    try {
      await Workmanager().registerOneOffTask(
        uniqueId,
        taskName,
        initialDelay: initialDelay,
        constraints: Constraints(
            networkType: NetworkType.not_required,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
    } catch (e) {
      throw ScheduleToggleScreenException(e.toString());
    }
  }

  static Future<void> cancelTask(String uniqueId) async {
    try {
      await Workmanager().cancelByUniqueName(uniqueId);
    } catch (e) {
      throw ScheduleToggleScreenException(e.toString());
    }
  }
}
