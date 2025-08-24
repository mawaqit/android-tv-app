import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/services/audio_stream_offline_manager.dart';
import 'package:mawaqit/src/state_management/prayer_audio/prayer_audio_state.dart';
import 'package:mawaqit/src/services/audio_manager.dart';
import 'package:mawaqit/src/helpers/connectivity_provider.dart';
import 'package:mawaqit/src/models/address_model.dart';

import 'package:mawaqit/const/resource.dart';

// Simple provider without auto-dispose
final prayerAudioProvider = StateNotifierProvider<PrayerAudioNotifier, PrayerAudioState>(
  (ref) => PrayerAudioNotifier(ref),
);

class PrayerAudioNotifier extends StateNotifier<PrayerAudioState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSubscription;
  final AudioManager _audioManager = AudioManager();
  final Ref _ref;

  PrayerAudioNotifier(this._ref) : super(const PrayerAudioState(processingState: ProcessingState.idle)) {
    log('PrayerAudioNotifier: Initializing with connectivity provider access');
  }

  // --- Public methods ---

  Future<void> playAdhan(MosqueConfig? mosqueConfig, {bool useFajrAdhan = false}) async {
    log('PrayerAudioNotifier: playAdhan called with useFajrAdhan=$useFajrAdhan');
    log('PrayerAudioNotifier: Current state before playAdhan: ${state.processingState}');

    if (mosqueConfig == null) {
      log('PrayerAudioNotifier: Invalid mosque config (null)');
      return;
    }

    final url = _audioManager.adhanLink(mosqueConfig, useFajrAdhan: useFajrAdhan);
    log('PrayerAudioNotifier: Will play adhan from $url');

    if (url.contains('bip')) {
      log('PrayerAudioNotifier: URL contains bip, playing bip asset');
      await _playAsset(R.ASSETS_VOICES_ADHAN_BIP_MP3);
    } else {
      log('PrayerAudioNotifier: URL does not contain bip, trying cached/network playback');
      await _playFromUrlWithCache(url);
    }
  }

  Future<void> playIqamaBip(MosqueConfig? mosqueConfig) async {
    log('PrayerAudioNotifier: playIqamaBip called');
    await _playAsset(R.ASSETS_VOICES_ADHAN_BIP_MP3);
  }

  Future<void> playDuaAfterAdhan(MosqueConfig? mosqueConfig) async {
    log('PrayerAudioNotifier: playDuaAfterAdhan called');
    await _playFromUrlWithCache(_audioManager.duaAfterAdhanLink);
  }

  Future<void> stop() async {
    log('PrayerAudioNotifier: Stopping playback');
    try {
      await _audioPlayer.stop();
      _playerStateSubscription?.cancel();
      _playerStateSubscription = null;
      state = const PrayerAudioState(processingState: ProcessingState.idle);
    } catch (e) {
      log('PrayerAudioNotifier: Error stopping playback: $e');
    }
  }

  // --- Private methods ---

  Future<void> _playFromUrlWithCache(String url) async {
    log('PrayerAudioNotifier: _playFromUrlWithCache called with URL: $url');

    try {
      // Stop any current playback
      await stop();

      // Update state to loading
      state = const PrayerAudioState(processingState: ProcessingState.loading);

      // Check if we have network connectivity
      final hasNetwork = await _hasNetworkConnection();
      log('PrayerAudioNotifier: Network available: $hasNetwork');

      bool playbackSuccessful = false;

      // Strategy 1: Try cached file first (works offline if cached)
      if (!playbackSuccessful) {
        playbackSuccessful = await _tryPlayFromCache(url, hasNetwork);
      }

      // If playback failed, just log and set state to idle
      if (!playbackSuccessful) {
        log('PrayerAudioNotifier: All strategies failed, no audio will be played');
        state = const PrayerAudioState(processingState: ProcessingState.idle);
        return;
      }

      // If we reach here, playback was successful, setup completion listener
      _setupPlaybackListener();
    } catch (e) {
      log('PrayerAudioNotifier: Error in _playFromUrlWithCache: $e');
      // Set state to idle on error, no fallback audio
      state = const PrayerAudioState(processingState: ProcessingState.idle);
    }
  }

  Future<bool> _tryPlayFromCache(String url, bool hasNetwork) async {
    try {
      log('PrayerAudioNotifier: Trying to get cached audio for: $url');

      // Use existing AudioManager's getFile method which handles caching
      // First try with cache enabled (will use cache if available, download if not)
      ByteData? audioData;

      if (hasNetwork) {
        log('PrayerAudioNotifier: Network available, trying cache/network');
        try {
          audioData = await _audioManager.getFile(url, enableCache: true);
          log('PrayerAudioNotifier: Successfully got audio data from AudioManager (${audioData.lengthInBytes} bytes)');
        } catch (e) {
          log('PrayerAudioNotifier: AudioManager getFile with network failed: $e');
        }
      }

      // If network failed or no network, try cache-only
      if (audioData == null) {
        log('PrayerAudioNotifier: Trying cache-only fallback');
        try {
          // Force cache-only by disabling cache temporarily and catching errors
          audioData = await _audioManager.getFile(url, enableCache: true);
          log('PrayerAudioNotifier: Successfully got audio data from cache-only (${audioData.lengthInBytes} bytes)');
        } catch (e) {
          log('PrayerAudioNotifier: Cache-only fallback failed: $e');
          return false;
        }
      }

      // Set audio source and play
      await _audioPlayer.setAudioSource(JustAudioBytesSource(audioData));
      await _audioPlayer.play();

      log('PrayerAudioNotifier: Successfully playing cached audio (${audioData.lengthInBytes} bytes)');

      // Update state with duration
      state = PrayerAudioState(
        duration: _audioPlayer.duration,
        processingState: ProcessingState.ready,
      );

      return true;
    } catch (e) {
      log('PrayerAudioNotifier: Cache playback failed: $e');
      return false;
    }
  }

  Future<bool> _hasNetworkConnection() async {
    try {
      await _ref.read(connectivityProvider.notifier).checkInternetConnection();

      final connectivityState = _ref.read(connectivityProvider);
      return connectivityState.when(
        data: (status) {
          final isConnected = status == ConnectivityStatus.connected;
          log('PrayerAudioNotifier: Network status from provider: $isConnected');
          return isConnected;
        },
        loading: () {
          log('PrayerAudioNotifier: Connectivity loading, assuming offline');
          return false;
        },
        error: (error, stack) {
          log('PrayerAudioNotifier: Connectivity error, assuming offline: $error');
          return false;
        },
      );
    } catch (e) {
      log('PrayerAudioNotifier: Network check failed: $e');
      return false;
    }
  }

  void _setupPlaybackListener() {
    // Listen for completion
    _playerStateSubscription?.cancel();
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((playerState) {
      log('PrayerAudioNotifier: Player state changed to ${playerState.processingState}');

      // Update state based on player state
      state = state.copyWith(processingState: playerState.processingState);

      if (playerState.processingState == ProcessingState.completed) {
        log('PrayerAudioNotifier: Playback completed');
        _playerStateSubscription?.cancel();
        _playerStateSubscription = null;
      }
    });
  }

  Future<void> _playAsset(String assetPath) async {
    log('PrayerAudioNotifier: _playAsset called with path: $assetPath');

    try {
      // Stop any current playback
      await stop();

      // Update state to loading
      state = const PrayerAudioState(processingState: ProcessingState.loading);

      // Set asset and play
      final duration = await _audioPlayer.setAsset(assetPath);
      log('PrayerAudioNotifier: Asset set, duration: $duration');

      await _audioPlayer.play();
      log('PrayerAudioNotifier: Play() called');

      // Update state
      state = PrayerAudioState(
        duration: duration,
        processingState: ProcessingState.ready,
      );

      // Setup listener
      _setupPlaybackListener();
    } catch (e) {
      log('PrayerAudioNotifier: Error in _playAsset: $e');
      state = const PrayerAudioState(processingState: ProcessingState.idle);
    }
  }

  @override
  void dispose() {
    log('PrayerAudioNotifier: Disposing');
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    _audioManager.dispose();
    super.dispose();
  }
}
