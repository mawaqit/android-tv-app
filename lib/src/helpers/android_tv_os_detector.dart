import 'dart:async';
import 'package:flutter/services.dart';

class AndroidTvOsDetector {
  static const MethodChannel _channel =
      const MethodChannel('nativeMethodsChannel');

  static Future<bool> isPhoneOrTablet() async {
    try {
      final bool isPhoneOrTablet =
          await _channel.invokeMethod('isPhoneOrTablet') ?? false;
      return isPhoneOrTablet;
    } on PlatformException catch (_) {
      return false;
    }
  }
}
