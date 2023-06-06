import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

/// save the last modified value and send it with the next request
class ApiCacheInterceptor extends DioCacheInterceptor {
  final CacheStore store;

  ApiCacheInterceptor(this.store) : super(options: CacheOptions(store: store, policy: CachePolicy.refresh));

  String getCacheKey(RequestOptions options) => CacheOptions.defaultCacheKeyBuilder(options);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await store.get(getCacheKey(options)).then((value) {
      if (value != null && options.extra['disableCache'] != true) {
        options.headers['If-Modified-Since'] = value.lastModified;
      }
    });

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    /// use cache if the server returns 304 or no response
    if (err.response?.statusCode == 404) return handler.next(err);

    final value = await store.get(getCacheKey(err.requestOptions));

    if (value != null && err.requestOptions.extra['disableCache'] != true)
      return handler.resolve(value.toResponse(err.requestOptions));

    return handler.next(err);
  }
}
