import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AndroidTvOsDetector {
  static Future<bool> isPhoneOrTablet() async {
    try {
      final screenSize =
          WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
      final orientation = screenSize.width > screenSize.height
          ? Orientation.landscape
          : Orientation.portrait;
      final deviceWidth = orientation == Orientation.landscape
          ? screenSize.height
          : screenSize.width;

      final isTablet = deviceWidth <= 950;

      return isTablet;
    } on PlatformException catch (_) {
      return false; 
    }
  }
}
