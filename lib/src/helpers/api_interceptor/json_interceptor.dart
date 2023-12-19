import 'dart:convert';

import 'package:dio/dio.dart';

class JsonInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      jsonDecode(response.data.toString());
    } catch (e) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Response is not in JSON format',
        type: DioExceptionType.badResponse,
      );
    }
  }
}
