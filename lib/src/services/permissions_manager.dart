import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:notification_overlay/notification_overlay.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mawaqit/src/const/constants.dart';

class PermissionsManager {
  static const String _permissionsGrantedKey = 'permissions_granted';

  /// Checks if permissions have already been granted
  static Future<bool> arePermissionsGranted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionsGrantedKey) ?? false;
  }

  /// Marks permissions as granted in shared preferences
  static Future<void> _markPermissionsAsGranted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionsGrantedKey, true);
  }

  /// Initialize permissions only if needed
  static Future<void> initializePermissions() async {
    // Quick check if permissions were already granted previously
    if (await arePermissionsGranted()) {
      developer.log('Permissions were already granted, skipping initialization');
      return;
    }

    final isRooted =
        await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel).invokeMethod(TurnOnOffTvConstant.kCheckRoot);
    final deviceModel = await _getDeviceModel();

    // Handle overlay permissions
    final overlayGranted = await _handleOverlayPermissions(deviceModel, isRooted);

    // Check for exact alarm permission
    final alarmPermissionGranted = await _checkAndRequestExactAlarmPermission();

    // Mark permissions as granted only if all permissions were successfully granted
    if (overlayGranted && alarmPermissionGranted) {
      await _markPermissionsAsGranted();
    }
  }

  /// Handle overlay permissions based on device model and root status
  /// Returns true if permission was granted
  static Future<bool> _handleOverlayPermissions(String deviceModel, bool isRooted) async {
    final methodChannel = MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel);
    final isPermissionGranted = await NotificationOverlay.checkOverlayPermission();

    // If permission is already granted, return true
    if (isPermissionGranted) {
      return true;
    }

    // Special handling for ONVO devices
    if (RegExp(r'ONVO.*').hasMatch(deviceModel)) {
      try {
        await methodChannel.invokeMethod("grantOnvoOverlayPermission");
        return true;
      } catch (e) {
        developer.log('Failed to grant ONVO overlay permission: $e');
        return false;
      }
    }

    // Handle overlay permission based on root status
    if (isRooted) {
      try {
        await methodChannel.invokeMethod("grantOverlayPermission");
        return true;
      } catch (e) {
        developer.log('Failed to grant overlay permission with root: $e');
        return false;
      }
    } else {
      // Request permission from user
      final granted = await NotificationOverlay.requestOverlayPermission();
      return granted;
    }
  }

  /// Get device model information
  static Future<String> _getDeviceModel() async {
    var hardware = await DeviceInfoPlugin().androidInfo;
    return hardware.model;
  }

  /// Check and request exact alarm permissions if needed (Android 12+)
  /// Returns true if permission is granted or not needed
  static Future<bool> _checkAndRequestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    // Only needed for Android 12 (API level 31) and above
    if (androidInfo.version.sdkInt >= 33) {
      final status = await Permission.scheduleExactAlarm.status;

      if (status.isDenied) {
        final result = await Permission.scheduleExactAlarm.request();

        if (result.isDenied) {
          developer.log('Exact alarm permission denied by user');
          return false;
        }
      }
    }

    return true;
  }

  /// Force re-initialization of permissions (use this if you need to request again)
  static Future<void> resetPermissionsStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionsGrantedKey, false);
    developer.log('Permission status reset - will request permissions on next app launch');
  }
}
