import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:mawaqit/main.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class ApiCacheInterceptor extends Interceptor {
  static Box<dynamic>? _box;

  static Future<void> init() async {
    if (_box != null) return;
    final directory = await getApplicationDocumentsDirectory();

    _box = await Hive.openBox('apiCache', path: directory.path);
  }

  Box<dynamic> get box => _box!;

  String getCacheKey(RequestOptions options) {
    return options.uri.toString();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final cacheKey = getCacheKey(options);
    try {
      logger.i('interceptor: onRequest: Box is open: ${box.isOpen}');
      logger.i('interceptor: onRequest: Box length: ${box.length}');
      logger.i('interceptor: onRequest: All keys in box: ${box.keys.toList()}');
      final cachedData = await box.get(cacheKey);
      logger.i('interceptor: onRequest: Cache key: $cacheKey - cachedData: $cachedData');

      if (cachedData != null && options.extra['disableCache'] != true) {
        final lastModified = cachedData['lastModified'];
        if (lastModified != null) {
          options.headers['If-Modified-Since'] = lastModified;
        }
      }
    } catch (e) {
      logger.e('interceptor: Error fetching from cache: $e');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    try {
      final cacheKey = getCacheKey(response.requestOptions);
      if (response.statusCode == 200) {
        await cacheResponse(cacheKey, response);
        logger.i('interceptor: onResponse: Cache key: $cacheKey - cachedData: ${response.data}');
      }
    } catch (e) {
      logger.e('interceptor: Error caching response: $e');
    }
    handler.next(response);
  }

  Future<void> cacheResponse(String cacheKey, Response response) async {
    final cacheData = {
      'data': json.encode(response.data),
      'lastModified': response.headers.value("Last-Modified"),
    };
    await box.put(cacheKey, cacheData);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 404) return handler.next(err);

    final cacheKey = getCacheKey(err.requestOptions);
    final cachedData = await box.get(cacheKey);

    if (cachedData != null && err.requestOptions.extra['disableCache'] != true) {
      final responseData = json.decode(cachedData['data']);
      final response = Response(
        data: responseData,
        headers: Headers.fromMap({'last-modified': cachedData['lastModified']}),
        statusCode: 200,
        requestOptions: err.requestOptions,
      );
      return handler.resolve(response);
    }

    return handler.next(err);
  }
}
