import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../services/FeatureManager.dart';
import 'TimeShiftManager.dart';

final TimeShiftManager _timeManager = TimeShiftManager();

class FeatureManagerProvider {
  static FeatureManager? _featureManager;

  static FeatureManager get featureManager {
    assert(_featureManager != null,
        'FeatureManager has not been initialized. Call FeatureManagerProvider.initialize() before accessing featureManager.');
    return _featureManager!;
  }

  static void initialize(BuildContext context) {
    _featureManager = Provider.of<FeatureManager>(context, listen: false);
  }
}

class AppDateTime {
  AppDateTime._();

  // Initial setup for debug time; can be replaced or modified as needed.
  static final DateTime _initialRealTime = DateTime.now();
  static final DateTime _initialDebugTime = DateTime(
    _initialRealTime.year,
    11,
    1,
    00,
    -20,
    00,
  );

  static final Duration _timeDifference = _initialDebugTime.difference(_initialRealTime);

  static DateTime now() {
    if (kDebugMode) {
      return DateTime.now().add(_timeDifference);
    } else {
      return FeatureManagerProvider.featureManager.isFeatureEnabled("timezone_shift") &&
              _timeManager.deviceModel == "MAWABOX" &&
              _timeManager.isLauncherInstalled
          ? DateTime.now().add(Duration(hours: _timeManager.shift, minutes: _timeManager.shiftInMinutes))
          : DateTime.now();
    }
  }

  static DateTime tomorrow() => DateTime.now().add(const Duration(days: 1));

  static bool get isFriday => now().weekday == DateTime.friday;
}
