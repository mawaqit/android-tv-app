import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';

/// BackgroundAudioService class to handle all audio-related operations
class BackgroundAudioScheduleService {
  static AudioPlayer? _audioPlayer;
  static Duration? _savedPosition;

  static bool isPlaying() => _audioPlayer?.playing ?? false;
  static AudioPlayer? get player => _audioPlayer;
  static final FlutterBackgroundService _service = FlutterBackgroundService();

  /// Initialize the background service
  static Future<void> initialize() async {
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
      ),
    );
    await service.startService();
  }

  /// Configure and start audio playback
  /// Configure and start audio playback
  static Future<void> playAudio(dynamic surahSource, {bool createPlaylist = false}) async {
    try {
      if (_audioPlayer == null) {
        _audioPlayer = AudioPlayer();
        await _configureAudioSession();
        await _setupAudioSource(surahSource, createPlaylist);
      }

      // If we have a saved position and the player is already set up
      if (_savedPosition != null && _audioPlayer?.audioSource != null) {
        await _audioPlayer?.seek(_savedPosition!);
        _savedPosition = null;
      }

      await _startPlayback(createPlaylist);
      _service.invoke('kAudioStateChanged', {'isPlaying': true});
    } catch (e) {
      print('Error playing audio: $e');
      _service.invoke('kAudioStateChanged', {'isPlaying': false});
    }
  }

  /// Stop audio playback
  static Future<void> stopPlayback() async {
    try {
      print('Pausing surah playback');
      // Save the current position before pausing
      _savedPosition = await _audioPlayer?.position;
      await _audioPlayer?.pause();
      _service.invoke('kAudioStateChanged', {'isPlaying': false});
    } catch (e) {
      print('Error stopping playback: $e');
    }
  }

  /// Configure audio session settings
  static Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(_getAudioSessionConfiguration());
    await session.setActive(true);
    await _audioPlayer?.setVolume(1.0);
  }

  /// Get audio session configuration
  static AudioSessionConfiguration _getAudioSessionConfiguration() {
    return AudioSessionConfiguration(
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
    );
  }

  /// Setup audio source based on playlist or single audio
  /// Setup audio source based on playlist or single audio
  static Future<void> _setupAudioSource(dynamic surahSource, bool createPlaylist) async {
    // Only set up new audio source if it's different or player has no source
    if (_audioPlayer?.audioSource == null) {
      if (createPlaylist) {
        await _setupPlaylist(surahSource);
      } else {
        await _setupSingleAudio(surahSource);
      }
      _savedPosition = null;
    }
  }

  /// Setup playlist audio source
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

  /// Setup single audio source
  static Future<void> _setupSingleAudio(dynamic surahSource) async {
    final source = surahSource is String ? AudioSource.uri(Uri.parse(surahSource)) : surahSource as AudioSource;
    await _audioPlayer?.setAudioSource(source);
    await _audioPlayer?.setLoopMode(LoopMode.one);
  }

  /// Start playback and configure completion handling
  static Future<void> _startPlayback(bool createPlaylist) async {
    await _audioPlayer?.play();
    _audioPlayer?.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.completed && !createPlaylist) {
        _audioPlayer?.seek(Duration.zero);
        _audioPlayer?.play();
        _savedPosition = null;
        _service.invoke('kAudioStateChanged', {'isPlaying': true});
      }
    });

    _audioPlayer?.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      _service.invoke('kAudioStateChanged', {'isPlaying': isPlaying});
    });
  }
}

/// Schedule management class
class ScheduleManager {
  /// Check and manage schedule
  static Future<void> checkSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    if (await _shouldSkipSchedule(prefs)) return;

    final scheduleData = await _getScheduleData(prefs);
    if (scheduleData == null) return;

    final currentTime = TimeOfDay.now();
    await _handleScheduleExecution(currentTime, scheduleData, prefs);
  }

  /// Check if schedule should be skipped
  static Future<bool> _shouldSkipSchedule(SharedPreferences prefs) async {
    final isPendingSchedule = prefs
            .getBool(BackgroundScheduleAudioServiceConstant.kPendingSchedule) ??
        false;
    final isScheduleEnabled = prefs.getBool(BackgroundScheduleAudioServiceConstant.kScheduleEnabled) ?? false;

    if (!isScheduleEnabled || isPendingSchedule) {
      if (BackgroundAudioScheduleService.isPlaying()) {
        await BackgroundAudioScheduleService.stopPlayback();
        FlutterBackgroundService().invoke('kAudioStateChanged', {'isPlaying': false});
      }
      return true;
    }
    return false;
  }

  /// Get schedule data from preferences
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

  /// Handle schedule execution
  static Future<void> _handleScheduleExecution(
      TimeOfDay currentTime, ScheduleData scheduleData, SharedPreferences prefs) async {
    final service = FlutterBackgroundService();

    if (_isTimeInRange(currentTime, scheduleData.startTime, scheduleData.endTime)) {
      if (!BackgroundAudioScheduleService.isPlaying()) {
        await _startScheduledPlayback(scheduleData);
        // Notify UI of playback state change
        service.invoke('kAudioStateChanged', {'isPlaying': true});
      }
    } else if (BackgroundAudioScheduleService.isPlaying()) {
      await BackgroundAudioScheduleService.stopPlayback();
      // Notify UI of playback state change
      service.invoke('kAudioStateChanged', {'isPlaying': false});
    }
  }

  /// Start scheduled playback
  static Future<void> _startScheduledPlayback(ScheduleData scheduleData) async {
    final service = FlutterBackgroundService();

    try {
      if (scheduleData.isRandomEnabled && scheduleData.randomUrls != null) {
        await BackgroundAudioScheduleService.playAudio(scheduleData.randomUrls,
            createPlaylist: true);
      } else if (scheduleData.selectedSurahUrl != null) {
        final surahIdStr =
            scheduleData.selectedSurah.toString().padLeft(3, '0');
        final surahUrl = "${scheduleData.selectedSurahUrl}$surahIdStr.mp3";
        await BackgroundAudioScheduleService.playAudio(surahUrl);
      }

      // Notify UI of successful playback start
      service.invoke('kAudioStateChanged', {'isPlaying': true});
    } catch (e) {
      print('Error starting scheduled playback: $e');
      // Notify UI of failure
      service.invoke('kAudioStateChanged', {'isPlaying': false});
    }
  }

  /// Parse time string to TimeOfDay
  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  /// Check if current time is within range
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

/// Service entry points
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  print("Background service started");

  _setupPeriodicScheduleCheck(service);
  _setupServiceListeners(service);
}

/// Setup periodic schedule check
void _setupPeriodicScheduleCheck(ServiceInstance service) {
  Timer.periodic(Duration(minutes: 1), (timer) async {
    print("Checking schedule: ${DateTime.now()}");
    await ScheduleManager.checkSchedule();
  });
}

/// Setup service listeners
void _setupServiceListeners(ServiceInstance service) {
  service.on('update_schedule').listen((event) async {
    print("Schedule updated, reloading preferences");
    await ScheduleManager.checkSchedule();
  });

  service.on('kStopAudio').listen((event) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(BackgroundScheduleAudioServiceConstant.kManualPause, true);
    await BackgroundAudioScheduleService.stopPlayback();
    service.invoke('kAudioStateChanged', {'isPlaying': false});
  });

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  service.on('kGetPlaybackState').listen((event) async {
    service.invoke('kAudioStateChanged', {'isPlaying': BackgroundAudioScheduleService.isPlaying()});
  });

  service.on('kResumeAudio').listen((event) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(BackgroundScheduleAudioServiceConstant.kManualPause, false);

    if (BackgroundAudioScheduleService.isPlaying()) {
      await BackgroundAudioScheduleService.player?.play();
      service.invoke('kAudioStateChanged', {'isPlaying': true});
    } else {
      await ScheduleManager.checkSchedule();
    }
  });
}
