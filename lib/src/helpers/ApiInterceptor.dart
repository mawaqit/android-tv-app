import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

/// save the last modified value and send it with the next request
/// The interceptor checks the cache before making a request and, if a valid
/// cached response exists, modifies the request headers to include
/// `If-Modified-Since`. This tells the server to return the resource only if
/// it has been modified since the provided date, minimizing data transfer.

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
    final cachedData = box.get(cacheKey);

    if (cachedData != null && options.extra['disableCache'] != true) {
      final lastModified = cachedData['lastModified'];
      if (lastModified != null) {
        options.headers['If-Modified-Since'] = lastModified;
      }
    }

    handler.next(options);
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
