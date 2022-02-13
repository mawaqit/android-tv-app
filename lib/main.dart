import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flyweb/i18n/AppLanguage.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/helpers/ConnectivityService.dart';
import 'package:flyweb/src/helpers/SharedPref.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/pages/SplashScreen.dart';
import 'package:flyweb/src/services/mosque_manager.dart';
import 'package:flyweb/src/services/settings_manager.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPref sharedPref = SharedPref();
  Settings settings = new Settings();

  await GlobalConfiguration().loadFromAsset("configuration");

  try {
    var set = await sharedPref.read("settings");
    if (set != null) {
      settings = Settings.fromJson(set);
    }
  } catch (Excepetion) {}

  return runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => new ThemeNotifier(),
      child: MyApp(settings: settings),
    ),
  );
}

class MyApp extends StatelessWidget {
  // final AppLanguage appLanguage;
  final Settings? settings;

  const MyApp({this.settings});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AppLanguage()..fetchLocale(),
        ),
        ChangeNotifierProvider(create: (context) => MosqueManager()..init()),
        ChangeNotifierProvider(create: (context) => SettingsManager()..init()),
      ],
      //   providers:
      // create: (_) => appLanguage,
      child: Consumer<AppLanguage>(builder: (context, model, child) {
        // ignore: missing_required_param
        return StreamProvider(
          initialData: null,
          create: (context) =>
              ConnectivityService().connectionStatusController.stream,
          child: Consumer<ThemeNotifier>(
            builder: (context, theme, _) => MaterialApp(
              theme: theme.getTheme(),
              locale: model.appLocal,
              localizationsDelegates: [
                I18n.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: I18n.delegate.supportedLocales,
              debugShowCheckedModeBanner: false,
              home: SplashScreen(localSettings: this.settings),
            ),
          ),
        );
      }),
    );
  }
}
