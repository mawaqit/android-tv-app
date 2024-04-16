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
  );

  late final dio = Dio()
    ..interceptors.add(DioCacheInterceptor(options: option));

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
      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          onDone?.call();
        }
      });
    } on PlayerException catch (e, s) {
      logger.e('[Error playing audio file] $e', stackTrace: s);

      onDone?.call();
    } on PlayerInterruptedException catch (e, s) {
      logger.e('[Error playing audio file] $e', stackTrace: s);
      onDone?.call();
    } catch (e, s) {
      logger.e('[Error playing audio file] $e', stackTrace: s);
      onDone?.call();
    }
  }

  Future<void> loadAndPlay({
    required String url,
    bool enableCache = true,
    VoidCallback? onDone,
  }) async {
    try {
      await player.setUrl(url);
      player.play();
      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          onDone?.call();
        }
      });
    } on PlayerException catch (e, s) {
      logger.e('[Error playing audio file] $e', stackTrace: s);

      onDone?.call();
    } on PlayerInterruptedException catch (e, s) {
      logger.e('[Error playing audio file] $e', stackTrace: s);
      onDone?.call();
    } catch (e, s) {
      logger.e('[Error playing audio file] $e', stackTrace: s);
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
    final file = await dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    return Uint8List.fromList(file.data!).buffer.asByteData();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
