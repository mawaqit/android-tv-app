import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/domain/model/quran/language_model.dart';
import 'package:mawaqit/src/domain/model/quran/surah_model.dart';

import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/module/dio_module.dart';

import 'package:mawaqit/src/domain/error/quran_exceptions.dart';

class QuranRemoteDataSource {
  final Dio _dio;

  QuranRemoteDataSource(this._dio);

  /// [getLanguages] get the list of languages
  ///
  /// gets the list of languages from the api `https://mp3quran.net/api/v3/languages`
  Future<List<LanguageModel>> getLanguages() async {
    try{
      final response = await _dio.get('languages');
      // log('quran: QuranRemoteDataSource: getLanguages: ${response.data}');
      return (response.data['language'] as List).map((e) => LanguageModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FetchLanguagesException(e.toString());
    }
  }

  /// [getSuwarByLanguage] get the list of surwars by language code
  ///
  /// [languageCode] is the language code of the surwars using the api `https://mp3quran.net/api/v3/suwar`
  Future<List<SurahModel>> getSuwarByLanguage({String languageCode = 'eng'}) async {
    try{
      final response = await _dio.get(
        'suwar',
        queryParameters: {'language': languageCode},
      );
      // log('quran: QuranRemoteDataSource: getSuwarByLanguage: ${response.data}');
      return (response.data['suwar'] as List).map((e) => SurahModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw FetchSuwarByLanguageException(e.toString());
    }
  }
}

final quranRemoteDataSourceProvider = Provider<QuranRemoteDataSource>((ref) {
  final dio = ref.watch(
    dioProvider(
      DioProviderParameter(baseUrl: QuranConstant.kQuranBaseUrl),
    ),
  );
  return QuranRemoteDataSource(dio.dio);
});
