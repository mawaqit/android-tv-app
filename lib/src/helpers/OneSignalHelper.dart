import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalHelper with ChangeNotifier {
  String? url;

  OneSignalHelper() {
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      if (result.notification.additionalData != null &&
          result.notification.additionalData!['url'] != null) {
        url = result.notification.additionalData!['url'];
        notifyListeners();
      }
    });
  }
}
