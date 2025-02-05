import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mawaqit/src/models/announcement.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/models/times.dart';
import 'package:mawaqit/src/pages/home/sub_screens/RandomHadithScreen.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/state_management/random_hadith/random_hadith_notifier.dart';
import 'package:mawaqit/src/state_management/random_hadith/random_hadith_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';
import '../../helpers/mocks.dart';

class MockRandomHadithNotifier extends RandomHadithNotifier {
  @override
  FutureOr<RandomHadithState> build() {
    // Provide a known initial state.
    return RandomHadithState(hadith: 'Mocked hadith from notifier', language: 'ar');
  }

  void updateHadith(String hadith, String language) {
    state = riverpod.AsyncData(RandomHadithState(hadith: hadith, language: language));
  }

  void triggerError([String errorMessage = 'Simulated error']) {
    state = riverpod.AsyncError(errorMessage, StackTrace.current);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  TestWidgetsFlutterBinding.ensureInitialized();

  final Directory tempDir = Directory.systemTemp.createTempSync();
  Hive.init(tempDir.path);

  setUpAll(() {
    setupPathProviderMocks();
  });

  group('RandomHadithScreen Tests', () {
    testWidgets('RandomHadithScreen updates text when notifier state changes', (WidgetTester tester) async {
      // Create mocks for our ChangeNotifier dependencies.
      final mockMosqueManager = MockMosqueManager();
      final mockAppLanguage = MockAppLanguage();

      when(() => mockAppLanguage.hadithLanguage).thenReturn('ar');
      when(() => mockMosqueManager.mosqueConfig).thenReturn(FakeMosqueConfig());
      when(() => mockMosqueManager.times).thenReturn(FakeTimes());
      when(() => mockMosqueManager.getColorTheme()).thenReturn(Colors.blue);

      // Create an instance of our RandomHadithNotifier mock.
      final mockNotifier = MockRandomHadithNotifier();

      await tester.pumpWidget(
        riverpod.ProviderScope(
          overrides: [
            // Use overrideWithValue with the notifier instance directly.
            randomHadithNotifierProvider.overrideWith(() => mockNotifier),
          ],
          child: provider.MultiProvider(
            providers: [
              provider.ChangeNotifierProvider<MosqueManager>.value(value: mockMosqueManager),
              provider.ChangeNotifierProvider<AppLanguage>.value(value: mockAppLanguage),
              provider.ChangeNotifierProvider<UserPreferencesManager>.value(value: MockUserPreferencesManager()),
            ],
            child: createWidgetForTesting(
              child: const RandomHadithScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the initial state appears.
      // expect(find.text('Mocked hadith from notifier'), findsOneWidget);

      // Update the notifier state.
      mockNotifier.updateHadith('Updated hadith text', 'en');
      await tester.pumpAndSettle();

      // Verify that the updated text is displayed.
      expect(find.text('Updated hadith text'), findsOneWidget);
    });
  });

  group('RandomHadithScreen Error State Test', () {
    testWidgets('should display error text and call onDone when notifier errors', (WidgetTester tester) async {
      // Create mocks for the dependencies.
      final mockMosqueManager = MockMosqueManager();
      final mockAppLanguage = MockAppLanguage();

      when(() => mockAppLanguage.hadithLanguage).thenReturn('ar');
      when(() => mockMosqueManager.mosqueConfig).thenReturn(FakeMosqueConfig());
      when(() => mockMosqueManager.times).thenReturn(FakeTimes());
      when(() => mockMosqueManager.getColorTheme()).thenReturn(Colors.blue);

      // Create our RandomHadithNotifier instance.
      final mockNotifier = MockRandomHadithNotifier();

      // Flag to verify if the onDone callback is called.
      bool onDoneCalled = false;

      await tester.pumpWidget(
        riverpod.ProviderScope(
          overrides: [
            randomHadithNotifierProvider.overrideWith(() => mockNotifier),
          ],
          child: provider.MultiProvider(
            providers: [
              provider.ChangeNotifierProvider<MosqueManager>.value(value: mockMosqueManager),
              provider.ChangeNotifierProvider<AppLanguage>.value(value: mockAppLanguage),
              provider.ChangeNotifierProvider<UserPreferencesManager>.value(value: MockUserPreferencesManager()),
            ],
            child: createWidgetForTesting(
              child: RandomHadithScreen(
                onDone: () {
                  onDoneCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Let the widget tree build.
      await tester.pumpAndSettle();

      // Simulate an error in the notifier.
      mockNotifier.triggerError("Simulated error");
      await tester.pumpAndSettle();

      // Verify that the error branch is rendered.
      expect(find.text('Error: Simulated error'), findsOneWidget);
      // Verify that the onDone callback was called.
      expect(onDoneCalled, isTrue);
    });
  });
}
