// prayer_audio_service.dart
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mawaqit/src/services/notification/notification_service.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/services.dart';
import 'dart:developer';

class PrayerAudioService {
  static AudioPlayer? _audioPlayer;
  
  // Add cache configuration for offline support
  static final _cacheOptions = CacheOptions(
    store: HiveCacheStore(null),
    priority: CachePriority.high,
    policy: CachePolicy.request, // Use request policy for cache/network handling
    maxStale: const Duration(days: 7),
  );
  
  static final _dio = Dio()..interceptors.add(DioCacheInterceptor(options: _cacheOptions));

  static Future<void> playPrayer(String adhanAsset, bool adhanFromAssets) async {
    _audioPlayer = AudioPlayer();
    final session = await _configureAudioSession();
    await session.setActive(true);
    await _audioPlayer?.setVolume(1);

    try {
      if (adhanFromAssets) {
        await _audioPlayer?.setAsset(adhanAsset);
        Future.delayed(const Duration(minutes: 1), () {
          NotificationService.dismissNotification();
        });
      } else {
        // Try to load from cache first, then fallback to URL
        await _loadAudioFromCacheOrUrl(adhanAsset);
      }

      await _audioPlayer?.play();

      _audioPlayer?.playbackEventStream.listen((event) {
        if (event.processingState == ProcessingState.completed) {
          session.setActive(false);
          if (!adhanFromAssets) {
            NotificationService.dismissNotification();
          }
        }
      });
    } catch (e) {
      log('Prayer audio service error: $e');
      await session.setActive(false);
    }
  }
  
  /// Load audio from cache first, fallback to URL if cache fails
  static Future<void> _loadAudioFromCacheOrUrl(String url) async {
    try {
      // First try to get cached audio data
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      
      if (response.data != null) {
        final audioData = Uint8List.fromList(response.data!).buffer.asByteData();
        await _audioPlayer?.setAudioSource(JustAudioBytesSource(audioData));
        log('Prayer audio loaded from cache/network successfully');
        return;
      }
    } catch (e) {
      log('Failed to load audio from cache/network: $e');
    }
    
    // If cache fails, try direct URL as fallback
    try {
      await _audioPlayer?.setUrl(url);
      log('Prayer audio loaded from URL as fallback');
    } catch (e) {
      log('Failed to load audio from URL: $e');
      // If both fail, we could potentially use a default bip sound
      throw Exception('Failed to load prayer audio from both cache and URL');
    }
  }

  static Future<void> stopAudio() async {
    await _audioPlayer?.stop();
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
}

// Helper class for audio data source
class JustAudioBytesSource extends StreamAudioSource {
  final ByteData _buffer;

  JustAudioBytesSource(this._buffer);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _buffer.lengthInBytes;
    return StreamAudioResponse(
      sourceLength: _buffer.lengthInBytes,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_buffer.buffer.asUint8List(start, end - start)),
      contentType: 'audio/mpeg',
    );
  }
}
