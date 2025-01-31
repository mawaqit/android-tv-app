import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mawaqit/src/services/salah_background_notification/adhan_audio_service.dart';
import 'package:mawaqit/src/services/salah_background_notification/prayer_notification_service.dart';
import 'package:mawaqit/src/services/salah_background_notification/prayer_scheduler_service.dart';
import 'package:notification_overlay/notification_overlay.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

import '../../const/resource.dart';
import '../../i18n/l10n.dart';
import '../const/constants.dart';
import '../helpers/AppDate.dart';
import '../models/mosqueConfig.dart';
import '../models/times.dart';

class BackgroundService with WidgetsBindingObserver {
  static final BackgroundService _instance = BackgroundService._internal();
  static bool _isInitialized = false;

  factory BackgroundService() => _instance;

  BackgroundService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  static Future<void> initializeService() async {
    if (_isInitialized) return;

    try {
      final service = FlutterBackgroundService();
      await _stopExistingService(service);
      await _configureAndStartService(service);
      await PrayerNotificationService.dismissNotification();
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
    PrayerNotificationService.setShouldShowNotification(shouldShow);
    final service = FlutterBackgroundService();

    if (!await _ensureServiceRunning(service)) return;

    service.invoke('updateNotificationVisibility', {'shouldShow': shouldShow});
  }

  static Future<void> pauseBackgroundOperations() async {
    final service = FlutterBackgroundService();
    if (!await service.isRunning()) return;

    service.invoke('pauseOperations');
    await Future.wait([
      PrayerNotificationService.dismissNotification(),
      AdhanAudioService.stopAdhan(),
    ]);
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

  // Background service handlers
  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    bool isPaused = false;

    _setupServiceListeners(service, isPaused);
  }

  static void _setupServiceListeners(
    ServiceInstance service,
    bool isPaused,
  ) {
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((_) => service.setAsForegroundService());
      service.on('setAsBackground').listen((_) => service.setAsBackgroundService());
    }

    service.on('stopService').listen((_) => service.stopSelf());

    service.on('updateNotificationVisibility').listen((event) {
      if (event?['shouldShow'] != null) {
        PrayerNotificationService.setShouldShowNotification(event!['shouldShow'] as bool);
      }
    });

    service.on('pauseOperations').listen((_) {
      isPaused = true;
      AdhanAudioService.stopAdhan();
      PrayerNotificationService.dismissNotification();
    });

    service.on('resumeOperations').listen((_) => isPaused = false);

    service.on('prayerTime').listen((event) async {
      if (event != null && !isPaused) {
        await _handlePrayerTime(event);
      }
    });
  }

  static Future<void> _handlePrayerTime(Map<dynamic, dynamic> event) async {
    final prayerName = event['prayer'] as String;
    final shouldPlayAdhan = event['shouldPlayAdhan'] as bool;
    final adhanAsset = event['adhanAsset'] as String;
    final adhanFromAssets = event['adhanFromAssets'] as bool;
    final salahName = event['salahName'] as String;
    final notificationFormat = event['notificationFormat'] as String;

    try {
      final notificationText = notificationFormat.replaceAll('{{salah}}', salahName).replaceAll('{{time}}', prayerName);

      await NotificationOverlay.showNotification(notificationText);

      if (shouldPlayAdhan) {
        await AdhanAudioService.playAdhan(adhanAsset, adhanFromAssets);
      }
    } catch (e) {
      await PrayerNotificationService.dismissNotification();
    }
  }

  static Future<void> schedulePrayerTasks(
    Times times,
    MosqueConfig? mosqueConfig,
    bool isAdhanVoiceEnabled,
    int salahIndex,
  ) async {
    await PrayerSchedulerService.schedulePrayerTasks(
      times,
      mosqueConfig,
      isAdhanVoiceEnabled,
      salahIndex,
    );
  }
}
