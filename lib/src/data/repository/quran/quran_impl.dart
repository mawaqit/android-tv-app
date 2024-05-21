import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/domain/model/quran/language_model.dart';
import 'package:mawaqit/src/domain/model/quran/surah_model.dart';
import 'package:mawaqit/src/domain/repository/quran/quran_repository.dart';
import 'package:mawaqit/src/data/data_source/quran/quran_local_data_source.dart';
import 'package:mawaqit/src/data/data_source/quran/quran_remote_data_source.dart';

class QuranImpl extends QuranRepository {
  final QuranRemoteDataSource _quranRemoteDataSource;
  final QuranLocalDataSource _quranLocalDataSource;

  QuranImpl(
    this._quranRemoteDataSource,
    this._quranLocalDataSource,
  );

  @override
  Future<List<LanguageModel>> getLanguages() async {
    final languages = await _quranRemoteDataSource.getLanguages();
    log('quran: QuranImpl: getSuwarByLanguage: ${languages[0]}');
    return languages;
  }

  @override
  Future<List<SurahModel>> getSuwarByLanguage({
    String languageCode = 'en',
  }) async {
    try {
      final suwar = await _quranRemoteDataSource.getSuwarByLanguage(languageCode: languageCode);
      log('quran: QuranImpl: getSuwarByLanguage: ${suwar[0]}');
      await _quranLocalDataSource.saveSuwarByLanguage(languageCode, suwar);
      return suwar;
    } on Exception catch (_) {
      final suwar = await _quranLocalDataSource.getSuwarByLanguage(languageCode);
      return suwar;
    }
  }
}

final quranRepositoryProvider = FutureProvider<QuranImpl>((ref) async {
  final quranRemoteDataSource = ref.read(quranRemoteDataSourceProvider);
  final quranLocalDataSource = await ref.read(quranLocalDataSourceProvider.future);
  return QuranImpl(quranRemoteDataSource, quranLocalDataSource);
});
