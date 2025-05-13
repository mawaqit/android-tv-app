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
import 'home/widgets/show_check_internet_dialog.dart';
import 'onBoarding/widgets/onboarding_timezone_selector.dart';
import '../services/storage_manager.dart';

enum ErrorState { mosqueNotFound, noInternet, mosqueDataError }

class Splash extends ConsumerStatefulWidget {
  const Splash({super.key});

  @override
  ConsumerState createState() => _SpashState();
}

class _SpashState extends ConsumerState<Splash> with WidgetsBindingObserver {
  final SharedPref sharedPref = SharedPref();
  ErrorState? error;
  bool _isNavigating = false;
  late final Future<bool> _boardingStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Start initialization
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Wait for app initialization (Firebase and critical services)
      // This ensures Firebase is properly initialized before we use it
      if (!appInitialized.isCompleted) {
        await appInitialized.future.timeout(Duration(seconds: 5), onTimeout: () {
          logger.w("App initialization timed out, continuing with splash flow");
        });
      }

      // Initialize UI components
      await _initAppUI();

      // Load boarding status
      _boardingStatus = _loadBoardingStatus();

      // Initialize mosque data
      await _initMosqueData();

      // Ready to navigate
      setState(() {
        _isLoading = false;
      });

      // Allow minimal time for animation
      await Future.delayed(Duration(milliseconds: 300));

      // Navigate to next screen
      final showBoarding = await _boardingStatus;
      _navigateToNextScreen(showBoarding);
    } catch (e, stack) {
      logger.e("Splash initialization error: $e", stackTrace: stack);

      // Still try to navigate after delay to avoid getting stuck
      Future.delayed(Duration(seconds: 2), () {
        if (!mounted) return;
        final mosqueManager = context.read<MosqueManager>();
        bool hasNoMosque = mosqueManager.mosqueUUID == null;
        _navigateToNextScreen(hasNoMosque);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Initialize UI components
  Future<void> _initAppUI() async {
    try {
      await GlobalConfiguration().loadFromAsset("configuration");

      // Set system UI configurations
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) async {
        if (systemOverlaysAreVisible) return;
        await Future.delayed(Duration(seconds: 3));
        SystemChrome.restoreSystemUIOverlays();
      });

      // Initialize HTTP overrides and focus settings
      HttpOverrides.global = MyHttpOverrides();
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;

      // Configure crashlytics
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

      // Initialize wakelock as a background task
      generateStream(Duration(minutes: 10))
          .listen((event) => WakelockPlus.enable().catchError(CrashlyticsWrapper.sendException));
    } catch (e, stack) {
      logger.e("UI initialization error $e", stackTrace: stack);
    }
  }

  // Load boarding status
  Future<bool> _loadBoardingStatus() async {
    try {
      var res = await sharedPref.read("boarding");
      return res == null;
    } catch (e) {
      logger.e("Error loading boarding status $e");
      return true;
    }
  }

  // Initialize mosque data
  Future<void> _initMosqueData() async {
    try {
      // Feature manager initialization
      FeatureManagerProvider.initialize(context);

      // Initialize language preferences
      await context.read<AppLanguage>().fetchLocale();

      // Initialize mosque manager
      await context.read<MosqueManager>().init();
      MosqueManager.setInstance(context.read<MosqueManager>());
    } on DioError catch (e) {
      if (e.response == null) {
        logger.w('No internet connection: ${e.requestOptions.uri}');
        if (mounted) setState(() => error = ErrorState.noInternet);
      } else {
        if (mounted) setState(() => error = ErrorState.mosqueNotFound);
      }
    } catch (e, stack) {
      logger.e("Mosque data initialization error $e", stackTrace: stack);
      if (mounted) setState(() => error = ErrorState.mosqueDataError);
    }
  }

  // Navigate to the appropriate screen
  void _navigateToNextScreen(bool showBoarding) {
    if (_isNavigating || !mounted) return;

    _isNavigating = true;

    final mosqueManager = context.read<MosqueManager>();
    bool hasNoMosque = mosqueManager.mosqueUUID == null;

    if (hasNoMosque || showBoarding) {
      AppRouter.pushReplacement(OnBoardingScreen());
    } else {
      AppRouter.pushReplacement(OfflineHomeScreen());
    }
  }

  // Reset the app and go to boarding
  void _changeMosque() {
    if (_isNavigating) return;
    _isNavigating = true;
    AppRouter.pushReplacement(OnBoardingScreen());
  }

  // Retry initialization
  void _retryInitialization() {
    setState(() {
      error = null;
      _isNavigating = false;
      _isLoading = true;
    });

    _initialize();
  }

  @override
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
          onTryAgain: _retryInitialization,
        );
      case ErrorState.mosqueDataError:
        return ErrorScreen(
          title: S.of(context).error,
          description: S.of(context).mosqueErrorMessage,
          image: R.ASSETS_IMG_ICON_EXIT_PNG,
          onTryAgain: _retryInitialization,
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
                  isLoading: _isLoading,
                  onSuccess: (e) {
                    if (!_isLoading) {
                      _boardingStatus.then(_navigateToNextScreen);
                    }
                  },
                  onError: (error, stacktrace) {
                    logger.e("Animation error $error", stackTrace: stacktrace);
                    if (!_isLoading) {
                      _boardingStatus.then(_navigateToNextScreen);
                    }
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
