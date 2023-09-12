import 'package:flutter/foundation.dart';

/// return
class AppDateTime {
  AppDateTime._();

  /// for debug purpose to be able to skip the time forward or backward
  static Duration difference = Duration(hours: -6, minutes: 30);

  static DateTime now() => kDebugMode ? DateTime.now().add(difference) : DateTime.now();
}
