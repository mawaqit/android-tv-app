import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mawaqit/src/models/times.dart';
import 'package:notification_overlay/notification_overlay.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

import '../../const/resource.dart';
import '../../i18n/l10n.dart';
import '../../main.dart';
import '../const/constants.dart';
import '../helpers/AppDate.dart';
import '../models/mosqueConfig.dart';
import 'mosque_manager.dart';
import 'audio_manager.dart';

class BackgroundService with WidgetsBindingObserver {
  static AudioPlayer? _audioPlayer;
  static Set<DateTime> _scheduledTimes = {};
  static bool _isInitialized = false;
  static Timer? _notificationTimer;
  static final BackgroundService _instance = BackgroundService._internal();
  static bool _shouldShowNotification = false;
  static String adhanAsset = "";
  static bool adhanfromAssets = false;
  static bool shouldPlayAdhan = false;
  MosqueManager? mosqueManager;
  AudioManager? audioManager;
  Duration duration = Duration();
  factory BackgroundService() {
    return _instance;
  }

  BackgroundService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }
  static String salahName(int index) {
    switch (index) {
      case 0:
        return S.current.fajr;
      case 1:
        return S.current.duhr;
      case 2:
        return S.current.asr;
      case 3:
        return S.current.maghrib;
      case 4:
        return S.current.isha;
      default:
        return '';
    }
  }

  static Future<void> setNotificationVisibility(bool shouldShow) async {
    _shouldShowNotification = shouldShow;
    // Update the background service
    final service = FlutterBackgroundService();

    service.invoke('updateNotificationVisibility', {'shouldShow': shouldShow});
  }

  static String adhanLink(MosqueConfig? mosqueConfig, {bool useFajrAdhan = false}) {
    String adhanLink = "$kStaticFilesUrl/mp3/adhan-afassy.mp3";

    if (mosqueConfig!.adhanVoice?.isNotEmpty ?? false) {
      adhanLink = "$kStaticFilesUrl/mp3/${mosqueConfig.adhanVoice!}.mp3";
    }

    if (useFajrAdhan && !adhanLink.contains('bip')) {
      adhanLink = adhanLink.replaceAll('.mp3', '-fajr.mp3');
    }

    return adhanLink;
  }

  static Future<void> pauseBackgroundOperations() async {
    final service = FlutterBackgroundService();
    service.invoke('pauseOperations');

    // Dismiss any existing notifications
    await dismissExistingNotification();

    // Stop audio playback if it's playing
    await _audioPlayer?.stop();

    // Cancel any scheduled timers
    _notificationTimer?.cancel();
  }

  static Future<void> resumeBackgroundOperations() async {
    final service = FlutterBackgroundService();
    service.invoke('resumeOperations');
  }

  static Future<void> initializeService() async {
    if (_isInitialized) return;

    final service = FlutterBackgroundService();

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

    _isInitialized = true;

    // Attempt to dismiss any existing notifications on initialization
    await dismissExistingNotification();
  }

  static Future<void> dismissExistingNotification() async {
    try {
      await NotificationOverlay.hideNotification();
    } catch (e) {
      logger.e('Error dismissing existing notification: $e', error: e);
    }
  }

  static Future<void> schedulePrayerTasks(
      Times times, MosqueConfig? mosqueConfig, bool isAdhanVoiceEnabled, int salahIndex) async {
    final service = FlutterBackgroundService();

    final prayerTimes = times.dayTimesStrings(AppDateTime.now(), salahOnly: true);
    for (var entry in prayerTimes) {
      final now = AppDateTime.now();
      final timeParts = entry.split(':');
      final scheduleTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      String adhanAssetToUse = "";
      bool adhanFromAssetsToUse = false;
      bool shouldPlayAdhanToUse = false;

      if (isAdhanVoiceEnabled) {
        shouldPlayAdhanToUse = true;
        final url = adhanLink(mosqueConfig, useFajrAdhan: salahIndex == 0);
        if (url.contains('bip')) {
          adhanFromAssetsToUse = true;
          adhanAssetToUse = R.ASSETS_VOICES_ADHAN_BIP_MP3;
        } else {
          adhanAssetToUse = url;
        }
      }

      if (_scheduledTimes.contains(scheduleTime)) {
        ;
        continue;
      }

      final delay = scheduleTime.difference(now);
      if (delay.isNegative) continue;

      Timer(delay, () {
        service.invoke('prayerTime', {
          'prayer': entry,
          'time': scheduleTime.toString(),
          'shouldPlayAdhan': shouldPlayAdhanToUse,
          'adhanAsset': adhanAssetToUse,
          'adhanFromAssets': adhanFromAssetsToUse,
          'salahName': salahName(prayerTimes.indexOf(entry))
        });
      });

      _scheduledTimes.add(scheduleTime);
    }
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });
    bool shouldShowNotification = false;

    service.on('updateNotificationVisibility').listen((event) {
      if (event != null && event['shouldShow'] != null) {
        shouldShowNotification = event['shouldShow'] as bool;

        if (!shouldShowNotification) {
          service.stopSelf();
        }
      }
    });
    bool isPaused = false;

    service.on('pauseOperations').listen((event) {
      isPaused = true;
      // Stop audio playback
      _audioPlayer?.stop();

      // Dismiss any existing notifications
      dismissExistingNotification();

      // Cancel any scheduled timers
      _notificationTimer?.cancel();
    });

    service.on('resumeOperations').listen((event) {
      isPaused = false;
    });
    service.on('prayerTime').listen((event) async {
      if (event != null && !isPaused) {
        final prayerName = event['prayer'] as String;
        final scheduledTime = DateTime.parse(event['time'] as String);
        final shouldPlayAdhan = event['shouldPlayAdhan'] as bool;
        final adhanAsset = event['adhanAsset'] as String;
        final adhanFromAssets = event['adhanFromAssets'] as bool;
        final salahName = event['salahName'] as String;

        // Check if we should show the notification
        if (shouldShowNotification) {
          // Initialize the audio player
          _audioPlayer = AudioPlayer();

          // Show notification and play audio
          try {
            await dismissExistingNotification();
            await NotificationOverlay.showNotification('$salahName time ($prayerName) notification');

            if (shouldPlayAdhan) {
              await playAudio(adhanAsset, adhanFromAssets);
            }

            // Set up a timer to dismiss the notification
            _notificationTimer?.cancel();
            _notificationTimer = Timer(Duration(minutes: 5), () async {
              await dismissExistingNotification();
            });

            _audioPlayer!.playbackEventStream.listen((event) {
              if (event.processingState == ProcessingState.completed) {
                dismissExistingNotification();
                _notificationTimer?.cancel();
              }
            });
          } catch (e) {
            logger.e('Error showing notification or playing audio in background: $e', error: e);
          }
        } else {
          print('App is in foreground, skipping notification');
        }
      }
    });
  }

  static Future<void> playAudio(String adhanAsset, bool adhanFromAssets) async {
    try {
      // Configure audio session
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

      // Activate the audio session
      await session.setActive(true);

      // Set the audio source and play
      if (adhanFromAssets) {
        await _audioPlayer?.setAsset(adhanAsset);
      } else {
        await _audioPlayer?.setUrl(adhanAsset);
      }
      await _audioPlayer?.play();

      // Deactivate the audio session when done
      _audioPlayer?.playbackEventStream.listen((event) {
        if (event.processingState == ProcessingState.completed) {
          session.setActive(false);
        }
      });
    } catch (e) {
      logger.e('Error playing audio: $e', error: e);
    }
  }
}
