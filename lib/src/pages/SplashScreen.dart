import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/models/settings.dart';
import 'package:mawaqit/src/pages/HomeScreen.dart';
import 'package:mawaqit/src/pages/onBoarding/OnBoardingScreen.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/settings_manager.dart';
import 'package:provider/provider.dart';
import 'package:rive_splash_screen/rive_splash_screen.dart';
import 'package:wakelock/wakelock.dart';

class Splash extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SplashScreen();
}

class _SplashScreen extends State<Splash> {
  SharedPref sharedPref = SharedPref();
  bool applicationProblem = false;

  Future<Settings> _initSettings() async {
    await context.read<AppLanguage>().fetchLocale();
    await context.read<MosqueManager>().init();

    final settingsManage = context.read<SettingsManager>();

    await settingsManage.init();
    return settingsManage.settings;
  }

  Future<bool> loadBoarding() async {
    var res = await sharedPref.read("boarding");
    return res == null;
  }

  /// navigates to first screen
  void _navigateToHome() async {
    try {
      Wakelock.enable().catchError((e) {});

      var settings = await _initSettings();

      var goBoarding = await loadBoarding();
      var mosqueManager = context.read<MosqueManager>();
      bool hasNoMosque = mosqueManager.mosqueId == null;

      if (hasNoMosque || goBoarding && settings.boarding == "1") {
        AppRouter.pushReplacement(OnBoardingScreen(settings));
      } else {
        AppRouter.pushReplacement(HomeScreen(settings));
      }
    } catch (e) {
      setState(() => applicationProblem = true);
      rethrow;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(
              'assets/backgrounds/splash_screen_5.png',
              fit: BoxFit.cover,
            ),
            Container(
              width: double.infinity,
              child: SplashScreen.callback(
                isLoading: false,
                onSuccess: (e) => _navigateToHome(),
                onError: (error, stacktrace) {},
                name: 'assets/animations/rive/mawaqit_logo_animation1.riv',
                fit: BoxFit.cover,
                startAnimation: 'idle',
                loopAnimation: 'loading_light',
                endAnimation: 'loaded_text_light',
                width: 100,
                height: 100,
              ),
            ),
            if (applicationProblem)
              Align(
                alignment: Alignment(0, .3),
                child: Text(
                  S.of(context).backendError,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.redAccent.withOpacity(.6),
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
