import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/cupertino.dart';
import 'package:mawaqit/src/helpers/ApiInterceptor.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/models/times.dart';

import '../models/mosque.dart';
import '../models/weather.dart';

const kBaseUrlV2 = 'https://mawaqit.net/api/2.0';
const kBaseUrl = 'https://mawaqit.net/api/3.0';
const token = 'ad283fb2-844b-40fe-967c-5cb593e9005e';

class Api {
  static final dio = Dio(
    BaseOptions(
      baseUrl: kBaseUrl,
      headers: {
        'Api-Access-Token': token,
        'accept': 'application/json',
        'mawaqit-device': 'android-tv',
      },
    ),
  );

  static Future<void> init() async {
    final options = CacheOptions(
      store: HiveCacheStore(null),
      policy: CachePolicy.refresh,
    );

    dio.interceptors.add(await ApiCacheInterceptor.open(HiveCacheStore(null)));
    dio.interceptors.add(DioCacheInterceptor(options: options));
    // dio.interceptors.add(DioCacheManager(CacheConfig()).interceptor);
  }

  static Future<bool> kMosqueExistence(int id) {
    var url = 'https://mawaqit.net/en/id/$id?view=desktop';

    return dio.get(url).then((value) => true).catchError((e) => false);
  }

  static Future<bool> checkTheInternetConnection() {
    final url = 'https://www.google.com/';

    return dio.get(url).timeout(Duration(seconds: 10)).then((value) => true).catchError((e) => false);
  }

  /// re check the mosque if there are any updated data
  static Stream<Mosque> getMosqueStream(String id) async* {
    yield await getMosque(id);
    await for (var i in Stream.periodic(Duration(minutes: 1))) {
      yield await getMosque(id);
    }
  }

  static Future<Mosque> getMosque(String id) async {
    final response = await dio.get('/mosque/$id/info');

    return Mosque.fromMap(response.data);
  }

  /// re check the mosque config if there are any updated data
  static Stream<MosqueConfig> getMosqueConfigStream(String uuid) async* {
    yield await getMosqueConfig(uuid);
    await for (var i in Stream.periodic(Duration(minutes: 5))) {
      yield await getMosqueConfig(uuid);
    }
  }

  static Future<MosqueConfig> getMosqueConfig(String id) async {
    final response = await dio.get('/mosque/$id/config');

    return MosqueConfig.fromMap(response.data);
  }

  /// re check the mosque config if there are any updated data
  static Stream<Times> getMosqueTimesStream(String uuid) async* {
    yield await getMosqueTimes(uuid);
    await for (var i in Stream.periodic(Duration(minutes: 5))) {
      yield await getMosqueTimes(uuid);
    }
  }

  static Future<Times> getMosqueTimes(String id) async {
    final response = await dio.get('/mosque/$id/times');

    return Times.fromMap(response.data);
  }

  static Future<List<Mosque>> searchMosques(String mosque, {page = 1}) async {
    final response = await dio.get('$kBaseUrlV2/mosque/search?word=$mosque&page=$page');
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
      throw Exception('Failed to fetch mosque');
    }
  }

  static Future<String> randomHadith({String language = 'ar'}) async {
    final response = await dio.get(
      '$kBaseUrlV2/hadith/random',
      queryParameters: {'lang': language},
    );

    return response.data['text'];
  }

  static Future<dynamic> getWeather(String mosqueUUID) async {
    final response = await dio.get('$kBaseUrlV2/mosque/$mosqueUUID/weather');

    return Weather.fromMap(response.data);
  }
}
