import 'dart:developer';
import 'dart:math' hide log;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:disk_space_2/disk_space_2.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/data/data_source/device_info_data_source.dart';
import 'package:mawaqit/src/helpers/ApiInterceptor.dart';
import 'package:mawaqit/src/helpers/StreamGenerator.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/models/times.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:xml/xml.dart';

import '../data/data_source/cache_local_data_source.dart';
import '../domain/model/failure/mosque/mosque_failure.dart';
import '../models/hijri_data_config_model.dart';
import '../models/mosque.dart';
import '../models/weather.dart';

class Api {
  static final dio = Dio(
    BaseOptions(
      baseUrl: kBaseUrl,
      validateStatus: (int? status) {
        return status! >= 200 && status < 300 || status == 304;
      },
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

  static Future<void> init() async {
    /// suggestion to use ref of riverpod which is more consistent
    final cacheStore = CacheLocalDataSource();
    await cacheStore.init();
    final apiCacheInterceptor = ApiCacheInterceptor(cacheStore);
    dio.interceptors.add(apiCacheInterceptor);
    dioStatic.interceptors.add(apiCacheInterceptor);
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

    return dio
        .get(url, options: Options(extra: {'bypassJsonInterceptor': true}))
        .then((value) => true)
        .catchError((e) => false);
  }

  static Future<bool> checkTheInternetConnection() {
    final url = 'https://www.google.com/';

    return dio
        .get(url, options: Options(extra: {'disableCache': true, 'bypassJsonInterceptor': true}))
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
    try {
      final response = await dio.get(
        '/3.0/mosque/$id/info',
      );
      return Mosque.fromMap(response.data);
    } on DioException catch (e) {
      // error 404
      if (e.response != null && e.response?.statusCode == 404) {
        log('Mosque not found');
        _handleMosqueNotFound();
        throw MosqueNotFoundFailure();
      }
      rethrow;
    }
  }

  static Future<void> _handleMosqueNotFound() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(MosqueManagerConstant.khasCachedMosque, false);
    } catch (e) {
      log('Failed to update SharedPreferences: $e');
    }
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

  /// [getMosqueTimes] Fetches prayer times and hijri date configuration for a mosque.
  ///
  /// Retrieves the prayer times for a given mosque identified by [id].
  /// It also fetches the hijri date configuration associated with the mosque
  /// and merges this information into the `Times` model.
  static Future<Times> getMosqueTimes(String id) async {
    final response = await dio.get('/3.1/mosque/$id/times');
    final hijriDateConfig = await _getHijriDate(id);

    // Adds hijri date adjustment details to the response data.
    response.data['hijriAdjustment'] = hijriDateConfig.hijriAdjustment;
    response.data['hijriDateForceTo30'] = hijriDateConfig.hijriDateForceTo30;

    return Times.fromMap(response.data);
  }

  /// [_getHijriDate] Fetches the Hijri date configuration for a mosque.
  ///
  /// Makes an API call to retrieve the Hijri date settings for the mosque
  /// identified by [id]. The settings include whether there is an adjustment
  /// to the Hijri date and if the Hijri date should be forced to 30 days.
  static Future<HijriDateConfigModel> _getHijriDate(String id) async {
    final response = await dio.get('/3.0/mosque/$id/hijri-date');
    return HijriDateConfigModel.fromJson(response.data);
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

  /// prepare the data to be cached
  static Future<void> cacheHadithXMLFiles({String language = 'ar'}) =>
      Future.wait(language.split('-').map((e) => dioStatic.get('/ahadith/$e.xml')));

  /// get the hadith file from the static server and cache it
  /// return random hadith from the file
  static Future<String?> randomHadithCached({String language = 'ar'}) async {
    /// select only single language
    language = (language.split('-')..shuffle()).first;

    /// this should be called only on offline mode so it should hit the cache

    final response = await dioStatic.get('/ahadith/$language.xml');

    final document = XmlDocument.parse(response.data);

    final hadiths = document.findAllElements('hadith');

    if (hadiths.isEmpty) return null;

    final random = Random().nextInt(hadiths.length);

    return hadiths.elementAt(random).innerText;
  }

  /// get the hadith from the server directly
  static Future<String> randomHadith({String language = 'ar'}) async {
    final response = await dio.get('/2.0/hadith/random',
        queryParameters: {'lang': language},
        options: Options(extra: {'disableCache': true, "bypassJsonInterceptor": true}));

    return response.data['text'];
  }

  static Future<dynamic> getWeather(String mosqueUUID) async {
    final response = await dio.get(
      '/2.0/mosque/$mosqueUUID/weather',
      options: Options(extra: {'disableCache': true, "bypassJsonInterceptor": true}),
    );

    return Weather.fromMap(response.data);
  }

  static Stream<void> updateUserStatusStream() async* {
    bool isBoxOrAndroidTV = await DeviceInfoDataSource().isBoxOrAndroidTV();
    if (isBoxOrAndroidTV) {
      await for (var i in generateStream(Duration(minutes: 10))) {
        await updateUserStatus();
        yield i;
      }
    }
  }

  static Future<(String, Map<String, dynamic>)?> prepareUserData() async {
    try {
      double? freeSpace = await DiskSpace.getFreeDiskSpace;
      double? totalSpace = await DiskSpace.getTotalDiskSpace;

      final userPreferencesManager = UserPreferencesManager();
      await userPreferencesManager.init();

      var hardwareFuture = DeviceInfoPlugin().androidInfo;
      var softwareFuture = PackageInfo.fromPlatform();
      var languageFuture = AppLanguage.getCountryCode();
      var deviceIdFuture = UniqueIdentifier.serial;

      // Wait for all futures to complete in a parallel way
      var results = await Future.wait([hardwareFuture, softwareFuture, languageFuture, deviceIdFuture]);

      // Extract results
      var hardware = results[0] as AndroidDeviceInfo;
      var software = results[1] as PackageInfo;
      var language = results[2] as String;
      var deviceId = results[3] as String;

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
