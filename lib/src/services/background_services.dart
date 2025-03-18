import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:notification_overlay/notification_overlay.dart';
import 'package:mawaqit/src/services/notification/notification_service.dart';
import 'package:mawaqit/src/services/notification/prayer_audio_service.dart';

/// Unified background service that handles both audio scheduling and prayer notifications
import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/services/notification/notification_service.dart';
import 'package:mawaqit/src/services/notification/prayer_audio_service.dart';

class UnifiedBackgroundService with WidgetsBindingObserver {
  static final UnifiedBackgroundService _instance = UnifiedBackgroundService._internal();
  static bool _isInitialized = false;
  static bool _shouldShowNotification = false;
  static AudioPlayer? _audioPlayer;
  static Duration? _savedPosition;

  factory UnifiedBackgroundService() => _instance;

  UnifiedBackgroundService._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  static bool isPlaying() => _audioPlayer?.playing ?? false;
  static AudioPlayer? get player => _audioPlayer;

  /// Initialize the unified background service
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
    await stopPlayback();
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

  // Audio-related methods
  static Future<void> playAudio(dynamic surahSource, {bool createPlaylist = false}) async {
    try {
      if (_audioPlayer == null) {
        _audioPlayer = AudioPlayer();
        await _configureAudioSession();
        await _setupAudioSource(surahSource, createPlaylist);
      }

      if (_savedPosition != null && _audioPlayer?.audioSource != null) {
        await _audioPlayer?.seek(_savedPosition!);
        _savedPosition = null;
      }

      await _startPlayback(createPlaylist);
      FlutterBackgroundService().invoke('kAudioStateChanged', {'isPlaying': true});
    } catch (e) {
      print('Error playing audio: $e');
      FlutterBackgroundService().invoke('kAudioStateChanged', {'isPlaying': false});
    }
  }

  static Future<void> stopPlayback() async {
    try {
      _savedPosition = await _audioPlayer?.position;
      await _audioPlayer?.pause();
      FlutterBackgroundService().invoke('kAudioStateChanged', {'isPlaying': false});
    } catch (e) {
      print('Error stopping playback: $e');
    }
  }

  // Audio configuration methods
  static Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
    await session.setActive(true);
    await _audioPlayer?.setVolume(1.0);
  }

  static Future<void> _setupAudioSource(dynamic surahSource, bool createPlaylist) async {
    if (_audioPlayer?.audioSource == null) {
      if (createPlaylist) {
        await _setupPlaylist(surahSource);
      } else {
        await _setupSingleAudio(surahSource);
      }
      _savedPosition = null;
    }
  }

  static Future<void> _setupPlaylist(dynamic surahSource) async {
    final playlist = ConcatenatingAudioSource(
      children: (surahSource as List).map((source) {
        if (source is String) {
          return AudioSource.uri(Uri.parse(source));
        } else if (source is AudioSource) {
          return source;
        }
        throw ArgumentError('Invalid source type: ${source.runtimeType}');
      }).toList(),
    );
    await _audioPlayer?.setAudioSource(playlist);
    await _audioPlayer?.setLoopMode(LoopMode.all);
  }

  static Future<void> _setupSingleAudio(dynamic surahSource) async {
    final source = surahSource is String ? AudioSource.uri(Uri.parse(surahSource)) : surahSource as AudioSource;
    await _audioPlayer?.setAudioSource(source);
    await _audioPlayer?.setLoopMode(LoopMode.one);
  }

  static Future<void> _startPlayback(bool createPlaylist) async {
    await _audioPlayer?.play();
    _audioPlayer?.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.completed && !createPlaylist) {
        _audioPlayer?.seek(Duration.zero);
        _audioPlayer?.play();
        _savedPosition = null;
        FlutterBackgroundService().invoke('kAudioStateChanged', {'isPlaying': true});
      }
    });

    _audioPlayer?.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      FlutterBackgroundService().invoke('kAudioStateChanged', {'isPlaying': isPlaying});
    });
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();

    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'en';
    final locale = Locale(langCode);
    final localizations = await AppLocalizations.delegate.load(locale);
    S.setCurrent(localizations);

    _setupServiceListeners(service);
    _setupPeriodicScheduleCheck(service);
  }

  static void _setupServiceListeners(ServiceInstance service) {
    bool isPaused = false;
    bool shouldShowNotification = _shouldShowNotification;

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((_) => service.setAsForegroundService());
      service.on('setAsBackground').listen((_) => service.setAsBackgroundService());
    }

    // Notification-related listeners
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
      print("called service prayerTime $shouldShowNotification");

      if (event != null && !isPaused && shouldShowNotification) {
        await _handlePrayerTime(event);
      }
    });

    // Audio-related listeners
    service.on('update_schedule').listen((_) async {
      await ScheduleManager.checkSchedule();
    });
    service.on('restart_schedule').listen((_) async {
      if (isPlaying()) {
        await stopPlayback();
      }
      _audioPlayer?.dispose();
      _audioPlayer = null;
      await ScheduleManager.checkSchedule();
    });
    service.on('kStopAudio').listen((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(BackgroundScheduleAudioServiceConstant.kManualPause, true);
      await stopPlayback();
      service.invoke('kAudioStateChanged', {'isPlaying': false});
    });
    service.on('kGetPlaybackState').listen((_) async {
      service.invoke('kAudioStateChanged', {'isPlaying': isPlaying()});
    });
    service.on('kResumeAudio').listen((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(BackgroundScheduleAudioServiceConstant.kManualPause, false);
      if (isPlaying()) {
        await player?.play();
        service.invoke('kAudioStateChanged', {'isPlaying': true});
      } else {
        await ScheduleManager.checkSchedule();
      }
    });
  }

  static void _setupPeriodicScheduleCheck(ServiceInstance service) {
    Timer.periodic(Duration(minutes: 1), (timer) async {
      print("Checking schedule: ${DateTime.now()}");
      await ScheduleManager.checkSchedule();
    });
  }

  static Future<void> _handlePrayerTime(Map<dynamic, dynamic> event) async {
    final prayerName = event['prayer'] as String;
    final shouldPlayAdhan = event['shouldPlayAdhan'] as bool;
    final adhanAsset = event['adhanAsset'] as String;
    final adhanFromAssets = event['adhanFromAssets'] as bool;
    final salahName = event['salahName'] as String;
    print("called service prayerTime $salahName $prayerName");

    await NotificationService.showPrayerNotification(salahName, prayerName, shouldPlayAdhan);

    if (shouldPlayAdhan) {
      await PrayerAudioService.playPrayer(adhanAsset, adhanFromAssets);
    }
  }
}

/// Schedule management class
class ScheduleManager {
  static Future<void> checkSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    final isManuallyPaused = prefs.getBool(BackgroundScheduleAudioServiceConstant.kManualPause) ?? false;
    final isScheduleEnabled = prefs.getBool(BackgroundScheduleAudioServiceConstant.kScheduleEnabled) ?? false;
    final isPendingSchedule = prefs.getBool(BackgroundScheduleAudioServiceConstant.kPendingSchedule) ?? false;

    if (!isScheduleEnabled || isPendingSchedule) {
      if (UnifiedBackgroundService.isPlaying()) {
        await UnifiedBackgroundService.stopPlayback();
        FlutterBackgroundService().invoke('kAudioStateChanged', {'isPlaying': false});
      }
      return;
    }

    final scheduleData = await _getScheduleData(prefs);
    if (scheduleData == null) return;

    final currentTime = TimeOfDay.now();
    final isInTimeRange = _isTimeInRange(currentTime, scheduleData.startTime, scheduleData.endTime);

    if (isInTimeRange && !isManuallyPaused) {
      if (UnifiedBackgroundService.isPlaying()) {
        await UnifiedBackgroundService.stopPlayback();
      }
      await _startScheduledPlayback(scheduleData);
      FlutterBackgroundService().invoke('kAudioStateChanged', {'isPlaying': true});
    } else if (!isInTimeRange) {
      if (UnifiedBackgroundService.isPlaying()) {
        await UnifiedBackgroundService.stopPlayback();
        FlutterBackgroundService().invoke('kAudioStateChanged', {'isPlaying': false});
      }
      await prefs.setBool(BackgroundScheduleAudioServiceConstant.kManualPause, false);
    }
  }

  static Future<ScheduleData?> _getScheduleData(SharedPreferences prefs) async {
    final startTimeString = prefs.getString(BackgroundScheduleAudioServiceConstant.kStartTime);
    final endTimeString = prefs.getString(BackgroundScheduleAudioServiceConstant.kEndTime);

    if (startTimeString == null || endTimeString == null) return null;

    return ScheduleData(
      startTime: _parseTimeOfDay(startTimeString),
      endTime: _parseTimeOfDay(endTimeString),
      isRandomEnabled: prefs.getBool(BackgroundScheduleAudioServiceConstant.kRandomEnabled) ?? false,
      randomUrls: prefs.getStringList(BackgroundScheduleAudioServiceConstant.kRandomUrls),
      selectedSurah: prefs.getInt(BackgroundScheduleAudioServiceConstant.kSelectedSurah) ?? 0,
      selectedSurahUrl: prefs.getString(BackgroundScheduleAudioServiceConstant.kSelectedSurahUrl),
    );
  }

  static Future<void> _startScheduledPlayback(ScheduleData scheduleData) async {
    final service = FlutterBackgroundService();

    try {
      if (scheduleData.isRandomEnabled && scheduleData.randomUrls != null) {
        await UnifiedBackgroundService.playAudio(scheduleData.randomUrls, createPlaylist: true);
      } else if (scheduleData.selectedSurahUrl != null) {
        final surahIdStr = scheduleData.selectedSurah.toString().padLeft(3, '0');
        final surahUrl = "${scheduleData.selectedSurahUrl}$surahIdStr.mp3";
        await UnifiedBackgroundService.playAudio(surahUrl);
      }

      service.invoke('kAudioStateChanged', {'isPlaying': true});
    } catch (e) {
      print('Error starting scheduled playback: $e');
      service.invoke('kAudioStateChanged', {'isPlaying': false});
    }
  }

  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static bool _isTimeInRange(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
    final now = current.hour * 60 + current.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes <= endMinutes) {
      return now >= startMinutes && now < endMinutes;
    }
    return now >= startMinutes || now < endMinutes;
  }
}

/// Data class for schedule information
class ScheduleData {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isRandomEnabled;
  final List<String>? randomUrls;
  final int selectedSurah;
  final String? selectedSurahUrl;

  ScheduleData({
    required this.startTime,
    required this.endTime,
    required this.isRandomEnabled,
    this.randomUrls,
    required this.selectedSurah,
    this.selectedSurahUrl,
  });
}
