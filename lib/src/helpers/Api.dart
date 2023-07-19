import 'dart:math';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/data/constants.dart';
import 'package:mawaqit/src/helpers/ApiInterceptor.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/models/times.dart';
import 'package:xml_parser/xml_parser.dart';

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

  /// this dio instance is used to get the static files like the ahadith
  static final dioStatic = Dio(
    BaseOptions(
      baseUrl: kStaticFilesUrl,
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

  /// get the hadith file from the static server and cache it
  /// return random hadith from the file
  static Future<String?> randomHadithCached({String language = 'ar'}) async {
    try {
      List<XmlElement> hadiths = [];

      for (var lang in language.split('-')) {
        final response = await dioStatic.get('/xml/ahadith/$lang.xml');

        final document = XmlDocument.from(response.data)!;

        hadiths.addAll(document.getElementsWhere(name: 'hadith')!);
      }

      final num = Random().nextInt(hadiths.length);
      return hadiths[num].text;
    } on DioError catch (e) {
      logger.d(e.requestOptions.uri);
    }
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
}
