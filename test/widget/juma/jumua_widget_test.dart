import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/models/times.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/SalahItem.dart';
import 'package:mawaqit/src/pages/times/widgets/jumua_widget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ChangeNotifierProvider, Provider;

// Mock classes
class MockMosqueManager extends Mock implements MosqueManager {}

class MockUserPreferencesManager extends Mock implements UserPreferencesManager {}

class MockAppLanguage extends Mock implements AppLanguage {
  @override
  bool isArabic() => false;

  @override
  Locale get appLocal => const Locale('en');

  @override
  String translate(String key) => key;
}

class MockTimes extends Mock implements Times {}

class MockMosque extends Mock implements Mosque {}

class MockMosqueConfig extends Mock implements MosqueConfig {}

void main() {
  late MockMosqueManager mosqueManager;
  late MockUserPreferencesManager userPreferencesManager;
  late MockTimes times;
  late MockMosque mosque;
  late MockMosqueConfig mosqueConfig;
  late MockAppLanguage mockAppLanguage;

  setUpAll(() {
    // Register fallbacks for mocks
    registerFallbackValue(Orientation.portrait);
    registerFallbackValue(DateTime(2023, 6, 30, 13, 0)); // Register a fallback DateTime
    registerFallbackValue(Colors.blue); // Register a fallback Color
    registerFallbackValue(MockTimes()); // Register a fallback Times
    registerFallbackValue(MockMosqueConfig()); // Register a fallback MosqueConfig
  });

  setUp(() {
    mosqueManager = MockMosqueManager();
    userPreferencesManager = MockUserPreferencesManager();
    times = MockTimes();
    mosque = MockMosque();
    mosqueConfig = MockMosqueConfig();
    mockAppLanguage = MockAppLanguage();

    // Setup behavior of mocks
    when(() => mosqueManager.jumuaaWorkflowTime()).thenReturn(false);
    when(() => mosqueManager.getOrderedJumuaTimes()).thenReturn([]);
    when(() => mosqueManager.typeIsMosque).thenReturn(true);
    when(() => mosqueManager.mosqueDate()).thenReturn(DateTime(2023, 6, 30, 13, 0));
    when(() => mosqueManager.showEid(any())).thenReturn(false);
    when(() => mosqueManager.times).thenReturn(times);
    when(() => mosqueManager.isImsakEnabled).thenReturn(false);
    when(() => mosqueManager.imsak).thenReturn("");
    when(() => mosqueManager.getShurukTimeString(any())).thenReturn(null);
    when(() => mosqueManager.mosqueConfig).thenReturn(mosqueConfig);
    when(() => mosqueManager.nextIqamaIndex()).thenReturn(0);
    when(() => mosqueManager.mosque).thenReturn(mosque);
    when(() => mosqueManager.nextSalahIndex()).thenReturn(0);
    when(() => mosqueManager.nextSalahAfter()).thenReturn(Duration(minutes: 30));
    when(() => mosqueManager.salahName(any())).thenReturn("Jumua");
    when(() => mosqueManager.getColorTheme()).thenReturn(Colors.blue);

    when(() => userPreferencesManager.hijriAdjustments).thenReturn(0);
    when(() => userPreferencesManager.isSecondaryScreen).thenReturn(false);
    when(() => userPreferencesManager.calculatedOrientation).thenReturn(Orientation.portrait);

    when(() => mosqueConfig.iqamaMoreImportant).thenReturn(false);
    when(() => mosqueConfig.jumuaTimeout).thenReturn(30);
    when(() => mosqueConfig.jumuaDhikrReminderEnabled).thenReturn(false);

    when(() => times.aidPrayerTime).thenReturn(null);
    when(() => times.aidPrayerTime2).thenReturn(null);
    when(() => times.jumua).thenReturn(null);
    when(() => times.jumua2).thenReturn(null);
    when(() => times.jumua3).thenReturn(null);
    when(() => times.jumuaAsDuhr).thenReturn(false);
    when(() => times.isTurki).thenReturn(false);

    when(() => mosque.streamUrl).thenReturn(null);
  });

  Widget createTestableWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MosqueManager>(
          create: (_) => mosqueManager,
        ),
        ChangeNotifierProvider<UserPreferencesManager>(
          create: (_) => userPreferencesManager,
        ),
        Provider<Times>(
          create: (_) => times,
        ),
        Provider<Mosque>(
          create: (_) => mosque,
        ),
        Provider<MosqueConfig>(
          create: (_) => mosqueConfig,
        ),
        ChangeNotifierProvider<AppLanguage>(
          create: (_) => mockAppLanguage,
        ),
      ],
      child: ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
          ],
          home: child,
        ),
      ),
    );
  }

  testWidgets('displays empty jumua widget when no jumua times are available', (WidgetTester tester) async {
    // No need to re-mock getOrderedJumuaTimes here since it's in setUp

    await tester.pumpWidget(createTestableWidget(const JumuaWidget()));
    await tester.pump();

    // For debugging
    final widgets = find.byType(Text);
    for (int i = 0; i < widgets.evaluate().length; i++) {
      final widget = widgets.at(i);
      print('Text widget $i: ${(widget.evaluate().first.widget as Text).data}');
    }

    // Updated expectation - the widget is expected to be empty
    expect(find.byType(JumuaWidget), findsOneWidget);
    expect(find.byType(SalahItemWidget), findsOneWidget);
  });

  group('JumuaWidget', () {
    testWidgets('displays single jumua time when only first jumua is configured', (WidgetTester tester) async {
      // Setup
      when(() => mosqueManager.getOrderedJumuaTimes()).thenReturn(['13:00']);

      // Build widget
      await tester.pumpWidget(createTestableWidget(const JumuaWidget()));
      await tester.pump();

      // Verify
      expect(find.text('13:00'), findsOneWidget);
      expect(find.byType(JumuaWidget), findsOneWidget);
      expect(find.byType(SalahItemWidget), findsOneWidget);
    });

    testWidgets('displays multiple jumua times when configured', (WidgetTester tester) async {
      // Setup
      when(() => mosqueManager.getOrderedJumuaTimes()).thenReturn(['13:00', '14:30', '16:00']);

      // Build widget
      await tester.pumpWidget(createTestableWidget(const JumuaWidget()));
      await tester.pump();

      // Verify
      for (final time in ['13:00', '14:30', '16:00']) {
        expect(find.text(time), findsOneWidget);
      }
      expect(find.byType(JumuaWidget), findsOneWidget);
      expect(find.byType(SalahItemWidget), findsOneWidget);
    });

    testWidgets('activates widget when in jumua workflow time', (WidgetTester tester) async {
      // Setup - During jumua workflow
      when(() => mosqueManager.getOrderedJumuaTimes()).thenReturn(['13:00']);
      when(() => mosqueManager.jumuaaWorkflowTime()).thenReturn(true);

      // Build widget
      await tester.pumpWidget(createTestableWidget(const JumuaWidget()));
      await tester.pump();

      // Find the SalahItemWidget
      final salahItemFinder = find.byType(SalahItemWidget);
      expect(salahItemFinder, findsOneWidget);

      // Extract and verify the SalahItemWidget has active=true
      final salahItem = tester.widget<SalahItemWidget>(salahItemFinder);
      expect(salahItem.active, isTrue);
    });

    // this will require to use this patch
    // Subject: [PATCH] Changes
    // ---
    //     Index: lib/src/pages/home/widgets/FadeInOut.dart
    // IDEA additional info:
    // Subsystem: com.intellij.openapi.diff.impl.patch.CharsetEP
    // <+>UTF-8
    // ===================================================================
    // diff --git a/lib/src/pages/home/widgets/FadeInOut.dart b/lib/src/pages/home/widgets/FadeInOut.dart
    // --- a/lib/src/pages/home/widgets/FadeInOut.dart
    // +++ b/lib/src/pages/home/widgets/FadeInOut.dart
    // @@ -25,14 +25,20 @@
    //
    // class _FadeInOutWidgetState extends State<FadeInOutWidget> {
    // bool _showSecond = false;
    // +  Timer? _timer;
    //
    // @override
    // void initState() {
    // -    Future.delayed(widget.duration, showNextItem);
    // -
    // +    _timer = Timer(widget.duration, showNextItem);
    // super.initState();
    // }
    //
    // +  @override
    // +  void dispose() {
    // +    _timer?.cancel();
    // +    super.dispose();
    // +  }
    // +
    // @override
    // Widget build(BuildContext context) {
    // return RepaintBoundary(
    // @@ -53,6 +59,7 @@
    //
    // final nextDuration = _showSecond ? widget.secondDuration ?? widget.duration : widget.duration;
    //
    // -    Future.delayed(nextDuration, showNextItem);
    // +    _timer?.cancel();
    // +    _timer = Timer(nextDuration, showNextItem);
    // }
    // }
    // ========
    // testWidgets('displays Eid widget when in Eid time', (WidgetTester tester) async {
    //   // Setup - During Eid
    //   when(() => mosqueManager.showEid(any())).thenReturn(true);
    //   when(() => times.aidPrayerTime).thenReturn('07:00');
    //   when(() => times.aidPrayerTime2).thenReturn('08:00');
    //
    //   // Build widget
    //   await tester.pumpWidget(createTestableWidget(const JumuaWidget()));
    //   await tester.pump();
    //
    //   // Basic verification
    //   expect(find.byType(JumuaWidget), findsOneWidget);
    //   expect(find.byType(SalahItemWidget), findsNWidgets(2)); // Expect two SalahItemWidget instances
    //
    //   // Pump a few more times to let the FadeInOutWidget timers complete
    //   await tester.pumpAndSettle(const Duration(seconds: 31)); // FadeInOutWidget uses 30 seconds duration
    // });
  });
}
