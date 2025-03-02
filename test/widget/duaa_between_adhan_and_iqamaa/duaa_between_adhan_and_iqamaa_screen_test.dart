import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mawaqit/src/pages/home/sub_screens/DuaaBetweenAdhanAndIqama.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/widgets/display_text_widget.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart' as provider;

import 'mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DuaaBetweenAdhanAndIqamaaScreen UI Tests', () {
    late MockMosqueManager mockMosqueManager;

    setUp(() {
      mockMosqueManager = MockMosqueManager();
      when(() => mockMosqueManager.mosqueConfig).thenReturn(FakeMosqueConfig());
    });

    tearDown(() {
      // Clean up any remaining timers
      // TestWidgetsFlutterBinding.instance.clock();
    });

    testWidgets(
      'Calls onDone after 80ms when dua is disabled',
      (WidgetTester tester) async {
        bool onDoneCalled = false;

        await tester.pumpWidget(
          ProviderScope(
            child: provider.MultiProvider(
              providers: [
                provider.ChangeNotifierProvider<MosqueManager>.value(
                  value: mockMosqueManager,
                ),
              ],
              child: createWidgetForTesting(
                child: DuaaBetweenAdhanAndIqamaaScreen(
                  onDone: () => onDoneCalled = true,
                ),
              ),
            ),
          ),
        );

        // Initial build
        await tester.pump();
        expect(onDoneCalled, isFalse);

        // Wait for 80ms
        await tester.pump(const Duration(milliseconds: 80));
        expect(onDoneCalled, isTrue);
      },
    );

    testWidgets(
      'Calls onDone after 30 seconds when dua is enabled',
      (WidgetTester tester) async {
        final fakeConfig = FakeMosqueConfigWithDuaEnabled();
        when(() => mockMosqueManager.mosqueConfig).thenReturn(fakeConfig);
        // when(() => mockMosqueManager.nextIqamaaAfter()).thenReturn(const Duration(minutes: 5));

        bool onDoneCalled = false;

        await tester.pumpWidget(
          ProviderScope(
            child: provider.MultiProvider(
              providers: [
                provider.ChangeNotifierProvider<MosqueManager>.value(
                  value: mockMosqueManager,
                ),
              ],
              child: createWidgetForTesting(
                child: DuaaBetweenAdhanAndIqamaaScreen(
                  onDone: () => onDoneCalled = true,
                ),
              ),
            ),
          ),
        );

        // Initial build
        await tester.pump();
        expect(onDoneCalled, isFalse);

        // Wait for 29 seconds
        await tester.pump(const Duration(seconds: 29));
        expect(onDoneCalled, isFalse);

        // Wait for final second
        await tester.pump(const Duration(seconds: 1));
        expect(onDoneCalled, isTrue);
      },
    );

    testWidgets('Displays the expected texts', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: provider.MultiProvider(
            providers: [
              provider.ChangeNotifierProvider<MosqueManager>.value(
                value: mockMosqueManager,
              ),
            ],
            child: createWidgetForTesting(
              child: DuaaBetweenAdhanAndIqamaaScreen(
                onDone: () {},
              ),
            ),
          ),
        ),
      );

      // Wait for widget to build
      await tester.pump();

      expect(find.byType(DisplayTextWidget), findsOneWidget);
      final displayTextWidget = tester.widget<DisplayTextWidget>(
        find.byType(DisplayTextWidget),
      );
      expect(
        displayTextWidget.title,
        equals('الدعاء لا يرد بين الأذان والإقامة'),
      );

      // Complete any remaining timers
      await tester.pumpAndSettle();
    });
  });
}
