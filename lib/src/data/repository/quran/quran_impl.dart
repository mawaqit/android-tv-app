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
  final Duration _cacheValidityDuration = Duration(hours: 24);

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
      // Check if cached data exists and is still valid
      if (await _isCacheValid(languageCode)) {
        final cachedSuwar = await _quranLocalDataSource.getSuwarByLanguage(languageCode);
        return cachedSuwar;
      }

      // If cache is invalid or doesn't exist, fetch from remote
      final suwar = await _quranRemoteDataSource.getSuwarByLanguage(languageCode: languageCode);

      // Save the new data to cache with current timestamp
      await _saveSuwarWithTimestamp(languageCode, suwar);

      return suwar;
    } on Exception catch (_) {
      // If remote fetch fails, try to return cached data even if it's outdated
      final cachedSuwar = await _quranLocalDataSource.getSuwarByLanguage(languageCode);
      if (cachedSuwar.isNotEmpty) {
        return cachedSuwar;
      }
      // If no cached data, rethrow the exception
      rethrow;
    }
  }

  Future<bool> _isCacheValid(String languageCode) async {
    final lastUpdateTimestamp = await _quranLocalDataSource.getLastUpdateTimestamp(languageCode);
    return lastUpdateTimestamp.fold(() => false, (time) {
      final currentTime = DateTime.now();
      final difference = currentTime.difference(time);
      return difference < _cacheValidityDuration;
    });
  }

  Future<void> _saveSuwarWithTimestamp(String languageCode, List<SurahModel> suwar) async {
    await _quranLocalDataSource.saveSuwarByLanguage(languageCode, suwar);
    await _quranLocalDataSource.saveLastUpdateTimestamp(languageCode, DateTime.now());
  }
}

final quranRepositoryProvider = FutureProvider<QuranImpl>((ref) async {
  final quranRemoteDataSource = ref.read(quranRemoteDataSourceProvider);
  final quranLocalDataSource = await ref.read(quranLocalDataSourceProvider.future);
  return QuranImpl(quranRemoteDataSource, quranLocalDataSource);
});
