import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/models/times.dart';

import '../models/mosque.dart';
import '../models/weather.dart';

const kBaseUrlV2 = 'https://mawaqit.net/api/2.0';
const kBaseUrl = 'https://mawaqit.net/api/3.0';
const token = 'ad283fb2-844b-40fe-967c-5cb593e9005e';

class Api {
  static final dio = Dio(BaseOptions(baseUrl: kBaseUrl, headers: {
    'Api-Access-Token': token,
    'accept': 'application/json',
    'mawaqit-device':'android-tv'
  }));

  static Future<void> init() async {
    dio.interceptors.add(DioCacheManager(CacheConfig()).interceptor);
    // final response = await dio.get(
    //   '$kBaseUrlV2/me',
    //   options: Options(headers: {'Authorization': token}),
    // );
    // //
    // dio.options.headers['Api-Access-Token'] = response.data['apiAccessToken'];
  }

  static Future<bool> kMosqueExistence(int id) {
    var url = 'https://mawaqit.net/en/id/$id?view=desktop';

    return dio.get(url).then((value) => true).catchError((e) => false);
  }

  static Future<Mosque> getMosque(String id) async {
    final response = await dio.get('/mosque/$id/info');

    return Mosque.fromMap(response.data);
  }
  static Future<MosqueConfig> getMosqueConfig(String id) async {
    final response = await dio.get('/mosque/$id/config');

    return MosqueConfig.fromMap(response.data);
  }

  static Future<Times> getMosqueTimes(String id) async {
    final response = await dio.get('/mosque/$id/times');

    return Times.fromMap(response.data);
  }

  static Future<List<Mosque>> searchMosques(String mosque, {page = 1}) async {
    final response = await dio.get('/mosque/search?word=$mosque&page=$page');
    if (response.statusCode == 200) {
      List<Mosque> mosques = [];

      for (var item in response.data) {
        try {
          mosques.add(Mosque.fromMap(item));
        } catch (e, stack) {
          debugPrintStack(label: e.toString(), stackTrace: stack);
        }
      }

      return mosques;
    } else {
      print(response.data);
      // If that response was not OK, throw an error.
      throw Exception('Failed to fetch mosque');
    }
  }

  static Future<String> randomHadith({String language = 'ar'}) async {
    final response = await dio.get(
      '$kBaseUrlV2/hadith/random',
      options: buildCacheOptions(Duration(days: 1)),
      queryParameters: {'lang': language},
    );

    return response.data['text'];
  }

  static Future<dynamic> getWeather(String mosqueUUID) async {
    final response = await dio.get(
      '$kBaseUrlV2/mosque/$mosqueUUID/weather',
      options: buildCacheOptions(Duration.zero, maxStale: Duration.zero),
    );

    return Weather.fromMap(response.data);
  }
}
