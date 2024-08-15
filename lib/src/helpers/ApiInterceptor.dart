import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:mawaqit/main.dart';

class ApiCacheInterceptor extends Interceptor {
  static Box<dynamic>? _box;

  static Future<void> init() async {
    if (_box != null) return;

    _box = await Hive.openBox('apiCache');
  }

  Box<dynamic> get box => _box!;

  String getCacheKey(RequestOptions options) {
    return options.uri.toString();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final cacheKey = getCacheKey(options);
    try {
      final cachedData = box.get(cacheKey);
      logger.i('interceptor: onRequest: Cache key: $cacheKey - cachedData: $cachedData');
      if (cachedData != null && options.extra['disableCache'] != true) {
        logger.i('interceptor: onRequest: Cache key: disableCache $cacheKey - cachedData: $cachedData');
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
        cacheResponse(cacheKey, response);
      }
      logger.i('interceptor: onResponse: Cache key: $cacheKey - cachedData: $response');
    } catch (e) {
      logger.e('interceptor: Error caching response: $e');
    }
    handler.next(response);
  }

  void cacheResponse(String cacheKey, Response response) {
    final cacheData = {
      'data': response,
      'lastModified': response.headers["Last-Modified"],
    };
    box.put(cacheKey, cacheData);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 404) return handler.next(err);

    final cacheKey = getCacheKey(err.requestOptions);
    final cachedData = box.get(cacheKey);

    if (cachedData != null && err.requestOptions.extra['disableCache'] != true) {
      final response = Response(
        data: cachedData['data'],
        headers: Headers.fromMap({'last-modified': cachedData['lastModified']}),
        statusCode: 200,
        requestOptions: err.requestOptions,
      );
      return handler.resolve(response);
    }

    return handler.next(err);
  }
}
