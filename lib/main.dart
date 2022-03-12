import 'dart:async';
import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/enum/connectivity_status.dart';
import 'package:mawaqit/src/helpers/AnalyticsWrapper.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/ConnectivityService.dart';
import 'package:mawaqit/src/pages/SplashScreen.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/settings_manager.dart';
import 'package:mawaqit/src/services/theme_manager.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // Sizer

    await GlobalConfiguration().loadFromAsset("configuration");

    await Firebase.initializeApp();

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
      );
    }).sendPort);

    if (kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    } else {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }

    // hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) async {
      if (systemOverlaysAreVisible) return;
      await Future.delayed(Duration(seconds: 3));
      SystemChrome.restoreSystemUIOverlays();
    });

    return runApp(
      ChangeNotifierProvider<ThemeNotifier>(
        create: (_) => new ThemeNotifier(),
        child: MyApp(),
      ),
    );
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppLanguage()),
        ChangeNotifierProvider(create: (context) => MosqueManager()),
        ChangeNotifierProvider(create: (context) => SettingsManager()),
      ],
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        return Sizer(builder: (context, orientation, size) {
          return StreamProvider(
            initialData: ConnectivityStatus.Offline,
            create: (context) => ConnectivityService().connectionStatusController.stream,
            child: Consumer<ThemeNotifier>(
              builder: (context, theme, _) => Shortcuts(
                shortcuts: {SingleActivator(LogicalKeyboardKey.select): ActivateIntent()},
                child: MaterialApp(
                  themeMode: theme.mode,
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
                  supportedLocales: S.delegate.supportedLocales,
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
