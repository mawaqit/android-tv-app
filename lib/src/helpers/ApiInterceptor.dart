import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

/// save the last modified value and send it with the next request
/// The interceptor checks the cache before making a request and, if a valid
/// cached response exists, modifies the request headers to include
/// `If-Modified-Since`. This tells the server to return the resource only if
/// it has been modified since the provided date, minimizing data transfer.
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
      // If a cached response exists and caching is not disabled for this request,
      // set the 'If-Modified-Since' header for efficient data transfer.
      print(value?.toResponse(options).statusCode);
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
