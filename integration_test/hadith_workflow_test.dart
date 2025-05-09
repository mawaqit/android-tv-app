import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/home/sub_screens/RandomHadithScreen.dart';
import 'package:mawaqit/src/pages/home/widgets/AboveSalahBar.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/responsive_mini_salah_bar_turkish_widget.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/responsive_mini_salah_bar_widget.dart';
import 'package:patrol/patrol.dart';
import 'package:mawaqit/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:media_kit/media_kit.dart';
import "../lib/i18n/l10n.dart" as l10n;
import 'package:flutter_gen/gen_l10n/app_localizations.dart' as gen;
import 'package:mawaqit/src/widgets/display_text_widget.dart';
import 'package:mawaqit/src/state_management/random_hadith/random_hadith_notifier.dart';
import 'package:mawaqit/src/pages/home/workflow/normal_workflow.dart';

/// Helper function to setup mock preferences for testing
Future<void> setupMockPreferences() async {
  SharedPreferences.setMockInitialValues({
    'boarding': json.encode('true'),
    'mosqueUUId': json.encode('f65b0003-c3e0-49f3-87fd-62b2d964b762'),
    // Ensure random hadith is enabled
    'hadith_language': 'ar', // Set the hadith language
    // Add other required preferences if needed
  });
}

/// Wait until a widget is found or timeout
Future<bool> waitForWidget(PatrolIntegrationTester $, Finder finder,
    {Duration timeout = const Duration(seconds: 5)}) async {
  try {
    await $.waitUntilVisible(
      finder,
      timeout: timeout,
    );
    return true;
  } catch (e) {
    print('Failed to find widget: $e');
    return false;
  }
}

void main() {
  patrolTest('Random hadith screen content verification', ($) async {
    // Setup mocks before starting the app
    await setupMockPreferences();

    final firebaseOptions = FirebaseOptions(
      apiKey: const String.fromEnvironment('mawaqit.firebase.api_key'),
      appId: const String.fromEnvironment('mawaqit.firebase.app_id'),
      messagingSenderId: const String.fromEnvironment('mawaqit.firebase.messaging_sender_id'),
      projectId: const String.fromEnvironment('mawaqit.firebase.project_id'),
      storageBucket: const String.fromEnvironment('mawaqit.firebase.storage_bucket'),
    );

    await Firebase.initializeApp(
      options: firebaseOptions,
    );

    // Initialize binding
    WidgetsFlutterBinding.ensureInitialized();
    tz.initializeTimeZones();
    S.setCurrent(gen.lookupAppLocalizations(const Locale('en')));
    MediaKit.ensureInitialized();

    await app.main();
    await $.pumpAndSettle();

    for (int i = 1; i <= 5; i++) {
      print('Waiting for RandomHadithScreen to appear in $i iteration...');
      // Wait for the RandomHadithScreen to be displayed
      final hadithScreenVisible = await waitForWidget($, find.byType(RandomHadithScreen),
          timeout: const Duration(
            minutes: 4,
            seconds: 10,
          ));
      expect(hadithScreenVisible, isTrue, reason: 'RandomHadithScreen should be displayed');

      /// Wait for the hadith text to be displayed

      // Verify that DisplayTextWidget.hadith is displayed
      final hadithWidget = find.byType(DisplayTextWidget);

      // Call waitUntilVisible without an assertion, then make a separate assertion
      await $.waitUntilVisible(hadithWidget); // This will throw if widget is not visible within timeout
      expect(hadithWidget, findsWidgets, reason: 'Hadith text should be visible');

      // Store the initial hadith text
      String? initialHadithText;
      if ($.tester.any(hadithWidget)) {
        final DisplayTextWidget displayTextWidget = $.tester.widget(hadithWidget.first);
        initialHadithText = displayTextWidget.translatedText;
        print('Initial Hadith content:');
        print('----------------------------------');
        print(initialHadithText);
        print('----------------------------------');
        print('Text direction: ${displayTextWidget.textDirection}');
      } else {
        fail('Initial hadith widget not found');
      }

      expect(find.byType(AboveSalahBar), findsOneWidget, reason: 'AboveSalahBar should be present');

      // Wait for the full duration cycle (_HadithDuration + a little buffer)
      // During this time the hadith screen should remain visible but might change content
      print('Waiting for hadith duration cycle...');
      await $.pump(Duration(seconds: 80)); // Less than _HadithDuration

      // Check if we're still on the RandomHadithScreen
      final stillOnHadithScreen = $.tester.any(find.byType(RandomHadithScreen));
      if (!stillOnHadithScreen) {
        fail('No longer on the RandomHadithScreen after waiting - this is expected if workflow progressed');
      }
    }
  });
}
