import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/CrashlyticsWrapper.dart';
import 'package:mawaqit/src/helpers/HttpOverrides.dart';
import 'package:mawaqit/src/helpers/PerformanceHelper.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/helpers/StreamGenerator.dart';
import 'package:mawaqit/src/models/settings.dart';
import 'package:mawaqit/src/pages/ErrorScreen.dart';
import 'package:mawaqit/src/pages/home/OfflineHomeScreen.dart';
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
  final animationFuture = Completer<void>();

  SharedPref sharedPref = SharedPref();
  ErrorState? error;

  void initState() {
    super.initState();
    _initApplication().logPerformance('Init application');
  }

  // bool applicationProblem = false;

  Future<void> initApplicationUI() async {
    await GlobalConfiguration().loadFromAsset("configuration");
    generateStream(Duration(minutes: 10)).listen((event) => Wakelock.enable().catchError(CrashlyticsWrapper.sendException));

    await AppDateFixer.init();

    Hive.initFlutter();

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

    HttpOverrides.global = MyHttpOverrides();
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;

    // hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) async {
      if (systemOverlaysAreVisible) return;
      await Future.delayed(Duration(seconds: 3));
      SystemChrome.restoreSystemUIOverlays();
    });
  }

  Future<Settings> _initSettings() async {
    await context.read<AppLanguage>().fetchLocale();
    await context.read<MosqueManager>().init().logPerformance("Mosque manager");

    final settingsManage = context.read<SettingsManager>();

    await settingsManage.init().logPerformance('Setting manager');
    return settingsManage.settings;
  }

  Future<bool> loadBoarding() async {
    var res = await sharedPref.read("boarding");

    return res == null;
  }

  /// navigates to first screen
  Future<void> _initApplication() async {
    try {
      await initApplicationUI();
      var settings = await _initSettings();
      var goBoarding = await loadBoarding();
      var mosqueManager = context.read<MosqueManager>();
      bool hasNoMosque = mosqueManager.mosqueUUID == null;

      /// waite for the animation if it is not loaded yet
      await animationFuture.future;

      if (hasNoMosque || goBoarding && settings.boarding == "1") {
        AppRouter.pushReplacement(OnBoardingScreen());
      } else {
        AppRouter.pushReplacement(OfflineHomeScreen());
      }
    } on DioError catch (e) {
      if (e.response == null) {
        print('no internet connection');
        print(e.requestOptions.uri);
        setState(() => error = ErrorState.noInternet);

        // mosque not found
      } else {
        setState(() => error = ErrorState.mosqueNotFound);
        // e.response!.data;
      }
    } catch (e, stack) {
      logger.e(e, '', stack);
      setState(() => error = ErrorState.mosqueDataError);
      rethrow;
    }
  }

  /// reset the app
  void _changeMosque() {
    AppRouter.pushReplacement(OnBoardingScreen());
  }

  Widget build(BuildContext context) {
    RelativeSizes.instance.size = MediaQuery.of(context).size;

    switch (error) {
      case ErrorState.mosqueNotFound:
        return ErrorScreen(
          title: S.of(context).reset,
          description: S.of(context).mosqueNotFoundMessage,
          image: R.ASSETS_IMG_ICON_EXIT_PNG,
          onTryAgain: _changeMosque,
          tryAgainText: S.of(context).changeMosque,
        );
      case ErrorState.noInternet:
        return ErrorScreen(
          title: S.of(context).noInternet,
          description: S.of(context).noInternetMessage,
          image: R.ASSETS_SVG_NO_WI_FI_SVG,
          onTryAgain: _initApplication,
        );
      case ErrorState.mosqueDataError:
        return ErrorScreen(
          title: S.of(context).error,
          description: S.of(context).mosqueErrorMessage,
          image: R.ASSETS_IMG_ICON_EXIT_PNG,
          onTryAgain: _initApplication,
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
              R.ASSETS_BACKGROUNDS_SPLASH_SCREEN_5_PNG,
              fit: BoxFit.cover,
            ),
            RepaintBoundary(
              child: Container(
                width: double.infinity,
                child: SplashScreen.callback(
                  isLoading: false,
                  onSuccess: (e) => animationFuture.complete(),
                  onError: (error, stacktrace) => animationFuture.completeError(error, stacktrace),
                  name: R.ASSETS_ANIMATIONS_RIVE_MAWAQIT_LOGO_ANIMATION1_RIV,
                  fit: BoxFit.cover,
                  startAnimation: 'idle',
                  loopAnimation: 'loading_light',
                  endAnimation: 'loaded_text_light',
                  width: 100,
                  height: 100,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Opacity(child: VersionWidget(), opacity: 1),
              alignment: Alignment.bottomCenter,
            ),
          ],
        ),
      ),
    );
  }
}
