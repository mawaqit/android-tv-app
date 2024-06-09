import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/error/quran_exceptions.dart';
import 'package:mawaqit/src/domain/model/quran/quran_favorite_reciter_favorite_model.dart';

class QuranFavoriteLocalDataSource {
  /// first map is the quran (riwayat -> list of suwars)
  final Box<QuranReciterFavoriteModel> _quranReciterFavoriteBox;

  QuranFavoriteLocalDataSource(
    this._quranReciterFavoriteBox,
  );

  Future<void> saveFavoriteReciter(int reciterId) async {
    try {
      final reciterFavorite = QuranReciterFavoriteModel(reciterId: reciterId, favoriteSuwar: []);
      await _quranReciterFavoriteBox.put(reciterId, reciterFavorite);
    } catch (e) {
      throw SaveFavoriteReciterException(e.toString());
    }
  }

  Future<void> saveFavoriteSurahByReciter(int reciterId, int surahId, int riwayatId) async {
    try {
      if (_quranReciterFavoriteBox.containsKey(reciterId)) {
        log('quran: QuranFavoriteLocalDataSource: saveFavoriteSurahByReciter: ${_quranReciterFavoriteBox.get(reciterId)}');
        final reciterFavorite = _quranReciterFavoriteBox.get(reciterId);
        final quranNewFavorite = reciterFavorite!.addSurahFavorite(surahId, riwayatId);
        await _quranReciterFavoriteBox.put(reciterId, quranNewFavorite);
      } else {
        log('quran: QuranFavoriteLocalDataSource: saveFavoriteSurahByReciter: ${_quranReciterFavoriteBox.get(reciterId)}');
        final reciterFavorite = QuranReciterFavoriteModel(
          reciterId: reciterId,
          favoriteSuwar: [
            SurahFavoriteModel(surahIds: [surahId], riwayatId: riwayatId),
          ],
        );
        await _quranReciterFavoriteBox.put(reciterId, reciterFavorite);
      }
    } catch (e) {
      throw SaveFavoriteSurahByReciterException(e.toString());
    }
  }

  Future<List<int>> getFavoriteReciters() async {
    try {
      final reciters = _quranReciterFavoriteBox.keys.cast<int>().toList();
      return reciters;
    } catch (e) {
      throw FetchFavoriteRecitersException(e.toString());
    }
  }

  List<int> getFavoriteSuwarByReciter(int reciterId, int riwayatId) {
    try {
      if (_quranReciterFavoriteBox.containsKey(reciterId)) {
        final quranReciter = _quranReciterFavoriteBox.get(reciterId);
        log('quran: QuranFavoriteLocalDataSource: getFavoriteSuwarByReciter: $quranReciter');
        final searched = quranReciter!.getFavoriteSuwarByRiwayatId(riwayatId);
        return searched?.surahIds.toList() ?? <int>[];
      } else {
        return [];
      }
    } catch (e) {
      throw FetchFavoriteSurahsByReciterException(e.toString());
    }
  }

  Future<void> deleteFavoriteReciter({required int reciterId}) async {
    try {
      await _quranReciterFavoriteBox.delete(reciterId);
    } catch (e) {
      throw DeleteFavoriteReciterException(e.toString());
    }
  }

  Future<void> deleteFavoriteSuwar({
    required int reciterId,
    required int surahId,
    required int riwayatId,
  }) async {
    try {
      if (_quranReciterFavoriteBox.containsKey(reciterId)) {
        final riwayatObject = _quranReciterFavoriteBox.get(reciterId);
        final newFavoriteSuwar = riwayatObject!.favoriteSuwar.map((e) {
          if (e.riwayatId == riwayatId) {
            final newSurahIds = e.surahIds.toSet()..remove(surahId);
            return e.copyWith(surahIds: newSurahIds.toList());
          } else {
            return e;
          }
        }).toList();
        await _quranReciterFavoriteBox.put(reciterId, riwayatObject.copyWith(favoriteSuwar: newFavoriteSuwar));
      }
    } catch (e) {
      throw DeleteFavoriteSurahException(e.toString());
    }
  }
}

final quranFavoriteLocalDataSourceProvider = FutureProvider<QuranFavoriteLocalDataSource>((ref) async {
  final quranReciterFavoriteBox = await Hive.openBox<QuranReciterFavoriteModel>(QuranConstant.kQuranReciterFavoriteBox);
  return QuranFavoriteLocalDataSource(quranReciterFavoriteBox);
});
