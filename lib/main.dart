import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_kurdish_localization/kurdish_cupertino_localization_delegate.dart';
import 'package:flutter_kurdish_localization/kurdish_material_localization_delegate.dart';
import 'package:flutter_kurdish_localization/kurdish_widget_localization_delegate.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:hive_flutter/adapters.dart';
import 'package:logger/logger.dart';
import 'package:mawaqit/firebase_options.dart';

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
import 'package:mawaqit/src/services/background_services.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/permissions_manager.dart';
import 'package:mawaqit/src/services/theme_manager.dart';
import 'package:mawaqit/src/services/toggle_screen_feature_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/services/background_work_managers/work_manager_services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:mawaqit/src/routes/route_generator.dart';

import 'package:montenegrin_localization/montenegrin_localization.dart';
import 'package:flutter_kurdish_localization/flutter_kurdish_localization.dart';

final logger = Logger();

// Flag to track whether the app is in foreground
bool _isAppInForeground = false;

@pragma("vm:entry-point")
Future<void> main() async {
  await CrashlyticsWrapper.init(
    () async {
      try {
        WidgetsFlutterBinding.ensureInitialized();

        final firebaseOptions = FirebaseOptions(
          apiKey: const String.fromEnvironment('mawaqit.firebase.api_key'),
          appId: const String.fromEnvironment('mawaqit.firebase.app_id'),
          messagingSenderId: const String.fromEnvironment('mawaqit.firebase.messaging_sender_id'),
          projectId: const String.fromEnvironment('mawaqit.firebase.project_id'),
          storageBucket: const String.fromEnvironment('mawaqit.firebase.storage_bucket'),
        );

        await Firebase.initializeApp(
          options: firebaseOptions,
        );

        final directory = await getApplicationDocumentsDirectory();
        Hive.init(directory.path);
        await FastCachedImageConfig.init(subDir: directory.path, clearCacheAfter: const Duration(days: 60));

        await _initializeCoreServices();

        runApp(
          riverpod.ProviderScope(
            child: MyApp(),
            observers: [
              RiverpodLogger(),
              RiverpodSentryProviderObserver(),
            ],
          ),
        );
      } catch (e, stackTrace) {
        developer.log('Initialization error', error: e, stackTrace: stackTrace);
        rethrow;
      }
    },
  );
}

// Only initialize non-background services
@pragma("vm:entry-point")
Future<void> _initializeCoreServices() async {
  try {
    tz.initializeTimeZones();

    // Register Hive adapters
    Hive.registerAdapter(SurahModelAdapter());
    Hive.registerAdapter(ReciterModelAdapter());
    Hive.registerAdapter(MoshafModelAdapter());

    // Initialize media kit
    MediaKit.ensureInitialized();
  } catch (e, stackTrace) {
    developer.log('Core services initialization error', error: e, stackTrace: stackTrace);
  }
}

// Safe initialization of background services
Future<void> _safelyInitializeBackgroundServices() async {
  try {
    // Only initialize if app is in foreground
    if (!_isAppInForeground) {
      developer.log('Skipping background service initialization - app not in foreground');
      return;
    }

    developer.log('Starting background services initialization');

    // Initialize permissions using the PermissionsManager
    try {
      await PermissionsManager.initializePermissions();
      developer.log('Permissions initialized successfully');
    } catch (e) {
      developer.log('Permissions initialization error', error: e);
    }

    try {
      await WorkManagerService.initialize();
      developer.log('WorkManagerService initialized successfully');
    } catch (e) {
      developer.log('WorkManagerService initialization error', error: e);
    }

    try {
      await UnifiedBackgroundService.initializeService();
      developer.log('UnifiedBackgroundService initialized successfully');

      UnifiedBackgroundService.setNotificationVisibility(false);
    } catch (e) {
      developer.log('UnifiedBackgroundService initialization error', error: e);
    }

    developer.log('Background services initialization completed');
  } catch (e, stackTrace) {
    developer.log('Background services initialization error', error: e, stackTrace: stackTrace);
  }
}

class MyApp extends riverpod.ConsumerStatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends riverpod.ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize background services when app is fully started
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBackgroundServicesWhenReady();
    });
  }

  Future<void> _initializeBackgroundServicesWhenReady() async {
    // Wait to ensure app is in foreground
    await Future.delayed(const Duration(seconds: 3));

    _isAppInForeground = true;
    await _safelyInitializeBackgroundServices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isAppInForeground = false;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppInForeground = state == AppLifecycleState.resumed;

    // Only call this if service is initialized
    try {
      UnifiedBackgroundService().didChangeAppLifecycleState(state);
    } catch (e) {
      // Ignore errors if service not initialized
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  child: SentryWidget(
                    child: MaterialApp(
                      title: kAppName,
                      themeMode: theme.mode,
                      localeResolutionCallback: (locale, supportedLocales) {
                        if (locale?.languageCode.toLowerCase() == 'ba' || locale?.languageCode.toLowerCase() == 'ff')
                          return Locale('en');

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
                        KurdishCupertinoLocalizations.delegate,
                      ],
                      supportedLocales: S.supportedLocales,
                      debugShowCheckedModeBanner: false,
                      onGenerateRoute: RouteGenerator.generateRoute,
                      home: Splash(),
                    ),
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
