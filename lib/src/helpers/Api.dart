import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/data/constants.dart';
import 'package:mawaqit/src/helpers/ApiInterceptor.dart';
import 'package:mawaqit/src/helpers/StreamGenerator.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/models/times.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:unique_identifier/unique_identifier.dart';

import '../models/mosque.dart';
import '../models/weather.dart';

class Api {
  static final dio = Dio(
    BaseOptions(
      baseUrl: kBaseUrl,
      headers: {
        'Api-Access-Token': kApiToken,
        'accept': 'application/json',
        'mawaqit-device': 'android-tv',
      },
    ),
  );

  static final cacheStore = HiveCacheStore(null);

  static Future<void> init() async {
    dio.interceptors.add(ApiCacheInterceptor(cacheStore));
  }

  /// only change the base url
  /// the local value should be saved using UserPreferences
  static useStagingApi([bool staging = true]) {
    if (staging)
      dio.options.baseUrl = kStagingUrl;
    else
      dio.options.baseUrl = kBaseUrl;
  }

  static Future<bool> kMosqueExistence(int id) {
    var url = 'https://mawaqit.net/en/id/$id?view=desktop';

    return dio.get(url).then((value) => true).catchError((e) => false);
  }

  static Future<bool> checkTheInternetConnection() {
    final url = 'https://www.google.com/';

    return dio
        .get(url, options: Options(extra: {'disableCache': true}))
        .timeout(Duration(seconds: 5))
        .then((value) => true)
        .catchError((e) => false);
  }

  /// re check the mosque if there are any updated data
  static Stream<Mosque> getMosqueStream(String id) async* {
    yield await getMosque(id);
    await for (var i in Stream.periodic(Duration(minutes: 1))) {
      yield await getMosque(id);
    }
  }

  static Future<Mosque> getMosque(String id) async {
    final response = await dio.get('/3.0/mosque/$id/info');

    return Mosque.fromMap(response.data);
  }

  /// re check the mosque config if there are any updated data
  static Stream<MosqueConfig> getMosqueConfigStream(String uuid) async* {
    yield await getMosqueConfig(uuid);
    await for (var i in Stream.periodic(Duration(minutes: 1))) {
      yield await getMosqueConfig(uuid);
    }
  }

  static Future<MosqueConfig> getMosqueConfig(String id) async {
    final response = await dio.get('/3.0/mosque/$id/config');

    return MosqueConfig.fromMap(response.data);
  }

  /// re check the mosque config if there are any updated data
  static Stream<Times> getMosqueTimesStream(String uuid) async* {
    yield await getMosqueTimes(uuid);
    await for (var i in Stream.periodic(Duration(minutes: 1))) {
      yield await getMosqueTimes(uuid);
    }
  }

  static Future<Times> getMosqueTimes(String id) async {
    final response = await dio.get('/3.0/mosque/$id/times');

    return Times.fromMap(response.data);
  }

  static Future<Mosque> searchMosqueWithId(String mosqueId) async {
    final response = await dio.get('/3.0/mosque/$mosqueId');

    return Mosque.fromMap(response.data);
  }

  static Future<List<Mosque>> searchMosques(String mosque, {page = 1}) async {
    final response = await dio.get(
      '/2.0/mosque/search?word=$mosque&page=$page',
    );

    List<Mosque> mosques = [];

    for (var item in response.data) {
      try {
        mosques.add(Mosque.fromMap(item));
      } catch (e, stack) {
        debugPrintStack(label: e.toString(), stackTrace: stack);
      }
    }

    return mosques;
  }

  static Future<String> randomHadith({String language = 'ar'}) async {
    final response = await dio.get(
      '/2.0/hadith/random',
      queryParameters: {'lang': language},
    );

    return response.data['text'];
  }

  static Future<dynamic> getWeather(String mosqueUUID) async {
    final response = await dio.get(
      '/2.0/mosque/$mosqueUUID/weather',
      options: Options(extra: {'disableCache': true}),
    );

    return Weather.fromMap(response.data);
  }

  static Stream<void> updateUserStatusStream() async* {
    await for (var i in generateStream(Duration(minutes: 10))) {
      await updateUserStatus();
      yield i;
    }
  }

  static Future<dynamic> updateUserStatus() async {
    final uuid = await MosqueManager.loadLocalUUID();
    if (uuid == null) return;

    final userPreferencesManager = UserPreferencesManager();
    await userPreferencesManager.init();
    final hardware = await DeviceInfoPlugin().androidInfo;
    final softWare = await PackageInfo.fromPlatform();
    final language = await AppLanguage.getCountryCode();

    final data = {
      'device-id': await UniqueIdentifier.serial,
      'box_brand': hardware.brand,
      'box_model': hardware.model,
      'android_version': hardware.version.release,
      'app_version': softWare.version,
      'language': language,
      'is_landscape': userPreferencesManager.orientationLandscape,
      'is_secondary_screen': userPreferencesManager.isSecondaryScreen,
      'is_web_view': userPreferencesManager.webViewMode,
      'is_announcement_mode': userPreferencesManager.announcementsOnly,
    };

    await dio
        .post('/3.0/mosque/$uuid/androidtv-life-status', data: data)
        .then((value) => logger.d(value))
        .catchError((e) => logger.d((e as DioError).requestOptions.uri));
  }
}
