import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/main.dart';

class BatteryOptimizationHelper {
  static Future<bool> isBatteryOptimizationDisabled() async {
    try {
      return await DisableBatteryOptimization.isBatteryOptimizationDisabled ?? false;
    } catch (e) {
      logger.e('Error checking battery optimization: $e');
      return false;
    }
  }

  static Future<void> requestDisableBatteryOptimization() async {
    try {
      await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
    } catch (e) {
      logger.e('Error requesting battery optimization exemption: $e');
    }
  }

  static Future<bool> showBatteryOptimizationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.battery_alert, color: Colors.orange),
                SizedBox(width: 8),
                Text(S.of(context).batteryOptimization),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).batteryOptimizationDesc,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(S.of(context).skip),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  requestDisableBatteryOptimization();
                },
                child: Text(S.of(context).openSettings),
              ),
            ],
          ),
        ) ??
        false;
  }

  static Future<void> checkAndHandleBatteryOptimization(BuildContext context) async {
    final bool isOptimized = !(await isBatteryOptimizationDisabled());

    if (isOptimized) {
      logger.w('Battery optimization is enabled - showing user dialog');
      await showBatteryOptimizationDialog(context);
    } else {
      logger.i('Battery optimization is already disabled - alarms should work reliably');
    }
  }
}
