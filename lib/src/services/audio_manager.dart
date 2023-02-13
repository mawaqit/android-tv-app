import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';

import 'package:flutter/foundation.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';

class AudioManager extends ChangeNotifier {
  String adhanLink = "$kStaticFilesUrl/mp3/adhan-afassy.mp3";
  String bipLink = "$kStaticFilesUrl/mp3/bip.mp3";
  String duaAfterAdhanLink = "$kStaticFilesUrl/mp3/duaa-after-adhan.mp3";

  Audio? player;

  final option = CacheOptions(
    store: HiveCacheStore(null),
    priority: CachePriority.high,
    policy: CachePolicy.forceCache,
  );

  late final dio = Dio()
    ..interceptors.add(DioCacheInterceptor(options: option));

  void loadAndPlayAdhanVoice(
    MosqueConfig? mosqueConfig, {
    VoidCallback? onDone,
  }) {
    if (mosqueConfig!.adhanVoice?.isNotEmpty ?? false) {
      adhanLink = "$kStaticFilesUrl/mp3/${mosqueConfig.adhanVoice!}.mp3";
    }

    loadAndPlay(url: adhanLink, onDone: onDone);
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
