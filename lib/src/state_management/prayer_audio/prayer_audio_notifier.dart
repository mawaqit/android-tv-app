import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/state_management/prayer_audio/prayer_audio_state.dart';
import 'package:mawaqit/src/services/audio_stream_offline_manager.dart';

import 'package:mawaqit/const/resource.dart';

// Simple provider without auto-dispose
final prayerAudioProvider = StateNotifierProvider<PrayerAudioNotifier, PrayerAudioState>(
  (ref) => PrayerAudioNotifier(),
);

class PrayerAudioNotifier extends StateNotifier<PrayerAudioState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSubscription;

  late final Dio _dio;

  PrayerAudioNotifier() : super(const PrayerAudioState(processingState: ProcessingState.idle)) {
    log('PrayerAudioNotifier: Initializing');

    // Initialize Dio with cache interceptor
    final cacheOptions = CacheOptions(
      store: HiveCacheStore(null),
      priority: CachePriority.high,
      policy: CachePolicy.request,
    );
    _dio = Dio()..interceptors.add(DioCacheInterceptor(options: cacheOptions));
  }

  // --- Public methods ---

  Future<void> playAdhan(MosqueConfig? mosqueConfig, {bool useFajrAdhan = false}) async {
    log('PrayerAudioNotifier: playAdhan called with useFajrAdhan=$useFajrAdhan');

    if (mosqueConfig == null) {
      log('PrayerAudioNotifier: Invalid mosque config (null)');
      return;
    }

    final url = _getAdhanLink(mosqueConfig, useFajrAdhan: useFajrAdhan);
    log('PrayerAudioNotifier: Will play adhan from $url');

    if (url == null) {
      log('PrayerAudioNotifier: Could not determine adhan URL');
      return;
    }

    if (url.contains('bip')) {
      await _playAsset(R.ASSETS_VOICES_ADHAN_BIP_MP3);
    } else {
      await _playFromUrl(url);
    }
  }

  Future<void> playIqamaBip(MosqueConfig? mosqueConfig) async {
    log('PrayerAudioNotifier: playIqamaBip called');
    await _playAsset(R.ASSETS_VOICES_ADHAN_BIP_MP3);
  }

  Future<void> playDuaAfterAdhan(MosqueConfig? mosqueConfig) async {
    log('PrayerAudioNotifier: playDuaAfterAdhan called');
    await _playFromUrl(_duaAfterAdhanLink);
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

  Future<void> _playFromUrl(String url) async {
    log('PrayerAudioNotifier: _playFromUrl called with URL: $url');

    try {
      // Stop any current playback
      await stop();

      // Update state to loading
      state = const PrayerAudioState(processingState: ProcessingState.loading);

      // Format URL
      String formattedUrl = url;
      if (!url.startsWith(PrayerAudioConstant.kHttpProtocol) && !url.startsWith(PrayerAudioConstant.kHttpsProtocol)) {
        formattedUrl = '${PrayerAudioConstant.kHttpsPrefix}$url';
      }

      // Download and set audio source
      try {
        final ByteData audioData = await _getFile(formattedUrl);
        log('PrayerAudioNotifier: Downloaded ${audioData.lengthInBytes} bytes');
        await _audioPlayer.setAudioSource(JustAudioBytesSource(audioData));
        log('PrayerAudioNotifier: Audio source set');
      } catch (e) {
        log('PrayerAudioNotifier: Failed to download/set audio from bytes, trying direct URL: $e');
        // Fallback to direct URL
        await _audioPlayer.setUrl(formattedUrl);
        log('PrayerAudioNotifier: Set URL directly');
      }

      // Play and setup listener
      await _audioPlayer.play();
      log('PrayerAudioNotifier: Play() called');

      // Update state with duration
      state = PrayerAudioState(
        duration: _audioPlayer.duration,
        processingState: ProcessingState.ready,
      );

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
    } catch (e) {
      log('PrayerAudioNotifier: Error in _playFromUrl: $e');
      state = const PrayerAudioState(processingState: ProcessingState.idle);
    }
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
    } catch (e) {
      log('PrayerAudioNotifier: Error in _playAsset: $e');
      state = const PrayerAudioState(processingState: ProcessingState.idle);
    }
  }

  Future<ByteData> _getFile(String url) async {
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data == null || response.data!.isEmpty) {
        throw Exception('Downloaded file is empty');
      }

      return Uint8List.fromList(response.data!).buffer.asByteData();
    } catch (e) {
      log('PrayerAudioNotifier: Error downloading file: $e');
      rethrow;
    }
  }

  String? _getAdhanLink(MosqueConfig mosqueConfig, {bool useFajrAdhan = false}) {
    String adhanLink =
        "$kStaticFilesUrl${PrayerAudioConstant.kMp3Directory}${PrayerAudioConstant.kDefaultAdhanFileName}"; // Default

    if (mosqueConfig.adhanVoice?.isNotEmpty ?? false) {
      adhanLink =
          "$kStaticFilesUrl${PrayerAudioConstant.kMp3Directory}${mosqueConfig.adhanVoice!}${PrayerAudioConstant.kMp3Extension}";
    }

    if (useFajrAdhan && !adhanLink.contains('bip')) {
      adhanLink = adhanLink.replaceAll(PrayerAudioConstant.kMp3Extension, PrayerAudioConstant.kFajrAdhanSuffix);
    }

    return adhanLink;
  }

  String get _duaAfterAdhanLink =>
      "$kStaticFilesUrl${PrayerAudioConstant.kMp3Directory}${PrayerAudioConstant.kDuaAfterAdhanFileName}";

  @override
  void dispose() {
    log('PrayerAudioNotifier: Disposing');
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
