import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart'; // For URL byte fetching if needed
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/state_management/prayer_audio/prayer_audio_state.dart';
import 'package:mawaqit/src/domain/error/prayer_audio_exceptions.dart';

import 'package:mawaqit/const/resource.dart';

// Provider definition - Changed to AutoDisposeAsyncNotifierProvider
final prayerAudioProvider = AsyncNotifierProvider.autoDispose<PrayerAudioNotifier, PrayerAudioState>(
  PrayerAudioNotifier.new,
);

// Changed to AutoDisposeAsyncNotifier
class PrayerAudioNotifier extends AutoDisposeAsyncNotifier<PrayerAudioState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSubscription;
  Timer? _initTimeoutTimer;

  // build now returns FutureOr<PrayerAudioState> and sets initial AsyncData
  @override
  FutureOr<PrayerAudioState> build() {
    log('PrayerAudioNotifier: Building initial state');
    _startInitTimeoutTimer(); // Start timeout timer

    ref.onDispose(() {
      log('PrayerAudioNotifier: Disposing');
      _initTimeoutTimer?.cancel();
      _playerStateSubscription?.cancel();
      _audioPlayer.dispose();
    });

    // Return initial state wrapped in AsyncData
    return const PrayerAudioState(processingState: ProcessingState.idle);
  }

  void _startInitTimeoutTimer() {
    _initTimeoutTimer?.cancel();
    _initTimeoutTimer = Timer(const Duration(seconds: 30), () {
      // If still loading after timeout, set AsyncError state
      if (state is AsyncLoading) {
        log('PrayerAudioNotifier: Init timeout - stuck in loading');
        state = AsyncError(
          AudioInitializationTimeoutException('Audio initialization timed out'),
          StackTrace.current,
        );
      }
    });
  }

  // --- Public methods to control playback ---

  Future<void> playAdhan(MosqueConfig? mosqueConfig, {bool useFajrAdhan = false}) async {
    log('PrayerAudioNotifier: playAdhan called with useFajrAdhan=$useFajrAdhan');

    if (mosqueConfig == null) {
      final error = PlayAdhanException('Invalid mosque config (null)');
      log('PrayerAudioNotifier: Error - ${error.message}');
      state = AsyncError(error, StackTrace.current);
      return;
    }

    final url = _getAdhanLink(mosqueConfig, useFajrAdhan: useFajrAdhan);
    log('PrayerAudioNotifier: Will play adhan from $url');

    if (url == null) {
      final error = PlayAdhanException('Invalid mosque config - could not determine adhan URL');
      log('PrayerAudioNotifier: Error - ${error.message}');
      state = AsyncError(error, StackTrace.current);
      return;
    }

    try {
      if (url.contains('bip')) {
        log('PrayerAudioNotifier: Playing bip sound from assets');
        await _playAsset(R.ASSETS_VOICES_ADHAN_BIP_MP3);
      } else {
        log('PrayerAudioNotifier: Playing adhan from URL: $url');
        await _playUrl(url);
      }
      _initTimeoutTimer?.cancel(); // Cancel timeout if playback starts
    } catch (e, s) {
      log('PrayerAudioNotifier: Error in playAdhan', error: e, stackTrace: s);
      final error = e is PrayerAudioException ? e : PlayAdhanException(e.toString());
      state = AsyncError(error, s);
    }
  }

  Future<void> playIqamaBip(MosqueConfig? mosqueConfig) async {
    log('PrayerAudioNotifier: playIqamaBip called');
    try {
      await _playAsset(R.ASSETS_VOICES_ADHAN_BIP_MP3);
      _initTimeoutTimer?.cancel();
    } catch (e, s) {
      log('PrayerAudioNotifier: Error in playIqamaBip', error: e, stackTrace: s);
      final error = e is PrayerAudioException ? e : PlayIqamaException(e.toString());
      state = AsyncError(error, s); // Set AsyncError state
    }
  }

  Future<void> playDuaAfterAdhan(MosqueConfig? mosqueConfig) async {
    log('PrayerAudioNotifier: playDuaAfterAdhan called');
    try {
      await _playUrl(_duaAfterAdhanLink);
      _initTimeoutTimer?.cancel();
    } catch (e, s) {
      log('PrayerAudioNotifier: Error in playDuaAfterAdhan', error: e, stackTrace: s);
      final error = e is PrayerAudioException ? e : PlayDuaException(e.toString());
      state = AsyncError(error, s); // Set AsyncError state
    }
  }

  Future<void> stop() async {
    log('PrayerAudioNotifier: Stopping playback');
    try {
      await _audioPlayer.stop();
      // State will be updated via the stream listener to ProcessingState.idle
    } catch (e, s) {
      log('PrayerAudioNotifier: Error stopping playback', error: e, stackTrace: s);
      // Optionally set an error state here if stopping fails critically
      final error = e is PrayerAudioException ? e : UnknownPrayerAudioException("Failed to stop: ${e.toString()}");
      state = AsyncError(error, s);
    }
  }

  Future<void> _playUrl(String url) async {
    log('PrayerAudioNotifier: _playUrl called with URL: $url');

    if (state is AsyncLoading) {
       log('PrayerAudioNotifier: Already loading, ignoring request.');
       return; // Avoid concurrent loading
    }
    await stop(); // Ensure previous playback is stopped

    state = const AsyncLoading(); // Set AsyncLoading state
    log('PrayerAudioNotifier: Set state to loading');

    try {
      String formattedUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        formattedUrl = 'https:$url';
      }

      log('PrayerAudioNotifier: Setting audio source: $formattedUrl');
      final duration = await _audioPlayer.setUrl(formattedUrl, headers: {
        'User-Agent': 'Mozilla/5.0 (Android) Flutter-just_audio (+https://pub.dev)',
        'Range': 'bytes=0-',
      });
      log('PrayerAudioNotifier: Audio source set, duration: $duration');

      _subscribeToPlayerState();

      // Set initial AsyncData state after loading source
      state = AsyncData(PrayerAudioState(duration: duration, processingState: _audioPlayer.processingState));
      log('PrayerAudioNotifier: Set initial data state, starting playback');

      await _audioPlayer.play();
      log('PrayerAudioNotifier: Play() called');
    } catch (e, s) {
      log('PrayerAudioNotifier: Error playing URL: $url | $e | $s', error: e, stackTrace: s);
      final error = e is PrayerAudioException ? e : PlayAdhanException("Failed to play URL: ${e.toString()}"); // Or more specific error
      state = AsyncError(error, s); // Set AsyncError state
    }
  }

  Future<void> _playAsset(String assetPath) async {
    log('PrayerAudioNotifier: _playAsset called with path: $assetPath');

     if (state is AsyncLoading) {
       log('PrayerAudioNotifier: Already loading, ignoring request.');
       return; // Avoid concurrent loading
    }
    await stop(); // Ensure previous playback is stopped

    state = const AsyncLoading(); // Set AsyncLoading state
    log('PrayerAudioNotifier: Set state to loading');

    try {
      log('PrayerAudioNotifier: Setting asset source: $assetPath');
      final duration = await _audioPlayer.setAsset(assetPath);
      log('PrayerAudioNotifier: Asset source set, duration: $duration');

      _subscribeToPlayerState();

      // Set initial AsyncData state after loading source
      state = AsyncData(PrayerAudioState(duration: duration, processingState: _audioPlayer.processingState));
      log('PrayerAudioNotifier: Set initial data state, starting playback');

      await _audioPlayer.play();
      log('PrayerAudioNotifier: Play() called');
    } catch (e, s) {
      log('PrayerAudioNotifier: Error playing asset: $assetPath', error: e, stackTrace: s);
      final error = e is PrayerAudioException ? e : PlayAdhanException("Failed to play asset: ${e.toString()}"); // Or more specific error
      state = AsyncError(error, s); // Set AsyncError state
    }
  }

  void _subscribeToPlayerState() {
    log('PrayerAudioNotifier: Setting up player state subscription');
    _playerStateSubscription?.cancel();

    _playerStateSubscription = _audioPlayer.playerStateStream.listen((playerState) {
      final newProcessingState = playerState.processingState;
      log('PrayerAudioNotifier: Player state changed: processingState=$newProcessingState');

      // Only update the data part if the current state is AsyncData
      if (state is AsyncData<PrayerAudioState>) {
        // Update processing state within the existing AsyncData
        state = AsyncData(state.value!.copyWith(processingState: newProcessingState));
      } else {
        log('PrayerAudioNotifier: Received player state update but notifier state is not AsyncData ($state)');
        // Optional: If loading completed but state wasn't AsyncData, maybe reset?
        // Example: if state is AsyncLoading and newProcessingState is ready/completed, transition to AsyncData
        if(state is AsyncLoading && (newProcessingState == ProcessingState.ready || newProcessingState == ProcessingState.completed || newProcessingState == ProcessingState.idle )) {
           state = AsyncData(PrayerAudioState(duration: _audioPlayer.duration, processingState: newProcessingState));
        }
      }
    }, onError: (e, s) {
      log('PrayerAudioNotifier: Player state stream error', error: e, stackTrace: s);
      final error = e is PrayerAudioException ? e : UnknownPrayerAudioException("Player stream error: ${e.toString()}");
      state = AsyncError(error, s); // Set AsyncError state on stream error
    });

    log('PrayerAudioNotifier: Player state subscription set up');
  }


  String? _getAdhanLink(MosqueConfig? mosqueConfig, {bool useFajrAdhan = false}) {
    if (mosqueConfig == null) return null;

    String adhanLink = "$kStaticFilesUrl/mp3/adhan-afassy.mp3"; // Default
    log('PrayerAudioNotifier: Default adhan link: $adhanLink');

    if (mosqueConfig.adhanVoice?.isNotEmpty ?? false) {
      adhanLink = "$kStaticFilesUrl/mp3/${mosqueConfig.adhanVoice!}.mp3";
      log('PrayerAudioNotifier: Using custom adhan voice: $adhanLink');
    }

    if (useFajrAdhan && !adhanLink.contains('bip')) {
      adhanLink = adhanLink.replaceAll('.mp3', '-fajr.mp3');
      log('PrayerAudioNotifier: Adjusted for Fajr adhan: $adhanLink');
    }

    return adhanLink;
  }

  final String _duaAfterAdhanLink = "$kStaticFilesUrl/mp3/duaa-after-adhan.mp3";
}
