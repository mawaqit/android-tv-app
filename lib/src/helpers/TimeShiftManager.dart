import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import 'package:flutter/services.dart';

import 'Api.dart';

// TimeShiftManager is a singleton class responsible for managing time adjustments,
// particularly handling time shifts and periodic adjustments. It utilizes shared preferences
// for data persistence, allowing the application to maintain state across sessions.
class TimeShiftManager {
  static final TimeShiftManager _instance = TimeShiftManager._internal();

  int _shift = 0;
  int _shiftinMinutes = 0;
  DateTime _adjustedTime = DateTime.now();
  DateTime _previousTime = DateTime.now();
  bool _timeSetFromHour = false;
  bool _timeSetManualy = false;
  bool _isLauncherInstalled = false;
  String _deviceModel = "";
  int _shiftedhours = 0;
  static const String _shiftKey = 'shift';
  static const String _shiftInMinutesKey = 'shiftInMinutes';
  static const String _adjustedTimeKey = 'adjustedTime';
  static const String _previousTimeKey = 'previousTime';
  static const String _shiftedhoursKey = 'shiftedhours';
  static const String _timeSetManualyKey = 'timeSetManualy';

  factory TimeShiftManager() => _instance;

  Future<bool> isPackageInstalled(String packageName) async {
    try {
      final result = await MethodChannel('nativeMethodsChannel')
          .invokeMethod('isPackageInstalled', {'packageName': packageName});
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  TimeShiftManager._internal() {
    initializeTimes();

    startPeriodicTimer();
  }

  // Initialize time-related properties from shared preferences or current time.
  Future<void> initializeTimes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _shift = prefs.getInt(_shiftKey) ?? 0;
    _shiftedhours = prefs.getInt(_shiftedhoursKey) ?? 0;
    _shiftinMinutes = prefs.getInt(_shiftInMinutesKey) ?? 0;
    _timeSetManualy = prefs.getBool(_timeSetManualyKey) ?? false;
    _adjustedTime = DateTime.parse(
        prefs.getString(_adjustedTimeKey) ?? DateTime.now().toIso8601String());
    _previousTime = DateTime.parse(
        prefs.getString(_previousTimeKey) ?? DateTime.now().toIso8601String());
    _isLauncherInstalled = await isPackageInstalled("com.mawaqit.launcher");
    try {
      final userData = await Api.prepareUserData();
      if (userData != null) {
        _deviceModel = userData.$2['model'];
      }
    } catch (e, stackTrace) {
      logger.e('Error fetching user data: $e', stackTrace: stackTrace);
    }
  }

  // Start a periodic timer for time adjustments, triggered every 30 seconds.
  void startPeriodicTimer() {
    const Duration period = Duration(seconds: 30);

    Timer.periodic(period, (Timer timer) {
      if (!_timeSetFromHour &&
          _isLauncherInstalled &&
          _deviceModel == "MAWABOX" &&
          !_timeSetManualy) {
        adjustTime();
      }
    });
  }

  // Perform time adjustments based on timezone changes and hourly differences.
  Future<void> adjustTime() async {
    try {
      DateTime currentTime = DateTime.now();

      const Duration timeThreshold = Duration(seconds: 30);

      // Save previous time if it is within the specified time threshold.
      if (_previousTime.isAfter(currentTime.subtract(timeThreshold)) &&
          _previousTime.isBefore(currentTime.add(timeThreshold))) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(_previousTimeKey, _previousTime.toIso8601String());
      } else {
        print("Not within the time threshold");
      }

      // Check if the hour has changed for adjusting time.
      if (currentTime.hour != _previousTime.hour) {
        int hourDifference = currentTime.hour - _previousTime.hour;
        if (hourDifference == 1) _shiftedhours++;
        // Calculate shift based on the hourly difference.
        if (_shiftedhours == 2) {
          _shift = -1;
          _adjustedTime = _adjustedTime.subtract(Duration(hours: 1));
          _shiftedhours = 0;
        }
        if (hourDifference == -1) {
          _timeSetManualy = true;
        }
        _previousTime = currentTime;

        // Save shift and adjusted time to shared preferences.
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt(_shiftKey, _shift);
        prefs.setBool(_timeSetManualyKey, _timeSetManualy);
        prefs.setInt(_shiftedhoursKey, _shiftedhours);
        prefs.setString(_adjustedTimeKey, _adjustedTime.toIso8601String());
      }
    } catch (e, stackTrace) {
      logger.e(e, stackTrace: stackTrace);
    }
  }

  // Adjust time based on the selected time from a time picker.
  Future<void> adjustTimeFromTimePicker(DateTime selectedTimeFromPicker) async {
    try {
      _timeSetFromHour = true;
      int hourDifference = selectedTimeFromPicker.hour - _previousTime.hour;
      int minuteDifference =
          selectedTimeFromPicker.minute - _previousTime.minute;
      _shift = hourDifference;
      _shiftinMinutes = minuteDifference;

      if (_shift > 0) {
        _adjustedTime = _adjustedTime.add(Duration(hours: _shift));
      } else if (_shift < 0) {
        _adjustedTime = _adjustedTime.subtract(Duration(hours: _shift));
      } else if (_shift == 0 && minuteDifference != 0) {
        _adjustedTime = _adjustedTime.add(Duration(minutes: _shiftinMinutes));
      }

      _previousTime = DateTime.now();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt(_shiftKey, _shift);
      prefs.setInt(_shiftInMinutesKey, _shiftinMinutes);
      prefs.setString(_adjustedTimeKey, _adjustedTime.toIso8601String());
    } catch (e, stackTrace) {
      logger.e(e, stackTrace: stackTrace);
    }
  }

  // Reset shift and use device Time.
  Future<void> useDeviceTime() async {
    try {
      _shift = 0;
      _adjustedTime = DateTime.now();
      _shiftinMinutes = 0;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt(_shiftKey, _shift);
      prefs.setInt(_shiftKey, _shiftinMinutes);
      prefs.setString(_adjustedTimeKey, _adjustedTime.toIso8601String());
    } catch (e, stackTrace) {
      logger.e(e, stackTrace: stackTrace);
    }
  }

  // Getters for external access to shift and adjusted time.
  int get shift => _shift;
  int get shiftInMinutes => _shiftinMinutes;
  String get deviceModel => _deviceModel;
  bool get isLauncherInstalled => _isLauncherInstalled;
  DateTime get adjustedTime => _adjustedTime;
}
