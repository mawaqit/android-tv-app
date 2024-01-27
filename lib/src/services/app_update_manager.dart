import 'dart:async';
import 'dart:io';

import 'package:app_installer/app_installer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../data/constants.dart';
import '../helpers/AppDate.dart';
import 'mosque_manager.dart';

enum AppUpdateState {
  idle,
  loading,
  error,
  updateAvailable,
  updateNotAvailable,
  updateInProgress,
  updateDownloaded,
  userCancelled,
}

class AppUpdateManager extends AsyncNotifier<AppUpdateState> {
  late final AppUpdateInfo _updateInfo;

  @override
  Future<AppUpdateState> build() async {
    try {
      _updateInfo = await InAppUpdate.checkForUpdate();
    } catch (e) {
      throw Exception('Error checking for update $e');
    }
    if (_updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
      return AppUpdateState.idle;
    } else {
      return AppUpdateState.updateNotAvailable;
    }
  }

  /// [settingsUpdate] checks for an update and returns the state of the update.
  Stream<InstallStatus> get installUpdateStream {
    return InAppUpdate.installUpdateListener;
  }

  /// [settingsUpdate] checks for an update and returns the state of the update.
  /// If an update is available, it will be downloaded in the background.
  Future<void> settingsUpdate() async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (_checkForUpdate()) {
        return InAppUpdate.startFlexibleUpdate().then((result) async {
          if (result == AppUpdateResult.success) {
            return AppUpdateState.updateDownloaded;
          } else if (result == AppUpdateResult.inAppUpdateFailed) {
            return AppUpdateState.error;
          } else if (result == AppUpdateResult.userDeniedUpdate) {
            return AppUpdateState.userCancelled;
          }
          return AppUpdateState.idle;
        }).catchError((e) {
          return AppUpdateState.error;
        });
      }
      return AppUpdateState.idle;
    });
  }

  /// [installUpdate] installs the update if it has been downloaded.
  /// full screen update
  Future<void> installUpdate() async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (_checkForUpdate()) {
        await InAppUpdate.performImmediateUpdate();
        return AppUpdateState.updateDownloaded;
      }
      return AppUpdateState.idle;
    });
  }

  /// [scheduleUpdate] Defines an asynchronous method for scheduling an app update.
  Future<void> scheduleUpdate() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();

      // Retrieves the timestamp of the last popup display from SharedPreferences, defaulting to 0 if not set.
      final lastPopupDisplay = sharedPreferences.getInt('last_popup_display') ?? 0;

      logger.i('Last popup display: $lastPopupDisplay');
      // Calculates the timestamp for one week ago.
      final oneWeekAgo = DateTime.now().subtract(Duration(days: 7)).millisecondsSinceEpoch;

      // Waits for the mosqueManagerProvider to complete its future and then watches its changes.
      await ref.read(mosqueManagerProvider.future);
      final mosqueManager = ref.watch(mosqueManagerProvider);

      // Handles the mosque manager data and handles the case where mosqueManager is null.
      mosqueManager.maybeWhen(
        orElse: () {
          logger.e('mosqueManager is null');
        },
        data: (mosqueManager) async {
          // Retrieves the prayer times from the mosqueManager.
          final prayerTimes = mosqueManager.times;

          // Checks if prayer times data is available, logs error and returns if not.
          if (prayerTimes == null) {
            logger.e('prayerTimes is null');
            return;
          }

          // Determines the current time, considering whether to use tomorrow's times based on the mosqueManager's state.
          final timeNow = mosqueManager.useTomorrowTimes ? AppDateTime.tomorrow() : AppDateTime.now();

          // Retrieves the day's prayer times based on the current time.
          final times = mosqueManager.times!.dayTimes(timeNow);

          // Logs various timestamps for debugging purposes.
          logger.d(
              'update: times: $times \n time now $timeNow \n last Popup Display: $lastPopupDisplay \n one week ago: $oneWeekAgo');

          // Checks if the current time is within a specific time window between two prayer times.
          // Also checks if the last popup display was more than a week ago.
          if (timeNow.isAfter(times[3]) &&
              timeNow.isBefore(times[4]) &&
              timeNow.millisecondsSinceEpoch >= lastPopupDisplay + oneWeekAgo) {
            // Updates the 'last_popup_display' timestamp in SharedPreferences to the current time.
            final check = await sharedPreferences.setInt('last_update', DateTime.now().millisecondsSinceEpoch);
            logger.d('update: check: $check');

            // Initiates the installation of the update.
            await installUpdate();
          }
        },
      );
    } catch (e) {
      // Logs any errors that occur during the update scheduling process.
      logger.e('error in scheduleUpdate $e');
    }
  }

  /// [downloadAndInstallApk] installs the APK from the provided URL.
  Future<void> downloadAndInstallApk(String url, String apkName) async {
    try {
      logger.i('Update: Downloading and installing the APK');
      await _requestPermissions();
      String apkPath = await _downloadApk(url, apkName);
      if (apkPath.isNotEmpty) {
        const platform = MethodChannel(updateApkMethodChannel);
        await platform.invokeMethod('installApk', {'apkPath': apkPath});
      } else {
        throw Exception('Error apk path is empty');
      }
    } catch (e) {
      logger.e('Error downloading and installing the APK: $e');
    }
  }


  /// [_checkForUpdate] Private method to check for update availability.
  bool _checkForUpdate() {
    if (_updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
      return true;
    } else {
      throw Exception('No update available');
    }
  }

  /// [_requestPermissions] requests the required permissions for the update.
  /// Currently only storage permissions are required.
  Future<void> _requestPermissions() async {
    try {
      await [Permission.storage].request();
    } catch (e) {
      throw Exception('Error requesting permissions.');
    }
  }

  /// [_downloadApk] downloads the APK from the provided URL and returns the path to the downloaded file.
  /// The file is downloaded to the application cache directory.
  Future<String> _downloadApk(String url, String fileName) async {
    Dio dio = Dio();
    try {
      // Get the application cache directory
      var dir = await getApplicationCacheDirectory();
      String apkPath = '${dir?.path}/mawaqit.apk';

      // If the file already exists, return the path
      File file = File(apkPath);
      if (await file.exists()) {
        return apkPath;
      }

      // if the file doesn't exist, download it
      await dio.download(
        url,
        apkPath,
      );
      return apkPath;
    } catch (e) {
      throw Exception('Error downloading the APK.');
    }
  }
}

final appUpdateManagerProvider = AsyncNotifierProvider<AppUpdateManager, AppUpdateState>(AppUpdateManager.new);
