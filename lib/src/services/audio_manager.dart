import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:mawaqit/src/data/constants.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';

class AudioManager extends ChangeNotifier {
  String bipLink = "$kStaticFilesUrl/mp3/bip.mp3";
  String duaAfterAdhanLink = "$kStaticFilesUrl/mp3/duaa-after-adhan.mp3";

  Audio? player;

  final option = CacheOptions(
    store: HiveCacheStore(null),
    priority: CachePriority.high,
    policy: CachePolicy.request,
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
    loadAndPlay(
      url: adhanLink(mosqueConfig, useFajrAdhan: useFajrAdhan),
      onDone: onDone,
    );
  }

  void loadAndPlayIqamaBipVoice(
    MosqueConfig? mosqueConfig, {
    VoidCallback? onDone,
  }) =>
      loadAndPlay(url: bipLink, onDone: onDone);

  void loadAndPlayDuaAfterAdhanVoice(
    MosqueConfig? mosqueConfig, {
    VoidCallback? onDone,
  }) =>
      loadAndPlay(url: duaAfterAdhanLink, onDone: onDone);

  Future<void> loadAssetsAndPlay(String assets, {VoidCallback? onDone}) async {
    if (player != null) stop();

    player = Audio.load(
      assets,
      onComplete: () {
        stop();

        onDone?.call();
      },
      onError: (message) => onDone?.call(),
    )..play();
  }

  Future<void> loadAndPlay({
    required String url,
    bool enableCache = true,
    VoidCallback? onDone,
  }) async {
    final file = await getFile(url, enableCache: enableCache);

    if (player != null) stop();

    player = Audio.loadFromByteData(
      file,
      onComplete: () {
        stop();
        onDone?.call();
      },
      onError: (message) {
        print("error$message");
        onDone?.call();
      },
    )..play();
  }

  Future<void> stop() async {
    player?.pause();
    player?.dispose();
  }

  /// this method will precache all the audio files for this mosque
  Future<void> precacheVoices(MosqueConfig config) async {
    await Future.wait([
      getFile(adhanLink(config)),
      getFile(adhanLink(config, useFajrAdhan: true)),
      getFile(bipLink),
      getFile(duaAfterAdhanLink),
    ]);
  }

  Future<ByteData> getFile(String url, {bool enableCache = true}) async {
    final file = await dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    return Uint8List.fromList(file.data!).buffer.asByteData();
  }

  void dispose() {
    stop();
    super.dispose();
  }
}
