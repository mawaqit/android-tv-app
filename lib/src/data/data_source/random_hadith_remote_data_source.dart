import 'dart:developer';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:xml/xml.dart';

import '../../../main.dart';
import '../../helpers/random_hadith_helper.dart';
import '../../module/dio_module.dart';

/// [RandomHadithRemoteDataSource] Handles the retrieval of random hadiths from a remote server using Dio.
///
/// This class provides methods to fetch hadiths in plain text and XML format.
class RandomHadithRemoteDataSource {
  /// [dio] The Dio client used for making HTTP requests.
  final Dio dio;
  final Dio staticDio;

  RandomHadithRemoteDataSource({
    required this.dio,
    required this.staticDio,
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
      rethrow;
    }
  }

  /// [getRandomHadithXML] Fetches a random hadith in XML format from the remote server based on the provided language.
  ///
  /// The method returns a list of XmlElement objects representing the hadiths.
  Future<List<XmlElement>?> getRandomHadithXML({
    String language = 'ar',
  }) async {
    log('random_hadith: RandomHadithRemoteDataSource: Fetching random hadith XML', time: DateTime.now());
    try {
      final response = await staticDio.get('/ahadith/$language.xml');
      final List<XmlElement>? hadithXML = await Isolate.run(
        () async {
          log('random_hadith: RandomHadithRemoteDataSource: start xml fetch', time: DateTime.now());
          final document = XmlDocument.parse(response.data);

          final hadithXmlList = document.findAllElements('hadith').toList();
          log('random_hadith: RandomHadithRemoteDataSource: xml list ${hadithXmlList[3]}', time: DateTime.now());
          return hadithXmlList;
        },
        debugName: 'random_hadith: getRandomHadithXML',
      );
      log('random_hadith: RandomHadithRemoteDataSource: Finished fetching random hadith XML ${hadithXML![0]}',
          time: DateTime.now());
      return hadithXML;
    } catch (e) {
      logger.e('Error fetching random hadith XML $e', error: e);
      rethrow;
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
    final staticDio = ref.read(dioProvider(DioProviderParameter(baseUrl: kStaticFilesUrl)));
    return RandomHadithRemoteDataSource(
      dio: dio.dio,
      staticDio: staticDio.dio,
    );
  },
);
