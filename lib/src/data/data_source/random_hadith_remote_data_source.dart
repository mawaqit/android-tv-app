import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:xml_parser/xml_parser.dart';

import '../../../main.dart';
import '../../module/dio_module.dart';

/// [RandomHadithRemoteDataSource] Handles the retrieval of random hadiths from a remote server using Dio.
///
/// This class provides methods to fetch hadiths in plain text and XML format.
class RandomHadithRemoteDataSource {
  /// [dio] The Dio client used for making HTTP requests.
  final Dio dio;

  RandomHadithRemoteDataSource({
    required this.dio,
  });

  /// [getRandomHadith] Fetches a random hadith in plain text format from the remote server based
  /// on the provided language.
  Future<String> getRandomHadith({
    String language = 'ar',
  }) async {
    try {
      final response = await dio.get(
        '/2.0/hadith/random',
        queryParameters: {'lang': language},
      );
      return response.data['text'];
    } catch (e) {
      throw e;
    }
  }

  /// [getRandomHadithXML] Fetches a random hadith in XML format from the remote server based on the provided language.
  ///
  /// This is a static method and initializes its own Dio client for the request.
  /// Dio is initialized internally to ensure the method can be seamlessly executed within an isolate.
  static Future<List<XmlElement>?> getRandomHadithXML({
    String language = 'ar',
  }) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: kStaticFilesUrl,
        headers: {
          'Api-Access-Token': kApiToken,
          'accept': 'application/json',
          'mawaqit-device': 'android-tv',
        },
      ),
    );

    try {
      final response = await dio.get('/xml/ahadith/$language.xml');

      final document = XmlDocument.from(response.data)!;

      final hadithXmlList = document.getElements('hadith');
      return hadithXmlList;
    } catch (e) {
      throw e;
    }
  }

}

/// Riverpod provider for [RandomHadithRemoteDataSource].
///
/// This provider auto-disposes and is responsible for initializing and providing an instance of
/// RandomHadithRemoteDataSource. It leverages the dioProvider for Dio client configuration.
final randomHadithRemoteDataSourceProvider = Provider.autoDispose<RandomHadithRemoteDataSource>(
  (ref) {
    final dioParameters = DioProviderParameter(
      baseUrl: kBaseUrl,
    );
    final dio = ref.read(dioProvider(dioParameters));
    return RandomHadithRemoteDataSource(
      dio: dio.dio,
    );
  },
);
