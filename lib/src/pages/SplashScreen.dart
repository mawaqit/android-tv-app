import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/CrashlyticsWrapper.dart';
import 'package:mawaqit/src/helpers/HttpOverrides.dart';
import 'package:mawaqit/src/helpers/PerformanceHelper.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/helpers/StreamGenerator.dart';
import 'package:mawaqit/src/pages/ErrorScreen.dart';
import 'package:mawaqit/src/pages/home/OfflineHomeScreen.dart';
import 'package:mawaqit/src/pages/onBoarding/OnBoardingScreen.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/state_management/random_hadith/random_hadith_notifier.dart';
import 'package:mawaqit/src/widgets/InfoWidget.dart';
import 'package:notification_overlay/notification_overlay.dart';
import 'package:provider/provider.dart';
import 'package:rive_splash_screen/rive_splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../helpers/AppDate.dart';
import '../helpers/connectivity_provider.dart';
import '../models/address_model.dart';
import '../services/FeatureManager.dart';
import '../services/notification_background_service.dart';
import 'home/widgets/show_check_internet_dialog.dart';
import 'onBoarding/widgets/onboarding_timezone_selector.dart';
import '../services/storage_manager.dart';

enum ErrorState { mosqueNotFound, noInternet, mosqueDataError }

class Splash extends ConsumerStatefulWidget {
  const Splash({super.key});

  @override
  ConsumerState createState() => _SpashState();
}

class _SpashState extends ConsumerState<Splash> {
  final animationFuture = Completer<void>();

  SharedPref sharedPref = SharedPref();
  ErrorState? error;

  void initState() {
    super.initState();
    print("[DEBUG][Splash] initState called");
    _initApplication().logPerformance('Init application');
  }

  // bool applicationProblem = false;

  Future<void> initApplicationUI() async {
    print("[DEBUG][Splash] Starting initApplicationUI");
    await GlobalConfiguration().loadFromAsset("configuration");
    print("[DEBUG][Splash] GlobalConfiguration loaded");

    Hive.initFlutter();
    print("[DEBUG][Splash] Hive initialized");

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
    print("[DEBUG][Splash] Crashlytics configured");

    HttpOverrides.global = MyHttpOverrides();
    print("[DEBUG][Splash] HTTP overrides set");
    
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
    print("[DEBUG][Splash] Focus highlight strategy set");

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    print("[DEBUG][Splash] System UI mode set to immersive");
    
    SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) async {
      print(
          "[DEBUG][Splash] System UI change callback triggered - overlays visible: $systemOverlaysAreVisible");
      if (systemOverlaysAreVisible) return;
      await Future.delayed(Duration(seconds: 3));
      SystemChrome.restoreSystemUIOverlays();
      print("[DEBUG][Splash] System UI overlays restored");
    });
    
    print("[DEBUG][Splash] About to save scheduled events to locale");
    await _saveScheduledEventsToLocale();
    print("[DEBUG][Splash] Completed initApplicationUI");
  }

  Future<void> _saveScheduledEventsToLocale() async {
    print("[DEBUG][Splash] Starting _saveScheduledEventsToLocale");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    print("[DEBUG][Splash] SharedPreferences instance obtained");

    logger.d("Saving into local");
    prefs.setBool("isEventsSet", false);
    print("[DEBUG][Splash] isEventsSet saved as false");
  }

  Future<void> _initSettings() async {
    print("[DEBUG][Splash] Starting _initSettings");
    FeatureManagerProvider.initialize(context);
    print("[DEBUG][Splash] FeatureManagerProvider initialized");
    
    await context.read<AppLanguage>().fetchLocale();
    print("[DEBUG][Splash] AppLanguage locale fetched");
    
    await context.read<MosqueManager>().init().logPerformance("Mosque manager");
    print("[DEBUG][Splash] MosqueManager initialized");
    
    MosqueManager.setInstance(context.read<MosqueManager>());
    print("[DEBUG][Splash] MosqueManager instance set");
  }

  Future<bool> loadBoarding() async {
    print("[DEBUG][Splash] Starting loadBoarding");
    var res = await sharedPref.read("boarding");
    print("[DEBUG][Splash] Boarding value read: $res");
    return res == null;
  }

  /// navigates to first screen
  Future<void> _initApplication() async {
    print("[DEBUG][Splash] Starting _initApplication");
    try {
      print("[DEBUG][Splash] Calling initApplicationUI");
      await initApplicationUI();
      print("[DEBUG][Splash] initApplicationUI completed");
      
      print("[DEBUG][Splash] Calling _initSettings");
      await _initSettings();
      print("[DEBUG][Splash] _initSettings completed");

      print("[DEBUG][Splash] Checking boarding status");
      var goBoarding = await loadBoarding();
      print("[DEBUG][Splash] Boarding status: $goBoarding");
      
      var mosqueManager = context.read<MosqueManager>();
      bool hasNoMosque = mosqueManager.mosqueUUID == null;
      print(
          "[DEBUG][Splash] Has no mosque: $hasNoMosque, UUID: ${mosqueManager.mosqueUUID}");

      /// waite for the animation if it is not loaded yet
      print("[DEBUG][Splash] Waiting for animation to complete");
      await animationFuture.future;
      print("[DEBUG][Splash] Animation completed");

      if (hasNoMosque || goBoarding) {
        print("[DEBUG][Splash] Navigating to OnBoardingScreen");
        AppRouter.pushReplacement(OnBoardingScreen());
      } else {
        print("[DEBUG][Splash] Navigating to OfflineHomeScreen");
        AppRouter.pushReplacement(OfflineHomeScreen());
      }
      
      print("[DEBUG][Splash] Setting up wakelock timer");
      generateStream(Duration(minutes: 10))
          .listen((event) {
        print("[DEBUG][Splash] Enabling wakelock");
        WakelockPlus.enable().catchError((e) {
          print("[DEBUG][Splash] Error enabling wakelock: $e");
          CrashlyticsWrapper.sendException;
        });
      });
      
    } on DioError catch (e) {
      if (e.response == null) {
        print(
            '[DEBUG][Splash] DioError: no internet connection for ${e.requestOptions.uri}');
        setState(() {
          error = ErrorState.noInternet;
          print("[DEBUG][Splash] Error state set to: $error");
        });

        // mosque not found
      } else {
        print(
            '[DEBUG][Splash] DioError: mosque not found, response: ${e.response}');
        setState(() {
          error = ErrorState.mosqueNotFound;
          print("[DEBUG][Splash] Error state set to: $error");
        });
        // e.response!.data;
      }
    } catch (e, stack) {
      print('[DEBUG][Splash] Exception during initialization: $e');
      logger.e(e, stackTrace: stack);
      setState(() {
        error = ErrorState.mosqueDataError;
        print("[DEBUG][Splash] Error state set to: $error");
      });
      rethrow;
    }
  }

  /// reset the app
  void _changeMosque() {
    print("[DEBUG][Splash] Changing mosque - navigating to OnBoardingScreen");
    AppRouter.pushReplacement(OnBoardingScreen());
  }

  Widget build(BuildContext context) {
    print("[DEBUG][Splash] Building Splash widget, error state: $error");
    RelativeSizes.instance.size = MediaQuery.of(context).size;
    print("[DEBUG][Splash] Screen size: ${MediaQuery.of(context).size}");

    switch (error) {
      case ErrorState.mosqueNotFound:
        print("[DEBUG][Splash] Rendering mosque not found error screen");
        return ErrorScreen(
          title: S.of(context).reset,
          description: S.of(context).mosqueNotFoundMessage,
          image: R.ASSETS_IMG_ICON_EXIT_PNG,
          onTryAgain: _changeMosque,
          tryAgainText: S.of(context).changeMosque,
        );
      case ErrorState.noInternet:
        print("[DEBUG][Splash] Rendering no internet error screen");
        return ErrorScreen(
          title: S.of(context).noInternet,
          description: S.of(context).noInternetMessage,
          image: R.ASSETS_SVG_NO_WI_FI_SVG,
          onTryAgain: _initApplication,
        );
      case ErrorState.mosqueDataError:
        print("[DEBUG][Splash] Rendering mosque data error screen");
        return ErrorScreen(
          title: S.of(context).error,
          description: S.of(context).mosqueErrorMessage,
          image: R.ASSETS_IMG_ICON_EXIT_PNG,
          onTryAgain: _initApplication,
        );
      case null:
        print("[DEBUG][Splash] Rendering normal splash screen");
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
                  onSuccess: (e) {
                    print(
                        "[DEBUG][Splash] Rive animation completed successfully");
                    animationFuture.complete();
                  },
                  onError: (error, stacktrace) {
                    print("[DEBUG][Splash] Rive animation error: $error");
                    animationFuture.completeError(error, stacktrace);
                  },
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
