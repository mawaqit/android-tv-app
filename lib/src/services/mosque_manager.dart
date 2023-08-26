import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/enum/home_active_screen.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/helpers/PerformanceHelper.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/mawaqit_image/mawaqit_cache.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/models/times.dart';
import 'package:mawaqit/src/pages/home/widgets/footer.dart';
import 'package:mawaqit/src/services/audio_manager.dart';
import 'package:mawaqit/src/services/mixins/mosque_helpers_mixins.dart';
import 'package:mawaqit/src/services/mixins/random_hadith_mixin.dart';
import 'package:mawaqit/src/services/mixins/weather_mixin.dart';

import 'mixins/audio_mixin.dart';
import 'mixins/connectivity_mixin.dart';

final mawaqitApi = "https://mawaqit.net/api/2.0";

const kAfterAdhanHadithDuration = Duration(minutes: 1);
const kAdhanBeforeFajrDuration = Duration(minutes: 10);

const kAzkarDuration = const Duration(seconds: 140);

class MosqueManager extends ChangeNotifier
    with
        WeatherMixin,
        AudioMixin,
        MosqueHelpersMixin,
        NetworkConnectivity,
        RandomHadithMixin {
  final sharedPref = SharedPref();

  // String? mosqueId;
  String? mosqueUUID;

  bool get loaded => mosque != null && times != null && mosqueConfig != null;

  Mosque? mosque;
  Times? times;
  MosqueConfig? mosqueConfig;

  StreamSubscription? _mosqueSubscription;
  StreamSubscription? _timesSubscription;
  StreamSubscription? _configSubscription;

  HomeActiveWorkflow workflow = HomeActiveWorkflow.normal;

  /// get current home url
  String buildUrl(String languageCode) {
    // if (mosqueId != null) return 'https://mawaqit.net/$languageCode/id/$mosqueId?view=desktop';
    // if (mosqueSlug != null) return 'https://mawaqit.net/$languageCode/$mosqueSlug?view=desktop';
    return 'https://mawaqit.net/$languageCode/id/${mosque?.id}?view=desktop';
  }

  Future<void> init() async {
    await Api.init();
    await loadFromLocale();
    // subscribeToTime();
    listenToConnectivity();

    notifyListeners();
  }

  /// update mosque id in the app and shared preference
  Future<void> setMosqueUUid(String uuid) async {
    try {
      await fetchMosque(uuid);
      calculateActiveWorkflow();

      _saveToLocale();

      // print("mosque url${mosque?.url}");
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> _saveToLocale() async {
    // await sharedPref.save('mosqueId', mosqueId);
    await sharedPref.save('mosqueUUId', mosqueUUID);
    // sharedPref.save('mosqueSlug', mosqueSlug);
  }

  static Future<String?> loadLocalUUID() async {
    final sharedPref = SharedPref();
    return await sharedPref.read('mosqueUUId');
  }

  Future<void> loadFromLocale() async {
    // mosqueId = await sharedPref.read('mosqueId');
    mosqueUUID = await sharedPref.read('mosqueUUId');
    if (mosqueUUID != null) {
      await fetchMosque(mosqueUUID!);
      calculateActiveWorkflow();
    }
  }

  /// this method responsible for
  /// - fetching mosque, times, config
  /// - request audio manager to precache voices
  /// - request mawaqit cache to precache images after first load
  /// - handle errors of response
  /// It will return a future that will be completed when all data is fetched and cached
  Future<void> fetchMosque(String uuid) async {
    _mosqueSubscription?.cancel();
    _timesSubscription?.cancel();
    _configSubscription?.cancel();

    /// if getting item returns an error
    onItemError(e, stack) {
      logger.e(e, '', stack);

      mosque = null;
      notifyListeners();

      throw e;
    }

    /// cache date before complete the [completer]
    Future<void> completeFuture() async {
      await Future.wait([
        AudioManager().precacheVoices(mosqueConfig!),
        preCacheImages(),
        preCacheHadith(),
      ]).catchError((e) {});
    }

    final mosqueStream = Api.getMosqueStream(uuid).asBroadcastStream();
    final timesStream = Api.getMosqueTimesStream(uuid).asBroadcastStream();
    final configStream = Api.getMosqueConfigStream(uuid).asBroadcastStream();

    _mosqueSubscription = mosqueStream.listen(
      (e) {
        mosque = e;
        notifyListeners();
      },
      onError: onItemError,
    );

    _timesSubscription = timesStream.listen(
      (e) {
        times = e;
        notifyListeners();
      },
      onError: onItemError,
    );

    _configSubscription = configStream.listen(
      (e) {
        mosqueConfig = e;
        notifyListeners();
      },
      onError: onItemError,
    );

    /// wait for all streams to complete
    await Future.wait([
      mosqueStream.first.logPerformance('mosque'),
      timesStream.first.logPerformance('times'),
      configStream.first.logPerformance('config'),
    ]).logPerformance('Mosque data loader');
    await completeFuture();

    loadWeather(mosque!);

    mosqueUUID = uuid;
  }

  Future<Mosque> searchMosqueWithId(String mosqueId) =>
      Api.searchMosqueWithId(mosqueId);

  Future<List<Mosque>> searchMosques(String mosque, {page = 1}) async =>
      Api.searchMosques(mosque, page: page);

//todo handle page and get more
  Future<List<Mosque>> searchWithGps() async {
    final position =
        await getCurrentLocation().catchError((e) => throw GpsError());

    final url = Uri.parse(
        "$mawaqitApi/mosque/search?lat=${position.latitude}&lon=${position.longitude}");
    Map<String, String> requestHeaders = {
      // "Api-Access-Token": mawaqitApiToken,
    };
    final response = await http.get(url, headers: requestHeaders);
    // print(response.body);
    if (response.statusCode == 200) {
      final results = jsonDecode(response.body);
      List<Mosque> mosques = [];

      for (var item in results) {
        try {
          mosques.add(Mosque.fromMap(item));
        } catch (e, stack) {
          debugPrintStack(label: e.toString(), stackTrace: stack);
        }
      }

      return mosques;
    } else {
      print(response.body);
      // If that response was not OK, throw an error.
      throw Exception('Failed to fetch mosque');
    }
  }

  Future<Position> getCurrentLocation() async {
    var enabled = await GeolocatorPlatform.instance
        .isLocationServiceEnabled()
        .timeout(Duration(seconds: 5));

    if (!enabled) {
      enabled = await GeolocatorPlatform.instance.openLocationSettings();
    }
    if (!enabled) throw GpsError();

    final permission = await GeolocatorPlatform.instance.requestPermission();
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) throw GpsError();

    return await GeolocatorPlatform.instance.getCurrentPosition();
  }

  /// handle pre caching for images
  /// Qr, mosque image, mosque logo, announcement image
  Future<void> preCacheImages() async {
    final images = [
      mosque?.image,
      mosque?.logo,
      mosque?.interiorPicture,
      mosque?.exteriorPicture,
      mosqueConfig?.motifUrl,
      kFooterQrLink,
      ...mosque?.announcements
              .map((e) => e.image)
              .where((element) => element != null) ??
          <String>[],
    ].where((e) => e != null).cast<String>();

    /// some images isn't existing anymore so we will ignore errors
    final futures = images
        .map((e) => MawaqitImageCache.cacheImage(e).catchError((e) {}))
        .toList();
    await Future.wait(futures);
  }
}

/// user for invalid mosque id-slug
class InvalidMosqueId implements Exception {}

class GpsError implements Exception {}
