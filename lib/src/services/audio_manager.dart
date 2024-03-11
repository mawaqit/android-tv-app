import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';

import '../../const/resource.dart';
import '../../main.dart';

class AudioManager extends ChangeNotifier {
  String bipLink = "$kStaticFilesUrl/mp3/bip.mp3";

  String duaAfterAdhanLink = "$kStaticFilesUrl/mp3/duaa-after-adhan.mp3";

  Audio? player;

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

  /// Plays audio from provided ByteData.
  ///
  /// This method does not need to know the source of the ByteData, enabling
  /// flexibility in playing audio from different sources such as assets or network responses.
  ///
  /// Parameters:
  /// - [byteData]: The ByteData of the audio file to be played.
  /// - [onDone]: A callback that gets called when audio playback is complete.
  Future<void> loadAndPlayFromByteData(ByteData byteData,
      {VoidCallback? onDone}) async {
    // Load and play the audio from ByteData
    player = Audio.loadFromByteData(
      byteData,
      onComplete: () {
        stop(); // Automatically stop and release resources when done
        onDone?.call(); // Call the onDone callback if provided
      },
      onError: (message) {
        logger.e("Error playing audio: $message");
        onDone?.call(); // Call the onDone callback if an error occurs
      },
    )..play();
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
    final file = await getFileFromAssets(R.ASSETS_VOICES_ADHAN_BIP_MP3);

    if (player != null) stop();

    player = Audio.loadFromByteData(
      file,
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

  void dispose() {
    stop();
    super.dispose();
  }
}
