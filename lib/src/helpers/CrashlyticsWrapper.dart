import 'dart:async';

import 'package:mawaqit/src/data/constants.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/helpers/StreamGenerator.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// this is a wrapper class for all crashlytics related functions
class CrashlyticsWrapper {
  static StreamSubscription? _subscription;
  static init(FutureOr? Function() appRunner) {
    Sentry.init(
      (options) async {
        final info = await PackageInfo.fromPlatform();
        final prefs = UserPreferencesManager();
        await prefs.init();

        options.dsn = kSentryDns;
        options.release = 'androidtv@${info.version.replaceAll('-tv', '')}';
        options.environment = prefs.forceStaging ? 'staging' : 'production';
      },
      appRunner: appRunner,
    );

    /// keep the user scope updated 
    _subscription?.cancel();
    _subscription = generateStream(Duration(minutes: 10)).listen((event) {
      updateUserScope();
    });
  }

  /// setup the user scope for crashlytics
  ///
  static Future<void> updateUserScope() async {
    final userData = await Api.prepareUserData();

    Sentry.configureScope((scopes) {
      if (userData == null) {
        scopes.clear();
        return;
      }

      final (uuid, data) = userData;

      scopes.setUser(SentryUser(segment: uuid, id: data['device-id']));

      for (var key in data.keys) {
        scopes.setContexts(key, data[key]);
      }
    });
  }

  /// function to report an exception to crashlytics if
  static Future<void> sendException(dynamic exception, StackTrace stackTrace) async {
    await Sentry.captureException(exception, stackTrace: stackTrace);
  }
}
