import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:notification_overlay/notification_overlay.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mawaqit/src/const/constants.dart';

class PermissionsManager {
  static const String _permissionsGrantedKey = 'permissions_granted';
  static const String _nativeMethodsChannel = 'nativeMethodsChannel';
  static const int _androidAlarmPermissionSdk = 33;

  /// Checks if permissions have already been granted
  static Future<bool> arePermissionsGranted() async {
    print('🔍 Starting arePermissionsGranted check');
    
    final prefs = await SharedPreferences.getInstance();
    final previouslyGranted = prefs.getBool(_permissionsGrantedKey) ?? false;
    print('📱 Previously granted from SharedPrefs: $previouslyGranted');

    if (await _isDeviceRooted()) {
      return await _handleRootedDevice(prefs, previouslyGranted);
    }

    if (!previouslyGranted) {
      print('❌ SharedPreferences indicates permissions not granted');
      return false;
    }

    return await _verifyCurrentPermissions(prefs);
  }

  /// Check if device is rooted
  static Future<bool> _isDeviceRooted() async {
    final isRooted = await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel)
        .invokeMethod(TurnOnOffTvConstant.kCheckRoot);
    print('🔐 Device rooted: $isRooted');
    return isRooted;
  }

  /// Handle rooted device logic
  static Future<bool> _handleRootedDevice(SharedPreferences prefs, bool previouslyGranted) async {
    print('✅ Device is rooted - assuming all permissions granted');
    if (!previouslyGranted) {
      await prefs.setBool(_permissionsGrantedKey, true);
      print('💾 Updated SharedPrefs to mark permissions as granted');
    }
    return true;
  }

  /// Verify current permission status with system
  static Future<bool> _verifyCurrentPermissions(SharedPreferences prefs) async {
    print('🔄 Verifying current permission status with system...');
    
    final overlayGranted = await _checkOverlayPermission();
    final alarmGranted = await _checkAlarmPermission();
    
    final allGranted = overlayGranted && alarmGranted;
    print('📊 All permissions currently granted: $allGranted (Overlay: $overlayGranted, Alarm: $alarmGranted)');

    if (!allGranted) {
      print('❌ Some permissions were revoked - updating SharedPreferences');
      await prefs.setBool(_permissionsGrantedKey, false);
      return false;
    }

    print('✅ All permissions verified as granted');
    return true;
  }

  /// Check overlay permission status
  static Future<bool> _checkOverlayPermission() async {
    final granted = await NotificationOverlay.checkOverlayPermission();
    print('🔔 Overlay permission currently granted: $granted');
    return granted;
  }

  /// Check alarm permission status
  static Future<bool> _checkAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    print('📱 Android SDK version: ${androidInfo.version.sdkInt}');
    
    if (androidInfo.version.sdkInt >= _androidAlarmPermissionSdk) {
      print('⏰ Checking exact alarm permission (Android 13+)');
      final granted = await MethodChannel(_nativeMethodsChannel)
          .invokeMethod('checkExactAlarmPermission');
      print('⏰ Exact alarm currently granted: $granted');
      return granted;
    } else {
      print('⏰ Android version < 33, skipping exact alarm permission check');
      return true;
    }
  }

  /// Marks permissions as granted in shared preferences
  static Future<void> _markPermissionsAsGranted() async {
    print('💾 Marking permissions as granted in SharedPreferences');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionsGrantedKey, true);
  }

  /// Initialize permissions only if needed
  static Future<void> initializePermissions() async {
    print('🚀 Starting permission initialization');
    
    // Quick check if permissions were already granted previously
    if (await arePermissionsGranted()) {
      print('✅ Permissions were already granted, skipping initialization');
      return;
    }

    print('⚙️ Proceeding with permission initialization...');

    final isRooted = await _isDeviceRooted();
    final deviceModel = await _getDeviceModel();
    print('📱 Device model: $deviceModel');

    // Handle overlay permissions
    print('🔔 Starting overlay permission handling...');
    final overlayGranted = await _handleOverlayPermissions(deviceModel, isRooted);
    print('🔔 Overlay permission result: $overlayGranted');

    // Check for exact alarm permission
    print('⏰ Starting exact alarm permission handling...');
    final alarmPermissionGranted = await _checkAndRequestExactAlarmPermission();
    print('⏰ Exact alarm permission result: $alarmPermissionGranted');

    // Mark permissions as granted only if all permissions were successfully granted
    print('📊 Final permission status - Overlay: $overlayGranted, Alarm: $alarmPermissionGranted');
    
    if (overlayGranted && alarmPermissionGranted) {
      await _markPermissionsAsGranted();
      print('✅ All permissions granted - marked in SharedPreferences');
    } else {
      print('❌ Not all permissions granted - will retry next time');
    }
  }

  /// Handle overlay permissions based on device model and root status
  /// Returns true if permission was granted
  static Future<bool> _handleOverlayPermissions(String deviceModel, bool isRooted) async {
    print('🔔 Starting overlay permission handling for device: $deviceModel, rooted: $isRooted');
    
    final methodChannel = MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel);
    final isPermissionGranted = await NotificationOverlay.checkOverlayPermission();

    // If permission is already granted, return true
    if (isPermissionGranted) {
      print('✅ Overlay permission already granted');
      return true;
    }

    print('🔔 Overlay permission not granted, attempting to grant...');

    // Special handling for ONVO devices
    if (_isOnvoDevice(deviceModel)) {
      return await _handleOnvoOverlayPermission(methodChannel);
    }

    // Handle overlay permission based on root status
    if (isRooted) {
      return await _handleRootedOverlayPermission(methodChannel);
    } else {
      return await _handleUserOverlayPermission();
    }
  }

  /// Check if device is ONVO
  static bool _isOnvoDevice(String deviceModel) {
    return RegExp(r'ONVO.*').hasMatch(deviceModel);
  }

  /// Handle ONVO device overlay permission
  static Future<bool> _handleOnvoOverlayPermission(MethodChannel methodChannel) async {
    print('📱 ONVO device detected - using special method');
    try {
      await methodChannel.invokeMethod("grantOnvoOverlayPermission");
      print('✅ ONVO overlay permission granted successfully');
      return true;
    } catch (e) {
      print('❌ Failed to grant ONVO overlay permission: $e');
      return false;
    }
  }

  /// Handle rooted device overlay permission
  static Future<bool> _handleRootedOverlayPermission(MethodChannel methodChannel) async {
    print('🔐 Rooted device - attempting root permission grant');
    try {
      await methodChannel.invokeMethod("grantOverlayPermission");
      print('✅ Overlay permission granted with root successfully');
      return true;
    } catch (e) {
      print('❌ Failed to grant overlay permission with root: $e');
      return false;
    }
  }

  /// Handle user overlay permission request
  static Future<bool> _handleUserOverlayPermission() async {
    print('📱 Non-rooted device - requesting permission from user');
    final granted = await NotificationOverlay.requestOverlayPermission();
    print('🔔 User overlay permission request result: $granted');
    return granted;
  }

  /// Get device model information
  static Future<String> _getDeviceModel() async {
    final hardware = await DeviceInfoPlugin().androidInfo;
    return hardware.model;
  }

  /// Check and request exact alarm permissions if needed (Android 13+)
  /// Returns true if permission is granted or not needed
  static Future<bool> _checkAndRequestExactAlarmPermission() async {
    print('⏰ Starting exact alarm permission check');
    
    if (!Platform.isAndroid) {
      print('⏰ Not Android platform - skipping exact alarm permission');
      return true;
    }

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    
    print('⏰ Android SDK version: $sdkInt');
    print('⏰ Android release: ${androidInfo.version.release}');

    // Only needed for Android 13 (API level 33) and above
    if (sdkInt >= _androidAlarmPermissionSdk) {
      return await _requestExactAlarmPermission();
    } else {
      print('⏰ Android version < $_androidAlarmPermissionSdk (API $_androidAlarmPermissionSdk) - exact alarm permission not required');
      return true;
    }
  }

  /// Request exact alarm permission for Android 13+
  static Future<bool> _requestExactAlarmPermission() async {
    print('⏰ Android 13+ detected - checking exact alarm permission');
    
    try {
      // First check if permission is already granted using native method
      final canSchedule = await MethodChannel(_nativeMethodsChannel)
          .invokeMethod('checkExactAlarmPermission');
      print('⏰ Native permission check result: $canSchedule');

      if (canSchedule) {
        print('✅ Exact alarm permission already granted');
        return true;
      }

      print('⏰ Exact alarm permission not granted - requesting permission');
      final requestResult = await MethodChannel(_nativeMethodsChannel)
          .invokeMethod('requestExactAlarmPermission');
      print('⏰ Permission request result: $requestResult');

      if (requestResult) {
        print('📱 Permission settings opened successfully - user needs to grant manually');
        return false; // Return false because user needs to grant manually and app will check again later
      } else {
        print('❌ Failed to open permission settings');
        return false;
      }
      
    } catch (e) {
      print('❌ Error checking/requesting exact alarm permission: $e');
      print('❌ Exception type: ${e.runtimeType}');
      print('❌ Exception details: ${e.toString()}');
      return false;
    }
  }

}
