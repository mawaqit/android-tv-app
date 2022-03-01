import 'dart:async';
import 'dart:isolate';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flyweb/generated/l10n.dart';
import 'package:flyweb/i18n/AppLanguage.dart';
import 'package:flyweb/src/helpers/AnalyticsWrapper.dart';
import 'package:flyweb/src/helpers/AppRouter.dart';
import 'package:flyweb/src/helpers/ConnectivityService.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/pages/SplashScreen.dart';
import 'package:flyweb/src/repository/settings_service.dart';
import 'package:flyweb/src/services/mosque_manager.dart';
import 'package:flyweb/src/services/settings_manager.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

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

    final settings = await SettingsService().getLocalSettings();

    return runApp(
      ChangeNotifierProvider<ThemeNotifier>(
        create: (_) => new ThemeNotifier(),
        child: MyApp(settings: settings),
      ),
    );
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

class MyApp extends StatelessWidget {
  // final AppLanguage appLanguage;
  final Settings? settings;

  const MyApp({this.settings});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppLanguage()..fetchLocale()),
        ChangeNotifierProvider(create: (context) => MosqueManager()..init()),
        ChangeNotifierProvider(create: (context) => SettingsManager()..init()),
      ],
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        // ignore: missing_required_param
        return StreamProvider(
          initialData: null,
          create: (context) => ConnectivityService().connectionStatusController.stream,
          child: Consumer<ThemeNotifier>(
            builder: (context, theme, _) => Shortcuts(
              shortcuts: {SingleActivator(LogicalKeyboardKey.select): ActivateIntent()},
              child: MaterialApp(
                theme: theme.getTheme(),
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
                home: SplashScreen(localSettings: this.settings),
              ),
            ),
          ),
        );
      }),
    );
  }
}
