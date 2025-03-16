import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/models/times.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AfterSalahAzkarScreen.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/widgets/display_text_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_ar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:global_configuration/global_configuration.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AfterSalahAzkar Integration Tests', () {
    late SharedPreferences prefs;
    late UserPreferencesManager userPrefsManager;
    late MosqueManager mosqueManager;
    late AppLanguage appLanguage;

    setUp(() async {
      // Initialize GlobalConfiguration with the default language
      await GlobalConfiguration().loadFromMap({
        "defaultLanguage": "en",
        "api_base_url": "https://android.mawaqit.net/",
        "firstColor": "#490094",
        "secondColor": "#391e61",
        "appIdOneSignal": "243f88d7-5535-4088-8532-ee967c8f7b25",
        "deeplink": "app.com.mawaqit.androidtv.scheme"
      });
      
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      // Initialize UserPreferencesManager with the mock SharedPreferences
      userPrefsManager = UserPreferencesManager();
      await userPrefsManager.init();

      // Initialize AppLanguage
      appLanguage = AppLanguage();
      await appLanguage.fetchLocale();

      // Initialize MosqueManager and API
      mosqueManager = MosqueManager();
      await Api.init(); // Initialize API

      // Setup mock data directly instead of trying to fetch from API
      mosqueManager.loaded = true;
      
      // Setup mock mosque data
      mosqueManager.mosque = Mosque(
        id: 3,
        uuid: '3',
        name: 'Test Mosque',
        city: 'Test City',
        country: 'Test Country',
        countryCode: 'TC',
        timeZone: 'UTC',
        latitude: 0.0,
        longitude: 0.0,
        address: 'Test Address',
      );
      
      // Setup mock times data
      mosqueManager.times = Times.fromMap({
        'id': 3,
        'date': '2023-01-01',
        'hijriDate': '1444-01-01',
        'fajr': '05:00',
        'dhuhr': '12:00',
        'asr': '15:00',
        'maghrib': '18:00',
        'isha': '20:00',
        'isTurki': false,
        'calendar': List.generate(
            12,
            (_) => {
                  for (int day = 1; day <= 31; day++)
                    day.toString(): ['05:00', '06:30', '12:00', '15:00', '18:00', '20:00']
                }),
        'iqamaCalendar': List.generate(
            12,
            (_) => {
                  for (int day = 1; day <= 31; day++)
                    day.toString(): ['05:15', '06:45', '12:15', '15:15', '18:15', '20:15']
                })
      });

      // Setup mock MosqueConfig
      mosqueManager.mosqueConfig = MosqueConfig(
        duaAfterPrayerShowTimes: ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'],
        hijriDateEnabled: true,
        duaAfterAzanEnabled: true,
        duaAfterPrayerEnabled: true,
        iqamaDisplayTime: 10,
        iqamaBip: true,
        backgroundColor: '#000000',
        jumuaDhikrReminderEnabled: true,
        jumuaTimeout: 30,
        randomHadithEnabled: true,
        blackScreenWhenPraying: true,
        wakeForFajrTime: 30,
        jumuaBlackScreenEnabled: true,
        temperatureEnabled: true,
        temperatureUnit: 'C',
        hadithLang: 'en',
        iqamaEnabled: true,
        randomHadithIntervalDisabling: '10',
        adhanVoice: 'default',
        footer: true,
        iqamaMoreImportant: true,
        timeDisplayFormat: '24h',
        backgroundType: 'image',
        backgroundMotif: '1',
        iqamaFullScreenCountdown: true,
        theme: 'dark',
        adhanEnabledByPrayer: ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'],
        showCityInTitle: true,
        showLogo: true,
        adhanDuration: 3,
        showPrayerTimesOnMessageScreen: true,
      );

      // Setup localization
      final appLocalizations = await AppLocalizations.delegate.load(const Locale('en'));
      S.setCurrent(appLocalizations);
    });

    testWidgets('Regular Azkar displays correctly', (WidgetTester tester) async {
      // Build test widget with all required providers
      await tester.pumpWidget(
        riverpod.ProviderScope(
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider<MosqueManager>.value(value: mosqueManager),
              ChangeNotifierProvider<UserPreferencesManager>.value(value: userPrefsManager),
              ChangeNotifierProvider<AppLanguage>.value(value: appLanguage),
            ],
            child: MaterialApp(
              localizationsDelegates: [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.supportedLocales,
              locale: const Locale('en'),
              home: Material(
                child: SingleChildScrollView(
                  child: AfterSalahAzkar(
                    onDone: () {},
                    isAfterAsrOrFajr: false,
                    isAfterAsr: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Wait for the widget to fully render
      await tester.pumpAndSettle();

      // Verify that the azkar content is displayed
      expect(find.byType(DisplayTextWidget), findsOneWidget);
    });

    testWidgets('Fajr Azkar displays correctly', (WidgetTester tester) async {
      // Build test widget with all required providers
      await tester.pumpWidget(
        riverpod.ProviderScope(
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider<MosqueManager>.value(value: mosqueManager),
              ChangeNotifierProvider<UserPreferencesManager>.value(value: userPrefsManager),
              ChangeNotifierProvider<AppLanguage>.value(value: appLanguage),
            ],
            child: MaterialApp(
              localizationsDelegates: [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.supportedLocales,
              locale: const Locale('en'),
              home: Material(
                child: SingleChildScrollView(
                  child: AfterSalahAzkar(
                    onDone: () {},
                    azkarTitle: AzkarConstant.kAzkarSabahAfterPrayer,
                    isAfterAsrOrFajr: true,
                    isAfterAsr: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Wait for the widget to fully render
      await tester.pumpAndSettle();

      // Verify that the azkar content is displayed
      expect(find.byType(DisplayTextWidget), findsOneWidget);
    });

    testWidgets('Asr Azkar displays correctly', (WidgetTester tester) async {
      // Build test widget with all required providers
      await tester.pumpWidget(
        riverpod.ProviderScope(
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider<MosqueManager>.value(value: mosqueManager),
              ChangeNotifierProvider<UserPreferencesManager>.value(value: userPrefsManager),
              ChangeNotifierProvider<AppLanguage>.value(value: appLanguage),
            ],
            child: MaterialApp(
              localizationsDelegates: [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.supportedLocales,
              locale: const Locale('en'),
              home: Material(
                child: SingleChildScrollView(
                  child: AfterSalahAzkar(
                    onDone: () {},
                    azkarTitle: AzkarConstant.kAzkarAsrAfterPrayer,
                    isAfterAsrOrFajr: true,
                    isAfterAsr: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Wait for the widget to fully render
      await tester.pumpAndSettle();

      // Verify that the azkar content is displayed
      expect(find.byType(DisplayTextWidget), findsOneWidget);
    });
  });
}
