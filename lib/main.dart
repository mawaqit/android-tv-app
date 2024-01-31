import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderBase, ProviderContainer, ProviderObserver, ProviderScope;
import 'package:logger/logger.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/data/constants.dart';
import 'package:mawaqit/src/enum/connectivity_status.dart';
import 'package:mawaqit/src/helpers/AnalyticsWrapper.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/ConnectivityService.dart';
import 'package:mawaqit/src/helpers/CrashlyticsWrapper.dart';
import 'package:mawaqit/src/helpers/riverpod_logger.dart';
import 'package:mawaqit/src/pages/SplashScreen.dart';
import 'package:mawaqit/src/services/audio_manager.dart';
import 'package:mawaqit/src/services/features_manager.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/settings_manager.dart';
import 'package:mawaqit/src/services/theme_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

final logger = Logger();

Future<void> main() async {
  await CrashlyticsWrapper.init(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      runApp(
        ProviderScope(
          child: MyApp(),
          observers: [RiverpodLogger()],
        ),
      );
    },
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeNotifier()),
        ChangeNotifierProvider(create: (context) => AppLanguage()),
        ChangeNotifierProvider(create: (context) => MosqueManager()),
        ChangeNotifierProvider(create: (context) => SettingsManager()),
        ChangeNotifierProvider(create: (context) => AudioManager()),
        ChangeNotifierProvider(create: (context) => FeatureManager(context)),
        ChangeNotifierProvider(
            create: (context) => UserPreferencesManager(), lazy: false),
        StreamProvider(
            create: (context) => Api.updateUserStatusStream(),
            initialData: 0,
            lazy: false),
      ],
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        return Sizer(builder: (context, orientation, size) {
          return StreamProvider(
            initialData: ConnectivityStatus.Offline,
            create: (context) => ConnectivityService()
                .connectionStatusController
                .stream
                .map((event) {
              if (event == ConnectivityStatus.Wifi ||
                  event == ConnectivityStatus.Cellular) {
                //todo check actual internet
              }

              return event;
            }),
            child: Consumer<ThemeNotifier>(
              builder: (context, theme, _) => Shortcuts(
                shortcuts: {
                  SingleActivator(LogicalKeyboardKey.select): ActivateIntent()
                },
                child: MaterialApp(
                  title: kAppName,
                  themeMode: theme.mode,
                  localeResolutionCallback: (locale, supportedLocales) {
                    if (locale?.languageCode.toLowerCase() == 'ba')
                      return Locale('en');

                    return locale;
                  },
                  theme: theme.lightTheme,
                  darkTheme: theme.darkTheme,
                  locale: model.appLocal,
                  navigatorKey: AppRouter.navigationKey,
                  navigatorObservers: [AnalyticsWrapper.observer()],
                  localizationsDelegates: [
                    S.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  supportedLocales: S.supportedLocales,
                  debugShowCheckedModeBanner: false,
                  home: Splash(),
                ),
              ),
            ),
          );
        });
      }),
    );
  }
}
