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

// FakeTimes now provides fixed prayer times and the needed properties.
class FakeTimes extends Fake implements Times {
  @override
  List<String> dayTimesStrings(DateTime date, {bool salahOnly = true}) => [
        "00:00", // an extra imsak time
        "05:00",
        "12:00",
        "15:00",
        "18:00",
        "20:00",
        "22:00",
      ];

  @override
  List<String> dayIqamaStrings(DateTime date) => [
        "05:10",
        "12:10",
        "15:10",
        "18:10",
        "20:10",
      ];

  @override
  bool get isTurki => false;

  @override
  int get imsakNbMinBeforeFajr => 10;

  @override
  int get hijriAdjustment => 0;

  @override
  String? get jumua => "12:00";

  @override
  bool get jumuaAsDuhr => false;

}

// FakeMosqueConfig now provides required values for properties used.
class FakeMosqueConfig extends Fake implements MosqueConfig {
  @override
  bool get iqamaMoreImportant => false;

  @override
  String get hadithLang => 'ar';

  @override
  String get timeDisplayFormat => '24'; // or "12" if you prefer

  @override
  List<String> get duaAfterPrayerShowTimes => ["10", "10", "10", "10", "10"];

  @override
  bool get iqamaEnabled => false;

  @override
  int get jumuaTimeout => 30;
}

// --- Provider-style mocks for ChangeNotifiers ---
class MockMosqueManager extends Mock implements MosqueManager {
  // Fixed test times
  final fixedTime = DateTime(2025, 1, 1, 14, 30); // 2:30 PM
  final List<DateTime> _prayerTimes = [
    DateTime(2025, 1, 1, 5, 0), // Fajr
    DateTime(2025, 1, 1, 12, 0), // Dhuhr
    DateTime(2025, 1, 1, 15, 0), // Asr
    DateTime(2025, 1, 1, 18, 0), // Maghrib
    DateTime(2025, 1, 1, 20, 0), // Isha
  ];

  final List<DateTime> _iqamaTimes = [
    DateTime(2025, 1, 1, 5, 10), // Fajr
    DateTime(2025, 1, 1, 12, 10), // Dhuhr
    DateTime(2025, 1, 1, 15, 10), // Asr
    DateTime(2025, 1, 1, 18, 10), // Maghrib
    DateTime(2025, 1, 1, 20, 10), // Isha
  ];

  @override
  List<String> get salahNames => [
        'Fajr',
        'Dhuhr',
        'Asr',
        'Maghrib',
        'Isha',
      ];

  @override
  String getSalahNameByIndex(int index, BuildContext context) => salahNames[index];

  @override
  bool isDisableHadithBetweenSalah() => false;

  @override
  bool adhanVoiceEnable([int? salahIndex]) => true;

  @override
  int get salahIndex => 2; // Asr time in our fixed time

  @override
  bool get isImsakEnabled => true;

  @override
  bool get isShurukTime => false;

  @override
  String getShurukInString(BuildContext context) => "Shuruk in 01:30";

  @override
  String? getShurukTimeString([DateTime? date]) => "06:00";

  @override
  bool get typeIsMosque => true;

  @override
  bool isEidFirstDay(int? hijriAdjustment) => false;

  @override
  bool showEid(int? hijriAdjustment) => false;

  @override
  List<DateTime> actualTimes([DateTime? date]) => _prayerTimes;

  @override
  List<DateTime> actualIqamaTimes([DateTime? date]) => _iqamaTimes;

  @override
  int nextIqamaIndex() => 2; // Asr in our fixed time

  @override
  int nextSalahIndex() => 2; // Asr in our fixed time

  @override
  int nextSalahAfterIqamaIndex() => 2;

  @override
  Duration nextSalahAfter() => Duration(hours: 2, minutes: 30);

  @override
  Duration nextIqamaaAfter() => Duration(hours: 2, minutes: 40);

  @override
  Duration get currentSalahDuration => Duration(minutes: 10);

  @override
  String get imsak => "04:50";

  @override
  DateTime mosqueDate() => fixedTime;

  @override
  TimeOfDay mosqueTimeOfDay() => TimeOfDay.fromDateTime(fixedTime);

  @override
  bool get useTomorrowTimes => false;

  @override
  List<String> timesOfDay(DateTime date, {bool forceActualDuhr = false}) => [
        "05:00",
        "12:00",
        "15:00",
        "18:00",
        "20:00",
      ];

  @override
  List<String> get todayTimes => timesOfDay(fixedTime);

  @override
  List<String> get tomorrowTimes => timesOfDay(fixedTime.add(Duration(days: 1)));

  @override
  List<String> iqamasOfDay(DateTime date) => [
        "05:10",
        "12:10",
        "15:10",
        "18:10",
        "20:10",
      ];

  @override
  DateTime nextFridayDate([DateTime? now]) {
    now ??= fixedTime;
    return now.add(Duration(days: (DateTime.friday - now.weekday + 7) % 7));
  }

  @override
  DateTime activeJumuaaDate([DateTime? now]) => DateTime(2025, 1, 3, 12, 0); // Next Friday at noon

  @override
  bool isJumuaOrJumua2EmptyOrNull() => false;

  @override
  bool isShortIqamaDuration(int salahIndex) => false;

  @override
  bool jumuaaWorkflowTime() => false;

  @override
  bool salahWorkflow() => false;

  @override
  List<Announcement> activeAnnouncements(bool enableVideos) => [];
}

class MockAppLanguage extends Mock implements AppLanguage {
  @override
  bool isArabic() => true;
}

class MockUserPreferencesManager extends Mock implements UserPreferencesManager {
  @override
  Orientation get calculatedOrientation => Orientation.landscape;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  bool get hasListeners => false;
}

class MockAppLocalizations extends Mock implements AppLocalizations {
  @override
  String get in1 => 'in';

  @override
  String get fajr => 'Fajr';

  @override
  String get duhr => 'Dhuhr';

  @override
  String get asr => 'Asr';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isha => 'Isha';

  @override
  String get shuruk => 'Shuruk';
}

// --- Helper function to wrap a widget into a MaterialApp ---
Widget createWidgetForTesting({required Widget child}) {
  return Sizer(
    builder: (context, orientation, deviceType) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      );
    },
  );
}

// --- Setup for platform channel mocks (if needed) ---

void setupPathProviderMocks() {
  const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (MethodCall call) async {
      if (call.method == 'getApplicationSupportDirectory') {
        return '/tmp';
      }
      return null;
    },
  );
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
