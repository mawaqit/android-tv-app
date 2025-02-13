import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:notification_overlay/notification_overlay.dart';
import 'package:mawaqit/src/services/notification/notification_service.dart';
import 'package:mawaqit/src/services/notification/prayer_audio_service.dart';

class NotificationBackgroundService with WidgetsBindingObserver {
  static final NotificationBackgroundService _instance = NotificationBackgroundService._internal();
  static bool _isInitialized = false;
  static bool _shouldShowNotification = false;

  factory NotificationBackgroundService() => _instance;

  NotificationBackgroundService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Initializes and starts the background service.
  static Future<void> initializeService() async {
    if (_isInitialized) return;

    try {
      final service = FlutterBackgroundService();
      await _stopExistingService(service);
      await _configureAndStartService(service);
      await NotificationService.dismissNotification();
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await setNotificationVisibility(false);
        await pauseBackgroundOperations();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        await initializeService();
        await setNotificationVisibility(true);
        await resumeBackgroundOperations();
        break;
    }
  }

  static Future<void> setNotificationVisibility(bool shouldShow) async {
    _shouldShowNotification = shouldShow;
    final service = FlutterBackgroundService();
    if (!await _ensureServiceRunning(service)) return;
    service.invoke('updateNotificationVisibility', {'shouldShow': shouldShow});
  }

  static Future<void> pauseBackgroundOperations() async {
    final service = FlutterBackgroundService();
    if (!await service.isRunning()) return;
    service.invoke('pauseOperations');
    await NotificationService.dismissNotification();
    await PrayerAudioService.stopAudio();
  }

  static Future<void> resumeBackgroundOperations() async {
    final service = FlutterBackgroundService();
    if (!await _ensureServiceRunning(service)) return;
    service.invoke('resumeOperations');
  }

  static Future<bool> _ensureServiceRunning(FlutterBackgroundService service) async {
    if (!await service.isRunning()) {
      await initializeService();
      return await service.isRunning();
    }
    return true;
  }

  static Future<void> _stopExistingService(FlutterBackgroundService service) async {
    if (await service.isRunning()) {
      service.invoke('stopService');
    }
  }

  static Future<void> _configureAndStartService(FlutterBackgroundService service) async {
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
    await service.startService();
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Ensure Flutter bindings are initialized.
    WidgetsFlutterBinding.ensureInitialized();

    // Load the user’s preferred language.
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'en';
    final locale = Locale(langCode);
    final localizations = await AppLocalizations.delegate.load(locale);
    S.setCurrent(localizations);

    _setupServiceListeners(service);
  }

  static void _setupServiceListeners(ServiceInstance service) {
    bool isPaused = false;
    bool shouldShowNotification = _shouldShowNotification;

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((_) => service.setAsForegroundService());
      service.on('setAsBackground').listen((_) => service.setAsBackgroundService());
    }
    service.on('stopService').listen((_) => service.stopSelf());
    service.on('updateNotificationVisibility').listen((event) {
      if (event?['shouldShow'] != null) {
        shouldShowNotification = event!['shouldShow'] as bool;
      }
    });
    service.on('pauseOperations').listen((_) {
      isPaused = true;
      PrayerAudioService.stopAudio();
      NotificationService.dismissNotification();
    });
    service.on('resumeOperations').listen((_) => isPaused = false);
    service.on('prayerTime').listen((event) async {
      if (event != null && !isPaused && shouldShowNotification) {
        await _handlePrayerTime(event);
      }
    });
  }

  static Future<void> _handlePrayerTime(Map<dynamic, dynamic> event) async {
    // Extract values from the event.
    final prayerName = event['prayer'] as String;
    final shouldPlayAdhan = event['shouldPlayAdhan'] as bool;
    final adhanAsset = event['adhanAsset'] as String;
    final adhanFromAssets = event['adhanFromAssets'] as bool;
    final salahName = event['salahName'] as String;

    // Show notification.
    await NotificationService.showPrayerNotification(salahName, prayerName);

    // Play audio if enabled.
    if (shouldPlayAdhan) {
      await PrayerAudioService.playPrayer(adhanAsset, adhanFromAssets);
    }
  }
}
