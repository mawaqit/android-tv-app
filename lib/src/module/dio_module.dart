import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mawaqit/src/const/constants.dart';

/// [DioModule] is a wrapper class for the Dio HTTP client.
/// It configures Dio with custom settings such as base URL, and interceptors.
class DioModule {
  Dio _dio;

  DioModule({
    String? baseUrl,
    Map<String, dynamic>? headers,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Dio? dio,
    Interceptor? interceptor,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? '',
                connectTimeout: connectTimeout ?? Duration(seconds: 5),
                receiveTimeout: receiveTimeout ?? Duration(seconds: 10),
                headers: headers,
              ),
            ) {
    if (interceptor != null) {
      _dio.interceptors.add(interceptor);
    }
    // Adding a logging interceptor for better debugging and logging of HTTP requests and responses.
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        responseBody: true,
        requestBody: true,
        requestHeader: false,
        responseHeader: false,
      ),
    );
  }

  Map<String, String> get defaultHeader => {
        'Api-Access-Token': kApiToken,
        'accept': 'application/json',
        'mawaqit-device': 'android-tv',
      };

  /// Getter to expose the Dio instance.
  Dio get dio => _dio;
}

/// [DioProviderParameter] is a configuration class to parameterize DioProvider.
class DioProviderParameter {
  /// [baseUrl]: The base URL to be used for HTTP requests.
  final String baseUrl;

  /// [interceptor]: An optional interceptor for Dio.
  final Interceptor? interceptor;

  DioProviderParameter({
    required this.baseUrl,
    this.interceptor,
  });
}

/// [dioProvider] is a Riverpod provider for creating DioModule instances.
/// It allows creating DioModule with different configurations throughout the app.
final dioProvider = Provider.family<DioModule, DioProviderParameter>((ref, dioParameter) {
  return DioModule(
    /// kStaticFilesUrl , kBaseUrl, kStaticFilesUrl
    baseUrl: dioParameter.baseUrl,
    headers: DioModule().defaultHeader,
    interceptor: dioParameter.interceptor,
  );
});
