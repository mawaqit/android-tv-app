import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kurdish_localization/flutter_kurdish_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';
import 'package:mawaqit/src/domain/model/quran/surah_model.dart';
import 'package:mawaqit/src/domain/model/connectivity_status.dart';
import 'package:mawaqit/src/helpers/AnalyticsWrapper.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/ConnectivityService.dart';
import 'package:mawaqit/src/helpers/CrashlyticsWrapper.dart';
import 'package:mawaqit/src/helpers/riverpod_logger.dart';
import 'package:mawaqit/src/helpers/riverpod_sentry_provider_observer.dart';
import 'package:mawaqit/src/pages/SplashScreen.dart';
import 'package:mawaqit/src/services/audio_manager.dart';
import 'package:mawaqit/src/services/FeatureManager.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/theme_manager.dart';
import 'package:mawaqit/src/services/toggle_screen_feature_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:mawaqit/src/routes/route_generator.dart';
import 'package:montenegrin_localization/montenegrin_localization.dart';

final logger = Logger();

Future<void> main() async {
  await CrashlyticsWrapper.init(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      final directory = await getApplicationDocumentsDirectory();
      Hive.init(directory.path);
      await FastCachedImageConfig.init(subDir: directory.path, clearCacheAfter: const Duration(days: 60));

      tz.initializeTimeZones();
      Hive.registerAdapter(SurahModelAdapter());
      Hive.registerAdapter(ReciterModelAdapter());
      Hive.registerAdapter(MoshafModelAdapter());
      MediaKit.ensureInitialized();
      runApp(
        riverpod.ProviderScope(
          child: MyApp(),
          observers: [
            RiverpodLogger(),
            RiverpodSentryProviderObserver(),
          ],
        ),
      );
      await Future.delayed(const Duration(seconds: 5));
      await ToggleScreenFeature.restoreScheduledTimers();
    },
  );
}

class MyApp extends riverpod.ConsumerWidget {
  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeNotifier()),
        ChangeNotifierProvider(create: (context) => AppLanguage()),
        ChangeNotifierProvider(create: (context) => MosqueManager()),
        ChangeNotifierProvider(create: (context) => AudioManager()),
        ChangeNotifierProvider(create: (context) => FeatureManager(context)),
        ChangeNotifierProvider(create: (context) => UserPreferencesManager(), lazy: false),
        StreamProvider(create: (context) => Api.updateUserStatusStream(), initialData: 0, lazy: false),
      ],
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        return Sizer(builder: (context, orientation, size) {
          return StreamProvider(
            initialData: ConnectivityStatus.Offline,
            create: (context) => ConnectivityService().connectionStatusController.stream.map((event) {
              if (event == ConnectivityStatus.Wifi || event == ConnectivityStatus.Cellular) {
                //todo check actual internet
              }

              return event;
            }),
            child: Consumer<ThemeNotifier>(
              builder: (context, theme, _) {
                return Shortcuts(
                  shortcuts: {SingleActivator(LogicalKeyboardKey.select): ActivateIntent()},
                  child: MaterialApp(
                    title: kAppName,
                    themeMode: theme.mode,
                    localeResolutionCallback: (locale, supportedLocales) {
                      if (locale?.languageCode.toLowerCase() == 'ba') return Locale('en');

                      return locale;
                    },
                    theme: theme.lightTheme,
                    darkTheme: theme.darkTheme,
                    locale: model.appLocal,
                    navigatorKey: AppRouter.navigationKey,
                    navigatorObservers: [
                      AnalyticsWrapper.observer(),
                    ],
                    localizationsDelegates: [
                      MontenegrinMaterialLocalizations.delegate,
                      MontenegrinWidgetsLocalizations.delegate,
                      MontenegrinCupertinoLocalizations.delegate,
                      S.delegate,
                      GlobalCupertinoLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      KurdishMaterialLocalizations.delegate,
                      KurdishWidgetLocalizations.delegate,
                      KurdishCupertinoLocalizations.delegate
                    ],
                    supportedLocales: S.supportedLocales,
                    debugShowCheckedModeBanner: false,
                    onGenerateRoute: RouteGenerator.generateRoute,
                    home: Splash(),
                  ),
                );
              },
            ),
          );
        });
      }),
    );
  }
}
