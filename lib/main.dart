import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

// import 'package:flutter_kurdish_localization/flutter_kurdish_localization.dart';
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
import 'package:mawaqit/src/services/theme_manager.dart';
import 'package:mawaqit/src/services/toggle_screen_feature_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/services/background_work_managers/work_manager_services.dart';
import 'package:notification_overlay/notification_overlay.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:mawaqit/src/routes/route_generator.dart';
// import 'package:montenegrin_localization/montenegrin_localization.dart';

final logger = Logger();

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

        // Check and request permissions
        await _initializePermissions();

        // Initialize other services
        await _initializeServices();

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

Future<void> _handleOverlayPermissions(String deviceModel, bool isRooted) async {
  final methodChannel = MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel);
  final isPermissionGranted = await NotificationOverlay.checkOverlayPermission();

  if (RegExp(r'ONVO.*').hasMatch(deviceModel)) {
    await methodChannel.invokeMethod("grantOnvoOverlayPermission");
    return;
  }

  if (!isPermissionGranted) {
    if (isRooted) {
      await methodChannel.invokeMethod("grantOverlayPermission");
    } else {
      await NotificationOverlay.requestOverlayPermission();
      await checkAndRequestExactAlarmPermission();
    }
  }
}

Future<void> _initializePermissions() async {
  final isRooted =
      await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel).invokeMethod(TurnOnOffTvConstant.kCheckRoot);
  final deviceModel = await _getDeviceModel();
  await _handleOverlayPermissions(deviceModel, isRooted);
  await UnifiedBackgroundService.initializeService();
}

Future<String> _getDeviceModel() async {
  var hardware = await DeviceInfoPlugin().androidInfo;
  return hardware.model;
}

Future<void> checkAndRequestExactAlarmPermission() async {
  if (Platform.isAndroid) {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    if (androidInfo.version.sdkInt >= 33) {
      final status = await Permission.scheduleExactAlarm.status;

      if (status.isDenied) {
        final result = await Permission.scheduleExactAlarm.request();

        if (result.isDenied) {
          developer.log('Exact alarm not granted error');
        }
      }
    }
  }
}

@pragma("vm:entry-point")
Future<void> _initializeServices() async {
  tz.initializeTimeZones();
  await WorkManagerService.initialize();
  // Register Hive adapters
  Hive.registerAdapter(SurahModelAdapter());
  Hive.registerAdapter(ReciterModelAdapter());
  Hive.registerAdapter(MoshafModelAdapter());

  // Initialize media kit
  MediaKit.ensureInitialized();
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
    UnifiedBackgroundService.setNotificationVisibility(false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    UnifiedBackgroundService().didChangeAppLifecycleState(state);
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
                  child: MaterialApp(
                    title: kAppName,
                    themeMode: theme.mode,
                    localeResolutionCallback: (locale, supportedLocales) {
                      if (locale?.languageCode.toLowerCase() == 'ba') return Locale('en');

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
                      // MontenegrinMaterialLocalizations.delegate,
                      // MontenegrinWidgetsLocalizations.delegate,
                      // MontenegrinCupertinoLocalizations.delegate,
                      S.delegate,
                      GlobalCupertinoLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      // KurdishMaterialLocalizations.delegate,
                      // KurdishWidgetLocalizations.delegate,
                      // KurdishCupertinoLocalizations.delegate
                    ],
                    supportedLocales: S.supportedLocales,
                    debugShowCheckedModeBanner: false,
                    onGenerateRoute: RouteGenerator.generateRoute,
                    home: Splash(),
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
