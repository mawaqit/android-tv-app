import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/models/settings.dart';
import 'package:mawaqit/src/pages/ErrorScreen.dart';
import 'package:mawaqit/src/pages/HomeScreen.dart';
import 'package:mawaqit/src/pages/onBoarding/OnBoardingScreen.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/settings_manager.dart';
import 'package:mawaqit/src/widgets/InfoWidget.dart';
import 'package:provider/provider.dart';
import 'package:rive_splash_screen/rive_splash_screen.dart';
import 'package:wakelock/wakelock.dart';

enum ErrorState { mosqueNotFound, noInternet, mosqueDataError }

class Splash extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _SplashScreen();
}

class _SplashScreen extends State<Splash> {
  SharedPref sharedPref = SharedPref();
  ErrorState? error;

  // bool applicationProblem = false;

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
      bool hasNoMosque = mosqueManager.mosqueUUID == null;

      if (hasNoMosque || goBoarding && settings.boarding == "1") {
        AppRouter.pushReplacement(OnBoardingScreen(settings));
      } else {
        AppRouter.pushReplacement(HomeScreen(settings));
      }
    } on DioError catch (e) {
      if (e.response == null) {
        setState(() => error = ErrorState.noInternet);

        // mosque not found
      } else {
        setState(() => error = ErrorState.mosqueNotFound);
        // e.response!.data;
      }
    } catch (e) {
      setState(() => error = ErrorState.mosqueDataError);
      rethrow;
    }
  }

  /// reset the app
  void _changeMosque() {
    AppRouter.pushReplacement(OnBoardingScreen(context.read<SettingsManager>().settings));
  }

  Widget build(BuildContext context) {
    RelativeSizes.instance.size = MediaQuery.of(context).size;

    switch (error) {
      case ErrorState.mosqueNotFound:
        return ErrorScreen(
          title: S.of(context).reset,
          description: S.of(context).mosqueNotFoundMessage,
          image: 'assets/img/icon_exit.png',
          onTryAgain: _changeMosque,
          tryAgainText: S.of(context).changeMosque,
        );
      case ErrorState.noInternet:
        return ErrorScreen(
          title: S.of(context).noInternet,
          description: S.of(context).noInternetMessage,
          image: 'assets/img/wifi.png',
          onTryAgain: _navigateToHome,
        );
      case ErrorState.mosqueDataError:
        return ErrorScreen(
          title: S.of(context).error,
          description: S.of(context).mosqueErrorMessage,
          image: 'assets/img/icon_exit.png',
          onTryAgain: _navigateToHome,
        );
      case null:
        break;
    }

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
            Container(
              padding: EdgeInsets.all(10),
              child: Opacity(child: VersionWidget(), opacity: .3),
              alignment: Alignment.bottomCenter,
            ),
          ],
        ),
      ),
    );
  }
}
