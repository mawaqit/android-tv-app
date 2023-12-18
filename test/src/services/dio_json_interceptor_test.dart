import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mawaqit/src/helpers/api_interceptor/json_interceptor.dart';

void main() {
  group('Interceptor Tests', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    const baseUrl = 'https://example.com';

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: baseUrl));
      dio.interceptors.add(JsonInterceptor());
      dioAdapter = DioAdapter(dio: dio);


    });
    test('Test onResponse Interceptor with correct JSON', () async {
      const route = '/test2';
      const responseJson =
      """
        {
          "message": "Success!"
        }
      """;
      dioAdapter.onGet(
          route,
            (server) => server.reply(
          200,
              responseJson,
          delay: const Duration(seconds: 1),
        ),
      );
      final response = await dio.get(route);
      expect(response.data, json.decode(responseJson));
    });

    test('Test onResponse Interceptor with incorrect JSON', () async {
      final responseJson = """test json""";
      final route = '/test';
      dioAdapter.onGet(
        route,
        (server) => server.reply(
          200,
          responseJson.toString(),
        ),
      );
      expect(() async => await dio.get(route), throwsA(isA<DioException>()));
    });
  });
}
