import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:hive/hive.dart';

/// save the last modified value and send it with the next request
class ApiCacheInterceptor extends Interceptor {
  final Box<String> cacheBox;
  final CacheStore store;

  ApiCacheInterceptor._(this.cacheBox, this.store);

  static Future<ApiCacheInterceptor> open(CacheStore store) async {
    final box = await Hive.openBox<String>('Api-Cache-Box');

    return ApiCacheInterceptor._(box, store);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final latModified = cacheBox.get(options.uri.toString());

    if (latModified != null) {
      options.headers['If-Modified-Since'] = latModified;
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final lastModified = response.headers['Last-Modified'];

    if (lastModified?.isNotEmpty ?? false) {
      cacheBox.put(response.requestOptions.uri.toString(), lastModified!.first);
    }

    print(response.statusCode);
    handler.next(response);
  }

  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    final value = await store.get(CacheOptions.defaultCacheKeyBuilder(err.requestOptions));

    if (value != null) return handler.resolve(value.toResponse(err.requestOptions));

    return handler.next(err);
  }
}
