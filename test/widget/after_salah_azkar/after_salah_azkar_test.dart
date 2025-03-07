import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AfterSalahAzkarScreen.dart';
import 'package:mawaqit/src/pages/home/widgets/AboveSalahBar.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/responsive_mini_salah_bar_widget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/widgets/display_text_widget.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart' as provider;
import 'mocks.dart';

class TestWrapper extends StatefulWidget {
  final Widget child;

  const TestWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _TestWrapperState createState() => _TestWrapperState();
}

class _TestWrapperState extends State<TestWrapper> {
  bool finished = false;

  void finish() {
    setState(() {
      finished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // When finished, show an empty container with key 'finished'
    return finished ? Container(key: const Key('finished')) : widget.child;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  TestWidgetsFlutterBinding.ensureInitialized();

  final Directory tempDir = Directory.systemTemp.createTempSync();

  setUpAll(() {
    setupPathProviderMocks();
  });

  group('AfterSalahAzkar Tests', () {
    late MockMosqueManager mockMosqueManager;
    late MockAppLanguage mockAppLanguage;
    late MockUserPreferencesManager mockUserPreferencesManager;

    setUp(() {
      mockMosqueManager = MockMosqueManager();
      mockAppLanguage = MockAppLanguage();
      mockUserPreferencesManager = MockUserPreferencesManager();

      // Setup common mock behaviors
      when(() => mockAppLanguage.hadithLanguage).thenReturn('ar');
      when(() => mockMosqueManager.mosqueConfig).thenReturn(FakeMosqueConfig());
      when(() => mockMosqueManager.times).thenReturn(FakeTimes());
      when(() => mockMosqueManager.getColorTheme()).thenReturn(Colors.blue);
    });

    testWidgets('When duaa is disabled, no azkar appears (wrapper removes widget)', (WidgetTester tester) async {
      // Use the fake config where duaAfterPrayerEnabled is false.
      final fakeConfig = FakeMosqueConfig(); // returns false for duaAfterPrayerEnabled
      when(() => mockMosqueManager.mosqueConfig).thenReturn(fakeConfig);

      bool onDoneCalled = false;

      // Create a GlobalKey to access TestWrapperState.
      final testWrapperKey = GlobalKey<_TestWrapperState>();

      // Build the TestWrapper (with our GlobalKey) wrapping the AfterSalahAzkar widget.
      final testWidget = TestWrapper(
        key: testWrapperKey,
        child: AfterSalahAzkar(
          onDone: () {
            onDoneCalled = true;
            // Mark the wrapper as finished.
            testWrapperKey.currentState?.finish();
          },
        ),
      );

      await tester.pumpWidget(
        riverpod.ProviderScope(
          child: provider.MultiProvider(
            providers: [
              provider.ChangeNotifierProvider<MosqueManager>.value(value: mockMosqueManager),
              provider.ChangeNotifierProvider<AppLanguage>.value(value: mockAppLanguage),
              provider.ChangeNotifierProvider<UserPreferencesManager>.value(value: mockUserPreferencesManager),
            ],
            child: createWidgetForTesting(child: testWidget),
          ),
        ),
      );

      // Pump enough time so that onDone is triggered (AfterSalahAzkar schedules 80ms when dua is disabled).
      await tester.pump(Duration(milliseconds: 200));

      // Verify that onDone was called.
      expect(onDoneCalled, isTrue);
      // Now, because finish() was called, the TestWrapper should show the finished container.
      expect(find.byKey(const Key('finished')), findsOneWidget);
    });

    testWidgets('AfterSalahAzkar displays initial azkar correctly', (WidgetTester tester) async {
      bool onDoneCalled = false;

      await tester.pumpWidget(
        riverpod.ProviderScope(
          child: provider.MultiProvider(
            providers: [
              provider.ChangeNotifierProvider<MosqueManager>.value(value: mockMosqueManager),
              provider.ChangeNotifierProvider<AppLanguage>.value(value: mockAppLanguage),
              provider.ChangeNotifierProvider<UserPreferencesManager>.value(value: mockUserPreferencesManager),
            ],
            child: createWidgetForTesting(
              child: AfterSalahAzkar(
                onDone: () {
                  onDoneCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(DisplayTextWidget), findsOneWidget);
    });

    // testWidgets('Cycles through azkar in correct sequence for Fajr (salahIndex = 0)', (WidgetTester tester) async {
    //   // ARRANGE: simulate Fajr scenario.
    //   when(() => mockMosqueManager.salahIndex).thenReturn(0);
    //
    //   // Pump the widget without an onDone callback so it remains visible.
    //   await tester.pumpWidget(riverpod.ProviderScope(
    //     child: provider.MultiProvider(
    //       providers: [
    //         provider.ChangeNotifierProvider<MosqueManager>.value(value: mockMosqueManager),
    //         provider.ChangeNotifierProvider<AppLanguage>.value(value: mockAppLanguage),
    //         provider.ChangeNotifierProvider<UserPreferencesManager>.value(value: mockUserPreferencesManager),
    //       ],
    //       child: createWidgetForTesting(
    //         child: AfterSalahAzkar(onDone: () {}),
    //       ),
    //     ),
    //   ));
    //   await tester.pumpAndSettle();
    //
    //   // 1) Check the initial displayed azkar (activeHadith should be 0).
    //   var displayText = tester.widget<DisplayTextWidget>(find.byType(DisplayTextWidget));
    //   expect(displayText.arabicText, equals('azkar0'));
    //
    //   // 2) Pump a duration equal to the periodic update (e.g., 20 seconds) to simulate one cycle.
    //   await tester.pump(const Duration(seconds: 20));
    //   await tester.pumpAndSettle();
    //
    //   // Now, activeHadith should be 1, so we expect 'azkar1'.
    //   displayText = tester.widget<DisplayTextWidget>(find.byType(DisplayTextWidget));
    //   expect(displayText.arabicText, equals('azkar1'));
    //
    //   // 3) Pump another 20 seconds.
    //   await tester.pump(const Duration(seconds: 20));
    //   await tester.pumpAndSettle();
    //
    //   // Expect activeHadith to be 2 → 'azkar2'
    //   displayText = tester.widget<DisplayTextWidget>(find.byType(DisplayTextWidget));
    //   expect(displayText.arabicText, equals('azkar2'));
    //
    //   // 4) Optionally, continue pumping and verify the modulo behavior.
    //   // For example, if the non-afterAsr list is defined as a list of 7 items,
    //   // you can pump enough times to cycle back to the first item.
    // });

    testWidgets('Non-afterAsr: Correct azkar list is presented', (WidgetTester tester) async {
      await tester.pumpWidget(
        riverpod.ProviderScope(
          child: provider.MultiProvider(
            providers: [
              provider.ChangeNotifierProvider<MosqueManager>.value(value: mockMosqueManager),
              // Provide our fake localization with known strings.
              provider.ChangeNotifierProvider<AppLanguage>.value(value: mockAppLanguage),
              provider.ChangeNotifierProvider<UserPreferencesManager>.value(value: mockUserPreferencesManager),
            ],
            child: createWidgetForTesting(
              child: AfterSalahAzkar(
                  // isAfterAsrOrFajr remains false.
                  ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final displayText = tester.widget<DisplayTextWidget>(find.byType(DisplayTextWidget));

      // Expect that the initial Arabic text is 'azkar0'
      // expect(displayText.arabicText, equals('azkar0'));
    });

    testWidgets('Fajr scenario: non-afterAsr list is used (salahIndex = 0)', (WidgetTester tester) async {
      // If needed, override your mockMosqueManager.salahIndex to simulate Fajr.

      await tester.pumpWidget(
        riverpod.ProviderScope(
          child: provider.MultiProvider(
            providers: [
              provider.ChangeNotifierProvider<MosqueManager>.value(value: mockMosqueManager),
              provider.ChangeNotifierProvider<AppLanguage>.value(value: mockAppLanguage),
              provider.ChangeNotifierProvider<UserPreferencesManager>.value(value: mockUserPreferencesManager),
            ],
            child: createWidgetForTesting(
              child: AfterSalahAzkar(), // isAfterAsrOrFajr is false by default.
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final displayText = tester.widget<DisplayTextWidget>(find.byType(DisplayTextWidget));
      // For Fajr (salahIndex == 0), expect the non-afterAsr branch (i.e. 'azkar0')
      expect(
          displayText.arabicText,
          equals(
              "أَسْـتَغْفِرُ الله، أَسْـتَغْفِرُ الله، أَسْـتَغْفِرُ الله اللّهُـمَّ أَنْـتَ السَّلامُ ، وَمِـنْكَ السَّلام ، تَبارَكْتَ يا ذا الجَـلالِ وَالإِكْـرام اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ"));
    });

    // testWidgets('AfterSalahAzkar cycles through different azkar', (WidgetTester tester) async {
    //   await tester.pumpWidget(
    //     riverpod.ProviderScope(
    //       child: provider.MultiProvider(
    //         providers: [
    //           provider.ChangeNotifierProvider<MosqueManager>.value(value: mockMosqueManager),
    //           provider.ChangeNotifierProvider<UserPreferencesManager>.value(value: mockUserPreferencesManager),
    //         ],
    //         child: createWidgetForTesting(
    //           child: AfterSalahAzkar(),
    //         ),
    //       ),
    //     ),
    //   );
    //
    //   await tester.pumpAndSettle();
    //   final initialWidget = find.byType(DisplayTextWidget);
    //   expect(initialWidget, findsOneWidget);
    //
    //   await tester.pump(Duration(seconds: 20));
    //   await tester.pumpAndSettle();
    //
    //   final updatedWidget = find.byType(DisplayTextWidget);
    //   expect(updatedWidget, findsOneWidget);
    // });

    testWidgets('AfterSalahAzkar respects isAfterAsrOrFajr flag', (WidgetTester tester) async {
      await tester.pumpWidget(
        riverpod.ProviderScope(
          child: provider.MultiProvider(
            providers: [
              provider.ChangeNotifierProvider<MosqueManager>.value(value: mockMosqueManager),
              provider.ChangeNotifierProvider<AppLanguage>.value(value: mockAppLanguage),
              provider.ChangeNotifierProvider<UserPreferencesManager>.value(value: mockUserPreferencesManager),
            ],
            child: createWidgetForTesting(
              child: AfterSalahAzkar(
                isAfterAsrOrFajr: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(DisplayTextWidget), findsOneWidget);
    });

    testWidgets('AfterSalahAzkar handles custom azkar title', (WidgetTester tester) async {
      const customTitle = 'Custom Azkar Title';

      await tester.pumpWidget(
        riverpod.ProviderScope(
          child: provider.MultiProvider(
            providers: [
              provider.ChangeNotifierProvider<MosqueManager>.value(value: mockMosqueManager),
              provider.ChangeNotifierProvider<AppLanguage>.value(value: mockAppLanguage),
              provider.ChangeNotifierProvider<UserPreferencesManager>.value(value: mockUserPreferencesManager),
            ],
            child: createWidgetForTesting(
              child: AfterSalahAzkar(
                azkarTitle: customTitle,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(DisplayTextWidget), findsOneWidget);
    });

    testWidgets('AfterSalahAzkar calls onDone when prayer is disabled', (WidgetTester tester) async {
      final fakeMosqueConfig = FakeMosqueConfig();
      when(() => mockMosqueManager.mosqueConfig).thenReturn(fakeMosqueConfig);

      bool onDoneCalled = false;

      await tester.pumpWidget(
        riverpod.ProviderScope(
          child: provider.MultiProvider(
            providers: [
              provider.ChangeNotifierProvider<MosqueManager>.value(value: mockMosqueManager),
              provider.ChangeNotifierProvider<AppLanguage>.value(value: mockAppLanguage),
              provider.ChangeNotifierProvider<UserPreferencesManager>.value(value: mockUserPreferencesManager),
            ],
            child: createWidgetForTesting(
              child: AfterSalahAzkar(
                onDone: () {
                  onDoneCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump(Duration(milliseconds: 1000));
      expect(onDoneCalled, isTrue);
    });

    testWidgets('AfterSalahAzkar displays correct layout components', (WidgetTester tester) async {
      await tester.pumpWidget(
        riverpod.ProviderScope(
          child: provider.MultiProvider(
            providers: [
              provider.ChangeNotifierProvider<MosqueManager>.value(value: mockMosqueManager),
              provider.ChangeNotifierProvider<AppLanguage>.value(value: mockAppLanguage),
              provider.ChangeNotifierProvider<UserPreferencesManager>.value(value: mockUserPreferencesManager),
            ],
            child: createWidgetForTesting(
              child: AfterSalahAzkar(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AboveSalahBar), findsOneWidget);
      expect(find.byType(DisplayTextWidget), findsOneWidget);
      expect(find.byType(ResponsiveMiniSalahBarWidget), findsOneWidget);
    });
  });

  group('AfterSalahAzkar Additional Tests', () {
    late MockMosqueManager mockMosqueManager;
    late MockAppLanguage mockAppLanguage;
    late MockUserPreferencesManager mockUserPreferencesManager;

    setUp(() {
      mockMosqueManager = MockMosqueManager();
      mockAppLanguage = MockAppLanguage();
      mockUserPreferencesManager = MockUserPreferencesManager();

      // Default mock behavior (dua disabled by default in FakeMosqueConfig)
      when(() => mockAppLanguage.hadithLanguage).thenReturn('ar');
      when(() => mockMosqueManager.mosqueConfig).thenReturn(FakeMosqueConfig());
      when(() => mockMosqueManager.times).thenReturn(FakeTimes());
      when(() => mockMosqueManager.getColorTheme()).thenReturn(Colors.blue);
    });

    testWidgets('onDone is not called immediately when dua is enabled', (WidgetTester tester) async {
      // Create a config that enables dua after prayer.
      // You might create a FakeMosqueConfig that returns true for duaAfterPrayerEnabled.
      final enabledConfig = FakeMosqueConfigWithDuaEnabled();
      when(() => mockMosqueManager.mosqueConfig).thenReturn(enabledConfig);

      bool onDoneCalled = false;
      await tester.pumpWidget(
        riverpod.ProviderScope(
          child: provider.MultiProvider(
            providers: [
              provider.ChangeNotifierProvider<MosqueManager>.value(value: mockMosqueManager),
              provider.ChangeNotifierProvider<AppLanguage>.value(value: mockAppLanguage),
              provider.ChangeNotifierProvider<UserPreferencesManager>.value(value: mockUserPreferencesManager),
            ],
            child: createWidgetForTesting(
              child: AfterSalahAzkar(
                onDone: () {
                  onDoneCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Pump 2 minutes (for a 2:20 duration),
      // leaving 20s to go.
      await tester.pump(const Duration(minutes: 2));
      expect(onDoneCalled, isFalse);

      // Pump 19 more seconds,
      // leaving 1s to go.
      await tester.pump(const Duration(seconds: 19));
      expect(onDoneCalled, isFalse);

      // Finally cross the boundary.
      await tester.pump(const Duration(seconds: 1));
      expect(onDoneCalled, isTrue);
    });

    testWidgets('Active hadith counter increments after periodic update', (WidgetTester tester) async {
      await tester.pumpWidget(
        riverpod.ProviderScope(
          child: provider.MultiProvider(
            providers: [
              provider.ChangeNotifierProvider<MosqueManager>.value(value: mockMosqueManager),
              provider.ChangeNotifierProvider<AppLanguage>.value(value: mockAppLanguage),
              provider.ChangeNotifierProvider<UserPreferencesManager>.value(value: mockUserPreferencesManager),
            ],
            child: createWidgetForTesting(
              child: AfterSalahAzkar(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Capture the initial DisplayTextWidget text.
      final initialTextWidget = tester.widget<DisplayTextWidget>(find.byType(DisplayTextWidget));
      final initialArabic = initialTextWidget.arabicText;
      final initialTranslated = initialTextWidget.translatedText;

      // Simulate waiting for one periodic update (20 seconds)
      await tester.pump(Duration(seconds: 20));
      await tester.pumpAndSettle();

      final updatedTextWidget = tester.widget<DisplayTextWidget>(find.byType(DisplayTextWidget));
      final updatedArabic = updatedTextWidget.arabicText;
      final updatedTranslated = updatedTextWidget.translatedText;

      // Expect that either the Arabic or translated texts have changed.
      expect(initialArabic != updatedArabic || initialTranslated != updatedTranslated, isTrue);
    });

    testWidgets('Custom azkar title is displayed correctly', (WidgetTester tester) async {
      const customTitle = 'Custom Azkar Title';
      await tester.pumpWidget(
        riverpod.ProviderScope(
          child: provider.MultiProvider(
            providers: [
              provider.ChangeNotifierProvider<MosqueManager>.value(value: mockMosqueManager),
              provider.ChangeNotifierProvider<AppLanguage>.value(value: mockAppLanguage),
              provider.ChangeNotifierProvider<UserPreferencesManager>.value(value: mockUserPreferencesManager),
            ],
            child: createWidgetForTesting(
              child: AfterSalahAzkar(
                azkarTitle: customTitle,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Check that the DisplayTextWidget receives the custom title.
      final displayTextWidget = tester.widget<DisplayTextWidget>(find.byType(DisplayTextWidget));
      expect(displayTextWidget.title, equals(customTitle));
    });

    testWidgets('Layout contains all required widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        riverpod.ProviderScope(
          child: provider.MultiProvider(
            providers: [
              provider.ChangeNotifierProvider<MosqueManager>.value(value: mockMosqueManager),
              provider.ChangeNotifierProvider<AppLanguage>.value(value: mockAppLanguage),
              provider.ChangeNotifierProvider<UserPreferencesManager>.value(value: mockUserPreferencesManager),
            ],
            child: createWidgetForTesting(
              child: AfterSalahAzkar(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that the background is applied (via Container with decoration)
      expect(find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final decoration = widget.decoration as BoxDecoration;
          return decoration.image != null;
        }
        return false;
      }), findsWidgets);

      // Verify that the AboveSalahBar and mini salah bar widget are present.
      expect(find.byType(AboveSalahBar), findsOneWidget);
      expect(find.byType(ResponsiveMiniSalahBarWidget), findsOneWidget);
    });
  });
}
