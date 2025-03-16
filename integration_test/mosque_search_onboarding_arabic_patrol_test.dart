import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol/patrol.dart';
import 'package:mawaqit/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  patrolTest(
    'Complete onboarding flow with Arabic language and mosque search',
    ($) async {
      // Launch the app
      await app.main();
      await $.pumpAndSettle();
      
      // Take screenshot of initial screen
      await $.screenshot('initial_screen');
      
      // Language selection screen - scroll until Arabic is visible
      await $.pumpAndSettle(const Duration(seconds: 5));
      await $.scrollUntilVisible(
        finder: find.text('العربية'),
        scrollable: find.byType(Scrollable).first,
        direction: AxisDirection.up,
      );
      
      // Select Arabic language
      await $.tap(text: 'العربية');
      await $.pumpAndSettle();
      await $.tap(text: 'التالي');
      await $.pumpAndSettle();
      
      // Orientation selection screen
      await $.tap(text: 'أفقي');
      await $.pumpAndSettle();
      await $.tap(text: 'التالي');
      await $.pumpAndSettle();
      
      // About screen
      await $.tap(text: 'التالي');
      await $.pumpAndSettle();
      
      // Mosque search type selection
      await $.tap(text: 'نعم');
      await $.pumpAndSettle();
      await $.tap(text: 'إنهاء');
      await $.pumpAndSettle();
      
      // Mosque ID input and search
      await $.enterText(finder: find.byType(TextField), text: '1');
      await $.pumpAndSettle();
      await $.tap(finder: find.byKey(const Key('search_mosque')));
      await $.pumpAndSettle(const Duration(seconds: 2)); // Wait for animation
      
      // Verify Next button is visible and tap it
      await $.native.waitUntilVisible(text: 'التالي');
      await $.tap(text: 'التالي');
      await $.pumpAndSettle();
    },
  );
}