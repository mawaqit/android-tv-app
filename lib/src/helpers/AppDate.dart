import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../services/FeatureManager.dart';
import 'TimeShiftManager.dart';

final TimeShiftManager _timeManager = TimeShiftManager();

class FeatureManagerProvider {
  static FeatureManager? _featureManager;

  static FeatureManager? get featureManager => _featureManager;

  static bool isFeatureEnabled(String featureName) {
    return _featureManager?.isFeatureEnabled(featureName) ?? false;
  }

  static void initialize(BuildContext context) {
    _featureManager = Provider.of<FeatureManager>(context, listen: false);
  }

  static bool get isInitialized => _featureManager != null;
}

class AppDateTime {
  AppDateTime._();

  // Initial setup for debug time; can be replaced or modified as needed.
  static final DateTime _initialRealTime = DateTime.now();
  static final DateTime _initialDebugTime = DateTime(
    _initialRealTime.year,
    _initialRealTime.month,
    _initialRealTime.day - 3,
    20,
    33 + 26,
    00,
  );

  static final Duration _timeDifference = _initialDebugTime.difference(_initialRealTime);

  static DateTime now() {
    if (kDebugMode) {
      return DateTime.now().add(_timeDifference);
    } else {
      // Safe access - use feature flag only if FeatureManager is initialized
      final shouldApplyTimeshift = FeatureManagerProvider.isInitialized &&
          FeatureManagerProvider.isFeatureEnabled("timezone_shift") &&
          _timeManager.deviceModel == "MAWABOX" &&
          _timeManager.isLauncherInstalled;

      return shouldApplyTimeshift
          ? DateTime.now().add(Duration(hours: _timeManager.shift, minutes: _timeManager.shiftInMinutes))
          : DateTime.now();
    }
  }

  static DateTime tomorrow() => now().add(const Duration(days: 1));

  static bool get isFriday => now().weekday == DateTime.friday;
}

class MockAppDateTime {
  static DateTime? _mockNow;

  static void setMockNow(DateTime dateTime) {
    _mockNow = dateTime;
  }

  static DateTime now() {
    return _mockNow ?? DateTime.now();
  }

  static void reset() {
    _mockNow = null;
  }
}
