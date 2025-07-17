import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';

import '../../const/resource.dart';
import '../../main.dart';
import 'audio_stream_offline_manager.dart';

class AudioManager extends ChangeNotifier {
  String bipLink = "$kStaticFilesUrl/mp3/bip.mp3";

  String duaAfterAdhanLink = "$kStaticFilesUrl/mp3/duaa-after-adhan.mp3";

  late AudioPlayer player;

  AudioManager() {
    player = AudioPlayer();
  }

  final option = CacheOptions(
    store: HiveCacheStore(null),
    priority: CachePriority.high,
    policy: CachePolicy.request,
    maxStale: const Duration(days: 7),
    hitCacheOnErrorExcept: [], // Always use cache when network fails
  );

  late final dio = Dio()..interceptors.add(DioCacheInterceptor(options: option));

  String adhanLink(MosqueConfig? mosqueConfig, {bool useFajrAdhan = false}) {
    String adhanLink = "$kStaticFilesUrl/mp3/adhan-afassy.mp3";
    if (mosqueConfig!.adhanVoice?.isNotEmpty ?? false) {
      adhanLink = "$kStaticFilesUrl/mp3/${mosqueConfig.adhanVoice!}.mp3";
    }

    if (useFajrAdhan && !adhanLink.contains('bip')) {
      adhanLink = adhanLink.replaceAll('.mp3', '-fajr.mp3');
    }

    return adhanLink;
  }

  void loadAndPlayAdhanVoice(
    MosqueConfig? mosqueConfig, {
    VoidCallback? onDone,
    bool useFajrAdhan = false,
  }) {
    final url = adhanLink(mosqueConfig, useFajrAdhan: useFajrAdhan);
    if (url.contains('bip')) {
      loadAndPlayIqamaBipVoice(mosqueConfig, onDone: onDone);
    } else {
      loadAndPlay(
        url: url,
        onDone: onDone,
      );
    }
  }

  void loadAndPlayIqamaBipVoice(
    MosqueConfig? mosqueConfig, {
    VoidCallback? onDone,
  }) {
    loadAssetsAndPlay(R.ASSETS_VOICES_ADHAN_BIP_MP3, onDone: onDone);
  }

  void loadAndPlayDuaAfterAdhanVoice(
    MosqueConfig? mosqueConfig, {
    VoidCallback? onDone,
  }) {
    loadAndPlay(url: duaAfterAdhanLink, onDone: onDone);
  }

  Future<void> loadAssetsAndPlay(String assets, {VoidCallback? onDone}) async {
    try {
      await player.setAsset(assets);
      player.play();
      log('audio: AudioManager: loadAssetsAndPlay: playing audio file');
      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          log('audio: AudioManager: loadAssetsAndPlay: done playing audio file');
          onDone?.call();
        }
      });
    } on PlayerException catch (e, s) {
      log(
        'audio: AudioManager: loadAssetsAndPlay: error PlayerException: $e',
        error: e,
        stackTrace: s,
      );
      onDone?.call();
    } on PlayerInterruptedException catch (e, s) {
      log(
        'audio: AudioManager: loadAssetsAndPlay: error PlayerInterruptedException: $e',
        error: e,
        stackTrace: s,
      );
      onDone?.call();
    } catch (e, s) {
      log(
        'audio: AudioManager: loadAssetsAndPlay: error : $e',
        error: e,
        stackTrace: s,
      );
      onDone?.call();
    }
  }

  Future<void> loadAndPlay({
    required String url,
    bool enableCache = true,
    VoidCallback? onDone,
  }) async {
    try {
      final file = await getFile(url, enableCache: enableCache);
      await player.setAudioSource(JustAudioBytesSource(file));
      player.play();
      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          log('audio: AudioManager: loadAndPlay: done playing audio file');
          onDone?.call();
        }
      });
    } on PlayerException catch (e, s) {
      log(
        'audio: AudioManager: loadAndPlay: error PlayerException: $e',
        error: e,
        stackTrace: s,
      );
      onDone?.call();
    } on PlayerInterruptedException catch (e, s) {
      log(
        'audio: AudioManager: loadAndPlay: error PlayerInterruptedException: $e',
        error: e,
        stackTrace: s,
      );
      onDone?.call();
    } catch (e, s) {
      log(
        'audio: AudioManager: loadAndPlay: error: $e',
        error: e,
        stackTrace: s,
      );
      onDone?.call();
    }
  }

  /// this method will precache all the audio files for this mosque
  Future<void> precacheVoices(MosqueConfig config) async {
    await Future.wait([
      getFile(adhanLink(config)),
      getFile(adhanLink(config, useFajrAdhan: true)),
      getFileFromAssets(R.ASSETS_VOICES_ADHAN_BIP_MP3),
      getFile(duaAfterAdhanLink),
    ]);
  }

  Future<ByteData> getFileFromAssets(String url) async {
    final file = await rootBundle.load(url);
    return file;
  }

  Future<ByteData> getFile(String url, {bool enableCache = true}) async {
    if (!enableCache) {
      // If cache is disabled, try direct network request
      final file = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(file.data!).buffer.asByteData();
    }

    try {
      // First attempt: Try with cache enabled
      log('audio: AudioManager: getFile: Attempting to load audio from cache/network for URL: $url');
      final file = await dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (file.data != null) {
        log('audio: AudioManager: getFile: Successfully loaded audio file');
        return Uint8List.fromList(file.data!).buffer.asByteData();
      }
    } catch (e) {
      log('audio: AudioManager: getFile: Failed to load from cache/network: $e');

      // Second attempt: Try with forceCache policy for offline mode
      try {
        log('audio: AudioManager: getFile: Attempting forceCache fallback');
        final cacheOptions = option.copyWith(policy: CachePolicy.forceCache);
        final tempDio = Dio()..interceptors.add(DioCacheInterceptor(options: cacheOptions));

        final file = await tempDio.get<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
        );

        if (file.data != null) {
          log('audio: AudioManager: getFile: Successfully loaded from forceCache fallback');
          return Uint8List.fromList(file.data!).buffer.asByteData();
        }
      } catch (cacheError) {
        log('audio: AudioManager: getFile: ForceCache fallback also failed: $cacheError');
      }

      // If all attempts fail, rethrow the original error
      throw Exception('Failed to load audio file from both network and cache: $e');
    }

    throw Exception('Failed to retrieve audio data');
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
