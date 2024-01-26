import 'dart:async';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

// TimeShiftManager is a singleton class responsible for managing time adjustments,
// particularly handling time shifts and periodic adjustments. It utilizes shared preferences
// for data persistence, allowing the application to maintain state across sessions.
class TimeShiftManager {
  static final TimeShiftManager _instance = TimeShiftManager._internal();

  int _shift = 0;
  int _shiftinMinutes = 0;
  DateTime _adjustedTime = DateTime.now();
  DateTime _previousTime = DateTime.now();
  String _previousTimeZone = Intl.getCurrentLocale();
  bool _timeSetFromHour = false;

  static const String _shiftKey = 'shift';
  static const String _shiftInMinutesKey = 'shiftInMinutes';
  static const String _adjustedTimeKey = 'adjustedTime';
  static const String _previousTimeKey = 'previousTime';

  factory TimeShiftManager() => _instance;

  TimeShiftManager._internal() {
    initializeTimes();
    startPeriodicTimer();
  }

  // Initialize time-related properties from shared preferences or current time.
  Future<void> initializeTimes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _shift = prefs.getInt(_shiftKey) ?? 0;
    _shiftinMinutes = prefs.getInt(_shiftKey) ?? 0;
    _adjustedTime = DateTime.parse(
        prefs.getString(_adjustedTimeKey) ?? DateTime.now().toIso8601String());
    _previousTime = DateTime.parse(
        prefs.getString(_previousTimeKey) ?? DateTime.now().toIso8601String());
    _previousTimeZone = DateTime.now().timeZoneName;
  }

  // Start a periodic timer for time adjustments, triggered every 1 hour.
  void startPeriodicTimer() {
    const Duration period = Duration(hours: 1);
    if (!_timeSetFromHour) {
      Timer.periodic(period, (Timer timer) {
        adjustTime();
      });
    }
  }

  // Perform time adjustments based on timezone changes and hourly differences.
  Future<void> adjustTime() async {
    try {
      DateTime currentTime = DateTime.now();
      String currentTimeZone = DateTime.now().timeZoneName;

      // Skip adjustment if timezone has changed.
      if (_previousTimeZone != currentTimeZone) {
        _previousTimeZone = currentTimeZone;
        return;
      }

      const Duration timeThreshold = Duration(minutes: 5);

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
        // Calculate shift based on the hourly difference.
        if (hourDifference == 2 || hourDifference == 1) {
          _shift = -1;
          _adjustedTime = _adjustedTime.subtract(Duration(hours: 1));
        }
        _previousTime = currentTime;

        // Save shift and adjusted time to shared preferences.
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt(_shiftKey, _shift);
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
      // Update adjusted time based on the shift.
      if (_shift > 0) {
        _adjustedTime = _adjustedTime.add(Duration(hours: _shift));
      } else if (_shift < 0) {
        _adjustedTime = _adjustedTime.subtract(Duration(hours: _shift));
      } else if (minuteDifference > 0) {
        _adjustedTime = _adjustedTime.add(Duration(minutes: _shiftinMinutes));
      } else if (minuteDifference < 0) {
        _adjustedTime = _adjustedTime.add(Duration(minutes: _shiftinMinutes));
      }

      _previousTime = DateTime.now();

      // Save shift and adjusted time to shared preferences.
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

      // Save shift and adjusted time to shared preferences.
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt(_shiftKey, _shift);
      prefs.setString(_adjustedTimeKey, _adjustedTime.toIso8601String());
    } catch (e, stackTrace) {
      logger.e(e, stackTrace: stackTrace);
    }
  }

  // Getters for external access to shift and adjusted time.
  int get shift => _shift;
  int get shiftInMinutes => _shiftinMinutes;

  DateTime get adjustedTime => _adjustedTime;
}
