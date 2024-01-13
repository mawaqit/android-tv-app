import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/data/constants.dart';
import 'package:mawaqit/src/helpers/cache_interceptor.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';

import '../../main.dart';
import '../helpers/device_manager_provider.dart';
import '../module/dio_module.dart';
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
    final file = await _getFile(url, enableCache: enableCache);

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
      _getFile(adhanLink(config)),
      _getFile(adhanLink(config, useFajrAdhan: true)),
      _getFile(bipLink),
      _getFile(duaAfterAdhanLink),
    ]);
  }

  Future<ByteData> _getFile(String url, {bool enableCache = true}) async {
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
/// [audioManagerProvider] is a Singleton provider for the AudioManager class.
/// It is responsible for creating and managing an instance of AudioManager,
///
/// The provider uses other providers and services to configure and initialize
/// the AudioManager with necessary dependencies like network access (Dio) and caching.
final audioManagerProvider = Provider<AudioManager>((ref) {

  // Watches the deviceManagerProvider to get the current device information.
  final deviceManager = ref.watch(deviceManagerProvider);

  // Watches the directoryProvider to get the current directory path.
  final directoryPath = ref.watch(directoryProvider);

  // Retrieves the actual path from the directoryPath provider, defaulting to an empty string if not available.
  final String path = directoryPath.maybeWhen(
    orElse: () => '',
    data: (path) {
      return path;
    },
  );

  // Creates a cache interceptor using the device information and directory path.
  final interceptor = CacheInterceptorHelper().createInterceptor(deviceManager, path);

  // Configures Dio for network requests with the base URL and the cache interceptor.
  final dioParameters = DioProviderParameter(
    interceptor: interceptor,
    baseUrl: kStaticFilesUrl,
  );

  // Watches the dioProvider to get a configured Dio instance.
  final dioModule = ref.watch(dioProvider(dioParameters));

  // Creates an instance of AudioManager with the Dio instance.
  final audioManager = AudioManager();
  ref.onDispose(audioManager.dispose);
  return audioManager;
});

