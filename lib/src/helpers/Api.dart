import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:disk_space/disk_space.dart';
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
import 'package:xml_parser/xml_parser.dart';

import '../models/mosque.dart';
import '../models/weather.dart';
import 'api_interceptor/json_interceptor.dart';

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

  /// this dio instance is used to get the static files like the ahadith
  static final dioStatic = Dio(
    BaseOptions(
      baseUrl: kStaticFilesUrl,
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 10),
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
    dioStatic.interceptors.add(ApiCacheInterceptor(cacheStore));
    dio.interceptors.add(JsonInterceptor());
    dioStatic.interceptors.add(JsonInterceptor());
  }

  /// only change the base url
  /// the local value should be saved using UserPreferences
  static useStagingApi([bool staging = true]) {
    if (staging) {
      dio.options.baseUrl = kStagingUrl;
      dioStatic.options.baseUrl = kStagingStaticFilesUrl;
    } else {
      dio.options.baseUrl = kBaseUrl;
      dioStatic.options.baseUrl = kStaticFilesUrl;
    }
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
    final response = await dio.get(
      '/3.0/mosque/$id/info',
    );

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
    final response = await dio.get('/3.1/mosque/$id/times');

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

  static Future<void> cacheHadithXMLFiles({String language = 'ar'}) =>
      Future.wait(
          language.split('-').map((e) => dioStatic.get('/xml/ahadith/$e.xml')));

  /// get the hadith file from the static server and cache it
  /// return random hadith from the file
  static Future<String?> randomHadithCached({String language = 'ar'}) async {
    /// select only single language
    language = (language.split('-')..shuffle()).first;

    /// this should be called only on offline mode so it should hit the cache

    final response = await dioStatic.get('/xml/ahadith/$language.xml');

    final document = XmlDocument.from(response.data)!;

    final hadiths = document.getElements('hadith');

    if (hadiths == null) return null;

    final random = Random().nextInt(hadiths.length);

    return hadiths[random].text;
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

  static Future<(String, Map<String, dynamic>)?> prepareUserData() async {
    try {
      final userPreferencesManager = UserPreferencesManager();
      await userPreferencesManager.init();

      var hardwareFuture = DeviceInfoPlugin().androidInfo;
      var softwareFuture = PackageInfo.fromPlatform();
      var languageFuture = AppLanguage.getCountryCode();
      var freeSpaceFuture = DiskSpace.getFreeDiskSpace;
      var totalSpaceFuture = DiskSpace.getTotalDiskSpace;
      var deviceIdFuture = UniqueIdentifier.serial;

      // Wait for all futures to complete in a parallel way
      var results = await Future.wait([
        hardwareFuture,
        softwareFuture,
        languageFuture,
        freeSpaceFuture,
        totalSpaceFuture,
        deviceIdFuture
      ]);

      // Extract results
      var hardware = results[0] as AndroidDeviceInfo;
      var software = results[1] as PackageInfo;
      var language = results[2] as String;
      var freeSpace = results[3] as double;
      var totalSpace = results[4] as double;
      var deviceId = results[5] as String;

      final commonDeviceData = {
        'device-id': deviceId,
        'brand': hardware.brand,
        'model': hardware.model,
        'android-version': hardware.version.release,
        'app-version': software.version,
        'space': totalSpace,
        'free-space': freeSpace,
      };

      final uuid = await MosqueManager.loadLocalUUID();
      if (uuid == null) {
        return ("Mosque uuid is not set", commonDeviceData);
      }

      final userData = {
        ...commonDeviceData,
        'mosque-uuid': uuid,
        'language': language,
        'landscape': userPreferencesManager.orientationLandscape,
        'secondary-screen': userPreferencesManager.isSecondaryScreen,
        'legacy-web-app': userPreferencesManager.webViewMode,
        'announcement-mode': userPreferencesManager.announcementsOnly,
      };
      return (uuid, userData);
    } catch (e, stack) {
      debugPrintStack(label: e.toString(), stackTrace: stack);
      return null;
    }
  }

  static Future<dynamic> updateUserStatus() async {
    final userData = await Api.prepareUserData();

    if (userData == null) return;
    final (uuid, data) = userData;

    await dio
        .post('/3.0/mosque/${uuid}/androidtv-life-status', data: data)
        .then((value) => logger.d(value))
        .catchError((e) => logger.d((e as DioError).requestOptions.uri));
  }
}
