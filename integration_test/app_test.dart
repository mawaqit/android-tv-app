import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mawaqit/main.dart';
import 'package:patrol/patrol.dart';

void testMain() {
  patrolTest(
    'counter state is the same after going to home and switching apps',
    ($) async {
      WidgetsFlutterBinding.ensureInitialized();

      final firebaseOptions = FirebaseOptions(
        apiKey: const String.fromEnvironment('mawaqit.firebase.api_key'),
        appId: const String.fromEnvironment('mawaqit.firebase.app_id'),
        messagingSenderId: const String.fromEnvironment('mawaqit.firebase.messaging_sender_id'),
        projectId: const String.fromEnvironment('mawaqit.firebase.project_id'),
        storageBucket: const String.fromEnvironment('mawaqit.firebase.storage_bucket'),
      );

      await Firebase.initializeApp(options: firebaseOptions);

      await main();

      // Only pump without settle (important)
      await $.pumpWidget(MyApp());

      // Then tap it
      await $('English').tap();

      await $('Landscape').tap();

      await $('Next').tap();

      await $('Yes').tap();

      await $(TextField).tap();

      await $.enterText(
        find.byType(TextFormField),
        '1',
      );

      await $(Icons.search_rounded).tap();

      await $.pumpAndSettle();
    },
  );
}
