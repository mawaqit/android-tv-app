import 'package:flutter/material.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/helpers/TimeShiftManager.dart';
import 'package:screen_control/screen_control.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().executeTask((taskName, inputData) async {
    try {
      switch (taskName) {
        case 'screenOn':
          if (TimeShiftManager().isLauncherInstalled) {
            await ScreenControl.toggleBoxScreenOn();
          } else {
            await ScreenControl.toggleTabletScreenOn();
          }
          break;

        case 'screenOff':
          if (TimeShiftManager().isLauncherInstalled) {
            await ScreenControl.toggleBoxScreenOff();
          } else {
            await ScreenControl.toggleTabletScreenOff();
          }
          break;

        case 'prayer_task':
          final service = FlutterBackgroundService();
          print('Prayer task triggered at ${DateTime.now()}');
          print('Prayer data: $inputData');
          if (inputData != null) {
            service.invoke('prayerTime', inputData);
          }
          break;
      }
      return true;
    } catch (e) {
      logger.e('work manager task error: $e');
      return false;
    }
  });
}
