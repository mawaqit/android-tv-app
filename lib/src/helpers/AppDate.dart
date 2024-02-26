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

  static Duration get difference =>
      Duration(days: 30 * 8 + 6, hours: -6, minutes: 30);

  static DateTime now() {
    if (kDebugMode) {
      return DateTime.now().add(difference);
    } else {
      return FeatureManagerProvider.featureManager
                  .isFeatureEnabled("timezone_shift") &&
              _timeManager.deviceModel == "MAWABOX" &&
              _timeManager.isLauncherInstalled
          ? DateTime.now().add(Duration(
              hours: _timeManager.shift, minutes: _timeManager.shiftInMinutes))
          : DateTime.now();
    }
  }

  static DateTime tomorrow() => DateTime.now().add(const Duration(days: 1));

  static bool get isFriday => now().weekday == DateTime.friday;
}
