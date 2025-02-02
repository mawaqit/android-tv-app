import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mawaqit/main.dart';
import 'package:notification_overlay/notification_overlay.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

import '../../const/resource.dart';
import '../../i18n/l10n.dart';
import '../const/constants.dart';
import '../helpers/AppDate.dart';
import '../models/mosqueConfig.dart';
import '../models/times.dart';

class NotificationBackgroundService with WidgetsBindingObserver {
  static final NotificationBackgroundService _instance = NotificationBackgroundService._internal();
  static AudioPlayer? _audioPlayer;
  static final Set<DateTime> _scheduledTimes = {};
  static bool _isInitialized = false;
  static Timer? _notificationTimer;
  static bool _shouldShowNotification = false;

  Duration duration = Duration();

  factory NotificationBackgroundService() => _instance;

  NotificationBackgroundService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  static String getSalahName(int index) {
    final names = {
      0: S.current.fajr,
      1: S.current.duhr,
      2: S.current.asr,
      3: S.current.maghrib,
      4: S.current.isha,
    };
    return names[index] ?? '';
  }

  static Future<void> initializeService() async {
    if (_isInitialized) return;

    try {
      final service = FlutterBackgroundService();
      await _stopExistingService(service);
      await _configureAndStartService(service);
      await dismissExistingNotification();
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

  static Future<void> dismissExistingNotification() async {
    await NotificationOverlay.hideNotification();
  }

  static Future<void> pauseBackgroundOperations() async {
    final service = FlutterBackgroundService();
    if (!await service.isRunning()) return;

    service.invoke('pauseOperations');
    await Future.wait([
      dismissExistingNotification(),
      _audioPlayer?.stop() ?? Future.value(),
    ]);
    _notificationTimer?.cancel();
  }

  static Future<void> resumeBackgroundOperations() async {
    final service = FlutterBackgroundService();

    if (!await _ensureServiceRunning(service)) return;

    service.invoke('resumeOperations');
  }

  static String getAdhanLink(MosqueConfig? mosqueConfig, {bool useFajrAdhan = false}) {
    String baseLink = "$kStaticFilesUrl/mp3/adhan-afassy.mp3";

    if (mosqueConfig?.adhanVoice?.isNotEmpty ?? false) {
      baseLink = "$kStaticFilesUrl/mp3/${mosqueConfig!.adhanVoice!}.mp3";
    }

    if (useFajrAdhan && !baseLink.contains('bip')) {
      baseLink = baseLink.replaceAll('.mp3', '-fajr.mp3');
    }

    return baseLink;
  }

  static Future<void> schedulePrayerTasks(
    Times times,
    MosqueConfig? mosqueConfig,
    bool isAdhanVoiceEnabled,
    int salahIndex,
  ) async {
    final service = FlutterBackgroundService();
    if (!await service.isRunning()) return;

    final prayerTimes = times.dayTimesStrings(AppDateTime.now(), salahOnly: true);
    final now = AppDateTime.now();

    for (var i = 0; i < prayerTimes.length; i++) {
      final entry = prayerTimes[i];
      final scheduleTime = _parseScheduleTime(entry, now);

      if (!_shouldSchedulePrayer(scheduleTime)) continue;

      final prayerConfig = _createPrayerConfig(
        entry,
        scheduleTime,
        isAdhanVoiceEnabled,
        mosqueConfig,
        salahIndex == 0,
        i,
      );

      _schedulePrayerTimer(service, prayerConfig, scheduleTime);
    }
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

  static DateTime _parseScheduleTime(String entry, DateTime now) {
    final timeParts = entry.split(':');
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  static bool _shouldSchedulePrayer(DateTime scheduleTime) {
    if (_scheduledTimes.contains(scheduleTime)) return false;
    final delay = scheduleTime.difference(AppDateTime.now());
    return !delay.isNegative;
  }

  static Map<String, dynamic> _createPrayerConfig(
    String entry,
    DateTime scheduleTime,
    bool isAdhanVoiceEnabled,
    MosqueConfig? mosqueConfig,
    bool isFajr,
    int index,
  ) {
    String adhanAsset = "";
    bool adhanFromAssets = false;
    bool shouldPlayAdhan = false;

    if (isAdhanVoiceEnabled) {
      shouldPlayAdhan = true;
      final url = getAdhanLink(mosqueConfig, useFajrAdhan: isFajr);
      if (url.contains('bip')) {
        adhanFromAssets = true;
        adhanAsset = R.ASSETS_VOICES_ADHAN_BIP_MP3;
      } else {
        adhanAsset = url;
      }
    }
    final notificationFormat = S.current.prayerTimeNotification("{{salah}}", "{{time}}");
    return {
      'prayer': entry,
      'time': scheduleTime.toString(),
      'shouldPlayAdhan': shouldPlayAdhan,
      'adhanAsset': adhanAsset,
      'adhanFromAssets': adhanFromAssets,
      'salahName': getSalahName(index),
      'notificationFormat': notificationFormat
    };
  }

  static void _schedulePrayerTimer(
    FlutterBackgroundService service,
    Map<String, dynamic> config,
    DateTime scheduleTime,
  ) {
    final delay = scheduleTime.difference(AppDateTime.now());
    Timer(delay, () => service.invoke('prayerTime', config));
    _scheduledTimes.add(scheduleTime);
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

    bool shouldShowNotification = false;
    bool isPaused = false;

    _setupServiceListeners(service, shouldShowNotification, isPaused);
  }

  static void _setupServiceListeners(
    ServiceInstance service,
    bool shouldShowNotification,
    bool isPaused,
  ) {
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
      _audioPlayer?.stop();
      dismissExistingNotification();
      _notificationTimer?.cancel();
    });

    service.on('resumeOperations').listen((_) => isPaused = false);

    service.on('prayerTime').listen((event) async {
      if (event != null && !isPaused) {
        await _handlePrayerTime(event, shouldShowNotification);
      }
    });
  }

  static Future<void> _handlePrayerTime(
    Map<dynamic, dynamic> event,
    bool shouldShowNotification,
  ) async {
    if (!shouldShowNotification) return;

    final prayerName = event['prayer'] as String;
    final shouldPlayAdhan = event['shouldPlayAdhan'] as bool;
    final adhanAsset = event['adhanAsset'] as String;
    final adhanFromAssets = event['adhanFromAssets'] as bool;
    final salahName = event['salahName'] as String;
    final notificationFormat = event['notificationFormat'] as String;

    _audioPlayer = AudioPlayer();

    try {
      await dismissExistingNotification();
      final notificationText = notificationFormat.replaceAll('{{salah}}', salahName).replaceAll('{{time}}', prayerName);
      try {
        await NotificationOverlay.showNotification(notificationText);
      } catch (e) {
        print(e);
      }
      if (shouldPlayAdhan) {
        await _playPrayerAudio(adhanAsset, adhanFromAssets);
      }

      _scheduleNotificationDismissal();
    } catch (e) {
      await dismissExistingNotification();
    }
  }

  static Future<void> _playPrayerAudio(String adhanAsset, bool adhanFromAssets) async {
    final session = await _configureAudioSession();
    await session.setActive(true);

    try {
      if (adhanFromAssets) {
        await _audioPlayer?.setAsset(adhanAsset);
      } else {
        await _audioPlayer?.setUrl(adhanAsset);
      }

      await _audioPlayer?.play();

      _audioPlayer?.playbackEventStream.listen((event) {
        if (event.processingState == ProcessingState.completed) {
          session.setActive(false);
          dismissExistingNotification();
        }
      });
    } catch (e) {
      await session.setActive(false);
      await dismissExistingNotification();
    }
  }

  static Future<AudioSession> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        flags: AndroidAudioFlags.audibilityEnforced,
        usage: AndroidAudioUsage.alarm,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
    return session;
  }

  static void _scheduleNotificationDismissal() {
    _notificationTimer?.cancel();
    _notificationTimer = Timer(
      const Duration(minutes: 5),
      dismissExistingNotification,
    );
  }
}
