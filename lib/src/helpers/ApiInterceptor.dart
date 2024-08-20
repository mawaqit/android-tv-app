import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/helpers/CrashlyticsWrapper.dart';
import 'dart:convert';

import 'package:mawaqit/src/data/data_source/cache_local_data_source.dart';

class ApiCacheInterceptor extends Interceptor {
  final CacheLocalDataSource cacheManager;

  ApiCacheInterceptor(this.cacheManager);

  String getCacheKey(RequestOptions options) {
    return options.uri.toString();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final cacheKey = getCacheKey(options);
    try {
      final cachedData = await cacheManager.getCachedData(cacheKey);
      if (cachedData != null && options.extra['disableCache'] != true) {
        final lastModified = cachedData['lastModified'];
        if (lastModified != null) {
          options.headers[HttpHeaderConstant.kHeaderIfModifiedSince] = lastModified;
        }
      }
    } catch (e, s) {
      logger.e('interceptor: Error handling request: $e');
      CrashlyticsWrapper.sendException(e, s);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    try {
      final cacheKey = getCacheKey(response.requestOptions);

      if (response.statusCode == 200 && _isJsonResponse(response)) {
        await cacheManager.cacheResponse(cacheKey, response);
      } else if (response.statusCode == 304) {
        final cachedData = await cacheManager.getCachedData(cacheKey);
        if (cachedData != null) {
          final responseData = json.decode(cachedData['data']);
          final cachedResponse = Response(
            data: responseData,
            headers: Headers.fromMap({
              'last-modified': [cachedData['lastModified']]
            }),
            statusCode: 200,
            requestOptions: response.requestOptions,
          );
          return handler.resolve(cachedResponse);
        }
      }
    } catch (e, s) {
      CrashlyticsWrapper.sendException(e, s);
      return handler.reject(DioError(requestOptions: response.requestOptions, error: e));
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_isConnectionError(err)) {
      final cacheKey = getCacheKey(err.requestOptions);
      try {
        final cachedData = await cacheManager.getCachedData(cacheKey);
        if (cachedData != null) {
          final responseData = json.decode(cachedData['data']);
          final cachedResponse = Response(
            data: responseData,
            headers: Headers.fromMap({
              'last-modified': [cachedData['lastModified']]
            }),
            statusCode: 200,
            requestOptions: err.requestOptions,
          );
          return handler.resolve(cachedResponse);
        }
      } catch (e, s) {
        logger.e('Error retrieving cached data: $e');
        CrashlyticsWrapper.sendException(e, s);
      }
    }
    if (err.response?.statusCode == 404) return handler.next(err);
    return handler.next(err);
  }

  bool _isJsonResponse(Response response) {
    final contentType = response.headers.value(HttpHeaderConstant.kHeaderContentType);
    return contentType != null && contentType.contains(HttpHeaderConstant.kContentTypeApplicationJson);
  }

  bool _isConnectionError(DioException err){
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError;
  }
}

final apiCacheInterceptorProvider = FutureProvider<ApiCacheInterceptor>((ref) async {
  final cacheLocalDataSource = await ref.read(cacheLocalDataSourceProvider.future);
  return ApiCacheInterceptor(cacheLocalDataSource);
});
