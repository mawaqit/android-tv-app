import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol/patrol.dart';
import 'package:mawaqit/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  patrolTest(
    'Complete onboarding flow with English language and mosque search',
    ($) async {
      // Launch the app
      await app.main();
      await $.pumpAndSettle();
      
      // Take screenshot of initial screen
      await $.screenshot('initial_screen');
      
      // Language selection screen - wait for English option to appear
      await $.pumpAndSettle(const Duration(seconds: 5));
      await $.native.waitUntilVisible(text: 'English');
      
      // Select English language
      await $.tap(text: 'English');
      await $.pumpAndSettle();
      await $.tap(text: 'Next');
      await $.pumpAndSettle();
      
      // Orientation selection screen
      await $.tap(text: 'Landscape');
      await $.pumpAndSettle();
      await $.tap(text: 'Next');
      await $.pumpAndSettle();
      
      // About screen
      await $.tap(text: 'Next');
      await $.pumpAndSettle();
      
      // Mosque search type selection
      await $.tap(text: 'Yes');
      await $.pumpAndSettle();
      await $.tap(text: 'Finish');
      await $.pumpAndSettle();
      
      // Mosque ID input and search
      await $.enterText(finder: find.byType(TextField), text: '1');
      await $.pumpAndSettle();
      await $.tap(finder: find.byKey(const Key('search_mosque')));
      await $.pumpAndSettle(const Duration(seconds: 2)); // Wait for animation
      
      // Verify Next button is visible and tap it
      await $.native.waitUntilVisible(text: 'Next');
      await $.tap(text: 'Next');
      await $.pumpAndSettle();
    },
  );
}