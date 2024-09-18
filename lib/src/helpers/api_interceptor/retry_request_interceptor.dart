import 'dart:io';
import 'package:dio/dio.dart';

class RetryOnConnectionInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryOnConnectionInterceptor({
    required this.dio,
    this.maxRetries = 3,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      try {
        final retrier = DioHttpRequestRetrier(dio: dio, maxRetries: maxRetries);
        final response = await retrier.requestRetry(err.requestOptions);
        handler.resolve(response);
      } catch (e) {
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException err) {
    return err.error is SocketException ||
        err.error is HandshakeException ||
        (err.error is HttpException &&
            (err.error as HttpException)
                .message
                .contains('Connection closed before full header was received'));
  }
}

class DioHttpRequestRetrier {
  final Dio dio;
  final int maxRetries;

  DioHttpRequestRetrier({
    required this.dio,
    this.maxRetries = 3,
  });

  Future<Response> requestRetry(RequestOptions requestOptions) async {
    int retries = 0;
    while (retries < maxRetries) {
      try {
        return await dio.request(
          requestOptions.path,
          cancelToken: requestOptions.cancelToken,
          data: requestOptions.data,
          onReceiveProgress: requestOptions.onReceiveProgress,
          onSendProgress: requestOptions.onSendProgress,
          queryParameters: requestOptions.queryParameters,
          options: Options(
            contentType: requestOptions.contentType,
            headers: requestOptions.headers,
            sendTimeout: requestOptions.sendTimeout,
            receiveTimeout: requestOptions.receiveTimeout,
            extra: requestOptions.extra,
            followRedirects: requestOptions.followRedirects,
            listFormat: requestOptions.listFormat,
            maxRedirects: requestOptions.maxRedirects,
            method: requestOptions.method,
            receiveDataWhenStatusError:
                requestOptions.receiveDataWhenStatusError,
            requestEncoder: requestOptions.requestEncoder,
            responseDecoder: requestOptions.responseDecoder,
            responseType: requestOptions.responseType,
            validateStatus: requestOptions.validateStatus,
          ),
        );
      } catch (e) {
        retries++;
        if (retries >= maxRetries) rethrow;
        await Future.delayed(
            Duration(seconds: 1 * retries)); // Add a delay before retrying
      }
    }
    throw DioException(
      requestOptions: requestOptions,
      error: 'Max retries reached',
    );
  }
}
