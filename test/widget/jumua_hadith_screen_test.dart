import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/models/times.dart';
import 'package:mawaqit/src/pages/home/sub_screens/JumuaHadithSubScreen.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ChangeNotifierProvider, Provider;
import 'package:mawaqit/src/widgets/display_text_widget.dart';
import 'package:mawaqit/src/pages/home/widgets/AboveSalahBar.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/responsive_mini_salah_bar_widget.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/responsive_mini_salah_bar_turkish_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:montenegrin_localization/montenegrin_localization.dart';

class MockMosque extends Mock implements Mosque {
  final MockMosqueConfig _config;
  final MockTimes _times;

  MockMosque({
    required MockMosqueConfig config,
    required MockTimes times,
  })  : _config = config,
        _times = times;

  @override
  MosqueConfig get config => _config;

  @override
  Times get times => _times;
}

class MockMosqueConfig extends Mock implements MosqueConfig {
  bool _isTurki = false;
  bool? _jumuaDhikrReminderEnabled = true;

  @override
  bool get isTurki => _isTurki;

  set isTurki(bool value) {
    _isTurki = value;
  }

  @override
  bool? get jumuaDhikrReminderEnabled => _jumuaDhikrReminderEnabled;

  set jumuaDhikrReminderEnabled(bool? value) {
    _jumuaDhikrReminderEnabled = value;
  }
}

class MockTimes extends Mock implements Times {
  bool _isTurki = false;
  List<String> _dayTimesStrings = ['05:00', '06:00', '12:00', '15:00', '18:00', '19:30'];

  @override
  bool get isTurki => _isTurki;

  @override
  List<String> dayTimesStrings(DateTime date, {bool salahOnly = true}) => _dayTimesStrings;

  @override
  List<String> dayIqamaStrings(DateTime date) {
    return ['05:00', '12:30', '15:45', '18:20', '20:00'];
  }

  set isTurki(bool value) {
    _isTurki = value;
  }

  void setDayTimesStrings(List<String> value) {
    _dayTimesStrings = value;
  }
}

class MockMosqueManager extends Mock implements MosqueManager {
  final MockMosque _mosque;
  bool _jumuaDhikrReminderEnabled = true;
  bool _useTomorrowTimes = false;
  DateTime _mosqueDate = DateTime.now();
  int _nextSalahIndex = 0;

  MockMosqueManager({required MockMosque mosque}) : _mosque = mosque;

  @override
  Duration nextSalahAfter() => const Duration(minutes: 30);

  @override
  bool get jumuaDhikrReminderEnabled => _jumuaDhikrReminderEnabled;

  @override
  Mosque get mosque => _mosque;

  @override
  MosqueConfig? get mosqueConfig => _mosque.config;

  @override
  Times? get times => _mosque.times;

  @override
  bool get useTomorrowTimes => _useTomorrowTimes;

  @override
  DateTime mosqueDate() => _mosqueDate;

  @override
  int nextSalahIndex() => _nextSalahIndex;

  @override
  String getSalahNameByIndex(int index, [BuildContext? context]) {
    return 'Salah $index';
  }

  @override
  Color getColorTheme() {
    return Colors.blue; // Default color for testing
  }

  @override
  String salahName(int index, [BuildContext? context]) {
    return 'Salah $index';
  }

  set jumuaDhikrReminderEnabled(bool value) {
    _jumuaDhikrReminderEnabled = value;
  }

  set useTomorrowTimes(bool value) {
    _useTomorrowTimes = value;
  }

  void setMosqueDate(DateTime value) {
    _mosqueDate = value;
  }

  void setNextSalahIndex(int value) {
    _nextSalahIndex = value;
  }
}

class MockUserPreferencesManager extends ChangeNotifier implements UserPreferencesManager {
  bool _announcementsOnly = false;
  bool _developerModeEnabled = false;
  bool _forceStaging = false;
  bool _isSecondaryScreen = false;
  bool _webViewMode = false;
  bool? _orientationLandscape = false;
  int? _hijriAdjustments;

  @override
  bool get announcementsOnly => _announcementsOnly;

  @override
  set announcementsOnly(bool value) {
    _announcementsOnly = value;
    notifyListeners();
  }

  @override
  bool get developerModeEnabled => _developerModeEnabled;

  @override
  set developerModeEnabled(bool value) {
    _developerModeEnabled = value;
    notifyListeners();
  }

  @override
  void forceOrientation() {}

  @override
  bool get forceStaging => _forceStaging;

  @override
  set forceStaging(bool value) {
    _forceStaging = value;
    notifyListeners();
  }

  @override
  int? get hijriAdjustments => _hijriAdjustments;

  @override
  set hijriAdjustments(int? value) {
    _hijriAdjustments = value;
    notifyListeners();
  }

  @override
  Future<UserPreferencesManager> init() async {
    return this;
  }

  @override
  bool get isSecondaryScreen => _isSecondaryScreen;

  @override
  set isSecondaryScreen(bool value) {
    _isSecondaryScreen = value;
    notifyListeners();
  }

  @override
  bool get orientationLandscape => _orientationLandscape ?? false;

  @override
  set orientationLandscape(bool? value) {
    _orientationLandscape = value;
    notifyListeners();
  }

  @override
  void toggleOrientation() {
    orientationLandscape = !orientationLandscape;
  }

  @override
  bool get webViewMode => _webViewMode;

  @override
  set webViewMode(bool value) {
    _webViewMode = value;
    notifyListeners();
  }

  @override
  Orientation get calculatedOrientation => Orientation.portrait;
}

class MockAppLanguage extends ChangeNotifier implements AppLanguage {
  @override
  Locale get appLocal => Locale('en');

  @override
  void changeLanguage(Locale type, String? mosqueId) {}

  @override
  String combinedLanguageName(String languageCode) => '';

  @override
  String get currentLanguageName => languageName(_appLocale.languageCode);

  @override
  Future<void> fetchLocale() async {}

  @override
  Future<String> getHadithLanguage(MosqueManager mosqueManager) async => 'ar';

  @override
  String get hadithLanguage => 'ar';

  @override
  Map<String, String Function(BuildContext)> hadithLocalizedLanguage = {
    'en': (context) => 'English',
    'ar': (context) => 'Arabic',
    'tr': (context) => 'Turkish',
    'fr': (context) => 'French',
    'de': (context) => 'German',
    'es': (context) => 'Spanish',
    'pt': (context) => 'Portuguese',
    'nl': (context) => 'Dutch',
    'fr_ar': (context) => 'French & Arabic',
    'en_ar': (context) => 'English & Arabic',
    'de_ar': (context) => 'German & Arabic',
    'ta_ar': (context) => 'Tamil & Arabic',
    'tr_ar': (context) => 'Turkish & Arabic',
    'es_ar': (context) => 'Spanish & Arabic',
    'pt_ar': (context) => 'Portuguese & Arabic',
    'nl_ar': (context) => 'Dutch & Arabic',
  };

  @override
  bool isArabic() => false;

  @override
  String languageName(String languageCode) => 'English';

  @override
  Future<void> setHadithLanguage(String language) async {}

  Locale _appLocale = Locale('en');
}


void main() {
  late MockMosqueManager mockMosqueManager;
  late MockUserPreferencesManager mockUserPreferencesManager;
  late MockAppLanguage mockAppLanguage;
  late MockMosque mockMosque;
  late MockMosqueConfig mockMosqueConfig;
  late MockTimes mockTimes;

  setUp(() {
    mockMosqueConfig = MockMosqueConfig();
    mockTimes = MockTimes();
    mockMosque = MockMosque(config: mockMosqueConfig, times: mockTimes);
    mockMosqueManager = MockMosqueManager(mosque: mockMosque);
    mockUserPreferencesManager = MockUserPreferencesManager();
    mockAppLanguage = MockAppLanguage();
  });

  Widget buildTestWidget({
    bool? jumuaDhikrReminderEnabled = true,
    bool isTurki = false,
  }) {
    mockMosqueConfig.jumuaDhikrReminderEnabled = jumuaDhikrReminderEnabled;
    mockMosqueConfig.isTurki = isTurki;
    mockTimes.isTurki = isTurki;

    // Set a fixed size for the test environment
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = Size(800, 600);
    binding.window.devicePixelRatioTestValue = 1.0;

    return ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<MosqueManager>.value(value: mockMosqueManager),
          ChangeNotifierProvider<UserPreferencesManager>.value(value: mockUserPreferencesManager),
          ChangeNotifierProvider<AppLanguage>.value(value: mockAppLanguage),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: [
            MontenegrinMaterialLocalizations.delegate,
            MontenegrinWidgetsLocalizations.delegate,
            MontenegrinCupertinoLocalizations.delegate,
            S.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: S.supportedLocales,
          home: Scaffold(
            body: JumuaHadithSubScreen(),
          ),
        ),
      ),
    );
  }

  testWidgets('should show content when jumuaDhikrReminderEnabled is true',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();
    expect(find.text(S.current.jumuaaScreenTitle), findsOneWidget);
  });

  testWidgets('should show black screen when jumuaDhikrReminderEnabled is false',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget(jumuaDhikrReminderEnabled: false));
    await tester.pumpAndSettle();
    expect(find.text(S.current.jumuaaScreenTitle), findsNothing);
  });

  testWidgets('should show Turkish widget when isTurki is true',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget(isTurki: true));
    await tester.pumpAndSettle();
    expect(find.text('Turkish Salah Bar Widget'), findsOneWidget);
  });

  testWidgets('should show regular widget when isTurki is false',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget(isTurki: false));
    await tester.pumpAndSettle();
    expect(find.text('Regular Salah Bar Widget'), findsOneWidget);
  });
}
