import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mawaqit/src/state_management/random_hadith/random_hadith_notifier.dart';
import 'package:mawaqit/src/state_management/random_hadith/random_hadith_state.dart';
import 'package:mawaqit/src/widgets/display_text_widget.dart';

class MockRandomHadithNotifier extends RandomHadithNotifier {
  @override
  FutureOr<RandomHadithState> build() {
    return RandomHadithState(hadith: 'Initial hadith', language: 'ar');
  }

  void updateHadith(String hadith, String language) {
    state = AsyncData(RandomHadithState(hadith: hadith, language: language));
  }
}


void setupPathProviderMocks() {
  const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
        (MethodCall methodCall) async {
      if (methodCall.method == 'getApplicationSupportDirectory') {
        return '/tmp';
      }
      return null;
    },
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    setupPathProviderMocks();
  });

  group('DisplayTextWidget.hadith Tests', () {
    testWidgets('Renders hadith text correctly', (WidgetTester tester) async {
      const String testHadith = 'Test hadith text';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            randomHadithNotifierProvider.overrideWith(() => MockRandomHadithNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: DisplayTextWidget.hadith(
                translatedText: testHadith,
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(testHadith), findsOneWidget);
    });

    testWidgets('Handles RTL text direction correctly', (WidgetTester tester) async {
      const String arabicHadith = 'حديث اختبار';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            randomHadithNotifierProvider.overrideWith(() => MockRandomHadithNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: DisplayTextWidget.hadith(
                translatedText: arabicHadith,
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textWidget = tester.widget<AutoSizeText>(
        find.byType(AutoSizeText),
      );
      expect(textWidget.textDirection, TextDirection.rtl);
    });

    testWidgets('Applies correct styling for hadith mode', (WidgetTester tester) async {
      const String testHadith = 'Test hadith text';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            randomHadithNotifierProvider.overrideWith(() => MockRandomHadithNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: DisplayTextWidget.hadith(
                translatedText: testHadith,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textWidget = tester.widget<AutoSizeText>(
        find.byType(AutoSizeText),
      );

      expect(textWidget.style?.color, Colors.white);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
      expect(textWidget.textAlign, TextAlign.center);
    });

    testWidgets('Handles long hadith text without overflow', (WidgetTester tester) async {
      const String longHadith = 'Very long hadith text that should be automatically resized to fit within the container without causing overflow issues. This tests the AutoSizeText functionality.';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            randomHadithNotifierProvider.overrideWith(() => MockRandomHadithNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 200,
                width: 300,
                child: DisplayTextWidget.hadith(
                  translatedText: longHadith,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text(longHadith), findsOneWidget);
    });
  });
}
