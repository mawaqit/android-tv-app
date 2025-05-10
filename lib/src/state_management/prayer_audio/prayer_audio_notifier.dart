import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart'; // For URL byte fetching if needed
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/helpers/connectivity_provider.dart';
import 'package:mawaqit/src/models/address_model.dart';
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
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

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
        await _playCachedUrl(url);
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
      await _playCachedUrl(_duaAfterAdhanLink);
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

  /// Play audio from URL with caching support
  Future<void> _playCachedUrl(String url) async {
    log('PrayerAudioNotifier: _playCachedUrl called with URL: $url');

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

      // Get the file from the cache manager, which will download if needed
      final File audioFile = await _getOrDownloadFile(formattedUrl);
      log('PrayerAudioNotifier: Retrieved cached/downloaded file: ${audioFile.path}');

      // Set the audio source from the local file
      try {
        final duration = await _audioPlayer.setFilePath(audioFile.path);
        log('PrayerAudioNotifier: Audio source set from local file, duration: $duration');

        _subscribeToPlayerState();

        // Set initial AsyncData state after loading source
        state = AsyncData(PrayerAudioState(duration: duration, processingState: _audioPlayer.processingState));
        log('PrayerAudioNotifier: Set initial data state, starting playback');

        await _audioPlayer.play();
        log('PrayerAudioNotifier: Play() called');
      } catch (e) {
        // If playback fails on the file, it might be corrupted
        log('PrayerAudioNotifier: Error playing cached file: $e, file might be corrupted');
        await _cacheManager.removeFile(formattedUrl); // Remove corrupted file
        throw AudioCacheCorruptedException('Cached audio file failed to play: ${e.toString()}');
      }
    } catch (e, s) {
      log('PrayerAudioNotifier: Error playing URL: $url | $e | $s', error: e, stackTrace: s);

      // Handle specific cache exceptions
      final PrayerAudioException error;
      if (e is PrayerAudioException) {
        error = e;
      } else if (e is FileSystemException) {
        error = AudioCacheCorruptedException('File system error: ${e.toString()}');
      } else {
        error = PlayAdhanException("Failed to play URL: ${e.toString()}");
      }

      state = AsyncError(error, s); // Set AsyncError state
    }
  }

  /// Get file from cache or download it
  Future<File> _getOrDownloadFile(String url) async {
    try {
      // First check if file exists in cache
      final fileInfo = await _cacheManager.getFileFromCache(url);
      if (fileInfo != null) {
        log('PrayerAudioNotifier: File found in cache: ${fileInfo.file.path}');

        // Check if the cached file is valid
        if (await fileInfo.file.exists() && await fileInfo.file.length() > 0) {
          return fileInfo.file;
        } else {
          log('PrayerAudioNotifier: Cached file is corrupted or empty');
          // If corrupted, remove it from cache
          await _cacheManager.removeFile(url);
          // Don't throw here, continue to downloading
        }
      }

      log('PrayerAudioNotifier: File not in cache, downloading: $url');

      // Check if we have any network connectivity
      final hasNetwork = ref.watch(connectivityProvider);
      return hasNetwork.maybeWhen(
        orElse: () async {
          log('PrayerAudioNotifier: Network unavailable, cannot download');
          final fileInfo = await _cacheManager.getFileFromCache(url);
          if (fileInfo != null && await fileInfo.file.exists()) {
            log('PrayerAudioNotifier: Using possibly outdated cached version due to no network');
            return fileInfo.file;
          }
          throw AudioCacheMissingException('No cached file available and network is unavailable');
        },
        data: (connectivity) async {
          if (connectivity == ConnectivityStatus.connected) {
            try {
              final file = await _cacheManager.getSingleFile(url);

              // Validate downloaded file
              if (await file.length() == 0) {
                throw AudioCacheCorruptedException('Downloaded file is empty');
              }

              log('PrayerAudioNotifier: File successfully downloaded: ${file.path}');
              return file;
            } catch (e) {
              log('PrayerAudioNotifier: Error downloading file: $e, falling back to cache if available');

              if (e is AudioCacheCorruptedException) {
                rethrow;
              }

              // If download fails, check if we have ANY cached version
              final fileInfo = await _cacheManager.getFileFromCache(url);
              if (fileInfo != null && await fileInfo.file.exists() && await fileInfo.file.length() > 0) {
                log('PrayerAudioNotifier: Using older cached version after download failure');
                return fileInfo.file;
              }

              // If we get here, both download and cache lookup failed
              throw AudioCacheDownloadException('Failed to download file: ${e.toString()}');
            }
          } else {
            log('PrayerAudioNotifier: Network unavailable, cannot download');
            final fileInfo = await _cacheManager.getFileFromCache(url);
            if (fileInfo != null && await fileInfo.file.exists()) {
              log('PrayerAudioNotifier: Using possibly outdated cached version due to no network');
              return fileInfo.file;
            }
            throw AudioCacheMissingException('No cached file available and network is unavailable');
          }
        },
      );
    } catch (e, s) {
      log('PrayerAudioNotifier: Error in _getOrDownloadFile: $e', error: e, stackTrace: s);

      // Re-throw specific cache exceptions
      if (e is PrayerAudioException) {
        rethrow;
      }

      throw AudioCacheDownloadException('Failed to retrieve audio file: ${e.toString()}');
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
      final error = e is PrayerAudioException
          ? e
          : PlayAdhanException("Failed to play URL: ${e.toString()}"); // Or more specific error
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
      final error = e is PrayerAudioException
          ? e
          : PlayAdhanException("Failed to play asset: ${e.toString()}"); // Or more specific error
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
        if (state is AsyncLoading &&
            (newProcessingState == ProcessingState.ready ||
                newProcessingState == ProcessingState.completed ||
                newProcessingState == ProcessingState.idle)) {
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

    String adhanLink = "$kStaticFilesUrl/audio/adhan-afassy.mp3"; // Default
    log('PrayerAudioNotifier: Default adhan link: $adhanLink');

    if (mosqueConfig.adhanVoice?.isNotEmpty ?? false) {
      adhanLink = "$kStaticFilesUrl/audio/${mosqueConfig.adhanVoice!}.mp3";
      log('PrayerAudioNotifier: Using custom adhan voice: $adhanLink');
    }

    if (useFajrAdhan && !adhanLink.contains('bip')) {
      adhanLink = adhanLink.replaceAll('.mp3', '-fajr.mp3');
      log('PrayerAudioNotifier: Adjusted for Fajr adhan: $adhanLink');
    }

    return adhanLink;
  }

  final String _duaAfterAdhanLink = "$kStaticFilesUrl/audio/duaa-after-adhan.mp3";
}
