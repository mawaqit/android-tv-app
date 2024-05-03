import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/model/quran/surah_model.dart';

import 'package:mawaqit/src/domain/error/quran_exceptions.dart';

class QuranLocalDataSource {
  final Box _surahBox;

  QuranLocalDataSource(this._surahBox);

  /// [saveSuwarByLanguage] save the list of surwars by language code
  Future<void> saveSuwarByLanguage(String languageCode, List<SurahModel> suwar) async {
    try {
      log('quran: saveSuwarByLanguage: ${suwar[0]} len ${suwar.length}');
      await _surahBox.put(languageCode, suwar);
    } catch (e) {
      log('quran: saveSuwarByLanguage: ${e.toString()}');
      throw SaveSuwarByLanguageException(e.toString());
    }
  }

  /// [getSuwarByLanguage] get the list of surwars by language code
  Future<List<SurahModel>> getSuwarByLanguage(String languageCode) async {
    try {
      final suwar = _surahBox.get(languageCode);
      log('quran: getSuwarByLanguage: ${suwar[0]}');
      if (suwar != null) {
        return List<SurahModel>.from(suwar);
      } else {
        return [];
      }
    } catch (e) {
      throw FetchSuwarByLanguageException(e.toString());
    }
  }

  Future<void> clearSuwarByLanguage(String languageCode) async {
    try {
      await _surahBox.delete(languageCode);
      log('quran: clearSuwarByLanguage: $languageCode');
    } catch (e) {
      throw ClearSuwarByLanguageException(e.toString());
    }
  }

  Future<void> clearAllSuwar() async {
    try {
      await _surahBox.clear();
    } catch (e) {
      throw ClearAllSuwarException(e.toString());
    }
  }

  /// [isSuwarByLanguageFound]

  bool isSuwarByLanguageFound(String languageCode) {
    try {
      if (_surahBox.keys.where((element) => element == languageCode).isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('quran: cannotFindSuwarByLanguageException: ${e.toString()}');
      throw CannotFindSuwarByLanguageException(e.toString());
    }
  }
}

final quranLocalDataSourceProvider = FutureProvider<QuranLocalDataSource>((ref) async {
  final surahBox = await Hive.openBox(QuranConstant.kSurahBox);
  return QuranLocalDataSource(surahBox);
});
