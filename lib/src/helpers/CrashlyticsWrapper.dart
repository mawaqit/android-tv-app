import 'dart:async';

import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/helpers/StreamGenerator.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// this is a wrapper class for all crashlytics related functions
class CrashlyticsWrapper {
  static StreamSubscription? _subscription;
  static init(FutureOr<void>? Function() appRunner) async {
    await Sentry.init(
      (options) async {
        options.dsn = "https://5cfba6c6f6374d4abcac5a22f8adff61@o1075739.ingest.us.sentry.io/4504947427901440";

        final info = await PackageInfo.fromPlatform();
        final prefs = UserPreferencesManager();
        await prefs.init();

        options.release = 'androidtv@${info.version}';
        options.environment = 'debug';
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
        scopes.setUser(null);

        scopes.setContexts("user-data", null);
        return;
      }
      final (uuid, data) = userData;

      scopes.setTag('app-version', data['app-version']);
      scopes.setTag('android-version', data['android-version']);
      scopes.setUser(SentryUser(segment: uuid, id: data['device-id']));
      scopes.setContexts("user-data", data);
    });
  }

  /// function to report an exception to crashlytics if
  static Future<void> sendException(dynamic exception, StackTrace stackTrace) async {
    await Sentry.captureException(exception, stackTrace: stackTrace);
  }
}
