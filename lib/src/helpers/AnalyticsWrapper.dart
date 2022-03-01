import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsWrapper {
  static final analytics = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver observer() => FirebaseAnalyticsObserver(analytics: analytics);

  static void changeMosque(String mosqueId) => analytics.logEvent(name: 'ChangeMosque', parameters: {
        'mosqueId': mosqueId,
      });

  static void changeLanguage({
    required String oldLanguage,
    required String language,
    required String? mosqueId,
  }) =>
      analytics.logEvent(name: 'ChangeLanguage', parameters: {
        'mosqueId': mosqueId,
        'oldLanguage': oldLanguage,
        'language': language,
      });
}
